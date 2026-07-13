import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';

class StoryResultPage extends StatelessWidget {
  final String hero;
  final String location;

  const StoryResultPage({
    super.key,
    required this.hero,
    required this.location,
  });

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
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: AppGradients.accent,
            image: const DecorationImage(
              image: NetworkImage('https://placeholder.com/400x200'), // Replace with AI generated image
              fit: BoxFit.cover,
            ),
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
              'The Brave $hero at $location',
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
    return LiquidGlass(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(24),
      fillOpacity: 0.5,
      child: const Text(
        "Once upon a time, in a world filled with magic and wonder, there lived a brave hero. They embarked on a journey that would change their life forever. Crossing mountains and sailing seas, they finally arrived at their destination, where a great challenge awaited them...\n\n(This is where your AI generated story will appear. The magic of stardust has brought these words to life just for you!)",
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: LiquidGlass(
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(
              child: Text(
                'Save Story',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: AppGradients.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'Read Aloud',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
