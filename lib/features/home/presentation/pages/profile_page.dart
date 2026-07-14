import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/liquid_glass.dart';
import '../../../profile/presentation/pages/edit_profile_page.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../story/presentation/providers/story_providers.dart';
import '../achievements.dart';
import 'achievements_page.dart';
import 'grown_ups_page.dart';
import 'settings_page.dart';

/// The Profile tab: real name, avatar, live stats and links to the
/// grown-ups area, settings and achievements.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final stats = ref.watch(storyStatsProvider);
    final badgeCount =
        appAchievements.where((a) => a.isUnlocked(stats)).length;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(context),
            const SizedBox(height: 30),
            _buildProfileCard(context, profile.displayName,
                profile.avatarEmoji, stats.level),
            const SizedBox(height: 24),
            _buildStatsRow(context, stats, badgeCount),
            const SizedBox(height: 24),
            _buildLinksList(context),
            const SizedBox(height: 120),
          ],
        ),
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

  Widget _buildProfileCard(
      BuildContext context, String name, String avatar, int level) {
    return Column(
      children: [
        Stack(
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
              child: Center(
                child: Text(avatar, style: const TextStyle(fontSize: 60)),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => _openEditProfile(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: AppColors.accentStart,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Level $level Storyteller',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes / 60;
    return hours == hours.roundToDouble()
        ? '${hours.round()}h'
        : '${hours.toStringAsFixed(1)}h';
  }

  Widget _buildStatsRow(BuildContext context, StoryStats stats, int badges) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem('${stats.storiesCreated}', 'Stories made'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
              _formatMinutes(stats.storyMinutes), 'Story time'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AchievementsPage()),
              );
            },
            child: _buildStatItem('$badges', 'Badges'),
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
              color: AppColors.accentStart,
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

  void _openEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }

  Widget _buildLinksList(BuildContext context) {
    return Column(
      children: [
        _buildLinkItem(
          icon: '👤',
          title: 'Edit profile',
          iconBgColor: const Color(0xFFE2D9FF),
          onTap: () => _openEditProfile(context),
        ),
        const SizedBox(height: 12),
        _buildLinkItem(
          icon: '🏆',
          title: 'Achievements',
          iconBgColor: const Color(0xFFFFEBCC),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AchievementsPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildLinkItem(
          icon: '⚙️',
          title: 'Settings',
          iconBgColor: const Color(0xFFFFD9D9),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildLinkItem(
          icon: '👨‍👩‍👧‍👦',
          title: 'Grown-ups & account',
          iconBgColor: const Color(0xFFD9F4FF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GrownUpsPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLinkItem({
    required String icon,
    required String title,
    required Color iconBgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlass(
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
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary.withOpacity(0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
