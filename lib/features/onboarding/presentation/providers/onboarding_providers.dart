import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/onboarding_local_data_source.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/entities/onboarding_content.dart';
import '../../domain/repositories/onboarding_repository.dart';

/// Overridden in `main()` with the real, already-initialized instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final onboardingLocalDataSourceProvider = Provider(
  (ref) => OnboardingLocalDataSource(ref.watch(sharedPreferencesProvider)),
);

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepositoryImpl(ref.watch(onboardingLocalDataSourceProvider)),
);

final onboardingContentProvider = Provider<OnboardingContent>(
  (ref) => ref.watch(onboardingRepositoryProvider).getContent(),
);

/// Whether onboarding has already been completed on this device.
final hasCompletedOnboardingProvider = FutureProvider<bool>(
  (ref) => ref.watch(onboardingRepositoryProvider).hasCompletedOnboarding(),
);

final onboardingControllerProvider = Provider(
  (ref) => OnboardingController(ref),
);

/// Thin use-case wrapper: marks onboarding complete and refreshes the
/// gate that decides whether to show onboarding or the home screen.
class OnboardingController {
  OnboardingController(this._ref);

  final Ref _ref;

  Future<void> finish() async {
    await _ref.read(onboardingRepositoryProvider).completeOnboarding();
    _ref.invalidate(hasCompletedOnboardingProvider);
  }
}