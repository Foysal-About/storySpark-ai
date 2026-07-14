import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;

import '../../../../core/config/env.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/gemini_tts_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart'
    show sharedPreferencesProvider;
import '../../data/datasources/story_local_data_source.dart';
import '../../data/repositories/story_repository_impl.dart';
import '../../domain/entities/generated_story.dart';
import '../../domain/entities/saved_story.dart';
import '../../domain/entities/story_request.dart';
import '../../domain/repositories/story_repository.dart';
import '../narration/narration_controller.dart';
import '../narration/narration_engine.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

final storyLocalDataSourceProvider = Provider(
  (ref) => StoryLocalDataSource(ref.watch(sharedPreferencesProvider)),
);

final savedStoriesProvider = Provider<List<SavedStory>>(
  (ref) => ref.watch(storyLocalDataSourceProvider).getSavedStories(),
);

final ttsServiceProvider = Provider<TtsService>((ref) {
  final tts = TtsService();
  ref.onDispose(tts.dispose);
  return tts;
});

/// Drives read-aloud narration and text highlighting on the result page.
/// The engine comes from `--dart-define=NARRATION_ENGINE=local|gemini`; the
/// cloud engine gets the on-device voice as a mid-story fallback so quota
/// errors never leave a child with a story that stops talking.
final narrationControllerProvider =
    ChangeNotifierProvider.autoDispose<NarrationController>((ref) {
  if (Env.narrationEngine == 'gemini') {
    return NarrationController(
      GeminiTtsNarrationEngine(GeminiTtsService()),
      fallbackEngine: LocalTtsNarrationEngine(TtsService()),
    );
  }
  return NarrationController(LocalTtsNarrationEngine(TtsService()));
});

final storyRepositoryProvider = Provider<StoryRepository>(
  (ref) => StoryRepositoryImpl(ref.watch(geminiServiceProvider)),
);

/// Holds the async state of the story currently being generated.
final storyGenerationProvider =
    AsyncNotifierProvider.autoDispose<StoryGenerationController, GeneratedStory?>(
  StoryGenerationController.new,
);

class StoryGenerationController extends AsyncNotifier<GeneratedStory?> {
  @override
  FutureOr<GeneratedStory?> build() => null;

  Future<void> generate(StoryRequest request) async {
    state = const AsyncValue.loading();
    final repository = ref.read(storyRepositoryProvider);
    state = await AsyncValue.guard(() => repository.generateStory(request));
  }
}
