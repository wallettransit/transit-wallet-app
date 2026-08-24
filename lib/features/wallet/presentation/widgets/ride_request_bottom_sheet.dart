import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/driver_ride_provider.dart';
import '../../../../core/components/tw_button.dart';

class RideRequestBottomSheet extends ConsumerWidget {
  final Map<String, dynamic> request;

  const RideRequestBottomSheet({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fare = request['fare_naira'] ?? 0;
    final distance = request['distance_km'] ?? 0.0;
    final duration = request['duration_minutes'] ?? 0;
    final destinationName = request['destination_name'] ?? 'Unknown Destination';
    final rideType = request['ride_type'] ?? 'Standard';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'New Ride Request',
            style: GoogleFonts.outfit(
              color: AppColors.ink,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ).animate().fade().slideY(begin: 0.2),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTIMATED FARE',
                      style: GoogleFonts.outfit(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₦$fare',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.kekeGreen,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${distance.toStringAsFixed(1)} km • $duration min',
                      style: GoogleFonts.outfit(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.kekeGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rideType.toString().toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: AppColors.kekeGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: 100.ms).fade().slideY(begin: 0.2),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.kekeGreen, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Drop-off',
                      style: GoogleFonts.outfit(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      destinationName,
                      style: GoogleFonts.outfit(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate(delay: 200.ms).fade().slideX(begin: 0.1),
          
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: TWButton(
                  label: 'Decline',
                  onPressed: () {
                    ref.read(driverRideProvider.notifier).declineRide();
                    Navigator.pop(context);
                  },
                  variant: TWButtonVariant.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: TWButton(
                  label: 'Accept Ride',
                  onPressed: () {
                    ref.read(driverRideProvider.notifier).acceptRide();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ).animate(delay: 300.ms).fade().scale(),
        ],
      ),
    );
  }
}
