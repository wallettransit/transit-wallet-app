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
import '../../auth/providers/auth_provider.dart';
import '../data/wallet_repository.dart';
import '../data/ride_repository.dart';
import '../../budget/presentation/passenger_budget_screen.dart';
import '../../../core/components/tw_coming_soon_screen.dart';
import 'offline_payment_qr_screen.dart';
import '../../../../core/components/tw_updates_carousel.dart';

class PassengerWalletScreen extends ConsumerWidget {
  const PassengerWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(offlineStateProvider);
    final currentUser = ref.watch(authRepositoryProvider).currentUser;
    final walletBalanceAsync = ref.watch(walletBalanceProvider);
    final recentRidesAsync = ref.watch(recentRidesProvider);
    
    final metadata = currentUser?.userMetadata ?? {};
    final fullName = metadata['full_name'] as String? ?? 'Passenger';
    
    String initials = 'P';
    if (fullName.isNotEmpty && fullName != 'Passenger') {
      final parts = fullName.split(' ');
      if (parts.length > 1 && parts[1].isNotEmpty) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = fullName.substring(0, 1).toUpperCase();
      }
    }

    return Scaffold(
      backgroundColor: AppColors.ink,
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
                              child: Text(initials, style: AppTypography.label.copyWith(color: AppColors.ink, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back', style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
                            Text(fullName, style: AppTypography.bodyMedium.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
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
                              walletBalanceAsync.when(
                                data: (balance) => Text(
                                  balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                                  style: AppTypography.heading1.copyWith(color: AppColors.ink, fontSize: 36, fontWeight: FontWeight.w800),
                                ),
                                loading: () => const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: AppColors.ink, strokeWidth: 3),
                                ),
                                error: (_, __) => Text('---', style: AppTypography.heading1.copyWith(color: AppColors.ink, fontSize: 36, fontWeight: FontWeight.w800)),
                              ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildFeatureCard('Group', Icons.people, AppColors.danfoYellow, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PassengerGroupRideHomeScreen()),
                              );
                            }),
                          ),
                          Expanded(
                            child: _buildFeatureCard('Book', Icons.menu_book, AppColors.kekeGreen, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TWComingSoonScreen(
                                    title: 'Book a Ride',
                                    featureName: 'ride booking',
                                    icon: Icons.menu_book,
                                  ),
                                ),
                              );
                            }),
                          ),
                          Expanded(
                            child: _buildFeatureCard('Transfer', Icons.send, AppColors.paper, () {
                              TWTransferBottomSheet.show(context);
                            }),
                          ),
                          Expanded(
                            child: _buildFeatureCard('Budget', Icons.account_balance_wallet, AppColors.paper, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PassengerBudgetScreen()),
                              );
                            }),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 150.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 32),
                    
                    TWUpdatesCarousel(promos: PromoData.passengerPromos).animate().fade(delay: 180.ms).slideX(begin: 0.1, end: 0),

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
                    
                    recentRidesAsync.when(
                      data: (rides) {
                        if (rides.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text('No recent rides', style: AppTypography.bodyMedium.copyWith(color: AppColors.muted)),
                            ),
                          );
                        }
                        return Column(
                          children: rides.map((ride) => _buildRideItem(
                            '${ride['start_location'] ?? 'Unknown'} → ${ride['end_location'] ?? 'Unknown'}',
                            'Recently',
                            '₦${ride['fare']}',
                          )).toList(),
                        ).animate().fade(delay: 300.ms).slideX(begin: 0.1, end: 0);
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator(color: AppColors.kekeGreen)),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Failed to load rides', style: AppTypography.bodySmall.copyWith(color: Colors.red)),
                      ),
                    ),
                    
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.ink.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.paper),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.label.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
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

  Widget _buildFeatureCard(String label, IconData icon, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.highlightBackground,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: iconColor == AppColors.paper ? AppColors.paper : iconColor, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label, 
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.paper),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
