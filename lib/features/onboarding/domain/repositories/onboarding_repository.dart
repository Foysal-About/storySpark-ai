import '../entities/onboarding_content.dart';

/// Boundary between the onboarding presentation layer and however
/// onboarding copy/state is actually persisted.
abstract class OnboardingRepository {
  OnboardingContent getContent();

  Future<bool> hasCompletedOnboarding();

  Future<void> completeOnboarding();
}