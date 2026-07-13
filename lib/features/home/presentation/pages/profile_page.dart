import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';
import 'home_page.dart';
import 'create_story_page.dart';
import 'library_page.dart';
import 'favorites_page.dart';
import 'achievements_page.dart';

import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(context),
                  const SizedBox(height: 30),
                  _buildProfileCard(),
                  const SizedBox(height: 24),
                  _buildStatsRow(context),
                  const SizedBox(height: 24),
                  _buildSettingsList(),
                  const SizedBox(height: 120),
                ],
              ),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFD194), Color(0xFFD1913C)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD1913C).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Text('🦄', style: TextStyle(fontSize: 60)),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Mia',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Level 4 Storyteller · Unicorn fan',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatItem('23', 'Stories made')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem('6.5h', 'Reading time')),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AchievementsPage()),
              );
            },
            child: _buildStatItem('9', 'Badges'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.symmetric(vertical: 20),
      fillOpacity: 0.6,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF6E63E0),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Column(
      children: [
        _buildSettingsItem(
          icon: '🎨',
          title: 'Theme & appearance',
          iconBgColor: const Color(0xFFE2D9FF),
        ),
        const SizedBox(height: 12),
        _buildSettingsItem(
          icon: '🌍',
          title: 'Language',
          trailing: 'English',
          iconBgColor: const Color(0xFFFFD9D9),
        ),
        const SizedBox(height: 12),
        _buildSettingsItem(
          icon: '👨‍👩‍👧‍👦',
          title: 'Grown-ups & account',
          iconBgColor: const Color(0xFFD9F4FF),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required String icon,
    required String title,
    String? trailing,
    required Color iconBgColor,
  }) {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(12),
      fillOpacity: 0.6,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary.withOpacity(0.5),
            size: 24,
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
                MaterialPageRoute(builder: (context) => const CreateStoryPage()),
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
          _NavBarItem(
            emoji: '💖',
            label: 'Favorites',
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
          const _NavBarItem(emoji: '😊', label: 'Profile', isActive: true),
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
