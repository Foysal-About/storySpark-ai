// Dev-only check: exercises the real Gemini integration end-to-end.
// Usage: GEMINI_API_KEY=... dart run tool/live_story_check.dart
import 'dart:io';

import 'package:storyspark_ai/core/services/gemini_service.dart';
import 'package:storyspark_ai/features/story/data/repositories/story_repository_impl.dart';
import 'package:storyspark_ai/features/story/domain/entities/story_request.dart';

Future<void> main() async {
  final apiKey = Platform.environment['GEMINI_API_KEY'] ?? '';
  final model = Platform.environment['GEMINI_MODEL'] ?? 'gemini-flash-latest';

  if (apiKey.isEmpty) {
    stderr.writeln('GEMINI_API_KEY is not set.');
    exit(1);
  }

  final repository = StoryRepositoryImpl(
    GeminiService(apiKey: apiKey, model: model),
  );

  final minutes = int.tryParse(Platform.environment['STORY_MINUTES'] ?? '') ?? 3;

  final request = StoryRequest(
    hero: 'Unicorn',
    heroName: 'Sparkle',
    location: 'The Moon',
    challenge: 'Find the lost key',
    mood: '😊',
    lengthMinutes: minutes,
  );

  print('Generating story with model=$model ...');
  final stopwatch = Stopwatch()..start();
  final story = await repository.generateStory(request);
  stopwatch.stop();

  print('--- done in ${stopwatch.elapsed.inSeconds}s ---');
  print('TITLE: ${story.title}');
  print('WORDS: ${story.content.split(RegExp(r'\s+')).length}');
  print('--- first 300 chars ---');
  print(story.content.substring(0, story.content.length.clamp(0, 300)));
}
