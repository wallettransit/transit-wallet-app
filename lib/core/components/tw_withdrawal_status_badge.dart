import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum TWWithdrawalStatus { pending, processing, successful, failed, reversed }

class TWWithdrawalStatusBadge extends StatelessWidget {
  final TWWithdrawalStatus status;

  const TWWithdrawalStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case TWWithdrawalStatus.pending:
      case TWWithdrawalStatus.processing:
        backgroundColor = AppColors.danfoYellow.withOpacity(0.15);
        textColor = AppColors.danfoYellow;
        label = status == TWWithdrawalStatus.pending ? 'Pending' : 'Processing';
        break;
      case TWWithdrawalStatus.successful:
        backgroundColor = AppColors.kekeGreen.withOpacity(0.15);
        textColor = AppColors.kekeGreen;
        label = 'Successful';
        break;
      case TWWithdrawalStatus.failed:
      case TWWithdrawalStatus.reversed:
        backgroundColor = AppColors.errorRed.withOpacity(0.15);
        textColor = AppColors.errorRed;
        label = status == TWWithdrawalStatus.failed ? 'Failed' : 'Reversed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
