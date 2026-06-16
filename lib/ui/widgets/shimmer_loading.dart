import 'package:flutter/material.dart';
import '../theme/japandi_theme.dart';

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({super.key});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: JC.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: JC.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ShimmerBox(
                    width: 36,
                    height: 36,
                    opacity: _animation.value,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 12),
                  _ShimmerBox(
                    width: 120,
                    height: 14,
                    opacity: _animation.value,
                    borderRadius: 4,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ShimmerBox(
                width: double.infinity,
                height: 12,
                opacity: _animation.value,
                borderRadius: 4,
              ),
              const SizedBox(height: 6),
              _ShimmerBox(
                width: 200,
                height: 12,
                opacity: _animation.value,
                borderRadius: 4,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.opacity,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.3 + (opacity * 0.4),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: JC.border,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
