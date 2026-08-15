import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'tw_button.dart';

class TWComingSoonScreen extends StatelessWidget {
  final String title;
  final String featureName;
  final IconData icon;

  const TWComingSoonScreen({
    super.key,
    required this.title,
    required this.featureName,
    this.icon = Icons.construction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.highlightBackground,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, size: 60, color: AppColors.kekeGreen),
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 32),
              
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.heading2.copyWith(color: AppColors.paper, fontWeight: FontWeight.w800),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 16),
              
              Text(
                'We are working hard to bring you the best $featureName experience. Stay tuned!',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
              ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 48),
              
              TWButton(
                label: 'Go Back',
                onPressed: () => Navigator.pop(context),
                variant: TWButtonVariant.secondary,
              ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}
