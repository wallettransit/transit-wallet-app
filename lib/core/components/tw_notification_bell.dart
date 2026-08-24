import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TWNotificationBell extends StatelessWidget {
  final VoidCallback? onTap;
  final bool hasUnread;

  const TWNotificationBell({
    super.key,
    this.onTap,
    this.hasUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_none,
              color: AppColors.paper,
              size: 20,
            ),
            if (hasUnread)
              Positioned(
                top: 0,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cardBackground, width: 1.5),
                  ),
                ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
              ),
          ],
        ),
      ),
    );
  }
}
