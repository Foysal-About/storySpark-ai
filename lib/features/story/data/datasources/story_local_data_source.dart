import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/saved_story.dart';

class StoryLocalDataSource {
  const StoryLocalDataSource(this._prefs);

  static const _savedStoriesKey = 'saved_stories';
  static const _readingProgressKey = 'reading_progress';
  static const _lastReadStoryKey = 'last_read_story';
  static const _storiesCreatedKey = 'stories_created_count';

  final SharedPreferences _prefs;

  List<SavedStory> getSavedStories() {
    final entries = _prefs.getStringList(_savedStoriesKey) ?? const [];
    return entries.map(_fromJson).toList();
  }

  Future<void> saveStory(SavedStory story) async {
    final entries = _prefs.getStringList(_savedStoriesKey) ?? [];
    entries.add(_toJson(story));
    await _prefs.setStringList(_savedStoriesKey, entries);
  }

  Future<void> deleteStory(String id) async {
    final stories = getSavedStories().where((s) => s.id != id);
    await _prefs.setStringList(
      _savedStoriesKey,
      stories.map(_toJson).toList(),
    );
    await clearReadingProgress(id);
  }

  Future<void> setFavorite(String id, bool isFavorite) async {
    final stories = getSavedStories()
        .map((s) => s.id == id ? s.copyWith(isFavorite: isFavorite) : s);
    await _prefs.setStringList(
      _savedStoriesKey,
      stories.map(_toJson).toList(),
    );
  }

  bool isSaved(String title) {
    return getSavedStories().any((s) => s.title == title);
  }

  // --- Reading progress (0.0 – 1.0 per story id) ---

  Map<String, double> getReadingProgress() {
    final raw = _prefs.getString(_readingProgressKey);
    if (raw == null) return const {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      return const {};
    }
  }

  Future<void> setReadingProgress(String id, double progress) async {
    final map = Map<String, double>.from(getReadingProgress());
    map[id] = progress.clamp(0.0, 1.0);
    await _prefs.setString(_readingProgressKey, jsonEncode(map));
    await _prefs.setString(_lastReadStoryKey, id);
  }

  Future<void> clearReadingProgress(String id) async {
    final map = Map<String, double>.from(getReadingProgress())..remove(id);
    await _prefs.setString(_readingProgressKey, jsonEncode(map));
    if (_prefs.getString(_lastReadStoryKey) == id) {
      await _prefs.remove(_lastReadStoryKey);
    }
  }

  String? getLastReadStoryId() => _prefs.getString(_lastReadStoryKey);

  // --- Lifetime counter of generated stories (saved or not) ---

  int getStoriesCreatedCount() => _prefs.getInt(_storiesCreatedKey) ?? 0;

  Future<void> incrementStoriesCreated() async {
    await _prefs.setInt(_storiesCreatedKey, getStoriesCreatedCount() + 1);
  }

  /// Removes every saved story and all reading progress (grown-ups area).
  Future<void> clearAllStories() async {
    await _prefs.remove(_savedStoriesKey);
    await _prefs.remove(_readingProgressKey);
    await _prefs.remove(_lastReadStoryKey);
  }

  String _toJson(SavedStory story) {
    return jsonEncode({
      'id': story.id,
      'title': story.title,
      'content': story.content,
      'hero': story.hero,
      'location': story.location,
      'mood': story.mood,
      'lengthMinutes': story.lengthMinutes,
      'isFavorite': story.isFavorite,
      'imageUrl': story.imageUrl,
      'savedAt': story.savedAt.toIso8601String(),
    });
  }

  SavedStory _fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    final savedAt =
        DateTime.tryParse(map['savedAt'] as String? ?? '') ?? DateTime.now();
    return SavedStory(
      // Legacy entries (pre-id) get a stable id derived from their timestamp.
      id: map['id'] as String? ?? 'story_${savedAt.microsecondsSinceEpoch}',
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      hero: map['hero'] as String? ?? '',
      location: map['location'] as String? ?? '',
      mood: map['mood'] as String? ?? '',
      lengthMinutes: (map['lengthMinutes'] as num?)?.toInt() ?? 0,
      isFavorite: map['isFavorite'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
      savedAt: savedAt,
    );
  }
}