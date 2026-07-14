class AppSettings {
  const AppSettings({
    this.soundsEnabled = true,
    this.notificationsEnabled = false,
    this.narrationVoice = 'Fairy Fern',
    this.appearance = 'Aurora',
    this.language = 'English',
  });

  final bool soundsEnabled;
  final bool notificationsEnabled;
  final String narrationVoice;
  final String appearance;
  final String language;

  /// Kid-friendly names for the narration voice picker.
  static const narrationVoices = [
    'Fairy Fern',
    'Captain Comet',
    'Grandma Willow',
    'Robo Beep',
  ];

  static const appearances = ['Aurora', 'Sunset', 'Ocean'];

  AppSettings copyWith({
    bool? soundsEnabled,
    bool? notificationsEnabled,
    String? narrationVoice,
    String? appearance,
    String? language,
  }) {
    return AppSettings(
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      narrationVoice: narrationVoice ?? this.narrationVoice,
      appearance: appearance ?? this.appearance,
      language: language ?? this.language,
    );
  }
}