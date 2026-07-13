import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

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
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        const Text(
                          'Your treasures',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildLevelCard(),
                        const SizedBox(height: 32),
                        _buildBadgesGrid(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard() {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(32),
      padding: const EdgeInsets.all(24),
      fillOpacity: 0.6,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBCC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('🏆', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Level 4 Storyteller',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 350 / 500,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFF8FB1)),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '350 / 500 stars to Level 5',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.8),
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

  Widget _buildBadgesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: const [
        _BadgeCard(
          emoji: '⭐',
          title: 'First Story',
          subtitle: 'Created your first tale',
          bgColor: Color(0xFFFFEDD5),
        ),
        _BadgeCard(
          emoji: '🦉',
          title: 'Night Owl',
          subtitle: '5 bedtime stories',
          bgColor: Color(0xFFE0E7FF),
        ),
        _BadgeCard(
          emoji: '🐠',
          title: 'Explorer',
          subtitle: 'Visited every world',
          bgColor: Color(0xFFDCFCE7),
        ),
        _BadgeCard(
          emoji: '💖',
          title: 'Big Heart',
          subtitle: '10 favorites saved',
          bgColor: Color(0xFFFCE7F3),
        ),
        _BadgeCard(
          emoji: '🔒',
          title: 'Dragon Tamer',
          subtitle: 'Locked · 3 dragon tales',
          isLocked: true,
        ),
        _BadgeCard(
          emoji: '🔒',
          title: 'Star Reader',
          subtitle: 'Locked · read 30 stories',
          isLocked: true,
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.bgColor,
    this.isLocked = false,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color? bgColor;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(16),
      fillOpacity: isLocked ? 0.3 : 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLocked ? Colors.white.withOpacity(0.3) : bgColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              emoji,
              style: TextStyle(fontSize: 32, color: isLocked ? Colors.grey : null),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLocked ? AppColors.textPrimary.withOpacity(0.5) : AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLocked ? AppColors.textSecondary.withOpacity(0.5) : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
