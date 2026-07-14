import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/liquid_glass.dart';
import '../providers/profile_providers.dart';

/// Lets the child pick their name and avatar, shown in greetings and on the
/// profile page.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  static const _avatarChoices = [
    '🦄', '🐲', '🤖', '🦊', '🐋', '🦉',
    '🐰', '🐼', '🦁', '🐸', '👧', '👦',
  ];

  late final TextEditingController _nameController;
  late String _selectedAvatar;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _selectedAvatar = profile.avatarEmoji;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(userProfileProvider.notifier).update(
          name: _nameController.text.trim(),
          avatarEmoji: _selectedAvatar,
        );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated! 🎉')),
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFFD194), Color(0xFFD1913C)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFD1913C).withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _selectedAvatar,
                                style: const TextStyle(fontSize: 60),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'What should we call you?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LiquidGlassTextField(
                          controller: _nameController,
                          hintText: 'Your name...',
                          prefixIcon: Icons.edit_outlined,
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Pick your avatar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAvatarGrid(),
                        const SizedBox(height: 120),
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
            child: GestureDetector(
              onTap: _save,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: AppGradients.accent,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentStart.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
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
            'Edit Profile',
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

  Widget _buildAvatarGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        for (final emoji in _avatarChoices)
          GestureDetector(
            onTap: () => setState(() => _selectedAvatar = emoji),
            child: Container(
              decoration: BoxDecoration(
                color: _selectedAvatar == emoji
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedAvatar == emoji
                      ? AppColors.accentStart.withValues(alpha: 0.5)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: _selectedAvatar == emoji
                    ? [
                        BoxShadow(
                          color: AppColors.accentStart.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
          ),
      ],
    );
  }
}
