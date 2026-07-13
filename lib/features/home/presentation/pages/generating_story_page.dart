import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';
import 'story_result_page.dart';

class GeneratingStoryPage extends StatefulWidget {
  final String hero;
  final String location;

  const GeneratingStoryPage({
    super.key,
    required this.hero,
    required this.location,
  });

  @override
  State<GeneratingStoryPage> createState() => _GeneratingStoryPageState();
}

class _GeneratingStoryPageState extends State<GeneratingStoryPage> {
  double _progress = 0.0;
  Timer? _timer;
  int _currentFactIndex = 0;

  final List<String> _facts = [
    "Unicorns sleep with one eye open to watch for shooting stars.",
    "Dragons love toasted marshmallows, but only if they're dragon-fired.",
    "Space robots recharge by dancing under the light of a full moon.",
    "Castles in stories often have secret passages leading to libraries.",
  ];

  @override
  void initState() {
    super.initState();
    _startProgress();
    _rotateFacts();
  }

  void _startProgress() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.005;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _timer?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StoryResultPage(
                hero: widget.hero,
                location: widget.location,
              ),
            ),
          );
        }
      });
    });
  }

  void _rotateFacts() {
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _currentFactIndex = (_currentFactIndex + 1) % _facts.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.background),
            ),
          ),
          // Decorative stars
          Positioned(
            top: 100,
            left: 60,
            child: Opacity(
              opacity: 0.3,
              child: Icon(Icons.star, size: 8, color: AppColors.accentStart.withOpacity(0.5)),
            ),
          ),
          Positioned(
            top: 250,
            right: 80,
            child: Opacity(
              opacity: 0.3,
              child: Icon(Icons.star, size: 12, color: AppColors.accentEnd.withOpacity(0.5)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Story Generation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 60),
                _buildMagicCircle(),
                const SizedBox(height: 48),
                const Text(
                  'Sprinkling stardust...',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your ${widget.hero.toLowerCase()} is packing for ${widget.location}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                _buildProgressBar(),
                const SizedBox(height: 12),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6E63E0),
                  ),
                ),
                const Spacer(),
                _buildTipBox(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagicCircle() {
    return Container(
      width: 180,
      height: 180,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            const Color(0xFF6E63E0).withOpacity(0.2),
            const Color(0xFFE07BC0),
            const Color(0xFF6E63E0),
            const Color(0xFF6E63E0).withOpacity(0.2),
          ],
          stops: const [0.0, 0.5, 0.8, 1.0],
          transform: const GradientRotation(0.5),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            '🪄',
            style: TextStyle(fontSize: 48),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          FractionallySizedBox(
            widthFactor: _progress,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6E63E0),
                    Color(0xFFE07BC0),
                    Color(0xFFFFA07A),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(20),
        fillOpacity: 0.4,
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _facts[_currentFactIndex],
                  key: ValueKey<int>(_currentFactIndex),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
