import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_timeline_item.dart';
import '../../driver_dashboard/presentation/driver_main_layout.dart';

class DriverOnboardingVerificationScreen extends StatelessWidget {
  const DriverOnboardingVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar Area Placeholder
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ONBOARDING STAGE',
                    style: AppTypography.heading3.copyWith(color: AppColors.danfoYellow, fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.danfoYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.danfoYellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pending Review',
                          style: AppTypography.label.copyWith(
                            color: AppColors.danfoYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Status Graphic
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.danfoYellow.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.danfoYellow, width: 4),
                      ),
                      child: Center(
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: const BoxDecoration(
                            color: AppColors.cardBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.access_time_filled,
                              size: 50,
                              color: AppColors.danfoYellow,
                            ),
                          ),
                        ),
                      ),
                    ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 40),
                    
                    // Messaging
                    Text(
                      'Verifying your profile',
                      style: AppTypography.heading1.copyWith(fontSize: 28, color: AppColors.paper),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 12),
                    Text(
                      'Our safety agents are currently reviewing your vehicle photos and LASG documents. This usually takes less than 2 hours.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 40),
                    
                    // Timeline
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.borderStroke),
                      ),
                      child: const Column(
                        children: [
                          TWTimelineItem(
                            title: 'Profile details received',
                            status: TimelineStatus.completed,
                          ),
                          SizedBox(height: 16),
                          TWTimelineItem(
                            title: 'Vehicle registration saved',
                            status: TimelineStatus.completed,
                          ),
                          SizedBox(height: 16),
                          TWTimelineItem(
                            title: 'Document review in progress',
                            status: TimelineStatus.inProgress,
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 600.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 32),
                    
                    // Fast-track Alert
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.borderStroke.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderStroke),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active_outlined, size: 18, color: AppColors.muted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'We\'ll send you a WhatsApp alert and SMS as soon as your account is activated.',
                              style: AppTypography.label.copyWith(fontSize: 13, color: AppColors.muted),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 700.ms).slideY(begin: 0.1, end: 0),
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
                label: 'Go to Dashboard',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverMainLayout(isPendingReview: true),
                    ),
                    (route) => false,
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
