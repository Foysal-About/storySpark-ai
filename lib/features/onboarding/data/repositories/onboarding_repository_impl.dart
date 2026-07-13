import '../../domain/entities/onboarding_content.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._localDataSource);

  final OnboardingLocalDataSource _localDataSource;

  @override
  OnboardingContent getContent() => const OnboardingContent(
    heroEmoji: '🧚',
    title: 'Pick your hero,\nbuild your world',
    subtitle:
        "Choose a hero, a magical place and a challenge — we'll weave "
        'them into a story just for you.',
    ctaLabel: 'Continue',
    stepCount: 3,
    activeStep: 1,
  );

  @override
  Future<bool> hasCompletedOnboarding() async =>
      _localDataSource.isCompleted();

  @override
  Future<void> completeOnboarding() => _localDataSource.markCompleted();
}