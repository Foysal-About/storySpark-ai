import 'package:shared_preferences/shared_preferences.dart';

/// Reads/writes the "has the user finished onboarding" flag on-device.
class OnboardingLocalDataSource {
  const OnboardingLocalDataSource(this._prefs);

  static const _completedKey = 'onboarding_completed';

  final SharedPreferences _prefs;

  bool isCompleted() => _prefs.getBool(_completedKey) ?? false;

  Future<void> markCompleted() => _prefs.setBool(_completedKey, true);
}