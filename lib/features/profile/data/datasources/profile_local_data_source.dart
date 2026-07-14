import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_profile.dart';

class ProfileLocalDataSource {
  const ProfileLocalDataSource(this._prefs);

  static const _nameKey = 'profile_name';
  static const _avatarKey = 'profile_avatar';

  final SharedPreferences _prefs;

  UserProfile getProfile() {
    return UserProfile(
      name: _prefs.getString(_nameKey) ?? '',
      avatarEmoji: _prefs.getString(_avatarKey) ??
          UserProfile.defaultProfile.avatarEmoji,
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_nameKey, profile.name);
    await _prefs.setString(_avatarKey, profile.avatarEmoji);
  }
}