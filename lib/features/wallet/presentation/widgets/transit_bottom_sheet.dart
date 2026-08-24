import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../passenger_top_up_screen.dart';
import '../passenger_qr_scan_screen.dart';
import '../offline_payment_qr_screen.dart';
import '../../../group_ride/presentation/passenger/passenger_group_ride_home_screen.dart';
import '../../../../core/components/tw_updates_carousel.dart';
import '../../../wallet/data/wallet_repository.dart';

class TransitBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback? onSearchTap;
  const TransitBottomSheet({super.key, this.onSearchTap});

  @override
  ConsumerState<TransitBottomSheet> createState() => _TransitBottomSheetState();
}

class _TransitBottomSheetState extends ConsumerState<TransitBottomSheet> {
  final DraggableScrollableController _controller = DraggableScrollableController();
  bool _isBalanceHidden = false;

  @override
  Widget build(BuildContext context) {
    final walletBalanceAsync = ref.watch(walletBalanceProvider);

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const <double>[0.15, 0.35, 0.85],
      builder: (context, scrollController) {
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              ...ScrollConfiguration.of(context).dragDevices,
              PointerDeviceKind.mouse,
            },
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // ── Wallet Card ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F3A26), Color(0xFF071F13)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F3A26).withOpacity(0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.kekeGreen.withOpacity(0.2),
                          width: 1,
                        ),
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
                                    child: const Icon(
                                      Icons.account_balance_wallet,
                                      color: AppColors.kekeGreen,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'OYAPAY WALLET',
                                    style: AppTypography.label.copyWith(
                                      color: AppColors.kekeGreen,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => setState(
                                  () => _isBalanceHidden = !_isBalanceHidden,
                                ),
                                child: Icon(
                                  _isBalanceHidden
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white54,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  '₦',
                                  style: AppTypography.heading2.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              walletBalanceAsync.when(
                                data: (balance) {
                                  if (_isBalanceHidden) {
                                    return Text(
                                      '••••',
                                      style: GoogleFonts.spaceGrotesk(
                                        color: Colors.white,
                                        fontSize: 38,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    );
                                  }
                                  final formatted = balance
                                      .toStringAsFixed(0)
                                      .replaceAllMapped(
                                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                        (m) => '${m[1]},',
                                      );
                                  return Text(
                                    formatted,
                                    style: GoogleFonts.spaceGrotesk(
                                      color: Colors.white,
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1.5,
                                    ),
                                  );
                                },
                                loading: () => Shimmer.fromColors(
                                  baseColor: Colors.white12,
                                  highlightColor: Colors.white24,
                                  child: Container(
                                    height: 42,
                                    width: 130,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                error: (_, __) => Text(
                                  '---',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Fund & Scan Buttons inside card
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const PassengerTopUpScreen(),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.kekeGreen,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.add, color: Colors.black, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Fund Wallet',
                                          style: AppTypography.label.copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const PassengerQrScanScreen(),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.qr_code_scanner, color: Colors.white, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Scan to Pay',
                                          style: AppTypography.label.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Search Bar ───────────────────────────────────────
                    GestureDetector(
                      onTap: widget.onSearchTap,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.black54),
                            const SizedBox(width: 12),
                            Text(
                              'Where to?',
                              style: AppTypography.heading3.copyWith(
                                color: Colors.black87,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Quick Actions ────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionItem(
                          context: context,
                          icon: Icons.qr_code_scanner,
                          label: 'Scan to Pay',
                          color: AppColors.kekeGreen,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const PassengerQrScanScreen())),
                        ),
                        _buildActionItem(
                          context: context,
                          icon: Icons.add_circle_outline,
                          label: 'Top Up',
                          color: Colors.blueAccent,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const PassengerTopUpScreen())),
                        ),
                        _buildActionItem(
                          context: context,
                          icon: Icons.groups_outlined,
                          label: 'Group Ride',
                          color: Colors.purpleAccent,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const PassengerGroupRideHomeScreen())),
                        ),
                        _buildActionItem(
                          context: context,
                          icon: Icons.wifi_off,
                          label: 'Offline Pay',
                          color: Colors.orangeAccent,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const OfflinePaymentQrScreen())),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── Offers & Updates ─────────────────────────────────
                    Text('Offers & Updates',
                        style: AppTypography.heading3.copyWith(color: AppColors.paper)),
                    const SizedBox(height: 16),
                    TWUpdatesCarousel(promos: PromoData.passengerPromos),

                    const SizedBox(height: 32),

                    // ── Recent Activity ──────────────────────────────────
                    Text('Recent Activity',
                        style: AppTypography.heading3.copyWith(color: AppColors.paper)),
                    const SizedBox(height: 16),
                    _buildMockActivityItem(
                        Icons.directions_car, 'Ride to Ikeja City Mall', '- ₦ 2,500', 'Today, 2:30 PM'),
                    _buildMockActivityItem(
                        Icons.account_balance_wallet, 'Top up from Bank', '+ ₦ 10,000', 'Yesterday'),
                    _buildMockActivityItem(
                        Icons.qr_code, 'Danfo Payment', '- ₦ 500', 'Mon, 9:15 AM'),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.paper,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockActivityItem(
      IconData icon, String title, String amount, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.paper, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(date,
                    style:
                        AppTypography.bodySmall.copyWith(color: Colors.black54)),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTypography.heading3.copyWith(
              color: amount.startsWith('+')
                  ? AppColors.kekeGreen
                  : AppColors.paper,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
