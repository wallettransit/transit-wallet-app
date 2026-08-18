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
import 'transaction_history_screen.dart';
import 'package:shimmer/shimmer.dart';

class PassengerWalletScreen extends ConsumerStatefulWidget {
  const PassengerWalletScreen({super.key});

  @override
  ConsumerState<PassengerWalletScreen> createState() => _PassengerWalletScreenState();
}

class _PassengerWalletScreenState extends ConsumerState<PassengerWalletScreen> {
  bool _isBalanceHidden = false;

  @override
  Widget build(BuildContext context) {
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
            // 1. Sleek Welcome Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                              child: Text(initials, style: AppTypography.bodyMedium.copyWith(color: AppColors.ink, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good morning,', style: AppTypography.label.copyWith(color: AppColors.muted)),
                            Text(fullName, style: AppTypography.bodyLarge.copyWith(color: AppColors.paper, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(Icons.notifications_none, color: AppColors.paper, size: 20),
                  ),
                ],
              ),
            ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic),
            
            Expanded(
              child: RefreshIndicator(
                color: AppColors.kekeGreen,
                backgroundColor: AppColors.cardBackground,
                onRefresh: () async {
                  ref.invalidate(walletBalanceProvider);
                  ref.invalidate(recentRidesProvider);
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 2. Glassmorphism Wallet Balance Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F3A26), Color(0xFF071F13)], // Deep elegant emerald to dark forest
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF0F3A26).withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 12)),
                          ],
                          border: Border.all(color: AppColors.kekeGreen.withOpacity(0.2), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                    Text('TRANSIT CASH', style: AppTypography.label.copyWith(color: AppColors.kekeGreen, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _isBalanceHidden = !_isBalanceHidden),
                                  child: Icon(
                                    _isBalanceHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.white54,
                                    size: 20,
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
                                  child: Text('₦', style: AppTypography.heading2.copyWith(color: Colors.white70)),
                                ),
                                const SizedBox(width: 6),
                                walletBalanceAsync.when(
                                  data: (balance) {
                                    if (_isBalanceHidden) {
                                      return Text('••••', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900));
                                    }
                                    return Text(
                                      balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                                      style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1.5),
                                    );
                                  },
                                  loading: () => Shimmer.fromColors(
                                    baseColor: Colors.white12,
                                    highlightColor: Colors.white24,
                                    child: Container(
                                      height: 48,
                                      width: 140,
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                  error: (_, __) => Text('---', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Floating Frosted Pill Buttons inside the card
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.add,
                                    label: 'Top Up',
                                    bgColor: AppColors.kekeGreen,
                                    textColor: AppColors.ink,
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PassengerTopUpScreen()));
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.qr_code_scanner,
                                    label: 'Scan to Pay',
                                    bgColor: Colors.white.withOpacity(0.1),
                                    textColor: Colors.white,
                                    border: Border.all(color: Colors.white24),
                                    onTap: () {
                                      if (isOffline) {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OfflinePaymentQrScreen()));
                                      } else {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PassengerQrScanScreen()));
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fade(delay: 100.ms, duration: 500.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 32),
                      
                      // 3. Quick Actions Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeatureCard('Group', Icons.people, const Color(0xFFFACC15), const Color(0xFF422006), () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const PassengerGroupRideHomeScreen()));
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFeatureCard('Transfer', Icons.send, const Color(0xFF60A5FA), const Color(0xFF172554), () {
                              TWTransferBottomSheet.show(context);
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFeatureCard('History', Icons.history, const Color(0xFF34D399), const Color(0xFF022C22), () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()));
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFeatureCard('Budget', Icons.pie_chart, const Color(0xFFA78BFA), const Color(0xFF2E1065), () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const PassengerBudgetScreen()));
                            }),
                          ),
                        ],
                      ).animate().fade(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1, curve: Curves.easeOutQuart),

                      const SizedBox(height: 32),
                      
                      TWUpdatesCarousel(promos: PromoData.passengerPromos).animate().fade(delay: 300.ms, duration: 500.ms).slideX(begin: 0.1, curve: Curves.easeOutQuart),

                      const SizedBox(height: 32),
                      
                      // 4. Recent Rides
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Recent Rides', style: AppTypography.heading3.copyWith(color: AppColors.paper)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const PassengerRideHistoryScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('View All', style: AppTypography.label.copyWith(color: AppColors.muted, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ).animate().fade(delay: 400.ms, duration: 400.ms),
                      
                      const SizedBox(height: 16),
                      
                      recentRidesAsync.when(
                        data: (rides) {
                          if (rides.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                                    child: const Icon(Icons.directions_car_outlined, color: Colors.white38, size: 32),
                                  ),
                                  const SizedBox(height: 16),
                                  Text('No rides yet', style: AppTypography.bodyMedium.copyWith(color: Colors.white54, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Scan a QR code to start a ride.', style: AppTypography.label.copyWith(color: Colors.white38)),
                                ],
                              ),
                            );
                          }
                          return Column(
                            children: rides.asMap().entries.map((entry) {
                              final index = entry.key;
                              final ride = entry.value;
                              return _buildRideItem(
                                '${ride['start_location'] ?? 'Unknown'} → ${ride['end_location'] ?? 'Unknown'}',
                                'Recently',
                                '₦${ride['fare']}',
                              ).animate().fade(delay: (450 + (index * 100)).ms, duration: 400.ms).slideY(begin: 0.2, curve: Curves.easeOutQuart);
                            }).toList(),
                          );
                        },
                        loading: () => Column(
                          children: List.generate(3, (index) => 
                            Shimmer.fromColors(
                              baseColor: AppColors.cardBackground,
                              highlightColor: AppColors.cardBackground.withOpacity(0.5),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            )
                          ),
                        ).animate().fade(delay: 400.ms),
                        error: (err, _) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Failed to load rides', style: AppTypography.bodySmall.copyWith(color: Colors.redAccent)),
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 90), // Spacer for floating bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color bgColor, required Color textColor, BoxBorder? border, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.label.copyWith(color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRideItem(String route, String time, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(Icons.location_on, size: 16, color: AppColors.danfoYellow),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(route, style: AppTypography.bodySmall.copyWith(color: AppColors.paper, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(time, style: AppTypography.label.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(amount, style: AppTypography.bodyLarge.copyWith(color: AppColors.kekeGreen, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String label, IconData icon, Color iconColor, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
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
            style: AppTypography.label.copyWith(fontWeight: FontWeight.bold, color: AppColors.paper),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
