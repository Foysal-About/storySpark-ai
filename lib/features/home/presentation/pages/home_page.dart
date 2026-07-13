import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';
import 'create_story_page.dart';

/// The main dashboard for StorySpark AI, featuring a scrollable list of stories,
/// challenges, and a floating navigation bar.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a Stack to keep the background and navigation bar fixed
      // while the main content scrolls.
      body: Stack(
        children: [
          // 1. Background Gradient
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.background),
            ),
          ),

          // 2. Scrollable Content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildFeaturedCard(),
                  const SizedBox(height: 20),
                  _buildCreateStoryButton(context),
                  const SizedBox(height: 24),
                  _buildContinueReading(),
                  const SizedBox(height: 24),
                  _buildChallengesAndBadges(),
                  const SizedBox(height: 32),
                  _buildRecentStoriesHeader(),
                  const SizedBox(height: 16),
                  _buildRecentStoriesList(),
                  const SizedBox(height: 120), // Extra bottom padding for floating nav
                ],
              ),
            ),
          ),

          // 3. Floating Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: _buildBottomNavBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good evening ✨',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Hi, Mia!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        _buildIconCircle(Icons.notifications_none_outlined),
        const SizedBox(width: 12),
        _buildProfileCircle('🦄'),
      ],
    );
  }

  Widget _buildIconCircle(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Icon(icon, color: AppColors.textPrimary, size: 24),
    );
  }

  Widget _buildProfileCircle(String emoji) {
    return Container(
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
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
    );
  }

  Widget _buildSearchBar() {
    return const LiquidGlassTextField(
      hintText: 'Search stories, heroes, places...',
      prefixIcon: Icons.search,
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
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
                  '7 min · Ages 4-8',
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
    );
  }

  Widget _buildCreateStoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateStoryPage()),
        );
      },
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

  Widget _buildContinueReading() {
    return LiquidGlass(
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
              gradient: const LinearGradient(
                colors: [Color(0xFF86A8FF), Color(0xFFD099FF)],
              ),
            ),
            child: const Center(
              child: Text('🚀', style: TextStyle(fontSize: 36)),
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
                    const Text(
                      "Milo's Moon Picnic",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '62%',
                      style: TextStyle(
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
                    value: 0.62,
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
    );
  }

  Widget _buildChallengesAndBadges() {
    return const Row(
      children: [
        Expanded(
          child: _SmallActionCard(
            emoji: '🌟',
            title: 'Daily challenge',
            subtitle: 'Make a story with a shy giant',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _SmallActionCard(
            emoji: '🏅',
            title: 'Star Reader',
            subtitle: '2 stories to your next badge',
          ),
        ),
      ],
    );
  }

  Widget _buildRecentStoriesHeader() {
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
          onPressed: () {},
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

  Widget _buildRecentStoriesList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _RecentStoryCard(
            emoji: '🦊',
            title: 'Fern the Fox',
            time: '5 min',
            color: Colors.orange.shade100,
          ),
          const SizedBox(width: 16),
          _RecentStoryCard(
            emoji: '🐋',
            title: 'Whale Song Sea',
            time: '8 min',
            color: Colors.teal.shade100,
          ),
          const SizedBox(width: 16),
          _RecentStoryCard(
            emoji: '🦉',
            title: 'Wise Owl',
            time: '6 min',
            color: Colors.blueGrey.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(40),
      padding: const EdgeInsets.symmetric(vertical: 12),
      fillOpacity: 0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const _NavBarItem(emoji: '🏠', label: 'Home', isActive: true),
          _NavBarItem(
            emoji: '✨',
            label: 'Create',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateStoryPage(),
                ),
              );
            },
          ),
          const _NavBarItem(emoji: '📚', label: 'Library', isActive: false),
          const _NavBarItem(emoji: '💖', label: 'Favorites', isActive: false),
          const _NavBarItem(emoji: '😊', label: 'Profile', isActive: false),
        ],
      ),
    );
  }
}

class _SmallActionCard extends StatelessWidget {
  const _SmallActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
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
    );
  }
}

class _RecentStoryCard extends StatelessWidget {
  const _RecentStoryCard({
    required this.emoji,
    required this.title,
    required this.time,
    required this.color,
  });

  final String emoji;
  final String title;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 52)),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
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
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.emoji,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  final String emoji;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: isActive ? 1.0 : 0.4,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  isActive
                      ? const Color(0xFF6E63E0)
                      : AppColors.textSecondary.withOpacity(0.5),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF6E63E0),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
