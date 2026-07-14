import '../../../../core/services/gemini_service.dart';
import '../../domain/entities/generated_story.dart';
import '../../domain/entities/story_request.dart';
import '../../domain/repositories/story_repository.dart';

class StoryRepositoryImpl implements StoryRepository {
  const StoryRepositoryImpl(this._geminiService);

  final GeminiService _geminiService;

  static const _systemPrompt =
      "You are an expert children's story writer. Create original, engaging, age-appropriate stories.";

  @override
  Future<GeneratedStory> generateStory(StoryRequest request) async {
    final raw = await _geminiService.generateContent(
      systemPrompt: _systemPrompt,
      userPrompt: _buildUserPrompt(request),
    );

    return _parse(raw);
  }

  /// Average read-aloud pace for a children's story.
  static const _wordsPerMinute = 130;

  static const _moodDescriptions = {
    '😊': 'happy and cheerful — warm, upbeat, full of wonder',
    '😴': 'calm and sleepy — a gentle, soothing bedtime tone',
    '🤡': 'silly and funny — playful jokes, goofy moments, giggles',
  };

  String _buildUserPrompt(StoryRequest request) {
    final mood = _moodDescriptions[request.mood] ?? request.mood;
    final targetWords = request.lengthMinutes * _wordsPerMinute;
    final minWords = (targetWords * 0.9).round();
    final maxWords = (targetWords * 1.1).round();

    return '''
Create a children's story using these choices:
Hero: a ${request.hero} named ${request.heroName}
Location: ${request.location}
Challenge: ${request.challenge}
Mood: $mood
Read-aloud duration: ${request.lengthMinutes} minutes

Requirements — every choice above must clearly shape the story:
- ${request.heroName} the ${request.hero} is the main character; use the name throughout and let the hero's nature (being a ${request.hero}) matter to the plot.
- The whole story takes place in ${request.location}; describe it with vivid, child-friendly sensory details.
- "${request.challenge}" is the central problem that drives the plot from beginning to end, and ${request.heroName} resolves it at the climax.
- Keep the mood $mood consistently, in both events and word choice.
- LENGTH IS CRITICAL: aim for $targetWords words — never fewer than $minWords and never more than $maxWords — so the story takes ${request.lengthMinutes} minutes to read aloud. Plan the scenes to fit this budget exactly: neither cut the story short nor pad it past the limit.
- Include a beginning, adventure, climax, and happy ending.
- Use simple language suitable for children.
- Return only the title on the first line, then the story. No word counts, notes, or markdown.
''';
  }

  /// Expects the model's reply to start with a title line, followed by the
  /// story body (optionally prefixed with "Title:" or markdown emphasis).
  GeneratedStory _parse(String raw) {
    final lines = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    if (lines.isEmpty) {
      return GeneratedStory(title: 'Your Adventure', content: raw.trim());
    }

    final title = lines.first
        .replaceAll(RegExp(r'^(title:\s*|#+\s*)', caseSensitive: false), '')
        .replaceAll(RegExp(r'^\*+|\*+$'), '')
        .trim();

    final content = lines.skip(1).join('\n\n').trim();

    if (title.isEmpty || content.isEmpty) {
      return GeneratedStory(title: 'Your Adventure', content: raw.trim());
    }

    return GeneratedStory(title: title, content: content);
  }
}
