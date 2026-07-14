import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/main_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../story/data/featured_story.dart';
import '../../../story/domain/entities/saved_story.dart';
import '../../../story/presentation/pages/story_reader_page.dart';
import '../../../story/presentation/providers/story_providers.dart';
import '../../../story/presentation/story_visuals.dart';
import 'achievements_page.dart';
import 'create_story_page.dart';

/// The Home tab: greeting, featured story, create CTA, continue reading,
/// challenges and the most recent library stories — all from live data.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _openStory(BuildContext context, SavedStory story) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoryReaderPage(story: story)),
    );
  }

  void _openCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateStoryPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = [...ref.watch(storyLibraryProvider)]
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    final continueReading = ref.watch(continueReadingProvider);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _Header(),
            const SizedBox(height: 24),
            LiquidGlassTextField(
              hintText: 'Search stories, heroes, places...',
              prefixIcon: Icons.search,
              readOnly: true,
              onTap: () => ref.read(mainTabIndexProvider.notifier).select(1),
            ),
            const SizedBox(height: 24),
            _buildFeaturedCard(context),
            const SizedBox(height: 20),
            _buildCreateStoryButton(context),
            if (continueReading != null) ...[
              const SizedBox(height: 24),
              _buildContinueReading(context, continueReading),
            ],
            const SizedBox(height: 24),
            _buildChallengesAndBadges(context, ref),
            const SizedBox(height: 32),
            _buildRecentStoriesHeader(ref),
            const SizedBox(height: 16),
            if (stories.isEmpty)
              _buildNoStoriesYet(context)
            else
              _buildRecentStoriesList(context, stories.take(6).toList()),
            const SizedBox(height: 120), // Extra bottom padding for floating nav
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _openStory(context, FeaturedStory.build()),
      child: Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9E8BFF), Color(0xFFF0A6E8)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9E8BFF).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned(
              right: 20,
              top: 20,
              child: Text('🐉', style: TextStyle(fontSize: 64)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'FEATURED TONIGHT',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The Dragon Who Lost His\nRoar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${FeaturedStory.lengthMinutes} min · Ages 4-8',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 24,
              bottom: 24,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF6E63E0),
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateStoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _openCreate(context),
      child: Container(
        height: 68,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: AppGradients.accent,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentStart.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('✨', style: TextStyle(fontSize: 24)),
              SizedBox(width: 10),
              Text(
                'Create a new story',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueReading(
    BuildContext context,
    ({SavedStory story, double progress}) item,
  ) {
    final percent = (item.progress * 100).round();
    return GestureDetector(
      onTap: () => _openStory(context, item.story),
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(30),
        padding: const EdgeInsets.all(18),
        fillOpacity: 0.5,
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: StoryVisuals.cardColor(item.story),
              ),
              child: Center(
                child: Text(
                  StoryVisuals.heroEmoji(item.story.hero),
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONTINUE READING',
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.story.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          color: AppColors.accentStart,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.accentStart,
                      ),
                      minHeight: 7,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengesAndBadges(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(storyStatsProvider);
    final starsToNextLevel = StoryStats.starsPerLevel - stats.starsIntoLevel;
    return Row(
      children: [
        Expanded(
          child: _SmallActionCard(
            emoji: '🌟',
            title: 'Daily challenge',
            subtitle: 'Make a story with a shy giant',
            onTap: () => _openCreate(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SmallActionCard(
            emoji: '🏅',
            title: 'Level ${stats.level}',
            subtitle: '$starsToNextLevel stars to Level ${stats.level + 1}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementsPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentStoriesHeader(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent stories',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        TextButton(
          onPressed: () => ref.read(mainTabIndexProvider.notifier).select(1),
          child: const Text(
            'See all',
            style: TextStyle(
              color: AppColors.accentStart,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoStoriesYet(BuildContext context) {
    return GestureDetector(
      onTap: () => _openCreate(context),
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.all(24),
        fillOpacity: 0.4,
        child: const Row(
          children: [
            Text('🌱', style: TextStyle(fontSize: 36)),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No stories yet',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Create your first adventure and it will live here.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentStoriesList(BuildContext context, List<SavedStory> stories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final (index, story) in stories.indexed) ...[
            if (index > 0) const SizedBox(width: 16),
            _RecentStoryCard(
              story: story,
              onTap: () => _openStory(context, story),
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Sweet dreams 🌙';
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 18) return 'Good afternoon 🌈';
    return 'Good evening ✨';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hi, ${profile.displayName}!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _showNotificationsSheet(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => ref.read(mainTabIndexProvider.notifier).select(3),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange.shade200, Colors.pink.shade200],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                profile.avatarEmoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "You're all caught up! Come back after your next adventure.",
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallActionCard extends StatelessWidget {
  const _SmallActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(30),
        padding: const EdgeInsets.all(20),
        fillOpacity: 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.9),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentStoryCard extends StatelessWidget {
  const _RecentStoryCard({required this.story, this.onTap});

  final SavedStory story;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: StoryVisuals.cardColor(story),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  StoryVisuals.heroEmoji(story.hero),
                  style: const TextStyle(fontSize: 52),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${story.readMinutes} min',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
