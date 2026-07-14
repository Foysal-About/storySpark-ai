import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';

/// Friendly placeholder for pages with no content yet, with an optional CTA
/// (e.g. "Create your first story").
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppGradients.accent,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentStart.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
