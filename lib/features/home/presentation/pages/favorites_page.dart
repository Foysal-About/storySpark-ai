import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/main_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/liquid_glass.dart';
import '../../../story/domain/entities/saved_story.dart';
import '../../../story/presentation/pages/story_reader_page.dart';
import '../../../story/presentation/providers/story_providers.dart';
import '../../../story/presentation/story_visuals.dart';

/// The Favorites tab: every story marked with a heart, as a grid or a list.
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  bool _gridView = true;

  void _openStory(SavedStory story) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoryReaderPage(story: story)),
    );
  }

  void _unfavorite(SavedStory story) {
    ref.read(storyLibraryProvider.notifier).toggleFavorite(story.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('"${story.title}" removed from favorites')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = [...ref.watch(favoriteStoriesProvider)]
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: favorites.isEmpty
                ? EmptyState(
                    emoji: '💖',
                    title: 'No favorites yet',
                    subtitle:
                        'Tap the heart on any story in your library and it will appear here.',
                    actionLabel: '📚 Go to library',
                    onAction: () =>
                        ref.read(mainTabIndexProvider.notifier).select(1),
                  )
                : _gridView
                    ? GridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                        children: [
                          for (final story in favorites)
                            _FavoriteGridCard(
                              story: story,
                              onTap: () => _openStory(story),
                              onHeartTap: () => _unfavorite(story),
                            ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                        itemCount: favorites.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => _FavoriteListCard(
                          story: favorites[index],
                          onTap: () => _openStory(favorites[index]),
                          onHeartTap: () => _unfavorite(favorites[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Favorites 💖',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                _viewToggle(Icons.grid_view_rounded, isActive: _gridView,
                    onTap: () => setState(() => _gridView = true)),
                const SizedBox(width: 4),
                _viewToggle(Icons.list_rounded, isActive: !_gridView,
                    onTap: () => setState(() => _gridView = false)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewToggle(IconData icon,
      {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? AppColors.accentStart : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _FavoriteGridCard extends StatelessWidget {
  const _FavoriteGridCard({
    required this.story,
    this.onTap,
    this.onHeartTap,
  });

  final SavedStory story;
  final VoidCallback? onTap;
  final VoidCallback? onHeartTap;

  @override
  Widget build(BuildContext context) {
    final color = StoryVisuals.cardColor(story);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.5), color],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        StoryVisuals.heroEmoji(story.hero),
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: onHeartTap,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite,
                              color: Colors.pink, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${story.readMinutes} min · ${StoryVisuals.tag(story)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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

class _FavoriteListCard extends StatelessWidget {
  const _FavoriteListCard({
    required this.story,
    this.onTap,
    this.onHeartTap,
  });

  final SavedStory story;
  final VoidCallback? onTap;
  final VoidCallback? onHeartTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.all(12),
        fillOpacity: 0.5,
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: StoryVisuals.cardColor(story),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  StoryVisuals.heroEmoji(story.hero),
                  style: const TextStyle(fontSize: 34),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${story.readMinutes} min · ${StoryVisuals.tag(story)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onHeartTap,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.favorite, color: Colors.pink, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
