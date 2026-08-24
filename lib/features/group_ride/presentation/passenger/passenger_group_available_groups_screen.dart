import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_profile_avatar.dart';
import '../../providers/group_ride_draft_provider.dart';
import 'passenger_group_route_setup_screen.dart';
import 'passenger_group_details_screen.dart';
import '../../data/group_ride_repository.dart';

class PassengerGroupAvailableGroupsScreen extends ConsumerWidget {
  const PassengerGroupAvailableGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableGroupsAsync = ref.watch(availableGroupRidesStreamProvider);
    final draft = ref.watch(groupRideDraftProvider);

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
                        'Groups traveling today',
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
                    draft.pickupLocation.isEmpty && draft.destination.isEmpty
                        ? 'Commutes matching your route'
                        : 'Commutes matching ${draft.pickupLocation.isNotEmpty ? draft.pickupLocation : "your route"} to ${draft.destination.isNotEmpty ? draft.destination : "your destination"}',
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
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  // Pagination not needed for stream yet  
                  return false;
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Groups Stack
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: availableGroupsAsync.when(
                          data: (groups) {
                            if (groups.isEmpty) {
                              return _buildPremiumEmptyState(context);
                            }
                            return Column(
                              children: [
                                ...groups.map((group) {
                                  final creatorName = group['users']?['full_name'] ?? 'Passenger';
                                  final groupName = group['group_name'] ?? '$creatorName\'s Group';
                                  final creatorId = group['creator_id'] ?? '';
                                  final capacity = group['capacity'] ?? 4;
                                  final joinedCount = group['joined_count'] ?? 1;
                                  final seatsLeft = capacity - joinedCount;
                                  final fare = group['fare_per_person'] ?? 0;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildGroupCard(
                                      context,
                                      groupId: group['id'],
                                      matchPercent: '95%', // Mock match for now
                                      creatorId: creatorId,
                                      groupName: groupName,
                                      creatorInitials: creatorName.substring(0, 1).toUpperCase(),
                                      creatorName: creatorName,
                                      groupType: '${capacity} Seat Group',
                                      seatsAvailable: '$seatsLeft seats left',
                                      departureTime: 'Departs Soon',
                                      originalPrice: '₦${(fare * 1.5).toStringAsFixed(0)}',
                                      groupPrice: '₦${fare.toStringAsFixed(0)}',
                                      route: '${group['pickup_location'] ?? 'Yaba'} → ${group['destination'] ?? 'Lekki'}',
                                      baseFare: (fare as num).toDouble(),
                                    ),
                                  );
                                }).toList().animate(interval: 100.ms).fade(duration: 400.ms).slideY(begin: 0.1),
                                if (availableGroupsAsync.isLoading)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(child: CircularProgressIndicator(color: AppColors.kekeGreen)),
                                  ),
                              ],
                            );
                          },
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: CircularProgressIndicator(color: AppColors.kekeGreen),
                            ),
                          ),
                          error: (err, _) => _buildErrorState(context, err.toString(), ref),
                        ),
                      ),

                    // Footer Note (only shown if not empty, handled inside empty state otherwise)
                    availableGroupsAsync.maybeWhen(
                      data: (groups) => groups.isNotEmpty 
                        ? Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const PassengerGroupRouteSetupScreen()),
                                  );
                                },
                                child: Text(
                                  "Don't see a suitable group? Create one!",
                                  style: GoogleFonts.manrope(
                                    color: AppColors.kekeGreen,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ).animate().fade(duration: 400.ms, delay: 400.ms)
                        : const SizedBox.shrink(),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
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

  Widget _buildErrorState(BuildContext context, String error, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
          const SizedBox(height: 16),
          Text(
            'Connection Error',
            style: GoogleFonts.outfit(
              color: AppColors.paper,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Could not load available group rides.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.muted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // No need to invalidate stream
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kekeGreen,
              foregroundColor: AppColors.ink,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing Icon Stack
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kekeGreen.withOpacity(0.05),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kekeGreen.withOpacity(0.15),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1500.ms),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.kekeGreen, Color(0xFF00E676)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kekeGreen.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.directions_car_filled, color: AppColors.ink, size: 30),
              ),
            ],
          ).animate().fade(duration: 500.ms).slideY(begin: 0.2),
          
          const SizedBox(height: 32),
          
          Text(
            'No Groups Found',
            style: GoogleFonts.outfit(
              color: AppColors.paper,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
          
          const SizedBox(height: 12),
          
          Text(
            'There are currently no open groups heading your way. Be the first to start one and let others join you!',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.muted,
              fontSize: 15,
              height: 1.5,
            ),
          ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
          
          const SizedBox(height: 12),
          
          Text(
            'Be the trendsetter. You pay less when others join!',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.kekeGreen,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fade(delay: 350.ms).slideY(begin: 0.2),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.kekeGreen.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // The user is starting the flow to create a group
                  // We send them to the pickup screen to define their route
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PassengerGroupRouteSetupScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kekeGreen,
                  foregroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Start a New Group Ride',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context, {
    required String groupId,
    required String creatorId,
    required String groupName,
    required String matchPercent,
    required String creatorInitials,
    required String creatorName,
    required String groupType,
    required String seatsAvailable,
    required String departureTime,
    required String originalPrice,
    required String groupPrice,
    required String route,
    required double baseFare,
  }) {
    // Determine Match Quality based on percentage string (e.g. '95%')
    final matchValue = int.tryParse(matchPercent.replaceAll('%', '')) ?? 0;
    Color badgeBgColor = AppColors.kekeGreen.withOpacity(0.15);
    Color badgeTextColor = AppColors.kekeGreen;
    String badgeText = '$matchPercent High Match';
    
    if (matchValue < 70) {
      badgeBgColor = AppColors.errorRed.withOpacity(0.15);
      badgeTextColor = AppColors.errorRed;
      badgeText = '$matchPercent Low Match';
    } else if (matchValue < 90) {
      badgeBgColor = AppColors.danfoYellow.withOpacity(0.15);
      badgeTextColor = AppColors.danfoYellow;
      badgeText = '$matchPercent Med Match';
    }

    final bool isLastSeat = seatsAvailable.contains('1 seat');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PassengerGroupDetailsScreen(
            groupId: groupId,
            creatorId: creatorId,
            groupName: groupName,
            creatorName: creatorName,
            route: route,
            baseFare: baseFare,
          )),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderStroke),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TWProfileAvatar(initials: creatorInitials, radius: 18),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: GoogleFonts.outfit(
                            color: AppColors.paper,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          groupType,
                          style: GoogleFonts.manrope(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.manrope(
                      color: badgeTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.borderStroke, height: 1),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.group_outlined, size: 14, color: isLastSeat ? AppColors.danfoYellow : AppColors.muted),
                          const SizedBox(width: 4),
                          Text(
                            seatsAvailable,
                            style: GoogleFonts.manrope(
                              color: isLastSeat ? AppColors.danfoYellow : AppColors.muted,
                              fontSize: 12,
                              fontWeight: isLastSeat ? FontWeight.bold : FontWeight.normal,
                            ),
                          ).animate(target: isLastSeat ? 1 : 0).scaleXY(begin: 1.0, end: 1.1, duration: 600.ms).then().scaleXY(begin: 1.1, end: 1.0, duration: 600.ms),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule_outlined, size: 14, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text(
                            departureTime,
                            style: GoogleFonts.manrope(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Save ₦${((baseFare * 1.5) - baseFare).toStringAsFixed(0)}! ',
                          style: GoogleFonts.manrope(
                            color: AppColors.danfoYellow,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          originalPrice,
                          style: GoogleFonts.manrope(
                            color: AppColors.muted,
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      groupPrice,
                      style: GoogleFonts.outfit(
                        color: AppColors.kekeGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
