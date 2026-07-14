class GeneratedStory {
  const GeneratedStory({
    required this.title,
    required this.content,
    this.imageUrl,
  });

  final String title;
  final String content;
  final String? imageUrl;

  GeneratedStory copyWith({String? imageUrl}) {
    return GeneratedStory(
      title: title,
      content: content,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
