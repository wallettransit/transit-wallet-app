import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_button.dart';
import 'components/tw_fare_breakdown.dart';
import 'driver_in_trip_screen.dart';

class DriverActiveGroupScreen extends StatelessWidget {
  final String pickup;
  final String destination;
  final double payout;
  final int passengerCount;

  const DriverActiveGroupScreen({
    super.key,
    required this.pickup,
    required this.destination,
    required this.payout,
    required this.passengerCount,
  });

  @override
  Widget build(BuildContext context) {
    // Mock economics calculations based on Epic rules
    final double standardFare = payout; // E.g., 12500
    final double groupDiscount = passengerCount * 300.0; // 300 discount per passenger
    final double passengerPayable = standardFare - groupDiscount;
    final double subsidy = groupDiscount; // Platform funded

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Active Group Trip',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.paper, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status Header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.danfoYellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.danfoYellow.withOpacity(0.5)),
                        ),
                        child: Text(
                          'Proceed to Pickup Location',
                          style: AppTypography.label.copyWith(
                            color: AppColors.danfoYellow,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ).animate().fade().slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Route Info
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderStroke, width: 1),
                      ),
                      child: Column(
                        children: [
                          _buildRouteLocation(Icons.my_location, AppColors.muted, pickup),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 1,
                                height: 16,
                                color: AppColors.borderStroke,
                              ),
                            ),
                          ),
                          _buildRouteLocation(Icons.location_on, AppColors.danfoYellow, destination),
                        ],
                      ),
                    ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Trip Economics',
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold),
                    ).animate().fade(delay: 200.ms),
                    const SizedBox(height: 12),
                    
                    TWFareBreakdown(
                      standardFare: standardFare,
                      groupDiscount: groupDiscount,
                      passengerPayable: passengerPayable,
                      driverPayout: payout,
                      subsidy: subsidy,
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Passengers ($passengerCount/4)',
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold),
                    ).animate().fade(delay: 400.ms),
                    const SizedBox(height: 12),
                    
                    // Passenger list unified stack
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: List.generate(passengerCount, (index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.paper.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.person, color: AppColors.paper, size: 16),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Passenger ${index + 1}',
                                        style: AppTypography.bodyMedium.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.kekeGreen.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Paid',
                                        style: AppTypography.label.copyWith(color: AppColors.kekeGreen, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (index < passengerCount - 1)
                                const Divider(height: 1, color: AppColors.borderStroke, indent: 12, endIndent: 12),
                            ],
                          ).animate().fade(delay: Duration(milliseconds: 500 + (index * 100))).slideX(begin: 0.1, end: 0);
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.ink,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: TWButton(
                label: 'Start Trip',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverInTripScreen(initialPassengerCount: passengerCount),
                    ),
                  );
                },
              ),
            ).animate().fade(delay: 600.ms).slideY(begin: 1.0, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteLocation(IconData icon, Color iconColor, String address) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            address,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.paper,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
