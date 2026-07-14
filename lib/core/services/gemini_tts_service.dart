import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/env.dart';
import 'gemini_service.dart' show GeminiRateLimitException, GeminiServiceException;

/// Synthesizes speech with Gemini's TTS models.
///
/// The API returns raw 16-bit mono PCM at 24 kHz; [synthesize] wraps it in a
/// WAV header so it can be handed directly to an audio player.
class GeminiTtsService {
  GeminiTtsService({http.Client? client, String? apiKey, String? model, String? voice})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? Env.geminiApiKey,
        _model = model ?? Env.geminiTtsModel,
        _voice = voice ?? Env.geminiTtsVoice;

  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const _sampleRate = 24000;

  final http.Client _client;
  final String _apiKey;
  final String _model;
  final String _voice;

  Future<Uint8List> synthesize(String text) async {
    if (_apiKey.isEmpty) {
      throw GeminiServiceException(
        'Missing Gemini API key. Run with --dart-define=GEMINI_API_KEY=...',
      );
    }

    final http.Response response;
    try {
      response = await _client.post(
        Uri.parse('$_baseUrl/$_model:generateContent'),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': text},
              ],
            },
          ],
          'generationConfig': {
            'responseModalities': ['AUDIO'],
            'speechConfig': {
              'voiceConfig': {
                'prebuiltVoiceConfig': {'voiceName': _voice},
              },
            },
          },
        }),
      );
    } catch (e) {
      throw GeminiServiceException('Could not reach Gemini TTS: $e');
    }

    if (response.statusCode == 429) {
      throw GeminiRateLimitException(
        'Gemini TTS rate limit hit: ${response.body}',
        retryAfter: _parseRetryDelay(response.body),
      );
    }
    if (response.statusCode != 200) {
      throw GeminiServiceException(
        'Gemini TTS request failed (${response.statusCode}): ${response.body}',
      );
    }

    final pcm = _extractAudio(response.body);
    if (pcm == null || pcm.isEmpty) {
      throw GeminiServiceException('Gemini TTS returned no audio.');
    }

    return _pcmToWav(pcm, sampleRate: _sampleRate);
  }

  /// Pulls the RetryInfo delay (e.g. `"retryDelay": "12s"`) out of a 429 body.
  Duration? _parseRetryDelay(String body) {
    final match = RegExp(r'"retryDelay":\s*"(\d+(?:\.\d+)?)s"').firstMatch(body);
    final seconds = match == null ? null : double.tryParse(match.group(1)!);
    return seconds == null ? null : Duration(milliseconds: (seconds * 1000).ceil());
  }

  Uint8List? _extractAudio(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List?;
      final content = (candidates?.first as Map?)?['content'] as Map?;
      final parts = content?['parts'] as List?;
      for (final part in parts ?? const []) {
        final data = (part as Map?)?['inlineData'] as Map?;
        final base64Audio = data?['data'] as String?;
        if (base64Audio != null) return base64Decode(base64Audio);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Prepends a 44-byte WAV header for 16-bit mono PCM.
  Uint8List _pcmToWav(Uint8List pcm, {required int sampleRate}) {
    const channels = 1;
    const bitsPerSample = 16;
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final blockAlign = channels * bitsPerSample ~/ 8;

    final header = ByteData(44);
    void writeAscii(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        header.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    header.setUint32(4, 36 + pcm.length, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little); // PCM format
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    writeAscii(36, 'data');
    header.setUint32(40, pcm.length, Endian.little);

    final wav = Uint8List(44 + pcm.length);
    wav.setRange(0, 44, header.buffer.asUint8List());
    wav.setRange(44, wav.length, pcm);
    return wav;
  }

  void dispose() {
    _client.close();
  }
}