import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/components/tw_profile_avatar.dart';
import '../../../core/components/tw_qr_bottom_sheet.dart';
import '../../profile/presentation/driver_profile_screen.dart';
import '../../group_ride/presentation/driver_group_requests_screen.dart';
import '../../../core/services/audio_haptic_service.dart';
import '../../driver/presentation/onboarding/driver_kyc_screen.dart';
import '../../driver/presentation/onboarding/driver_vehicle_setup_screen.dart';

class DriverDashboardScreen extends StatelessWidget {
  final bool isPendingReview;
  
  const DriverDashboardScreen({super.key, this.isPendingReview = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              // top-bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DriverProfileScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [AppColors.kekeGreen.withOpacity(0.6), AppColors.kekeGreen.withOpacity(0.0)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 3000.ms, color: Colors.white24),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.danfoYellow,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.ink, width: 2),
                                ),
                                alignment: Alignment.center,
                                child: Text('AK', style: GoogleFonts.outfit(color: AppColors.ink, fontWeight: FontWeight.w900, fontSize: 16)),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Good morning,', style: GoogleFonts.outfit(color: AppColors.muted, fontSize: 12)),
                              Text(
                                'Alhaji Kehinde',
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppColors.paper,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.kekeGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.kekeGreen.withOpacity(0.4), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.kekeGreen,
                              shape: BoxShape.circle,
                            ),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(duration: 1.seconds),
                          const SizedBox(width: 6),
                          Text(
                            'ONLINE',
                            style: GoogleFonts.outfit(
                              color: AppColors.kekeGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic),
              
              if (isPendingReview)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danfoYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.danfoYellow.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled, color: AppColors.danfoYellow, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your profile is under review. Some features may be restricted.',
                            style: GoogleFonts.outfit(
                              color: AppColors.danfoYellow,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0),
                ),
              
              // action-prompts (KYC & Vehicle Setup)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  children: [
                    _buildActionPrompt(
                      context,
                      title: 'Identity Verification',
                      subtitle: 'Provide BVN/NIN to unlock payouts',
                      icon: Icons.shield_outlined,
                      color: AppColors.danfoYellow,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppColors.ink,
                          builder: (context) => const DriverKYCScreen(),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionPrompt(
                      context,
                      title: 'Vehicle Inspection',
                      subtitle: 'Upload vehicle photos to start',
                      icon: Icons.directions_car_outlined,
                      color: Colors.blueAccent,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppColors.ink,
                          builder: (context) => const DriverVehicleSetupScreen(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // earnings-card
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F3A26), Color(0xFF071F13)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF0F3A26).withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 12)),
                    ],
                    border: Border.all(color: AppColors.kekeGreen.withOpacity(0.2), width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.kekeGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.account_balance_wallet, color: AppColors.kekeGreen, size: 14),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "TODAY'S NET EARNINGS",
                                style: GoogleFonts.outfit(
                                  color: AppColors.kekeGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Net of levies",
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text('₦', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 32, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "18,450",
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.5,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.only(top: 16.0),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "32 RIDES COMPLETED",
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              "Last trip: 4m ago",
                              style: GoogleFonts.outfit(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 100.ms, duration: 500.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
                ),
              ),
              
              // quick-actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        'Group', 
                        Icons.group, 
                        const Color(0xFFFACC15), const Color(0xFF422006),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DriverGroupRequestsScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildQuickAction('Book', Icons.menu_book, const Color(0xFF34D399), const Color(0xFF022C22), onTap: () {})),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        'My QR', 
                        Icons.qr_code, 
                        const Color(0xFF60A5FA), const Color(0xFF172554),
                        onTap: () {
                          TWQrBottomSheet.show(context, paymentId: 'AKIN-8472-X9');
                        },
                      ),
                    ),
                  ].animate(interval: 100.ms).fade(duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                ),
              ),
              const SizedBox(height: 24),
              
              // recent-trips
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Payments',
                          style: GoogleFonts.outfit(
                            color: AppColors.paper,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('View All', style: GoogleFonts.outfit(color: AppColors.muted, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTripItem('₦700', 'Bal: ₦18,450', 'Just now'),
                    _buildTripItem('₦300', 'Bal: ₦17,750', '2h ago'),
                    _buildTripItem('₦700', 'Bal: ₦17,450', 'Yesterday'),
                  ].animate(interval: 100.ms, delay: 200.ms).fade(duration: 400.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                ),
              ),
              const SizedBox(height: 90), // spacing for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color iconColor, Color bgColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: iconColor.withOpacity(0.2)),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label, 
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.paper, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTripItem(String amount, String balance, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.kekeGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.kekeGreen.withOpacity(0.3)),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_downward, size: 20, color: AppColors.kekeGreen),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Passenger Fare',
                    style: GoogleFonts.outfit(
                      color: AppColors.paper,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: GoogleFonts.outfit(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.kekeGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                balance,
                style: GoogleFonts.outfit(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionPrompt(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: AppColors.paper,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: AppColors.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
          ],
        ),
      ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }
}
