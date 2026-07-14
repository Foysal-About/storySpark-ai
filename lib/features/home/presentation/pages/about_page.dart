import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: AppGradients.accent,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.accentStart.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('✨', style: TextStyle(fontSize: 52)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'StorySpark AI',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 28),
                        LiquidGlass(
                          borderRadius: BorderRadius.circular(28),
                          padding: const EdgeInsets.all(24),
                          fillOpacity: 0.5,
                          child: const Text(
                            'StorySpark AI turns your child\'s ideas into '
                            'one-of-a-kind bedtime stories. Pick a hero, a '
                            'place and a challenge — and a brand-new '
                            'adventure is written just for them, ready to '
                            'read together or listen to out loud.',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        LiquidGlass(
                          borderRadius: BorderRadius.circular(28),
                          padding: const EdgeInsets.all(8),
                          fillOpacity: 0.5,
                          child: Column(
                            children: const [
                              _AboutRow(
                                emoji: '🪄',
                                label: 'Stories written by',
                                value: 'Google Gemini',
                              ),
                              _AboutRow(
                                emoji: '🎙️',
                                label: 'Read aloud with',
                                value: 'On-device & cloud voices',
                              ),
                              _AboutRow(
                                emoji: '🔒',
                                label: 'Your library lives',
                                value: 'On this device',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Made with 💜 for little dreamers',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const Text(
            'About',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
