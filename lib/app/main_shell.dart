import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_gradients.dart';
import '../core/widgets/app_bottom_nav_bar.dart';
import '../features/home/presentation/pages/favorites_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/home/presentation/pages/library_page.dart';
import '../features/home/presentation/pages/profile_page.dart';

/// Index of the visible tab in [MainShell]: 0 Home, 1 Library, 2 Favorites,
/// 3 Profile. Pages can switch tabs (e.g. home's "See all" opens Library).
final mainTabIndexProvider = NotifierProvider<MainTabController, int>(
  MainTabController.new,
);

class MainTabController extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

/// Root scaffold after onboarding: one background, one floating glass nav
/// bar, and the four tab pages kept alive in an [IndexedStack].
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(mainTabIndexProvider);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.background),
            ),
          ),
          IndexedStack(
            index: index,
            children: const [
              HomePage(),
              LibraryPage(),
              FavoritesPage(),
              ProfilePage(),
            ],
          ),
          const Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: AppBottomNavBar(),
          ),
        ],
      ),
    );
  }
}
