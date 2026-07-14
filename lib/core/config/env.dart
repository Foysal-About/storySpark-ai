class Env {
  const Env._();

  /// Pass with `--dart-define=GEMINI_API_KEY=...`
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Pass with `--dart-define=GEMINI_MODEL=gemini-flash-latest` to override.
  static const geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-flash-latest',
  );

  /// Narration engine: `local` (on-device flutter_tts, word-level highlight)
  /// or `gemini` (Gemini cloud TTS, sentence-level highlight).
  static const narrationEngine = String.fromEnvironment(
    'NARRATION_ENGINE',
    defaultValue: 'local',
  );

  /// Model used when [narrationEngine] is `gemini`.
  static const geminiTtsModel = String.fromEnvironment(
    'GEMINI_TTS_MODEL',
    defaultValue: 'gemini-2.5-flash-preview-tts',
  );

  /// Prebuilt Gemini TTS voice (e.g. Sulafat, Gacrux).
  static const geminiTtsVoice = String.fromEnvironment(
    'GEMINI_TTS_VOICE',
    defaultValue: 'Sulafat',
  );
}

