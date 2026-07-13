import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';

import 'create_story_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.background),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        const LiquidGlassTextField(
                          hintText: 'Search your stories...',
                          prefixIcon: Icons.search,
                        ),
                        const SizedBox(height: 24),
                        _buildFilterChips(),
                        const SizedBox(height: 24),
                        _buildStoryList(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Library',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: const Row(
              children: [
                Text(
                  'Newest',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(Icons.arrow_downward, size: 16, color: AppColors.textPrimary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isActive: true,
            gradient: AppGradients.accent,
          ),
          const SizedBox(width: 12),
          const _FilterChip(label: '💖 Favorites'),
          const SizedBox(width: 12),
          const _FilterChip(label: '⬇️ Downloads'),
          const SizedBox(width: 12),
          const _FilterChip(label: '📖 Reading'),
        ],
      ),
    );
  }

  Widget _buildStoryList() {
    return Column(
      children: [
        _LibraryStoryCard(
          emoji: '🦄',
          title: 'Luna and the Lost Moon Key',
          date: 'Yesterday',
          duration: '7 min',
          tag: 'Adventure',
          color: Colors.indigo.shade100,
          isFavorite: true,
        ),
        const SizedBox(height: 16),
        _LibraryStoryCard(
          emoji: '🐲',
          title: 'The Dragon Who Lost His Roar',
          date: '2 days ago',
          duration: '6 min',
          tag: 'Brave',
          color: Colors.pink.shade100,
        ),
        const SizedBox(height: 16),
        _LibraryStoryCard(
          emoji: '🚀',
          title: "Milo's Moon Picnic",
          date: 'Reading',
          duration: '62%',
          tag: 'Cozy',
          color: Colors.blue.shade100,
          isReading: true,
        ),
        const SizedBox(height: 16),
        _LibraryStoryCard(
          emoji: '🦊',
          title: 'Fern the Fox Finds a Friend',
          date: 'Last week',
          duration: '5 min',
          tag: 'Kindness',
          color: Colors.orange.shade100,
          isFavorite: true,
        ),
      ],
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
          _NavBarItem(
            emoji: '🏠',
            label: 'Home',
            isActive: false,
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
          _NavBarItem(
            emoji: '✨',
            label: 'Create',
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CreateStoryPage()),
              );
            },
          ),
          const _NavBarItem(emoji: '📚', label: 'Library', isActive: true),
          _NavBarItem(
            emoji: '💖',
            label: 'Favorites',
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage()),
              );
            },
          ),
          _NavBarItem(
            emoji: '😊',
            label: 'Profile',
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.isActive = false,
    this.gradient,
  });

  final String label;
  final bool isActive;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive && gradient == null ? Colors.white : (gradient != null ? null : Colors.white.withOpacity(0.5)),
        gradient: isActive ? gradient : null,
        borderRadius: BorderRadius.circular(25),
        border: isActive ? null : Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.accentStart.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LibraryStoryCard extends StatelessWidget {
  const _LibraryStoryCard({
    required this.emoji,
    required this.title,
    required this.date,
    required this.duration,
    required this.tag,
    required this.color,
    this.isFavorite = false,
    this.isReading = false,
  });

  final String emoji;
  final String title;
  final String date;
  final String duration;
  final String tag;
  final Color color;
  final bool isFavorite;
  final bool isReading;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(12),
      fillOpacity: 0.5,
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date · $duration',
                  style: TextStyle(
                    color: isReading ? AppColors.accentStart : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: AppColors.accentStart,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.pink : AppColors.textSecondary.withOpacity(0.3),
            size: 24,
          ),
          const SizedBox(width: 8),
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
              color: isActive ? const Color(0xFF6E63E0) : AppColors.textSecondary.withOpacity(0.5),
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
