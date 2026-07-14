import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;

import '../../../../core/config/env.dart';
import '../../../../core/services/claude_service.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/gemini_tts_service.dart';
import '../../../../core/services/text_generation_service.dart';
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

final claudeServiceProvider = Provider<ClaudeService>((ref) => ClaudeService());

/// The LLM that writes stories: Claude Opus 4.8 when an Anthropic key is
/// configured (or `--dart-define=STORY_ENGINE=claude`), otherwise Gemini.
final storyEngineProvider = Provider<TextGenerationService>((ref) {
  if (Env.storyEngine == 'claude') {
    return ref.watch(claudeServiceProvider);
  }
  return ref.watch(geminiServiceProvider);
});

final storyLocalDataSourceProvider = Provider(
  (ref) => StoryLocalDataSource(ref.watch(sharedPreferencesProvider)),
);

/// The saved-story library. All mutations go through this notifier so every
/// page watching it (home, library, favorites, reader) updates together.
final storyLibraryProvider =
    NotifierProvider<StoryLibraryController, List<SavedStory>>(
  StoryLibraryController.new,
);

class StoryLibraryController extends Notifier<List<SavedStory>> {
  StoryLocalDataSource get _dataSource =>
      ref.read(storyLocalDataSourceProvider);

  @override
  List<SavedStory> build() =>
      ref.watch(storyLocalDataSourceProvider).getSavedStories();

  Future<void> save(SavedStory story) async {
    if (state.any((s) => s.id == story.id)) return;
    await _dataSource.saveStory(story);
    state = _dataSource.getSavedStories();
  }

  Future<void> delete(String id) async {
    await _dataSource.deleteStory(id);
    ref.invalidate(readingProgressProvider);
    state = _dataSource.getSavedStories();
  }

  Future<void> toggleFavorite(String id) async {
    final story = state.where((s) => s.id == id).firstOrNull;
    if (story == null) return;
    await _dataSource.setFavorite(id, !story.isFavorite);
    state = _dataSource.getSavedStories();
  }

  Future<void> clearAll() async {
    await _dataSource.clearAllStories();
    ref.invalidate(readingProgressProvider);
    state = const [];
  }
}

final favoriteStoriesProvider = Provider<List<SavedStory>>(
  (ref) =>
      ref.watch(storyLibraryProvider).where((s) => s.isFavorite).toList(),
);

/// Reading progress per story id (0.0 – 1.0), updated as the reader scrolls.
final readingProgressProvider =
    NotifierProvider<ReadingProgressController, Map<String, double>>(
  ReadingProgressController.new,
);

class ReadingProgressController extends Notifier<Map<String, double>> {
  StoryLocalDataSource get _dataSource =>
      ref.read(storyLocalDataSourceProvider);

  @override
  Map<String, double> build() =>
      ref.watch(storyLocalDataSourceProvider).getReadingProgress();

  Future<void> setProgress(String id, double progress) async {
    // Progress only moves forward; re-opening a story never loses the place.
    final current = state[id] ?? 0;
    final next = progress.clamp(0.0, 1.0);
    if (next <= current && state.containsKey(id)) {
      await _dataSource.setReadingProgress(id, current);
      return;
    }
    await _dataSource.setReadingProgress(id, next);
    state = {...state, id: next};
  }
}

/// The most recently opened saved story that isn't finished yet — powers the
/// home "Continue reading" card. Null when there is nothing to continue.
final continueReadingProvider = Provider<({SavedStory story, double progress})?>(
  (ref) {
    final library = ref.watch(storyLibraryProvider);
    final progress = ref.watch(readingProgressProvider);
    final lastReadId =
        ref.watch(storyLocalDataSourceProvider).getLastReadStoryId();

    if (lastReadId != null) {
      final story = library.where((s) => s.id == lastReadId).firstOrNull;
      final p = progress[lastReadId] ?? 0;
      if (story != null && p < 0.95) return (story: story, progress: p);
    }

    // Fall back to any unfinished story, most recently saved first.
    final unfinished = library.where((s) => (progress[s.id] ?? 0) < 0.95).toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    if (unfinished.isEmpty) return null;
    final story = unfinished.first;
    return (story: story, progress: progress[story.id] ?? 0);
  },
);

/// Lifetime count of generated stories (whether or not they were saved).
final storiesCreatedProvider =
    NotifierProvider<StoriesCreatedController, int>(
  StoriesCreatedController.new,
);

class StoriesCreatedController extends Notifier<int> {
  @override
  int build() =>
      ref.watch(storyLocalDataSourceProvider).getStoriesCreatedCount();

  Future<void> increment() async {
    await ref.read(storyLocalDataSourceProvider).incrementStoriesCreated();
    state = state + 1;
  }
}

/// Aggregate numbers shown on the profile and achievements pages.
class StoryStats {
  const StoryStats({
    required this.storiesCreated,
    required this.savedCount,
    required this.favoritesCount,
    required this.storyMinutes,
    required this.finishedCount,
    required this.bedtimeCount,
    required this.heroesUsed,
    required this.locationsVisited,
  });

  final int storiesCreated;
  final int savedCount;
  final int favoritesCount;
  final int storyMinutes;
  final int finishedCount;
  final int bedtimeCount;
  final Set<String> heroesUsed;
  final Set<String> locationsVisited;

  static const starsPerLevel = 100;

  /// Stars reward creating, finishing and loving stories.
  int get stars =>
      storiesCreated * 20 + finishedCount * 10 + favoritesCount * 5;

  int get level => 1 + stars ~/ starsPerLevel;

  int get starsIntoLevel => stars % starsPerLevel;
}

final storyStatsProvider = Provider<StoryStats>((ref) {
  final library = ref.watch(storyLibraryProvider);
  final progress = ref.watch(readingProgressProvider);
  final created = ref.watch(storiesCreatedProvider);

  return StoryStats(
    storiesCreated: created,
    savedCount: library.length,
    favoritesCount: library.where((s) => s.isFavorite).length,
    storyMinutes: library.fold(0, (sum, s) => sum + s.readMinutes),
    finishedCount:
        library.where((s) => (progress[s.id] ?? 0) >= 0.95).length,
    bedtimeCount: library.where((s) => s.mood == '😴').length,
    heroesUsed: library.map((s) => s.hero).where((h) => h.isNotEmpty).toSet(),
    locationsVisited:
        library.map((s) => s.location).where((l) => l.isNotEmpty).toSet(),
  );
});

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
  (ref) => StoryRepositoryImpl(ref.watch(storyEngineProvider)),
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
    if (state.hasValue && state.value != null) {
      await ref.read(storiesCreatedProvider.notifier).increment();
    }
  }
}