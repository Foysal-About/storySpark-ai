class Env {
  const Env._();

  /// Pass with `--dart-define=GEMINI_API_KEY=...`
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Pass with `--dart-define=ANTHROPIC_API_KEY=...`
  static const anthropicApiKey = String.fromEnvironment('ANTHROPIC_API_KEY');

  /// Claude model used for story generation.
  /// Override with `--dart-define=CLAUDE_MODEL=...`.
  static const claudeModel = String.fromEnvironment(
    'CLAUDE_MODEL',
    defaultValue: 'claude-opus-4-8',
  );

  /// Story engine: `claude` (Claude Opus 4.8) or `gemini`.
  /// Pass with `--dart-define=STORY_ENGINE=claude|gemini`; when unset, Claude
  /// is used if an Anthropic key was provided, otherwise Gemini.
  static const _storyEngineOverride = String.fromEnvironment('STORY_ENGINE');

  static String get storyEngine {
    if (_storyEngineOverride.isNotEmpty) return _storyEngineOverride;
    return anthropicApiKey.isNotEmpty ? 'claude' : 'gemini';
  }

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

