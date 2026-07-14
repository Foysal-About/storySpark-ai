// Dev-only check: exercises the real story-generation integration end-to-end.
// Usage:
//   GEMINI_API_KEY=...    dart run tool/live_story_check.dart
//   ANTHROPIC_API_KEY=... dart run tool/live_story_check.dart   (Claude Opus 4.8)
import 'dart:io';

import 'package:storyspark_ai/core/services/claude_service.dart';
import 'package:storyspark_ai/core/services/gemini_service.dart';
import 'package:storyspark_ai/core/services/text_generation_service.dart';
import 'package:storyspark_ai/features/story/data/repositories/story_repository_impl.dart';
import 'package:storyspark_ai/features/story/domain/entities/story_request.dart';

Future<void> main() async {
  final anthropicKey = Platform.environment['ANTHROPIC_API_KEY'] ?? '';
  final geminiKey = Platform.environment['GEMINI_API_KEY'] ?? '';

  final TextGenerationService service;
  final String engineLabel;
  if (anthropicKey.isNotEmpty) {
    final model =
        Platform.environment['CLAUDE_MODEL'] ?? 'claude-opus-4-8';
    service = ClaudeService(apiKey: anthropicKey, model: model);
    engineLabel = 'claude ($model)';
  } else if (geminiKey.isNotEmpty) {
    final model =
        Platform.environment['GEMINI_MODEL'] ?? 'gemini-flash-latest';
    service = GeminiService(apiKey: geminiKey, model: model);
    engineLabel = 'gemini ($model)';
  } else {
    stderr.writeln('Set ANTHROPIC_API_KEY or GEMINI_API_KEY.');
    exit(1);
  }

  final repository = StoryRepositoryImpl(service);

  final minutes = int.tryParse(Platform.environment['STORY_MINUTES'] ?? '') ?? 3;

  final request = StoryRequest(
    hero: 'Unicorn',
    heroName: 'Sparkle',
    location: 'The Moon',
    challenge: 'Find the lost key',
    mood: '😊',
    lengthMinutes: minutes,
  );

  print('Generating story with engine=$engineLabel ...');
  final stopwatch = Stopwatch()..start();
  final story = await repository.generateStory(request);
  stopwatch.stop();

  print('--- done in ${stopwatch.elapsed.inSeconds}s ---');
  print('TITLE: ${story.title}');
  print('WORDS: ${story.content.split(RegExp(r'\s+')).length}');
  print('--- first 300 chars ---');
  print(story.content.substring(0, story.content.length.clamp(0, 300)));
}
