import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';
import '../../domain/entities/saved_story.dart';
import '../narration/narration_controller.dart';
import '../providers/story_providers.dart';
import '../story_visuals.dart';

/// Full-screen reader for a story from the library (or the bundled featured
/// story). Supports read-aloud with highlighting, favorite, share, delete,
/// and tracks scroll progress to power "Continue reading".
class StoryReaderPage extends ConsumerStatefulWidget {
  const StoryReaderPage({super.key, required this.story});

  final SavedStory story;

  @override
  ConsumerState<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends ConsumerState<StoryReaderPage> {
  final _scrollController = ScrollController();
  double _maxProgressSeen = 0;

  /// Current version of the story: the library copy when saved (so the
  /// favorite state stays live), otherwise the one passed in.
  SavedStory get _story {
    final inLibrary = ref
        .watch(storyLibraryProvider)
        .where((s) => s.id == widget.story.id)
        .firstOrNull;
    return inLibrary ?? widget.story;
  }

  bool get _isInLibrary => ref
      .watch(storyLibraryProvider)
      .any((s) => s.id == widget.story.id);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // A story short enough to need no scrolling counts as fully read.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent <= 0) {
        _maxProgressSeen = 1.0;
      }
    });
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;
    final progress = (position.pixels / position.maxScrollExtent).clamp(0.0, 1.0);
    if (progress > _maxProgressSeen) _maxProgressSeen = progress;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _persistProgress() {
    if (!ref.read(storyLibraryProvider).any((s) => s.id == widget.story.id)) {
      return;
    }
    if (_maxProgressSeen > 0) {
      ref
          .read(readingProgressProvider.notifier)
          .setProgress(widget.story.id, _maxProgressSeen);
    }
  }

  Future<void> _toggleFavorite() async {
    if (!_isInLibrary) return;
    await ref.read(storyLibraryProvider.notifier).toggleFavorite(_story.id);
  }

  Future<void> _saveToLibrary() async {
    await ref.read(storyLibraryProvider.notifier).save(widget.story);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Story saved to your library! ✨')),
    );
  }

  Future<void> _shareStory() async {
    await Clipboard.setData(ClipboardData(
      text:
          '${_story.title}\n\n${_story.content}\n\n— made with StorySpark AI ✨',
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Story copied — paste it anywhere to share! 📋'),
      ),
    );
  }

  Future<void> _deleteStory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete this story?'),
        content: Text(
          '"${_story.title}" will be gone from your library forever.',
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
    if (confirmed != true || !mounted) return;
    await ref.read(storyLibraryProvider.notifier).delete(widget.story.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _toggleReadAloud() {
    return ref.read(narrationControllerProvider).toggle(
          title: _story.title,
          content: _story.content,
          mood: _story.mood,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(narrationControllerProvider, (_, controller) {
      final notice = controller.takeNotice();
      if (notice != null && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(notice)));
      }
    });

    return PopScope(
      onPopInvokedWithResult: (_, _) => _persistProgress(),
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradients.background),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildContent(),
                          const SizedBox(height: 32),
                          _buildActionButtons(),
                          const SizedBox(height: 8),
                        ],
                      ),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const Text(
            'Story Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isInLibrary)
                IconButton(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _story.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _story.isFavorite
                        ? Colors.pink
                        : AppColors.textPrimary,
                  ),
                ),
              IconButton(
                onPressed: _shareStory,
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final color = StoryVisuals.cardColor(_story);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.7), color],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StoryVisuals.heroEmoji(_story.hero),
            style: const TextStyle(fontSize: 52),
          ),
          const SizedBox(height: 12),
          Text(
            _story.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip('⏱️ ${_story.readMinutes} min'),
              if (_story.location.isNotEmpty)
                _metaChip(
                  '${StoryVisuals.locationEmoji(_story.location)} ${_story.location}',
                ),
              _metaChip('🏷️ ${StoryVisuals.tag(_story)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildContent() {
    final highlight = ref.watch(
      narrationControllerProvider.select((c) => c.highlight),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const baseStyle = TextStyle(
      fontSize: 16,
      height: 1.6,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w500,
    );
    final highlightStyle = baseStyle.copyWith(
      backgroundColor:
          isDark ? const Color(0xFF6E63E0) : const Color(0xFFFFE59A),
      color: isDark ? Colors.white : const Color(0xFF2C2A4A),
      fontWeight: FontWeight.w700,
    );

    final content = _story.content;
    final spans = highlight == null ||
            highlight.start >= highlight.end ||
            highlight.end > content.length
        ? [TextSpan(text: content)]
        : [
            TextSpan(text: content.substring(0, highlight.start)),
            TextSpan(
              text: content.substring(highlight.start, highlight.end),
              style: highlightStyle,
            ),
            TextSpan(text: content.substring(highlight.end)),
          ];

    return LiquidGlass(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(24),
      fillOpacity: 0.5,
      child: Text.rich(
        TextSpan(style: baseStyle, children: spans),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _isInLibrary ? _deleteStory : _saveToLibrary,
            child: LiquidGlass(
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  _isInLibrary ? 'Delete' : 'Save Story',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _isInLibrary
                        ? Colors.redAccent
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: _toggleReadAloud,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppGradients.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(child: _buildReadButtonLabel()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadButtonLabel() {
    final status = ref.watch(
      narrationControllerProvider.select((c) => c.status),
    );

    const style = TextStyle(fontWeight: FontWeight.w700, color: Colors.white);
    return switch (status) {
      NarrationStatus.idle => const Text('Read Aloud', style: style),
      NarrationStatus.loading => const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Text('Preparing…', style: style),
          ],
        ),
      NarrationStatus.playing => const Text('Stop', style: style),
    };
  }
}
