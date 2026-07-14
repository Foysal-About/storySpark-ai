class SavedStory {
  const SavedStory({
    required this.id,
    required this.title,
    required this.content,
    required this.hero,
    required this.location,
    required this.savedAt,
    this.mood = '',
    this.lengthMinutes = 0,
    this.isFavorite = false,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String content;
  final String hero;
  final String location;
  final DateTime savedAt;

  /// Mood emoji chosen when the story was created ('😊', '😴', '🤡').
  final String mood;

  /// Requested read-aloud length; 0 when unknown (legacy entries).
  final int lengthMinutes;
  final bool isFavorite;
  final String? imageUrl;

  /// Average read-aloud pace, used to estimate minutes for legacy stories
  /// saved before a length was stored.
  static const _wordsPerMinute = 130;

  /// Read-aloud minutes: the requested length, or an estimate from the text.
  int get readMinutes {
    if (lengthMinutes > 0) return lengthMinutes;
    final words = content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return (words / _wordsPerMinute).ceil().clamp(1, 60);
  }

  SavedStory copyWith({bool? isFavorite}) {
    return SavedStory(
      id: id,
      title: title,
      content: content,
      hero: hero,
      location: location,
      savedAt: savedAt,
      mood: mood,
      lengthMinutes: lengthMinutes,
      isFavorite: isFavorite ?? this.isFavorite,
      imageUrl: imageUrl,
    );
  }
}