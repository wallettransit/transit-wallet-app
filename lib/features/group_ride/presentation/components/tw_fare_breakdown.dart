import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class TWFareBreakdown extends StatelessWidget {
  final double standardFare;
  final double groupDiscount;
  final double passengerPayable;
  final double driverPayout;
  final double subsidy;

  const TWFareBreakdown({
    super.key,
    required this.standardFare,
    required this.groupDiscount,
    required this.passengerPayable,
    required this.driverPayout,
    required this.subsidy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke, width: 1),
      ),
      child: Column(
        children: [
          // Passenger Economics
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people, size: 14, color: AppColors.muted),
                    const SizedBox(width: 8),
                    Text(
                      'PASSENGER ECONOMICS',
                      style: AppTypography.label.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRow('Standard Fare (Total)', standardFare),
                const SizedBox(height: 8),
                _buildRow('Group Discount', -groupDiscount, isHighlight: true, highlightColor: AppColors.kekeGreen),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: AppColors.borderStroke, height: 1),
                ),
                _buildRow('Passengers Pay', passengerPayable, isBold: true),
              ],
            ),
          ),
          
          // Driver Economics
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.danfoYellow.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(color: AppColors.danfoYellow.withOpacity(0.2), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 14, color: AppColors.danfoYellow),
                        const SizedBox(width: 8),
                        Text(
                          'DRIVER PAYOUT',
                          style: AppTypography.label.copyWith(color: AppColors.danfoYellow),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.kekeGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Subsidized: ₦${subsidy.toStringAsFixed(0)}',
                        style: AppTypography.label.copyWith(
                          color: AppColors.kekeGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRow('Guaranteed Earnings', driverPayout, isBold: true, highlightColor: AppColors.danfoYellow),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double amount, {bool isBold = false, bool isHighlight = false, Color? highlightColor}) {
    final textColor = highlightColor ?? (isBold ? AppColors.paper : AppColors.muted);
    final prefix = amount < 0 ? '-₦' : '₦';
    final formattedAmount = amount.abs().toStringAsFixed(0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: textColor,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          '$prefix$formattedAmount',
          style: AppTypography.bodyMedium.copyWith(
            color: textColor,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
