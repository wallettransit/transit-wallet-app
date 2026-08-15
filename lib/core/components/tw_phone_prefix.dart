import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TWPhonePrefix extends StatelessWidget {
  const TWPhonePrefix({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇳🇬', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text('+234', style: AppTypography.bodyMedium.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(width: 1, height: 20, color: AppColors.muted.withOpacity(0.3)),
        ],
      ),
    );
  }
}
