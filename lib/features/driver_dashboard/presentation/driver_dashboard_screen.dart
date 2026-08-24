import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/components/tw_qr_bottom_sheet.dart';
import '../../profile/presentation/driver_profile_screen.dart';
import '../../group_ride/presentation/driver_group_requests_screen.dart';
import '../../driver/presentation/onboarding/driver_kyc_screen.dart';
import '../../driver/presentation/onboarding/driver_vehicle_setup_screen.dart';
import 'dart:ui';
import '../../wallet/presentation/widgets/ride_request_bottom_sheet.dart';
import '../../wallet/providers/driver_ride_provider.dart';
import 'driver_active_ride_screen.dart';
import '../../../features/auth/providers/auth_provider.dart';

class DriverDashboardScreen extends ConsumerStatefulWidget {
  final bool isPendingReview;
  
  const DriverDashboardScreen({super.key, this.isPendingReview = false});

  @override
  ConsumerState<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends ConsumerState<DriverDashboardScreen> {
  bool isOnline = false;
  GoogleMapController? _mapController;
  final LatLng _initialLocation = const LatLng(6.5244, 3.3792);

  void _toggleOnlineStatus(String vehicleType) {
    setState(() {
      isOnline = !isOnline;
    });

    if (isOnline) {
      ref.read(driverRideProvider.notifier).startListeningForRequests(vehicleType);
    } else {
      ref.read(driverRideProvider.notifier).stopListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.valueOrNull;
    final driverName = profile?['full_name'] as String? ?? 'Driver';
    final vehicleType = profile?['vehicle_type'] as String? ?? 'Standard';
    final initials = driverName.isNotEmpty
        ? driverName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'DR';

    ref.listen<DriverRideState>(driverRideProvider, (previous, next) {
      if (previous?.status != DriverRideStatus.reviewingRequest &&
          next.status == DriverRideStatus.reviewingRequest &&
          next.currentRequest != null) {
        showModalBottomSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          builder: (context) => RideRequestBottomSheet(request: next.currentRequest!),
        );
      }
      
      if (previous?.status == DriverRideStatus.reviewingRequest &&
          next.status == DriverRideStatus.idle) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      }

      if (previous?.status != DriverRideStatus.enRouteToPickup &&
          next.status == DriverRideStatus.enRouteToPickup) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DriverActiveRideScreen()),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Map
          Positioned.fill(
            child: _buildMap(),
          ),

          // Top Floating Elements
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(initials, driverName, vehicleType),
                if (widget.isPendingReview) _buildPendingReviewBanner(),
              ],
            ),
          ),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.2,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5)),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          // Drag Handle
                          Container(
                            width: 48,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Quick Actions
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              children: [
                                Expanded(child: _buildQuickAction('Group', Icons.group, const Color(0xFFD97706), const Color(0xFFFEF3C7), onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverGroupRequestsScreen()));
                                })),
                                const SizedBox(width: 12),
                                Expanded(child: _buildQuickAction('Book', Icons.menu_book, const Color(0xFF059669), const Color(0xFFD1FAE5), onTap: () {})),
                                const SizedBox(width: 12),
                                Expanded(child: _buildQuickAction('My QR', Icons.qr_code, const Color(0xFF2563EB), const Color(0xFFDBEAFE), onTap: () {
                                  TWQrBottomSheet.show(context, paymentId: 'AKIN-8472-X9');
                                })),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Action Prompts
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: [
                                _buildActionPrompt(
                                  context,
                                  title: 'Identity Verification',
                                  subtitle: 'Provide BVN/NIN to unlock payouts',
                                  icon: Icons.shield_outlined,
                                  color: const Color(0xFFD97706),
                                  bgColor: const Color(0xFFFEF3C7),
                                  onTap: () {
                                    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, builder: (context) => const DriverKYCScreen());
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildActionPrompt(
                                  context,
                                  title: 'Vehicle Inspection',
                                  subtitle: 'Upload vehicle photos to start',
                                  icon: Icons.directions_car_outlined,
                                  color: const Color(0xFF2563EB),
                                  bgColor: const Color(0xFFDBEAFE),
                                  onTap: () {
                                    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, builder: (context) => const DriverVehicleSetupScreen());
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Recent Trips
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                  Text('Recent Trips', style: GoogleFonts.outfit(color: AppColors.paper, fontSize: 18, fontWeight: FontWeight.w700)),
                                    Text('View All', style: GoogleFonts.outfit(color: AppColors.kekeGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildTripItem('₦700', 'Bal: ₦18,450', 'Just now'),
                                _buildTripItem('₦300', 'Bal: ₦17,750', '2h ago'),
                                _buildTripItem('₦700', 'Bal: ₦17,450', 'Yesterday'),
                                const SizedBox(height: 90), // Bottom nav padding
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialLocation,
            zoom: 14.5,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            // Removed dark mode map styling
          },
        ),
        // Center pin overlay
        IgnorePointer(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Text('Current Location', style: GoogleFonts.outfit(color: AppColors.paper, fontSize: 12, fontWeight: FontWeight.bold)),
                ).animate().fade().slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.kekeGreen.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        color: isOnline ? AppColors.kekeGreen : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(String initials, String driverName, String vehicleType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverProfileScreen()));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  padding: const EdgeInsets.only(right: 16, top: 4, bottom: 4, left: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(color: AppColors.danfoYellow, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text(initials, style: GoogleFonts.outfit(color: AppColors.paper, fontWeight: FontWeight.w900, fontSize: 15)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '₦18,450',
                        style: GoogleFonts.spaceGrotesk(color: AppColors.paper, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Online Toggle
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _toggleOnlineStatus(vehicleType);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.kekeGreen : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isOnline ? Icons.check_circle : Icons.power_settings_new, color: isOnline ? Colors.white : Colors.grey[600], size: 18),
                      const SizedBox(width: 8),
                      Text(
                        isOnline ? 'ONLINE' : 'GO ONLINE',
                        style: GoogleFonts.outfit(
                          color: isOnline ? Colors.white : Colors.grey[600],
                          fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildPendingReviewBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7), // Light yellow
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time_filled, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your profile is under review. Features restricted.',
                  style: GoogleFonts.outfit(color: const Color(0xFFB45309), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildQuickAction(String label, IconData icon, Color iconColor, Color bgColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.paper, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTripItem(String amount, String balance, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Icon(Icons.arrow_downward, size: 20, color: Color(0xFF059669))),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Passenger Fare', style: GoogleFonts.outfit(color: AppColors.paper, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(time, style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: GoogleFonts.spaceGrotesk(color: AppColors.kekeGreen, fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(balance, style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionPrompt(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required Color bgColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(color: AppColors.paper, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}
