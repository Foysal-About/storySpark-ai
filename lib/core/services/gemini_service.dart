import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';
import 'text_generation_service.dart';

/// Thrown when a request to the Gemini API fails.
class GeminiServiceException implements Exception {
  GeminiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown on HTTP 429; [retryAfter] carries the API's suggested wait, if any.
class GeminiRateLimitException extends GeminiServiceException {
  GeminiRateLimitException(super.message, {this.retryAfter});

  final Duration? retryAfter;
}

/// Thin wrapper around Google's Gemini generateContent endpoint.
class GeminiService implements TextGenerationService {
  GeminiService({http.Client? client, String? apiKey, String? model})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? Env.geminiApiKey,
        _model = model ?? Env.geminiModel;

  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  final http.Client _client;
  final String _apiKey;
  final String _model;

  @override
  Future<String> generateContent({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    if (_apiKey.isEmpty) {
      throw GeminiServiceException(
        'Missing Gemini API key. Run with --dart-define=GEMINI_API_KEY=...',
      );
    }

    // The API occasionally returns a candidate with no text (e.g. when
    // thinking exhausts the output budget); one retry recovers those.
    try {
      return await _generateOnce(systemPrompt: systemPrompt, userPrompt: userPrompt);
    } on GeminiServiceException {
      return _generateOnce(systemPrompt: systemPrompt, userPrompt: userPrompt);
    }
  }

  Future<String> _generateOnce({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final http.Response response;
    try {
      response = await _client.post(
        Uri.parse('$_baseUrl/$_model:generateContent'),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          // Generous output budget so long stories are never truncated, with
          // bounded thinking so word-count planning stays fast and reliable.
          'generationConfig': {
            'maxOutputTokens': 32768,
            'thinkingConfig': {'thinkingBudget': 8192},
          },
          'system_instruction': {
            'parts': [
              {'text': systemPrompt},
            ],
          },
          'contents': [
            {
              'parts': [
                {'text': userPrompt},
              ],
            },
          ],
        }),
      );
    } catch (e) {
      throw GeminiServiceException('Could not reach Gemini: $e');
    }

    if (response.statusCode != 200) {
      throw GeminiServiceException(
        'Gemini request failed (${response.statusCode}): ${response.body}',
      );
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw GeminiServiceException('Could not parse Gemini response: $e');
    }

    final content = _extractText(decoded);

    if (content == null || content.trim().isEmpty) {
      throw GeminiServiceException('Gemini returned an empty response.');
    }

    return content.trim();
  }

  String? _extractText(Map<String, dynamic> decoded) {
    final candidates = decoded['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;

    final first = candidates.first;
    if (first is! Map<String, dynamic>) return null;

    final content = first['content'];
    if (content is! Map<String, dynamic>) return null;

    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) return null;

    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map<String, dynamic> && part['text'] is String) {
        buffer.write(part['text'] as String);
      }
    }

    final text = buffer.toString();
    return text.isEmpty ? null : text;
  }
}
