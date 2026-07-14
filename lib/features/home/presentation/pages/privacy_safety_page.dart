import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';

class PrivacySafetyPage extends StatelessWidget {
  const PrivacySafetyPage({super.key});

  static const _sections = [
    (
      emoji: '📱',
      title: 'Everything stays on this device',
      body:
          'Stories, favorites, reading progress and the profile are stored '
          'only on this device. There are no accounts, and nothing is shared '
          'with other people.',
    ),
    (
      emoji: '🪄',
      title: 'How stories are made',
      body:
          'When you create a story, the choices you picked (hero, place, '
          'challenge, mood and length) are sent to Google Gemini to write '
          'the story. No names, photos or personal details are ever sent.',
    ),
    (
      emoji: '🧒',
      title: 'Made for kids',
      body:
          'Stories are always requested in child-friendly language with a '
          'happy ending. The app has no ads, no in-app purchases and no '
          'links to the open internet.',
    ),
    (
      emoji: '👨‍👩‍👧‍👦',
      title: 'Grown-ups stay in charge',
      body:
          'Clearing the library or resetting the app lives behind the '
          'grown-ups gate on the profile page, so little fingers can\'t '
          'delete their stories by accident.',
    ),
  ];

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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                    children: [
                      for (final section in _sections) ...[
                        LiquidGlass(
                          borderRadius: BorderRadius.circular(28),
                          padding: const EdgeInsets.all(20),
                          fillOpacity: 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(section.emoji,
                                      style: const TextStyle(fontSize: 26)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      section.title,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                section.body,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
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
            'Privacy & Safety',
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
