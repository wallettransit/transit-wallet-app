import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TWBankAccountCard extends StatelessWidget {
  final String bankName;
  final String maskedAccountNumber;
  final String? accountName;
  final bool isVerified;
  final String? actionLabel;
  final VoidCallback? onActionTapped;
  final Color backgroundColor;
  final bool isSelected;

  const TWBankAccountCard({
    super.key,
    required this.bankName,
    required this.maskedAccountNumber,
    this.accountName,
    this.isVerified = true,
    this.actionLabel,
    this.onActionTapped,
    this.backgroundColor = AppColors.highlightBackground,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.kekeGreen : AppColors.borderStroke,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.borderStroke,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.account_balance,
                      size: 20,
                      color: isVerified ? AppColors.kekeGreen : AppColors.muted,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bankName,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.paper,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        maskedAccountNumber,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (accountName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          accountName!,
                          style: AppTypography.label.copyWith(
                            color: AppColors.muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onActionTapped != null)
            GestureDetector(
              onTap: onActionTapped,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  actionLabel!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.kekeGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
