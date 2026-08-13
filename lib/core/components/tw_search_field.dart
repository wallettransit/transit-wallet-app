import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TWSearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const TWSearchField({
    super.key,
    this.hintText = 'Search',
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.highlightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderStroke, width: 1),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.paper),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
          prefixIcon: const Icon(Icons.search, color: AppColors.muted, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
