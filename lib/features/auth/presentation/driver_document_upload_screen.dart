import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_document_upload_tile.dart';
import 'driver_onboarding_verification_screen.dart';

class DriverDocumentUploadScreen extends StatelessWidget {
  const DriverDocumentUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // Stepper Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderStroke),
                          ),
                          child: const Icon(Icons.chevron_left, size: 20, color: AppColors.paper),
                        ),
                      ),
                      Text(
                        'Step 3 of 4',
                        style: AppTypography.heading3.copyWith(color: AppColors.kekeGreen, fontSize: 14),
                      ),
                      Text(
                        'Skip',
                        style: AppTypography.heading3.copyWith(color: AppColors.muted, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.borderStroke,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.75,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.kekeGreen,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ).animate().scaleX(begin: 0.5, end: 1, duration: 600.ms, curve: Curves.easeOutCubic, alignment: Alignment.centerLeft),
                  const SizedBox(height: 16),
                  Text(
                    'Upload your documents',
                    style: AppTypography.heading1.copyWith(fontSize: 24, color: AppColors.paper),
                  ).animate().fade(delay: 200.ms).slideX(begin: -0.1, end: 0),
                ],
              ),
            ),

            // Form Fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We require verified federal and state-level driver details to keep our transit platform secure and compliant.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),
                    
                    TWDocumentUploadTile(
                      label: 'Driver\'s License',
                      status: DocumentStatus.uploaded,
                      documentIcon: Icons.badge_outlined,
                      onTap: () {},
                    ).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 16),
                    
                    TWDocumentUploadTile(
                      label: 'Vehicle Papers (LASG / State)',
                      status: DocumentStatus.underReview,
                      documentIcon: Icons.description_outlined,
                      onTap: () {},
                    ).animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 16),
                    
                    TWDocumentUploadTile(
                      label: 'Vehicle Insurance Policy',
                      status: DocumentStatus.pending,
                      documentIcon: Icons.shield_outlined,
                      onTap: () {},
                    ).animate().fade(delay: 600.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 16),
                    
                    TWDocumentUploadTile(
                      label: 'Road Worthiness Certificate',
                      status: DocumentStatus.pending,
                      documentIcon: Icons.verified_outlined,
                      onTap: () {},
                    ).animate().fade(delay: 700.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 32),
                    
                    // Security Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, size: 16, color: AppColors.muted),
                        const SizedBox(width: 8),
                        Text(
                          'LASG & FRSC regulatory compliant storage',
                          style: AppTypography.label.copyWith(fontSize: 12, color: AppColors.muted),
                        ),
                      ],
                    ).animate().fade(delay: 800.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.ink,
                border: Border(top: BorderSide(color: AppColors.borderStroke)),
              ),
              child: TWButton(
                label: 'Submit Documents',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverOnboardingVerificationScreen()),
                  );
                },
              ),
            ).animate().slideY(begin: 1, end: 0, duration: 400.ms, delay: 900.ms, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}
