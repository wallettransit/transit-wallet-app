import '../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/components/tw_profile_avatar.dart';
import '../../../core/components/tw_qr_bottom_sheet.dart';
import '../../profile/presentation/driver_profile_screen.dart';
import '../../group_ride/presentation/driver_group_requests_screen.dart';
import '../../../core/services/audio_haptic_service.dart';

class DriverDashboardScreen extends StatelessWidget {
  final bool isPendingReview;
  
  const DriverDashboardScreen({super.key, this.isPendingReview = false});

  @override
  Widget build(BuildContext context) {
    // Note: The BottomNavigationBar is handled by DriverMainLayout,
    // so this screen only needs to render its scrollable content.
    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // top-bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        TWProfileAvatar(
                          initials: 'AK',
                          radius: 20.0,
                          onUploadTapped: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DriverProfileScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Alhaji Kehinde',
                          style: GoogleFonts.manrope(
                            color: AppTheme.paper,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 24.0 / 16,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.kekeGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.kekeGreen.withOpacity(0.5), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.kekeGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ONLINE',
                            style: GoogleFonts.manrope(
                              color: AppTheme.kekeGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 16.5 / 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              if (isPendingReview)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.danfoYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.danfoYellow.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled, color: AppTheme.danfoYellow, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your profile is under review. Some features may be restricted.',
                            style: GoogleFonts.manrope(
                              color: AppTheme.danfoYellow,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0),
                ),
              if (isPendingReview) const SizedBox(height: 12),
              
              // earnings-card
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.kekeGreen, Color(0xFF00E676)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.kekeGreen.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // card-top
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "TODAY'S NET EARNINGS",
                              style: GoogleFonts.manrope(
                                color: AppTheme.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            "Levies & fuel deducted",
                            style: GoogleFonts.manrope(
                              color: AppTheme.ink.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // card-amount
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "₦",
                            style: GoogleFonts.outfit(
                              color: AppTheme.ink,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "18,450",
                            style: GoogleFonts.manrope(
                              color: AppTheme.ink,
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // card-bottom
                      Container(
                        padding: const EdgeInsets.only(top: 8.0),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppTheme.ink, width: 1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "32 Rides Completed",
                                style: GoogleFonts.manrope(
                                  color: AppTheme.ink,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              "Last trip: 4 mins ago",
                              style: GoogleFonts.manrope(
                                color: AppTheme.ink.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack, duration: 600.ms).fade(duration: 400.ms),
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
                        AppTheme.danfoYellow, 
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DriverGroupRequestsScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildQuickAction('Book', Icons.menu_book, AppTheme.kekeGreen, onTap: () {})),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        'My QR', 
                        Icons.qr_code, 
                        AppTheme.paper, 
                        onTap: () {
                          TWQrBottomSheet.show(context, paymentId: 'AKIN-8472-X9');
                        },
                      ),
                    ),
                  ].animate(interval: 100.ms).fade(duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                ),
              ),
              const SizedBox(height: 12),
              
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
                          style: GoogleFonts.manrope(
                            color: AppTheme.muted,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 22.5 / 15,
                          ),
                        ),
                        Text(
                          'View All',
                          style: GoogleFonts.manrope(
                            color: AppTheme.kekeGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 19.5 / 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTripItem('₦700', 'Bal: ₦18,450'),
                    const SizedBox(height: 10),
                    _buildTripItem('₦300', 'Bal: ₦17,750'),
                    const SizedBox(height: 10),
                    _buildTripItem('₦700', 'Bal: ₦17,450'),
                  ].animate(interval: 100.ms, delay: 200.ms).fade(duration: 400.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                ),
              ),
              const SizedBox(height: 40), // spacing for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color iconBgColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Icon(icon, size: 28, color: AppTheme.ink),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.manrope(
                color: AppTheme.paper,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripItem(String amount, String balance) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.kekeGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_downward, size: 16, color: AppTheme.kekeGreen),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Passenger Fare',
                    style: GoogleFonts.manrope(
                      color: AppTheme.paper,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Just now',
                    style: GoogleFonts.manrope(
                      color: AppTheme.muted,
                      fontSize: 12,
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
                style: GoogleFonts.manrope(
                  color: AppTheme.paper,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 19.1 / 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                balance,
                style: GoogleFonts.manrope(
                  color: AppTheme.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 16.5 / 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
