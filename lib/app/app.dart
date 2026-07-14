import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/onboarding/presentation/providers/onboarding_providers.dart';
import 'main_shell.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _handleSplash();
  }

  Future<void> _handleSplash() async {
    // Show splash for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _Splash(),
      );
    }

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

class _Splash extends StatefulWidget {
  const _Splash();

  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _dotsController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundBottom, // Pinkish at top
              AppColors.backgroundMid,
              AppColors.backgroundTop,    // Mintish at bottom
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative stars
            const Positioned(top: 140, left: 70, child: _Star(opacity: 0.4, size: 14)),
            const Positioned(top: 220, right: 90, child: _Star(opacity: 0.2, size: 8)),
            const Positioned(bottom: 250, left: 110, child: _Star(opacity: 0.15, size: 10)),
            const Positioned(bottom: 180, right: 70, child: _Star(opacity: 0.3, size: 12)),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Floating Book Logo
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Text(
                        '📖',
                        style: TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'StoryWonder',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Every night, a new adventure',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 54),
                  // Animated Dots (Blinking left to right)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AnimatedDot(
                        index: 0,
                        controller: _dotsController,
                        color: AppColors.accentStart,
                      ),
                      _AnimatedDot(
                        index: 1,
                        controller: _dotsController,
                        color: AppColors.accentEnd,
                      ),
                      _AnimatedDot(
                        index: 2,
                        controller: _dotsController,
                        color: const Color(0xFFB4EBE0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Color color;

  const _AnimatedDot({
    required this.index,
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double progress = controller.value;
        double dotOpacity = 0.2;
        
        // Split cycle into 3 parts
        double start = index / 3.0;
        double end = (index + 1) / 3.0;
        
        if (progress >= start && progress <= end) {
          // Fade in and out within this window
          double localProgress = (progress - start) * 3.0; // 0 to 1
          if (localProgress < 0.5) {
            dotOpacity = 0.2 + (0.8 * localProgress * 2);
          } else {
            dotOpacity = 1.0 - (0.8 * (localProgress - 0.5) * 2);
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(dotOpacity),
          ),
        );
      },
    );
  }
}

class _Star extends StatelessWidget {
  final double opacity;
  final double size;
  const _Star({this.opacity = 1.0, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Icon(Icons.star_rounded, color: AppColors.textPrimary, size: size),
    );
  }
}
