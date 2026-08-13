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
    final double containerSize = size * 1.8;
    
    final Widget logoIcon = Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: AppColors.kekeGreen,
        borderRadius: BorderRadius.circular(containerSize * 0.3),
      ),
      child: Center(
        child: Icon(
          Icons.account_balance_wallet,
          color: AppColors.paper,
          size: size,
        ),
      ),
    );

    if (!showText) return logoIcon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoIcon,
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
  }
}
