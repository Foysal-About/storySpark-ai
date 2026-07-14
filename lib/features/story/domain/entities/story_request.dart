class StoryRequest {
  const StoryRequest({
    required this.hero,
    required this.heroName,
    required this.location,
    required this.challenge,
    required this.mood,
    required this.lengthMinutes,
  });

  final String hero;
  final String heroName;
  final String location;
  final String challenge;
  final String mood;
  final int lengthMinutes;
}
