class SavedStory {
  const SavedStory({
    required this.title,
    required this.content,
    required this.hero,
    required this.location,
    required this.savedAt,
    this.imageUrl,
  });

  final String title;
  final String content;
  final String hero;
  final String location;
  final DateTime savedAt;
  final String? imageUrl;
}
