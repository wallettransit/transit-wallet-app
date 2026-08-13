import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TWVehicleTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const TWVehicleTypeCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kekeGreen.withOpacity(0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.kekeGreen : AppColors.borderStroke,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.kekeGreen : AppColors.ink.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.ink : AppColors.paper,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTypography.heading3.copyWith(
                fontSize: 15,
                color: AppColors.paper,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
      duration: 150.ms,
      curve: Curves.easeOutCubic,
      begin: const Offset(1, 1),
      end: isSelected ? const Offset(1.02, 1.02) : const Offset(1, 1),
    );
  }
}
