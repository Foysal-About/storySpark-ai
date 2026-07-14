import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../story/presentation/providers/story_providers.dart';

/// Grown-ups area: a simple math gate keeps kids out, then offers data
/// management (clear library, full reset) and account info.
class GrownUpsPage extends ConsumerStatefulWidget {
  const GrownUpsPage({super.key});

  @override
  ConsumerState<GrownUpsPage> createState() => _GrownUpsPageState();
}

class _GrownUpsPageState extends ConsumerState<GrownUpsPage> {
  bool _unlocked = false;
  String _answer = '';

  // Rotating gate question so it isn't always the same one.
  static const _questions = [
    (question: 'What is 7 × 4?', answer: '28'),
    (question: 'What is 6 × 8?', answer: '48'),
    (question: 'What is 9 × 3?', answer: '27'),
  ];

  late final _gate = _questions[DateTime.now().second % _questions.length];

  void _checkAnswer() {
    if (_answer.trim() == _gate.answer) {
      setState(() => _unlocked = true);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Not quite — ask a grown-up! 🙂')),
        );
    }
  }

  Future<void> _clearLibrary() async {
    final confirmed = await _confirm(
      title: 'Clear the library?',
      message:
          'All saved stories, favorites and reading progress will be deleted. '
          'This cannot be undone.',
      confirmLabel: 'Clear library',
    );
    if (confirmed != true || !mounted) return;
    await ref.read(storyLibraryProvider.notifier).clearAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Library cleared.')),
    );
  }

  Future<void> _resetApp() async {
    final confirmed = await _confirm(
      title: 'Reset the whole app?',
      message:
          'Stories, profile, settings and progress will all be erased, and '
          'the app will start fresh from the welcome screen.',
      confirmLabel: 'Reset everything',
    );
    if (confirmed != true || !mounted) return;

    await ref.read(sharedPreferencesProvider).clear();
    ref.invalidate(storyLibraryProvider);
    ref.invalidate(readingProgressProvider);
    ref.invalidate(storiesCreatedProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(appSettingsProvider);
    ref.invalidate(hasCompletedOnboardingProvider);
    if (!mounted) return;
    // Back to the root; the app gate now shows onboarding again.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
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
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: _unlocked ? _buildContent() : _buildGate(),
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const Text(
            'Grown-ups',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildGate() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text('🔐', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 20),
          const Text(
            'Grown-ups only',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'To keep stories safe, answer this question:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.9),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            _gate.question,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          LiquidGlassTextField(
            hintText: 'Your answer...',
            prefixIcon: Icons.calculate_outlined,
            onChanged: (value) => _answer = value,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _checkAnswer,
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: AppGradients.accent,
              ),
              child: const Center(
                child: Text(
                  'Unlock',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final stats = ref.watch(storyStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _sectionHeader('THIS DEVICE'),
          const SizedBox(height: 12),
          LiquidGlass(
            borderRadius: BorderRadius.circular(28),
            padding: const EdgeInsets.all(8),
            fillOpacity: 0.5,
            child: Column(
              children: [
                _infoRow('📚', 'Stories saved', '${stats.savedCount}'),
                _infoRow('✨', 'Stories created', '${stats.storiesCreated}'),
                _infoRow('☁️', 'Account', 'None — all data is local'),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _sectionHeader('MANAGE DATA'),
          const SizedBox(height: 12),
          _dangerButton(
            emoji: '🧹',
            label: 'Clear story library',
            onTap: _clearLibrary,
          ),
          const SizedBox(height: 12),
          _dangerButton(
            emoji: '🗑️',
            label: 'Reset the whole app',
            onTap: _resetApp,
          ),
          const SizedBox(height: 28),
          Text(
            'Deleting data here removes it from this device permanently. '
            'Nothing is stored anywhere else.',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.8),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _infoRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dangerButton({
    required String emoji,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        fillOpacity: 0.5,
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
