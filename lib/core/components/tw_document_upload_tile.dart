import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum DocumentStatus {
  uploaded,
  underReview,
  pending
}

class TWDocumentUploadTile extends StatelessWidget {
  final String label;
  final DocumentStatus status;
  final IconData documentIcon;
  final VoidCallback onTap;

  const TWDocumentUploadTile({
    super.key,
    required this.label,
    required this.status,
    required this.documentIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusBgColor;
    Color statusTextColor;
    String statusText;
    IconData actionIcon;

    switch (status) {
      case DocumentStatus.uploaded:
        statusBgColor = AppColors.kekeGreen.withOpacity(0.1);
        statusTextColor = AppColors.kekeGreen;
        statusText = 'Uploaded';
        actionIcon = Icons.check;
        break;
      case DocumentStatus.underReview:
        statusBgColor = AppColors.danfoYellow.withOpacity(0.15);
        statusTextColor = AppColors.danfoYellow;
        statusText = 'Under Review';
        actionIcon = Icons.access_time_filled;
        break;
      case DocumentStatus.pending:
        statusBgColor = AppColors.borderStroke;
        statusTextColor = AppColors.muted;
        statusText = 'Pending Upload';
        actionIcon = Icons.add;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderStroke, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.ink.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(documentIcon, size: 20, color: AppColors.paper),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.heading3.copyWith(
                      fontSize: 15,
                      color: AppColors.paper,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: AppTypography.label.copyWith(
                        color: statusTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: statusBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  actionIcon,
                  size: 14,
                  color: statusTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
