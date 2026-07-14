class UserProfile {
  const UserProfile({
    required this.name,
    required this.avatarEmoji,
  });

  static const defaultProfile =
      UserProfile(name: '', avatarEmoji: '🦄');

  final String name;
  final String avatarEmoji;

  /// Name to show in greetings when none has been set yet.
  String get displayName => name.isEmpty ? 'Storyteller' : name;

  bool get isSet => name.isNotEmpty;

  UserProfile copyWith({String? name, String? avatarEmoji}) {
    return UserProfile(
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
    );
  }
}