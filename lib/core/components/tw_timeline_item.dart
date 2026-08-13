import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum TimelineStatus { completed, inProgress, pending }

class TWTimelineItem extends StatelessWidget {
  final String title;
  final TimelineStatus status;

  const TWTimelineItem({
    super.key,
    required this.title,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon;
    Color iconBgColor;

    switch (status) {
      case TimelineStatus.completed:
        iconBgColor = AppColors.kekeGreen.withOpacity(0.1);
        icon = const Icon(Icons.check, size: 12, color: AppColors.kekeGreen);
        break;
      case TimelineStatus.inProgress:
        iconBgColor = AppColors.danfoYellow.withOpacity(0.15);
        icon = Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.danfoYellow,
            shape: BoxShape.circle,
          ),
        );
        break;
      case TimelineStatus.pending:
        iconBgColor = AppColors.borderStroke;
        icon = const SizedBox();
        break;
    }

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Center(child: icon),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTypography.label.copyWith(
            fontWeight: status == TimelineStatus.inProgress ? FontWeight.w700 : FontWeight.w600,
            fontSize: 14,
            color: status == TimelineStatus.pending ? AppColors.muted : AppColors.paper,
          ),
        ),
      ],
    );
  }
}
