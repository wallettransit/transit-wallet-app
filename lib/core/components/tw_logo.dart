import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TWLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color textColor;

  const TWLogo({
    Key? key,
    this.size = 20,
    this.showText = true,
    this.textColor = AppColors.paper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/oyapay_logo.png',
      height: size * 1.5,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if the image doesn't load for some reason
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet, color: AppColors.kekeGreen, size: size),
            SizedBox(width: size * 0.4),
            Text(
              'OyaPay',
              style: AppTypography.heading1.copyWith(
                fontSize: size,
                color: textColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
