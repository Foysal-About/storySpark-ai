import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/onboarding_dots_indicator.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(onboardingContentProvider);
    final controller = ref.watch(onboardingControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppGradients.background),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.topRight,
                    child: LiquidGlassPillButton(
                      label: 'Skip',
                      textColor: AppColors.textPrimary,
                      onTap: () => controller.finish(),
                    ),
                  ),
                  const Spacer(flex: 3),
                  LiquidGlass(
                    borderRadius: BorderRadius.circular(32),
                    child: SizedBox(
                      height: 168,
                      width: 168,
                      child: Center(
                        child: Text(
                          content.heroEmoji,
                          style: const TextStyle(fontSize: 72),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  Text(
                    content.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    content.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(flex: 3),
                  OnboardingDotsIndicator(
                    stepCount: content.stepCount,
                    activeStep: content.activeStep,
                  ),
                  const SizedBox(height: 24),
                  LiquidGlassCtaButton(
                    label: content.ctaLabel,
                    gradient: AppGradients.accent,
                    onTap: () => controller.finish(),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}