import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'passenger_top_up_screen.dart';
import 'passenger_qr_scan_screen.dart';
import 'passenger_ride_history_screen.dart';
import '../../profile/presentation/passenger_profile_screen.dart';
import '../../../core/components/tw_logo.dart';
import '../../group_ride/presentation/passenger/passenger_group_ride_home_screen.dart';
import '../../../../core/components/tw_transfer_bottom_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/network_provider.dart';
import 'offline_payment_qr_screen.dart';

class PassengerWalletScreen extends ConsumerWidget {
  const PassengerWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(offlineStateProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.borderStroke.withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home_filled, 'Home', true, () {}),
                _buildNavItem(Icons.qr_code_scanner, 'Scan to Pay', false, () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PassengerQrScanScreen()));
                }),
                _buildNavItem(Icons.history, 'History', false, () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PassengerRideHistoryScreen()));
                }),
              ],
            ),
          ),
        ),
      ),
          ),
        ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PassengerProfileScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 38,
                              height: 38,
                              child: CircularProgressIndicator(
                                value: 0.6,
                                color: AppColors.kekeGreen,
                                backgroundColor: AppColors.kekeGreen.withOpacity(0.2),
                                strokeWidth: 2,
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.danfoYellow,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text('AO', style: AppTypography.label.copyWith(color: AppColors.ink, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back', style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
                            Text('Amara Okafor', style: AppTypography.bodyMedium.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TWLogo(size: 16, textColor: AppColors.paper),
                ],
              ),
            ).animate().fade().slideY(begin: -0.2, end: 0),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Balance Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.kekeGreen, Color(0xFF00E676)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.kekeGreen.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'YOUR WALLET BALANCE',
                                  style: AppTypography.label.copyWith(color: AppColors.ink, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('Transit Cash', style: AppTypography.label.copyWith(color: AppColors.ink, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('₦', style: AppTypography.heading1.copyWith(color: AppColors.ink, fontSize: 24)),
                              const SizedBox(width: 4),
                              Text('4,850', style: AppTypography.heading1.copyWith(color: AppColors.ink, fontSize: 36, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.account_balance_wallet,
                                  label: 'Top Up',
                                  color: AppColors.kekeGreen,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const PassengerTopUpScreen()),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.qr_code_scanner,
                                  label: 'Scan to Pay',
                                  color: AppColors.danfoYellow,
                                  onTap: () {
                                    if (isOffline) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const OfflinePaymentQrScreen()),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const PassengerQrScanScreen()),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard('Group', Icons.people, AppColors.danfoYellow, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PassengerGroupRideHomeScreen()),
                            );
                          }),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureCard('Book', Icons.menu_book, AppColors.kekeGreen, () {}),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureCard('Transfer', Icons.send, AppColors.paper, () {
                            TWTransferBottomSheet.show(context);
                          }),
                        ),
                      ],
                    ).animate().fade(delay: 150.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),
                    
                    // Recent Rides
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Rides', style: AppTypography.bodyMedium.copyWith(color: AppColors.muted, fontWeight: FontWeight.bold)),
                        Text('View All', style: AppTypography.bodySmall.copyWith(color: AppColors.kekeGreen, fontWeight: FontWeight.bold)),
                      ],
                    ).animate().fade(delay: 200.ms),
                    
                    const SizedBox(height: 12),
                    
                    _buildRideItem('Oshodi → CMS', 'Today, 09:37 AM', '₦350').animate().fade(delay: 300.ms).slideX(begin: 0.1, end: 0),
                    _buildRideItem('CMS → Lekki', 'Yesterday, 06:15 PM', '₦500').animate().fade(delay: 400.ms).slideX(begin: 0.1, end: 0),
                    _buildRideItem('Ikeja → Oshodi', '24 Jan, 08:20 AM', '₦700').animate().fade(delay: 500.ms).slideX(begin: 0.1, end: 0),
                    
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 80), // Spacer for floating bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.label.copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRideItem(String route, String time, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.kekeGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_bus, size: 14, color: AppColors.ink),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(route, style: AppTypography.bodySmall.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
                  Text(time, style: AppTypography.label.copyWith(color: AppColors.muted)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(amount, style: AppTypography.bodyMedium.copyWith(color: AppColors.paper, fontWeight: FontWeight.w800)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Re-ride action
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.kekeGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.kekeGreen.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.replay, size: 12, color: AppColors.kekeGreen),
                      const SizedBox(width: 4),
                      Text('Ride Again', style: AppTypography.label.copyWith(color: AppColors.kekeGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.ink, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.paper)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kekeGreen.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.kekeGreen : AppColors.muted,
            ).animate(target: isSelected ? 1 : 0).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 200.ms,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  color: AppColors.kekeGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fade(duration: 200.ms).slideX(begin: 0.2, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}
