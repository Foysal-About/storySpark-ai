import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    children: [
                      _buildSectionHeader('EXPERIENCE'),
                      const SizedBox(height: 12),
                      _buildSettingsGroup([
                        _SettingItem(
                          emoji: '🎨',
                          title: 'Appearance',
                          trailing: 'Aurora',
                          onTap: () {},
                        ),
                        _SettingItem(
                          emoji: '🔊',
                          title: 'Sounds',
                          hasSwitch: true,
                          switchValue: true,
                          onChanged: (val) {},
                        ),
                        _SettingItem(
                          emoji: '🎙️',
                          title: 'Narration voice',
                          trailing: 'Fairy Fern',
                          onTap: () {},
                        ),
                      ]),
                      const SizedBox(height: 32),
                      _buildSectionHeader('GENERAL'),
                      const SizedBox(height: 12),
                      _buildSettingsGroup([
                        _SettingItem(
                          emoji: '🔔',
                          title: 'Notifications',
                          hasSwitch: true,
                          switchValue: false,
                          onChanged: (val) {},
                        ),
                        _SettingItem(
                          emoji: '🌐',
                          title: 'Language',
                          trailing: 'English',
                          onTap: () {},
                        ),
                        _SettingItem(
                          emoji: '🛡️',
                          title: 'Privacy & safety',
                          onTap: () {},
                        ),
                        _SettingItem(
                          emoji: '📖',
                          title: 'About StoryWonder',
                          onTap: () {},
                        ),
                      ]),
                    ],
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 20),
          const Text(
            'Settings',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        children: items,
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.emoji,
    required this.title,
    this.trailing,
    this.hasSwitch = false,
    this.switchValue = false,
    this.onChanged,
    this.onTap,
  });

  final String emoji;
  final String title;
  final String? trailing;
  final bool hasSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
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
            if (hasSwitch)
              Switch(
                value: switchValue,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFFB4A7F2), // Light purple track
                inactiveTrackColor: Colors.black.withOpacity(0.1),
              )
            else ...[
              if (trailing != null)
                Text(
                  trailing!,
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSecondary.withOpacity(0.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
