import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._prefs);

  static const _soundsKey = 'settings_sounds';
  static const _notificationsKey = 'settings_notifications';
  static const _voiceKey = 'settings_narration_voice';
  static const _appearanceKey = 'settings_appearance';
  static const _languageKey = 'settings_language';

  final SharedPreferences _prefs;

  AppSettings getSettings() {
    const defaults = AppSettings();
    return AppSettings(
      soundsEnabled: _prefs.getBool(_soundsKey) ?? defaults.soundsEnabled,
      notificationsEnabled:
          _prefs.getBool(_notificationsKey) ?? defaults.notificationsEnabled,
      narrationVoice: _prefs.getString(_voiceKey) ?? defaults.narrationVoice,
      appearance: _prefs.getString(_appearanceKey) ?? defaults.appearance,
      language: _prefs.getString(_languageKey) ?? defaults.language,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setBool(_soundsKey, settings.soundsEnabled);
    await _prefs.setBool(_notificationsKey, settings.notificationsEnabled);
    await _prefs.setString(_voiceKey, settings.narrationVoice);
    await _prefs.setString(_appearanceKey, settings.appearance);
    await _prefs.setString(_languageKey, settings.language);
  }
}
