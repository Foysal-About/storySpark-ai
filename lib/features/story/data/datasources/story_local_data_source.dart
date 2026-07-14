import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/saved_story.dart';

class StoryLocalDataSource {
  const StoryLocalDataSource(this._prefs);

  static const _savedStoriesKey = 'saved_stories';

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

  bool isSaved(String title) {
    return getSavedStories().any((s) => s.title == title);
  }

  String _toJson(SavedStory story) {
    return jsonEncode({
      'title': story.title,
      'content': story.content,
      'hero': story.hero,
      'location': story.location,
      'imageUrl': story.imageUrl,
      'savedAt': story.savedAt.toIso8601String(),
    });
  }

  SavedStory _fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return SavedStory(
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      hero: map['hero'] as String? ?? '',
      location: map['location'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      savedAt: DateTime.tryParse(map['savedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
