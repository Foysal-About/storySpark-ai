import 'package:flutter_tts/flutter_tts.dart';

/// Reads story text aloud using the platform's text-to-speech engine.
class TtsService {
  TtsService({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.1);
    _tts.awaitSpeakCompletion(true);
  }

  final FlutterTts _tts;

  /// Adjusts voice delivery; takes effect on the next [speak].
  Future<void> configure({required double rate, required double pitch}) async {
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);
  }

  /// Called when speech finishes on its own.
  void onComplete(void Function() callback) {
    _tts.setCompletionHandler(callback);
  }

  /// Reports the character range of the word currently being spoken,
  /// relative to the utterance passed to [speak].
  void onProgress(
    void Function(String text, int start, int end, String word) callback,
  ) {
    _tts.setProgressHandler(callback);
  }

  /// Completes when the utterance has finished (or was stopped).
  Future<void> speak(String text) => _tts.speak(text);

  Future<void> stop() => _tts.stop();

  void dispose() {
    _tts.stop();
  }
}