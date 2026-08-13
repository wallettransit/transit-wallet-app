import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TWProfileAvatar extends StatelessWidget {
  final String initials;
  final String? imageUrl;
  final double radius;
  final VoidCallback? onUploadTapped;

  const TWProfileAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.radius = 24.0,
    this.onUploadTapped,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUploadTapped,
      child: Stack(
        children: [
          // The main avatar
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              color: AppColors.danfoYellow,
              shape: BoxShape.circle,
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: imageUrl == null
                ? Center(
                    child: Text(
                      initials,
                      style: AppTypography.heading3.copyWith(
                        color: AppColors.ink,
                        fontSize: radius * 0.8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : null,
          ),
          
          // The edit/upload badge
          if (onUploadTapped != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(radius * 0.15),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: radius * 0.5,
                  color: AppColors.ink,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
                    duration: 2000.ms,
                    color: AppColors.kekeGreen.withOpacity(0.5),
                  ),
            ),
        ],
      ).animate().scale(
        duration: 300.ms,
        curve: Curves.easeOutBack,
      ),
    );
  }
}
