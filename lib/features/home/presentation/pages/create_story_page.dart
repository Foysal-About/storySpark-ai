import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';

class CreateStoryPage extends StatefulWidget {
  const CreateStoryPage({super.key});

  @override
  State<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends State<CreateStoryPage> {
  String selectedHero = 'Unicorn';
  String selectedLocation = 'The Moon';
  String selectedChallenge = 'Find the lost key';
  String selectedMood = '😊';
  double storyLength = 7;

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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Who is the hero?'),
                        const SizedBox(height: 12),
                        const LiquidGlassTextField(
                          hintText: 'Give your hero a name...',
                          prefixIcon: Icons.edit_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildHeroSelection(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Where does it happen?'),
                        const SizedBox(height: 12),
                        _buildLocationSelection(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("What's the challenge?"),
                        const SizedBox(height: 12),
                        _buildChallengeSelection(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: _buildMoodSection()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildLengthSection()),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildPreviewSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: _buildCreateButton(),
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const Text(
            'Create Story',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 48), // Spacer to balance the back button
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Build your story',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        _buildSurpriseMeButton(),
      ],
    );
  }

  Widget _buildSurpriseMeButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: const Row(
        children: [
          Text('🎲', style: TextStyle(fontSize: 14)),
          SizedBox(width: 6),
          Text(
            'Surprise me',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6E63E0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildHeroSelection() {
    final heroes = [
      {'emoji': '🦄', 'name': 'Unicorn'},
      {'emoji': '🤖', 'name': 'Robot'},
      {'emoji': '🐲', 'name': 'Dragon'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: heroes.map((hero) {
        final isSelected = selectedHero == hero['name'];
        return _buildSelectionCard(
          emoji: hero['emoji']!,
          label: hero['name']!,
          isSelected: isSelected,
          onTap: () => setState(() => selectedHero = hero['name']!),
        );
      }).toList(),
    );
  }

  Widget _buildLocationSelection() {
    final locations = [
      {'emoji': '🏰', 'name': 'Castle'},
      {'emoji': '🌙', 'name': 'The Moon'},
      {'emoji': '🌊', 'name': 'Deep Sea'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: locations.map((loc) {
        final isSelected = selectedLocation == loc['name'];
        return _buildSelectionCard(
          emoji: loc['emoji']!,
          label: loc['name']!,
          isSelected: isSelected,
          onTap: () => setState(() => selectedLocation = loc['name']!),
          selectedColor: const Color(0xFFFF5E7D),
        );
      }).toList(),
    );
  }

  Widget _buildSelectionCard({
    required String emoji,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color selectedColor = const Color(0xFF6E63E0),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 110,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? selectedColor.withOpacity(0.5) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeSelection() {
    final challenges = [
      {'name': 'Find the lost key', 'icon': Icons.vpn_key_outlined},
      {'name': 'Calm the storm', 'icon': Icons.wb_cloudy_outlined},
      {'name': 'Save the party', 'icon': Icons.celebration_outlined},
    ];

    return Column(
      children: challenges.map((challenge) {
        final name = challenge['name'] as String;
        final icon = challenge['icon'] as IconData;
        final isSelected = selectedChallenge == name;
        final color = isSelected ? const Color(0xFF33CCB7) : AppColors.textSecondary;

        return GestureDetector(
          onTap: () => setState(() => selectedChallenge = name),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? color.withOpacity(0.5) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMoodSection() {
    final moods = ['😊', '😴', '🤡'];
    return LiquidGlass(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      fillOpacity: 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MOOD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: moods.map((mood) {
              final isSelected = selectedMood == mood;
              return GestureDetector(
                onTap: () => setState(() => selectedMood = mood),
                child: Opacity(
                  opacity: isSelected ? 1.0 : 0.4,
                  child: Text(
                    mood,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLengthSection() {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      fillOpacity: 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LENGTH',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: const Color(0xFF6E63E0),
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    thumbColor: Colors.white,
                    overlayColor: const Color(0xFF6E63E0).withOpacity(0.1),
                  ),
                  child: Slider(
                    value: storyLength,
                    min: 1,
                    max: 15,
                    onChanged: (val) => setState(() => storyLength = val),
                  ),
                ),
              ),
              Text(
                '${storyLength.toInt()} min',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      fillOpacity: 0.4,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🦄', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textPrimary,
                  fontFamily: 'Roboto',
                ),
                children: [
                  const TextSpan(
                    text: 'Preview: ',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text:
                        'A brave unicorn travels to the Moon to find the lost key...',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: AppGradients.accent,
        boxShadow: [
          BoxShadow(
            color: AppColors.accentStart.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Start your adventure',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
