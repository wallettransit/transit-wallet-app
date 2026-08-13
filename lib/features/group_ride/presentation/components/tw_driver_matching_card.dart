import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_swipe_button.dart';

class TWDriverMatchingCard extends StatelessWidget {
  final String pickup;
  final String destination;
  final int passengerCount;
  final String distance;
  final String time;
  final double guaranteedPayout;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const TWDriverMatchingCard({
    super.key,
    required this.pickup,
    required this.destination,
    required this.passengerCount,
    required this.distance,
    required this.time,
    required this.guaranteedPayout,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.kekeGreen.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.kekeGreen.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top section: Urgency + Pax
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.kekeGreen,
                            shape: BoxShape.circle,
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(duration: 500.ms),
                        const SizedBox(width: 8),
                        Text(
                          'NEW REQUEST',
                          style: AppTypography.label.copyWith(
                            color: AppColors.kekeGreen,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderStroke),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.group, size: 14, color: AppColors.paper),
                          const SizedBox(width: 6),
                          Text(
                            '$passengerCount Pax',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.paper,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Massive Payout
                Text(
                  'Guaranteed Payout',
                  style: AppTypography.label.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  '₦${guaranteedPayout.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColors.paper,
                    letterSpacing: -1,
                  ),
                ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Divider(color: AppColors.borderStroke, height: 1),
                ),
                
                // Compact Route
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.my_location, size: 16, color: AppColors.muted),
                        Container(
                          width: 2,
                          height: 32,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: AppColors.borderStroke,
                        ),
                        const Icon(Icons.location_on, size: 16, color: AppColors.danfoYellow),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pickup,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.paper),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 32), // space to align with destination icon
                          Text(
                            destination,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Meta Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetaStat(Icons.route, distance),
                    _buildMetaStat(Icons.schedule, time),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Action: Swipe to Accept
                TWSwipeButton(
                  label: 'Swipe to Accept',
                  onSwipe: onAccept,
                ),
              ],
            ),
          ),
          
          // Decline Button (Top Right)
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: onDecline,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderStroke),
                ),
                child: const Icon(Icons.close, size: 16, color: AppColors.muted),
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildMetaStat(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.kekeGreen),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTypography.label.copyWith(
              color: AppColors.paper,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
