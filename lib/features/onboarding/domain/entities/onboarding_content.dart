/// Static copy + progress info for the onboarding screen.
class OnboardingContent {
  const OnboardingContent({
    required this.heroEmoji,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.stepCount,
    required this.activeStep,
  });

  final String heroEmoji;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final int stepCount;
  final int activeStep;
}