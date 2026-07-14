import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import 'liquid_glass.dart';

/// A stylized error dialog that matches the "liquid glass" theme, featuring
/// a friendly emoji, a title, descriptive text, and primary/secondary actions.
class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    this.title = 'Oops, the magic hiccuped',
    this.subtitle = "Our storyteller dropped the quill.\nLet's try that page again.",
    this.tryAgainLabel = 'Try again',
    this.onTryAgain,
    this.backHomeLabel = 'Back home',
    this.onBackHome,
  });

  final String title;
  final String subtitle;
  final String tryAgainLabel;
  final VoidCallback? onTryAgain;
  final String backHomeLabel;
  final VoidCallback? onBackHome;

  /// Helper to show this dialog from anywhere with a [BuildContext].
  static Future<void> show(
    BuildContext context, {
    String? title,
    String? subtitle,
    VoidCallback? onTryAgain,
    VoidCallback? onBackHome,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.15),
      builder: (context) => ErrorDialog(
        title: title ?? 'Oops, the magic hiccuped',
        subtitle: subtitle ??
            "Our storyteller dropped the quill.\nLet's try that page again.",
        onTryAgain: onTryAgain,
        onBackHome: onBackHome,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: LiquidGlass(
        fillOpacity: 0.95,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🐣',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            LiquidGlassCtaButton(
              label: tryAgainLabel,
              onTap: () {
                Navigator.pop(context);
                onTryAgain?.call();
              },
              gradient: AppGradients.accent,
            ),
            const SizedBox(height: 12),
            _SecondaryButton(
              label: backHomeLabel,
              onTap: () {
                Navigator.pop(context);
                onBackHome?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(28),
        fillOpacity: 1.0,
        blurSigma: 0, // No need for blur on a solid button
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
