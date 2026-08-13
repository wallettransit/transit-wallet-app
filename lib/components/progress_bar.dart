import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ProgressBar extends StatelessWidget {
  final int done;
  final int total;

  const ProgressBar({super.key, required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < total - 1 ? 4.0 : 0),
            decoration: BoxDecoration(
              color: index < done ? AppTheme.danfoYellow : AppTheme.asphalt2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
