import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/onboarding/presentation/providers/onboarding_providers.dart';
import 'main_shell.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingStatus = ref.watch(hasCompletedOnboardingProvider);

    return MaterialApp(
      title: 'StorySpark AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.accentStart,
        scaffoldBackgroundColor: AppColors.backgroundTop,
        fontFamily: 'Roboto',
      ),
      home: onboardingStatus.when(
        data: (completed) => completed ? const MainShell() : const OnboardingPage(),
        loading: () => const _Splash(),
        error: (_, _) => const OnboardingPage(),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundTop,
      body: SizedBox.shrink(),
    );
  }
}