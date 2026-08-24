import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_profile_avatar.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../wallet/data/wallet_repository.dart';
import '../../data/driver_repository.dart';
import '../../../../core/components/tw_updates_carousel.dart';
import '../../../group_ride/data/group_ride_repository.dart';
import '../../../../core/components/tw_snackbar.dart';
import '../../../../core/components/tw_skeleton_loader.dart';
import 'driver_help_screen.dart';

class DriverDashboardScreen extends ConsumerStatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  ConsumerState<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends ConsumerState<DriverDashboardScreen> {
  bool _isCashOutLoading = false;
  bool _isBalanceHidden = false;

  void _handleCashOut() async {
    setState(() => _isCashOutLoading = true);
    
    // Simulate API call for v0
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isCashOutLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cash out successful! Funds sent to your linked account.',
            style: GoogleFonts.manrope(color: AppColors.paper),
          ),
          backgroundColor: AppColors.kekeGreen,
        ),
      );
      // In a real app, we would refresh the wallet balance here
      ref.invalidate(walletBalanceProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final balanceAsync = ref.watch(walletBalanceProvider);

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: user == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.kekeGreen))
            : FutureBuilder<Map<String, dynamic>?>(
                future: ref.read(driverRepositoryProvider).getActiveDriverProfile(user.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.kekeGreen));
                  }
                  
                  final profile = snapshot.data;
                  if (profile == null) {
                    return const Center(child: Text('Driver profile not found.', style: TextStyle(color: Colors.white)));
                  }

                  // Extract data carefully from the Supabase response
                  final vehicleType = profile['vehicle_type'] ?? 'Vehicle';
                  final plateNumber = profile['plate_number'] ?? 'Unknown';
                  final routes = profile['routes'] as List?;
                  final activeRoute = routes != null && routes.isNotEmpty ? routes.first : null;
                  final origin = activeRoute != null ? activeRoute['origin'] : 'Unknown';
                  final destination = activeRoute != null ? activeRoute['destination'] : 'Unknown';
                  
                  final driverCodes = activeRoute != null ? activeRoute['driver_codes'] as List? : null;
                  final qrPayload = (driverCodes != null && driverCodes.isNotEmpty) 
                      ? driverCodes.first['qr_payload'] 
                      : 'NO_QR_DATA';

                  return RefreshIndicator(
                    color: AppColors.kekeGreen,
                    backgroundColor: AppColors.ink,
                    onRefresh: () async {
                      ref.invalidate(walletBalanceProvider);
                      setState(() {});
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Driver Dashboard',
                                      style: GoogleFonts.outfit(
                                        color: AppColors.paper,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$origin → $destination',
                                      style: GoogleFonts.manrope(
                                        color: AppColors.kekeGreen,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Help Icon with Pill
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const DriverHelpScreen()),
                                        );
                                      },
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.ink, // Using ink instead of cardBackground for contrast on driver dashboard
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white10),
                                            ),
                                            child: const Icon(Icons.headset_mic_outlined, color: AppColors.paper, size: 20),
                                          ),
                                          Positioned(
                                            top: -4,
                                            right: -4,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.errorRed.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'HELP',
                                                style: GoogleFonts.manrope(
                                                  color: AppColors.errorRed,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const TWProfileAvatar(
                                      initials: 'DR',
                                      imageUrl: null, // Fallback to placeholder
                                      radius: 24,
                                    ),
                                  ],
                                ),
                              ],
                            ).animate().fade().slideY(begin: -0.1),

                            const SizedBox(height: 32),

                            TWUpdatesCarousel(promos: PromoData.driverPromos).animate().fade(delay: 150.ms).slideY(begin: 0.1),

                            const SizedBox(height: 32),

                            // Earnings Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.kekeGreen, Color(0xFF00C853)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.kekeGreen.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Today\'s Earnings',
                                        style: GoogleFonts.manrope(
                                          color: AppColors.ink,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () => setState(() => _isBalanceHidden = !_isBalanceHidden),
                                        child: Icon(
                                          _isBalanceHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.ink.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Active',
                                          style: GoogleFonts.outfit(
                                            color: AppColors.ink,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  balanceAsync.when(
                                    data: (balance) {
                                      if (_isBalanceHidden) {
                                        return Text(
                                          '••••',
                                          style: GoogleFonts.outfit(
                                            color: AppColors.ink,
                                            fontSize: 40,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        );
                                      }
                                      return Text(
                                        '₦${balance.toStringAsFixed(0)}',
                                        style: GoogleFonts.outfit(
                                          color: AppColors.ink,
                                          fontSize: 40,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      );
                                    },
                                    loading: () => const TWSkeletonLoader(width: 120, height: 40, borderRadius: 8),
                                    error: (_, __) => Text(
                                      'Error loading',
                                      style: GoogleFonts.outfit(color: AppColors.ink, fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isCashOutLoading ? null : _handleCashOut,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.ink,
                                        foregroundColor: AppColors.kekeGreen,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: _isCashOutLoading
                                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.kekeGreen, strokeWidth: 2))
                                          : Text(
                                              'Cash Out Now',
                                              style: GoogleFonts.outfit(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

                            const SizedBox(height: 32),

                            // Code Display
                            Text(
                              'Your Vehicle Code',
                              style: GoogleFonts.outfit(
                                color: AppColors.paper,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ).animate().fade(delay: 300.ms),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.ink,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.borderStroke),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: QrImageView(
                                      data: qrPayload,
                                      version: QrVersions.auto,
                                      size: 200.0,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            plateNumber,
                                            style: GoogleFonts.outfit(
                                              color: AppColors.paper,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${vehicleType.toString().toUpperCase()} • ID: ${qrPayload.substring(0, 8)}...',
                                            style: GoogleFonts.manrope(
                                              color: AppColors.muted,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.highlightBackground,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.print_outlined, color: AppColors.kekeGreen),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Printing functionality coming soon...')),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ).animate().fade(delay: 400.ms).slideY(begin: 0.1),

                            const SizedBox(height: 32),

                            // Available Rides (Realtime)
                            Text(
                              'Available Group Rides',
                              style: GoogleFonts.outfit(
                                color: AppColors.paper,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ).animate().fade(delay: 500.ms),
                            const SizedBox(height: 16),
                            Consumer(
                              builder: (context, ref, child) {
                                final ridesAsync = ref.watch(availableGroupRidesStreamProvider);
                                return ridesAsync.when(
                                  data: (rides) {
                                    if (rides.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                                          child: Text(
                                            'No open rides at the moment.',
                                            style: GoogleFonts.manrope(
                                              color: AppColors.muted,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: rides.length,
                                      itemBuilder: (context, index) {
                                        final ride = rides[index];
                                        return _DriverRideCard(ride: ride, driverId: user.id);
                                      },
                                    );
                                  },
                                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.kekeGreen)),
                                  error: (err, st) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
                                );
                              },
                            ).animate().fade(delay: 600.ms),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _DriverRideCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> ride;
  final String driverId;

  const _DriverRideCard({required this.ride, required this.driverId});

  @override
  ConsumerState<_DriverRideCard> createState() => _DriverRideCardState();
}

class _DriverRideCardState extends ConsumerState<_DriverRideCard> {
  bool _isAccepting = false;

  void _acceptRide() async {
    setState(() => _isAccepting = true);
    final repo = ref.read(groupRideRepositoryProvider);
    final res = await repo.acceptGroupRide(
      groupId: widget.ride['id'],
      driverId: widget.driverId,
    );
    if (mounted) {
      setState(() => _isAccepting = false);
      if (res['success'] == true) {
        TWSnackbar.showSuccess(context, 'Ride Accepted! Drive safe.');
      } else {
        TWSnackbar.showError(context, 'Failed: ${res['message']}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = widget.ride['pickup_location'] ?? 'Unknown';
    final destination = widget.ride['destination'] ?? 'Unknown';
    final fare = widget.ride['fare_per_person'] ?? 0;
    final capacity = widget.ride['capacity'] ?? 4;
    final joined = widget.ride['joined_count'] ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$pickup → $destination',
                  style: GoogleFonts.outfit(color: AppColors.paper, fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.kekeGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$joined/$capacity',
                  style: GoogleFonts.manrope(color: AppColors.kekeGreen, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₦$fare per person',
            style: GoogleFonts.manrope(color: AppColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: TWButton(
              label: 'Accept Ride',
              onPressed: _isAccepting ? () {} : _acceptRide,
              isLoading: _isAccepting,
            ),
          ),
        ],
      ),
    );
  }
}

