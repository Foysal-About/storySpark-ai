import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';
import 'text_generation_service.dart';

/// Thrown when a request to the Claude API fails.
class ClaudeServiceException implements Exception {
  ClaudeServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thin wrapper around Anthropic's Messages API (`POST /v1/messages`),
/// used when the story engine is `claude` (Claude Opus 4.8).
class ClaudeService implements TextGenerationService {
  ClaudeService({http.Client? client, String? apiKey, String? model})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? Env.anthropicApiKey,
        _model = model ?? Env.claudeModel;

  static const _endpoint = 'https://api.anthropic.com/v1/messages';
  static const _apiVersion = '2023-06-01';

  final http.Client _client;
  final String _apiKey;
  final String _model;

  @override
  Future<String> generateContent({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    if (_apiKey.isEmpty) {
      throw ClaudeServiceException(
        'Missing Anthropic API key. Run with --dart-define=ANTHROPIC_API_KEY=...',
      );
    }

    final http.Response response;
    try {
      response = await _client.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': _apiVersion,
        },
        body: jsonEncode({
          'model': _model,
          // Stories top out around 2K words (~3K tokens); 16K leaves ample
          // headroom while staying safely under HTTP timeout territory.
          'max_tokens': 16000,
          // Claude decides when and how much to think — helps it plan the
          // word budget without a fixed thinking allowance.
          'thinking': {'type': 'adaptive'},
          'system': systemPrompt,
          'messages': [
            {'role': 'user', 'content': userPrompt},
          ],
        }),
      );
    } catch (e) {
      throw ClaudeServiceException('Could not reach Claude: $e');
    }

    if (response.statusCode == 429) {
      throw ClaudeServiceException(
        'Claude is a little busy right now. Please try again in a moment.',
      );
    }
    if (response.statusCode != 200) {
      throw ClaudeServiceException(
        'Claude request failed (${response.statusCode}): ${response.body}',
      );
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw ClaudeServiceException('Could not parse Claude response: $e');
    }

    final stopReason = decoded['stop_reason'];
    if (stopReason == 'refusal') {
      throw ClaudeServiceException(
        "Claude couldn't write this story. Try different choices.",
      );
    }

    final text = _extractText(decoded);
    if (text == null || text.trim().isEmpty) {
      throw ClaudeServiceException('Claude returned an empty response.');
    }

    if (stopReason == 'max_tokens') {
      throw ClaudeServiceException(
        'The story came back incomplete. Please try again.',
      );
    }

    return text.trim();
  }

  /// Joins the `text` content blocks; thinking blocks are skipped.
  String? _extractText(Map<String, dynamic> decoded) {
    final content = decoded['content'];
    if (content is! List || content.isEmpty) return null;

    final buffer = StringBuffer();
    for (final block in content) {
      if (block is Map<String, dynamic> &&
          block['type'] == 'text' &&
          block['text'] is String) {
        buffer.write(block['text'] as String);
      }
    }

    final text = buffer.toString();
    return text.isEmpty ? null : text;
  }
}
