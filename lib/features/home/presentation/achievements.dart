import 'package:flutter/material.dart';

import '../../story/presentation/providers/story_providers.dart';

/// A badge on the achievements page, unlocked by real activity in the app.
class Achievement {
  const Achievement({
    required this.emoji,
    required this.title,
    required this.unlockedSubtitle,
    required this.lockedHint,
    required this.bgColor,
    required this.isUnlocked,
  });

  final String emoji;
  final String title;
  final String unlockedSubtitle;

  /// Shown while locked, telling the child how to earn it.
  final String lockedHint;
  final Color bgColor;
  final bool Function(StoryStats stats) isUnlocked;
}

final appAchievements = <Achievement>[
  Achievement(
    emoji: '⭐',
    title: 'First Story',
    unlockedSubtitle: 'Created your first tale',
    lockedHint: 'Create your first story',
    bgColor: const Color(0xFFFFEDD5),
    isUnlocked: (s) => s.storiesCreated >= 1,
  ),
  Achievement(
    emoji: '✍️',
    title: 'Tale Weaver',
    unlockedSubtitle: 'Created 5 stories',
    lockedHint: 'Create 5 stories',
    bgColor: const Color(0xFFE2D9FF),
    isUnlocked: (s) => s.storiesCreated >= 5,
  ),
  Achievement(
    emoji: '🦉',
    title: 'Night Owl',
    unlockedSubtitle: 'Saved 3 bedtime stories',
    lockedHint: 'Save 3 sleepy 😴 stories',
    bgColor: const Color(0xFFE0E7FF),
    isUnlocked: (s) => s.bedtimeCount >= 3,
  ),
  Achievement(
    emoji: '🐠',
    title: 'Explorer',
    unlockedSubtitle: 'Visited every world',
    lockedHint: 'Save stories in 3 places',
    bgColor: const Color(0xFFDCFCE7),
    isUnlocked: (s) => s.locationsVisited.length >= 3,
  ),
  Achievement(
    emoji: '💖',
    title: 'Big Heart',
    unlockedSubtitle: 'Loved 5 stories',
    lockedHint: 'Favorite 5 stories',
    bgColor: const Color(0xFFFCE7F3),
    isUnlocked: (s) => s.favoritesCount >= 5,
  ),
  Achievement(
    emoji: '📖',
    title: 'Bookworm',
    unlockedSubtitle: 'Finished 5 stories',
    lockedHint: 'Read 5 stories to the end',
    bgColor: const Color(0xFFFFF3C9),
    isUnlocked: (s) => s.finishedCount >= 5,
  ),
  Achievement(
    emoji: '🐲',
    title: 'Dragon Tamer',
    unlockedSubtitle: 'Saved a dragon tale',
    lockedHint: 'Save a dragon story',
    bgColor: const Color(0xFFD5F2EA),
    isUnlocked: (s) => s.heroesUsed.contains('Dragon'),
  ),
  Achievement(
    emoji: '🌟',
    title: 'Star Reader',
    unlockedSubtitle: 'Created 30 stories',
    lockedHint: 'Create 30 stories',
    bgColor: const Color(0xFFFFDCEB),
    isUnlocked: (s) => s.storiesCreated >= 30,
  ),
];
