import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart' show TextRange;

import '../../../../core/services/gemini_service.dart'
    show GeminiRateLimitException;
import '../../../../core/services/gemini_tts_service.dart';
import '../../../../core/services/tts_service.dart';

/// Emits the range of [content] currently being narrated (null = no highlight).
typedef HighlightCallback = void Function(TextRange? range);

/// How the narrator should sound, derived from the story's mood choice.
///
/// [instruction] steers the Gemini TTS voice (it follows natural-language
/// style directions); [rate] and [pitch] approximate the same feel on the
/// on-device engine, which has no expressive control.
class NarrationStyle {
  const NarrationStyle({
    required this.instruction,
    required this.rate,
    required this.pitch,
  });

  final String instruction;
  final double rate;
  final double pitch;

  static NarrationStyle fromMood(String? mood) {
    switch (mood) {
      case '😴':
        return const NarrationStyle(
          instruction:
              'in a soft, slow, soothing bedtime voice — calm and gentle, '
              'with long relaxed pauses, winding down towards sleep',
          rate: 0.38,
          pitch: 1.0,
        );
      case '🤡':
        return const NarrationStyle(
          instruction:
              'in a playful, giggly voice bursting with silly energy — '
              'exaggerate the funny moments and give characters goofy voices',
          rate: 0.5,
          pitch: 1.25,
        );
      default:
        return const NarrationStyle(
          instruction:
              'in a warm, cheerful storyteller voice full of wonder — '
              'lively and expressive, like reading to a curious child',
          rate: 0.45,
          pitch: 1.1,
        );
    }
  }
}

/// A strategy for reading a story aloud while reporting highlight progress.
abstract class NarrationEngine {
  /// Reads [title] then [content] aloud. Resolves when narration finishes or
  /// is stopped. [onHighlight] receives ranges relative to [content].
  Future<void> start({
    required String title,
    required String content,
    required NarrationStyle style,
    required HighlightCallback onHighlight,
  });

  Future<void> stop();

  void dispose();
}

/// Approach A — on-device TTS via flutter_tts.
///
/// Uses the engine's progress handler to highlight the exact word being
/// spoken. The title is folded into the utterance and its offsets are
/// subtracted so highlight ranges always map onto the visible story text.
class LocalTtsNarrationEngine implements NarrationEngine {
  LocalTtsNarrationEngine(this._tts);

  final TtsService _tts;

  @override
  Future<void> start({
    required String title,
    required String content,
    required NarrationStyle style,
    required HighlightCallback onHighlight,
  }) async {
    await _tts.configure(rate: style.rate, pitch: style.pitch);
    final prefix = title.isEmpty ? '' : '$title.\n\n';
    final utterance = '$prefix$content';

    _tts.onProgress((text, start, end, word) {
      final s = start - prefix.length;
      final e = end - prefix.length;
      if (s >= 0 && e > s && e <= content.length) {
        onHighlight(TextRange(start: s, end: e));
      } else {
        onHighlight(null);
      }
    });

    try {
      await _tts.speak(utterance);
    } finally {
      onHighlight(null);
    }
  }

  @override
  Future<void> stop() => _tts.stop();

  @override
  void dispose() {
    _tts.dispose();
  }
}

/// Approach B — Gemini cloud TTS.
///
/// Cloud audio has no word-level timing metadata, so the story is chunked
/// sentence-by-sentence: each chunk is synthesized, its whole range is
/// highlighted while its audio plays, and the next chunk is prefetched in
/// parallel so playback flows without gaps.
class GeminiTtsNarrationEngine implements NarrationEngine {
  GeminiTtsNarrationEngine(this._tts, {AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final GeminiTtsService _tts;
  final AudioPlayer _player;
  bool _stopped = false;

  /// Gemini TTS follows spoken-style directions given as a system instruction.
  String _styleInstruction(NarrationStyle style) =>
      "You are a world-class children's storyteller. Read the provided story excerpt "
      "${style.instruction}. Focus on emotion, pacing, and character voices. "
      "Output ONLY the audio for the story text itself.";

  @override
  Future<void> start({
    required String title,
    required String content,
    required NarrationStyle style,
    required HighlightCallback onHighlight,
  }) async {
    _stopped = false;
    final chunks = _chunkBySentence(content);
    if (chunks.isEmpty) return;

    final systemInstruction = _styleInstruction(style);

    try {
      // Title first, with no highlight (it lives outside the story body).
      Future<Uint8List> next = title.isEmpty
          ? _synthesizeWithRetry(
              content.substring(chunks[0].start, chunks[0].end),
              systemInstruction: systemInstruction,
            )
          : _synthesizeWithRetry(title, systemInstruction: systemInstruction);
      var start = title.isEmpty ? 0 : -1;

      for (var i = start; i < chunks.length; i++) {
        final bytes = await next;
        if (_stopped) return;

        // Prefetch the following chunk while this one plays.
        if (i + 1 < chunks.length) {
          final upcoming = chunks[i + 1];
          next = _synthesizeWithRetry(
            content.substring(upcoming.start, upcoming.end),
            systemInstruction: systemInstruction,
          );
        }

        onHighlight(i >= 0 ? chunks[i] : null);
        await _play(bytes);
        if (_stopped) return;
      }
    } finally {
      onHighlight(null);
    }
  }

  /// The TTS preview models have tight per-minute quotas (~3 RPM on the free
  /// tier), so 429s are expected mid-story: honor the API's suggested delay
  /// and retry before giving up.
  Future<Uint8List> _synthesizeWithRetry(
    String text, {
    required String systemInstruction,
  }) async {
    for (var attempt = 0; ; attempt++) {
      try {
        return await _tts.synthesize(text, systemInstruction: systemInstruction);
      } on GeminiRateLimitException catch (e) {
        final wait = e.retryAfter ?? const Duration(seconds: 20);
        if (attempt >= 2 || wait > const Duration(seconds: 60)) rethrow;
        final deadline = wait + const Duration(seconds: 1);
        for (var waited = Duration.zero;
            waited < deadline;
            waited += const Duration(milliseconds: 200)) {
          if (_stopped) rethrow;
          await Future<void>.delayed(const Duration(milliseconds: 200));
        }
      }
    }
  }

  Future<void> _play(Uint8List wavBytes) async {
    final done = _player.onPlayerComplete.first;
    await _player.play(BytesSource(wavBytes));
    await Future.any([done, _stoppedFuture()]);
  }

  Future<void> _stoppedFuture() async {
    while (!_stopped) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Splits [content] into sentence ranges (offsets into [content]).
  /// Consecutive short sentences are merged so chunks stay TTS-friendly.
  static List<TextRange> _chunkBySentence(String content) {
    final ranges = <TextRange>[];
    final sentenceEnd = RegExp(r'[.!?…]+[\s]+|\n+');

    var start = 0;
    for (final match in sentenceEnd.allMatches(content)) {
      final end = match.end;
      if (content.substring(start, end).trim().isNotEmpty) {
        ranges.add(TextRange(start: start, end: end));
      }
      start = end;
    }
    if (start < content.length && content.substring(start).trim().isNotEmpty) {
      ranges.add(TextRange(start: start, end: content.length));
    }

    // Merge sentences into larger blocks: every chunk is one API request, and
    // the per-minute quota is tiny, so fewer/longer chunks keep narration
    // within limits (~300 chars ≈ 25s of audio ≈ 2 requests/minute).
    const targetChunkChars = 300;
    final merged = <TextRange>[];
    for (final range in ranges) {
      final lastLength =
          merged.isEmpty ? 0 : merged.last.end - merged.last.start;
      if (merged.isNotEmpty &&
          lastLength + (range.end - range.start) <= targetChunkChars) {
        merged[merged.length - 1] =
            TextRange(start: merged.last.start, end: range.end);
      } else {
        merged.add(range);
      }
    }
    return merged;
  }

  @override
  Future<void> stop() async {
    _stopped = true;
    await _player.stop();
  }

  @override
  void dispose() {
    _stopped = true;
    _player.dispose();
    _tts.dispose();
  }
}