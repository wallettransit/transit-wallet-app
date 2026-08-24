import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class TWSkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const TWSkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.borderStroke,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 1500.ms, color: Colors.white54);
  }
}
