import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A whimsical, animated loading indicator that fits the "StorySpark" theme.
/// It features a rotating gradient ring and a pulsing magic spark.
class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({
    super.key,
    this.size = 60,
    this.message,
  });

  final double size;
  final String? message;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating ring
                    Transform.rotate(
                      angle: _controller.value * 2 * math.pi,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              AppColors.accentStart.withValues(alpha: 0.1),
                              AppColors.accentStart,
                              AppColors.accentEnd,
                              AppColors.accentStart.withValues(alpha: 0.1),
                            ],
                            stops: const [0.0, 0.25, 0.75, 1.0],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Inner pulsing spark
                    Transform.scale(
                      scale: 0.8 + (math.sin(_controller.value * 2 * math.pi) * 0.1),
                      child: const Text(
                        '✨',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
