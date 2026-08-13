import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_profile_avatar.dart';
import '../../../../core/components/tw_live_tracking_map.dart';
import 'passenger_group_fare_review_screen.dart';

class PassengerGroupDetailsScreen extends StatelessWidget {
  const PassengerGroupDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIconButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.pop(context),
                      ),
                      Text(
                        'Amara\'s Ride Group',
                        style: GoogleFonts.outfit(
                          color: AppColors.paper,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      _buildIconButton(
                        icon: Icons.help_outline,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Route: Yaba Terminal → Lekki Phase 1',
                    style: GoogleFonts.manrope(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fade(duration: 300.ms).slideY(begin: -0.1),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Map Preview
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: TWLiveTrackingMap(height: 150),
                    ).animate().fade(duration: 400.ms, delay: 100.ms),

                    // Members
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Joined Commuters (4/14)',
                            style: GoogleFonts.outfit(
                              color: AppColors.paper,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const TWProfileAvatar(initials: 'AM', radius: 20),
                              const SizedBox(width: 8),
                              const TWProfileAvatar(initials: 'JD', radius: 20),
                              const SizedBox(width: 8),
                              const TWProfileAvatar(initials: 'SO', radius: 20),
                              const SizedBox(width: 8),
                              const TWProfileAvatar(initials: 'EB', radius: 20),
                              const SizedBox(width: 8),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.borderStroke),
                                ),
                                child: const Center(
                                  child: Icon(Icons.add, size: 14, color: AppColors.muted),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),

                    // Fare Breakdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Commute Pricing Breakdown',
                            style: GoogleFonts.outfit(
                              color: AppColors.paper,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.ink,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderStroke),
                            ),
                            child: Column(
                              children: [
                                _buildFareRow('Standard Private Fare', '₦1,200', AppColors.muted, AppColors.paper),
                                const SizedBox(height: 12),
                                _buildFareRow('Group Discount (60%)', '-₦720', AppColors.muted, AppColors.errorRed),
                                const SizedBox(height: 12),
                                const Divider(color: AppColors.borderStroke, height: 1),
                                const SizedBox(height: 12),
                                _buildFareRow(
                                  'Your Price to Pay',
                                  '₦480',
                                  AppColors.paper,
                                  AppColors.kekeGreen,
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1),

                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: TWButton(
                          label: 'Join Group Ride',
                          icon: Icons.arrow_forward,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PassengerGroupFareReviewScreen()),
                            );
                          },
                        ),
                      ),
                    ).animate().fade(duration: 400.ms, delay: 400.ms),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Icon(icon, size: 20, color: AppColors.paper),
      ),
    );
  }

  Widget _buildFareRow(String title, String amount, Color titleColor, Color amountColor, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isTotal
              ? GoogleFonts.outfit(color: titleColor, fontSize: 16, fontWeight: FontWeight.w800)
              : GoogleFonts.manrope(color: titleColor, fontSize: 14),
        ),
        Text(
          amount,
          style: isTotal
              ? GoogleFonts.outfit(color: amountColor, fontSize: 20, fontWeight: FontWeight.w800)
              : GoogleFonts.manrope(color: amountColor, fontSize: 14),
        ),
      ],
    );
  }
}
