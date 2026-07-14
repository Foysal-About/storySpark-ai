import 'package:flutter/material.dart';

import '../domain/entities/saved_story.dart';

/// Maps story attributes (hero, mood, location) to the emoji, tags and
/// pastel colors used on cards across the app, so every page renders a
/// story the same way.
abstract final class StoryVisuals {
  static const _heroEmojis = {
    'Unicorn': '🦄',
    'Robot': '🤖',
    'Dragon': '🐲',
    'Fox': '🦊',
    'Whale': '🐋',
    'Owl': '🦉',
  };

  static const _locationEmojis = {
    'Castle': '🏰',
    'The Moon': '🌙',
    'Deep Sea': '🌊',
  };

  static const _moodTags = {
    '😊': 'Cheerful',
    '😴': 'Bedtime',
    '🤡': 'Funny',
  };

  static const _palette = [
    Color(0xFFE0DCFF), // lavender
    Color(0xFFFFE3D5), // peach
    Color(0xFFD5F2EA), // mint
    Color(0xFFFFDCEB), // pink
    Color(0xFFD9E8FF), // sky
    Color(0xFFFFF3C9), // butter
  ];

  static String heroEmoji(String hero) => _heroEmojis[hero] ?? '✨';

  static String locationEmoji(String location) =>
      _locationEmojis[location] ?? '🗺️';

  /// Short tag for a story card: mood if known, otherwise the location.
  static String tag(SavedStory story) =>
      _moodTags[story.mood] ?? (story.location.isNotEmpty ? story.location : 'Adventure');

  /// Stable pastel color per story, so a story keeps its color everywhere.
  static Color cardColor(SavedStory story) =>
      _palette[story.id.hashCode.abs() % _palette.length];

  /// Friendly relative date for library rows ("Today", "3 days ago"...).
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    if (diff < 30) return diff < 14 ? 'Last week' : '${diff ~/ 7} weeks ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}