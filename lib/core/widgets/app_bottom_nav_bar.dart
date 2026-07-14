import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/main_shell.dart';
import '../../features/home/presentation/pages/create_story_page.dart';
import '../theme/app_colors.dart';
import 'liquid_glass.dart';

/// The floating glass navigation bar shared by every tab. Home, Library,
/// Favorites and Profile switch tabs; Create pushes the story builder.
class AppBottomNavBar extends ConsumerWidget {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(mainTabIndexProvider);
    void selectTab(int index) =>
        ref.read(mainTabIndexProvider.notifier).select(index);

    return LiquidGlass(
      borderRadius: BorderRadius.circular(40),
      padding: const EdgeInsets.symmetric(vertical: 12),
      fillOpacity: 0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavBarItem(
            emoji: '🏠',
            label: 'Home',
            isActive: activeIndex == 0,
            onTap: () => selectTab(0),
          ),
          _NavBarItem(
            emoji: '✨',
            label: 'Create',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateStoryPage(),
                ),
              );
            },
          ),
          _NavBarItem(
            emoji: '📚',
            label: 'Library',
            isActive: activeIndex == 1,
            onTap: () => selectTab(1),
          ),
          _NavBarItem(
            emoji: '💖',
            label: 'Favorites',
            isActive: activeIndex == 2,
            onTap: () => selectTab(2),
          ),
          _NavBarItem(
            emoji: '😊',
            label: 'Profile',
            isActive: activeIndex == 3,
            onTap: () => selectTab(3),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.emoji,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  final String emoji;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: isActive ? 1.0 : 0.4,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? AppColors.accentStart
                  : AppColors.textSecondary.withOpacity(0.5),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.accentStart,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
