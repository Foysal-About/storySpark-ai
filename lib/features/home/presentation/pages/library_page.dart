import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/liquid_glass.dart';
import '../../../story/domain/entities/saved_story.dart';
import '../../../story/presentation/pages/story_reader_page.dart';
import '../../../story/presentation/providers/story_providers.dart';
import '../../../story/presentation/story_visuals.dart';
import 'create_story_page.dart';

enum _LibraryFilter { all, favorites, reading, bedtime }

/// The Library tab: every saved story with live search, filters and sorting.
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  String _query = '';
  _LibraryFilter _filter = _LibraryFilter.all;
  bool _newestFirst = true;

  List<SavedStory> _visibleStories() {
    final progress = ref.watch(readingProgressProvider);
    var stories = ref.watch(storyLibraryProvider).where((story) {
      final matchesQuery = _query.isEmpty ||
          story.title.toLowerCase().contains(_query) ||
          story.hero.toLowerCase().contains(_query) ||
          story.location.toLowerCase().contains(_query);
      final matchesFilter = switch (_filter) {
        _LibraryFilter.all => true,
        _LibraryFilter.favorites => story.isFavorite,
        _LibraryFilter.reading => () {
            final p = progress[story.id] ?? 0;
            return p > 0 && p < 0.95;
          }(),
        _LibraryFilter.bedtime => story.mood == '😴',
      };
      return matchesQuery && matchesFilter;
    }).toList();

    stories.sort(
      (a, b) => _newestFirst
          ? b.savedAt.compareTo(a.savedAt)
          : a.savedAt.compareTo(b.savedAt),
    );
    return stories;
  }

  void _openStory(SavedStory story) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoryReaderPage(story: story)),
    );
  }

  Future<void> _confirmDelete(SavedStory story) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete this story?'),
        content: Text(
          '"${story.title}" will be gone from your library forever.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(storyLibraryProvider.notifier).delete(story.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyStories = ref.watch(storyLibraryProvider).isNotEmpty;
    final stories = _visibleStories();
    final progress = ref.watch(readingProgressProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: !hasAnyStories
                ? EmptyState(
                    emoji: '📚',
                    title: 'Your library is empty',
                    subtitle:
                        'Every story you save will be kept here, ready for story time.',
                    actionLabel: '✨ Create a story',
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateStoryPage(),
                        ),
                      );
                    },
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        LiquidGlassTextField(
                          hintText: 'Search your stories...',
                          prefixIcon: Icons.search,
                          onChanged: (value) => setState(
                            () => _query = value.trim().toLowerCase(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildFilterChips(),
                        const SizedBox(height: 24),
                        if (stories.isEmpty)
                          const EmptyState(
                            emoji: '🔍',
                            title: 'Nothing here',
                            subtitle:
                                'No stories match your search or filter yet.',
                          )
                        else
                          for (final (index, story) in stories.indexed) ...[
                            if (index > 0) const SizedBox(height: 16),
                            _LibraryStoryCard(
                              story: story,
                              progress: progress[story.id] ?? 0,
                              onTap: () => _openStory(story),
                              onLongPress: () => _confirmDelete(story),
                              onFavoriteTap: () => ref
                                  .read(storyLibraryProvider.notifier)
                                  .toggleFavorite(story.id),
                            ),
                          ],
                        const SizedBox(height: 120),
                      ],
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
            'Library',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _newestFirst = !_newestFirst),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Text(
                    _newestFirst ? 'Newest' : 'Oldest',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(
                    _newestFirst ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final (filter, label) in const [
            (_LibraryFilter.all, 'All'),
            (_LibraryFilter.favorites, '💖 Favorites'),
            (_LibraryFilter.reading, '📖 Reading'),
            (_LibraryFilter.bedtime, '😴 Bedtime'),
          ]) ...[
            if (filter != _LibraryFilter.all) const SizedBox(width: 12),
            _FilterChip(
              label: label,
              isActive: _filter == filter,
              onTap: () => setState(() => _filter = filter),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? null : Colors.white.withOpacity(0.5),
          gradient: isActive ? AppGradients.accent : null,
          borderRadius: BorderRadius.circular(25),
          border:
              isActive ? null : Border.all(color: Colors.white.withOpacity(0.4)),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accentStart.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _LibraryStoryCard extends StatelessWidget {
  const _LibraryStoryCard({
    required this.story,
    required this.progress,
    this.onTap,
    this.onLongPress,
    this.onFavoriteTap,
  });

  final SavedStory story;
  final double progress;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavoriteTap;

  bool get _isReading => progress > 0 && progress < 0.95;

  @override
  Widget build(BuildContext context) {
    final subtitle = _isReading
        ? 'Reading · ${(progress * 100).round()}%'
        : '${StoryVisuals.relativeDate(story.savedAt)} · ${story.readMinutes} min';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.all(12),
        fillOpacity: 0.5,
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: StoryVisuals.cardColor(story),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  StoryVisuals.heroEmoji(story.hero),
                  style: const TextStyle(fontSize: 36),
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
                    subtitle,
                    style: TextStyle(
                      color: _isReading
                          ? AppColors.accentStart
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentStart.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      StoryVisuals.tag(story),
                      style: const TextStyle(
                        color: AppColors.accentStart,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onFavoriteTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  story.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: story.isFavorite
                      ? Colors.pink
                      : AppColors.textSecondary.withOpacity(0.3),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
