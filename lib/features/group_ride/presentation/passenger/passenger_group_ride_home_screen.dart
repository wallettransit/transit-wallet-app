import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../wallet/presentation/passenger_qr_scan_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import 'passenger_group_available_groups_screen.dart';
import '../../../../core/components/tw_logo.dart';
import '../../../wallet/data/ride_repository.dart';
import '../../providers/group_ride_draft_provider.dart';

class PassengerGroupRideHomeScreen extends ConsumerWidget {
  const PassengerGroupRideHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentRidesAsync = ref.watch(recentRidesProvider);
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const TWLogo(size: 20, textColor: AppColors.paper),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.kekeGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green[700],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'NG',
                                  style: GoogleFonts.manrope(
                                    color: AppColors.kekeGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 400.ms).slideY(begin: -0.1),

                    // Hero Zone
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: AppColors.paper, // Dark background
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.kekeGreen.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.danfoYellow,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'SAVE UP TO 60%',
                                style: GoogleFonts.manrope(
                                  color: AppColors.ink,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Go Together.\nPay Lesser.',
                              style: GoogleFonts.outfit(
                                color: AppColors.ink,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Book a group ride with fellow commuters heading your way.',
                              style: GoogleFonts.manrope(
                                color: AppColors.ink.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: TWButton(
                                label: 'Create or Join a Group Ride',
                                icon: Icons.add,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const PassengerGroupAvailableGroupsScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 400.ms, delay: 100.ms).scale(curve: Curves.easeOutBack),
                    ),

                    // Recent Rides
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Recent Routes',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.paper,
                            ),
                          ),
                          const SizedBox(height: 16),
                          recentRidesAsync.when(
                            data: (rides) {
                              if (rides.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Text(
                                      'No recent routes yet. Create your first group ride!',
                                      style: GoogleFonts.manrope(color: AppColors.muted),
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                children: rides.take(3).map((ride) {
                                  final pickup = ride['start_location'] ?? 'Unknown';
                                  final destination = ride['end_location'] ?? 'Unknown';
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        ref.read(groupRideDraftProvider.notifier)
                                          ..setPickup(pickup)
                                          ..setDestination(destination);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const PassengerGroupAvailableGroupsScreen()),
                                        );
                                      },
                                      child: _buildRecentRouteCard(
                                        icon: Icons.directions_bus_filled_outlined,
                                        iconBg: AppColors.kekeGreen.withOpacity(0.1),
                                        iconColor: AppColors.kekeGreen,
                                        routeText: '$pickup → $destination',
                                        subText: 'Recently traveled',
                                        price: '₦${ride['fare']}',
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.kekeGreen)),
                            error: (err, _) => Text('Error loading routes: $err', style: const TextStyle(color: Colors.red)),
                          ),
                        ].animate(interval: 50.ms, delay: 200.ms).fade(duration: 400.ms).slideY(begin: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRouteCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String routeText,
    required String subText,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routeText,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.paper,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subText,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.kekeGreen,
            ),
          ),
        ],
      ),
    );
  }
}
