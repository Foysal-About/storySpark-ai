import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';
import '../../../story/domain/entities/generated_story.dart';
import '../../../story/domain/entities/saved_story.dart';
import '../../../story/domain/entities/story_request.dart';
import '../../../story/presentation/narration/narration_controller.dart';
import '../../../story/presentation/providers/story_providers.dart';

class StoryResultPage extends ConsumerStatefulWidget {
  final StoryRequest request;
  final GeneratedStory story;

  const StoryResultPage({
    super.key,
    required this.request,
    required this.story,
  });

  @override
  ConsumerState<StoryResultPage> createState() => _StoryResultPageState();
}

class _StoryResultPageState extends ConsumerState<StoryResultPage> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isSaved = ref
        .read(storyLocalDataSourceProvider)
        .isSaved(widget.story.title);
  }

  Future<void> _saveStory() async {
    if (_isSaved) return;
    await ref.read(storyLocalDataSourceProvider).saveStory(
          SavedStory(
            title: widget.story.title,
            content: widget.story.content,
            hero: widget.request.hero,
            location: widget.request.location,
            imageUrl: widget.story.imageUrl,
            savedAt: DateTime.now(),
          ),
        );
    ref.invalidate(savedStoriesProvider);
    if (!mounted) return;
    setState(() => _isSaved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Story saved to your library! ✨')),
    );
  }

  Future<void> _toggleReadAloud() {
    return ref.read(narrationControllerProvider).toggle(
          title: widget.story.title,
          content: widget.story.content,
          mood: widget.request.mood,
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

    return Scaffold(
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildStoryHeader(),
                        const SizedBox(height: 24),
                        _buildStoryContent(),
                        const SizedBox(height: 40),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.close_rounded),
          ),
          const Text(
            'Your Adventure',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryHeader() {
    final imageUrl = widget.story.imageUrl;
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: AppGradients.accent,
            image: imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
            ),
            padding: const EdgeInsets.all(24),
            alignment: Alignment.bottomLeft,
            child: Text(
              widget.story.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryContent() {
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
    // High-contrast pair per theme: dark ink on a light glow in light mode,
    // light ink on a saturated indigo in dark mode.
    final highlightStyle = baseStyle.copyWith(
      backgroundColor:
          isDark ? const Color(0xFF6E63E0) : const Color(0xFFFFE59A),
      color: isDark ? Colors.white : const Color(0xFF2C2A4A),
      fontWeight: FontWeight.w700,
    );

    final content = widget.story.content;
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
            onTap: _saveStory,
            child: LiquidGlass(
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  _isSaved ? 'Saved ✓' : 'Save Story',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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
