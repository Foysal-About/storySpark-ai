import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';

import 'create_story_page.dart';
import 'library_page.dart';
import 'profile_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

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
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(20),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: const [
                      _FavoriteStoryCard(
                        emoji: '🦄',
                        title: 'Luna and the Moon Key',
                        duration: '7 min',
                        tag: 'Adventure',
                        color: Colors.indigoAccent,
                      ),
                      _FavoriteStoryCard(
                        emoji: '🐳',
                        title: 'Whale Song Sea',
                        duration: '8 min',
                        tag: 'Calm',
                        color: Colors.tealAccent,
                      ),
                      _FavoriteStoryCard(
                        emoji: '🦊',
                        title: 'Fern the Fox',
                        duration: '5 min',
                        tag: 'Kindness',
                        color: Colors.orangeAccent,
                      ),
                      _FavoriteStoryCard(
                        emoji: '🏰',
                        title: 'The Giggling Castle',
                        duration: '6 min',
                        tag: 'Funny',
                        color: Colors.pinkAccent,
                      ),
                    ],
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
            'Favorites 💖',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.grid_view_rounded, size: 20, color: AppColors.textPrimary),
                SizedBox(width: 8),
                Icon(Icons.list_rounded, size: 20, color: AppColors.textSecondary),
              ],
            ),
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
          _NavBarItem(
            emoji: '📚',
            label: 'Library',
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LibraryPage()),
              );
            },
          ),
          const _NavBarItem(emoji: '💖', label: 'Favorites', isActive: true),
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

class _FavoriteStoryCard extends StatelessWidget {
  const _FavoriteStoryCard({
    required this.emoji,
    required this.title,
    required this.duration,
    required this.tag,
    required this.color,
  });

  final String emoji;
  final String title;
  final String duration;
  final String tag;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.5), color],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Stack(
                children: [
                  Center(child: Text(emoji, style: const TextStyle(fontSize: 48))),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite, color: Colors.pink, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                  '$duration · $tag',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
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
