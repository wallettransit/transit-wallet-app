import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/ride_booking_repository.dart';
import '../../../auth/providers/auth_provider.dart';

class TripPreviewSheet extends ConsumerWidget {
  const TripPreviewSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(rideBookingProvider);
    final notifier = ref.read(rideBookingProvider.notifier);
    final user = ref.watch(authRepositoryProvider).currentUser;
    final estimate = bookingState.estimate;

    if (estimate == null) return const SizedBox.shrink();

    final isBooking = bookingState.status == BookingStatus.booking;
    final isBooked = bookingState.status == BookingStatus.booked;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
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

              if (isBooked) ...[
                // ── Booked State ───────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.kekeGreen.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle,
                            color: AppColors.kekeGreen, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ride Requested!',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Looking for a driver near you…',
                        style: AppTypography.bodySmall
                            .copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(
                        color: AppColors.kekeGreen,
                        strokeWidth: 2,
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => notifier.reset(),
                        child: Text(
                          'Cancel Ride',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.errorRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // ── Trip Preview ───────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Trip',
                            style: AppTypography.label
                                .copyWith(color: Colors.black45),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            estimate.destinationPrediction.mainText,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (estimate.destinationPrediction.secondaryText
                              .isNotEmpty)
                            Text(
                              estimate.destinationPrediction.secondaryText,
                              style: AppTypography.label
                                  .copyWith(color: Colors.black45),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => notifier.reset(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.black54),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.straighten,
                        label: 'Distance',
                        value: estimate.distanceDisplay,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.timer_outlined,
                        label: 'ETA',
                        value: estimate.durationDisplay,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.account_balance_wallet,
                        label: 'Fare',
                        value: estimate.fareDisplay,
                        color: AppColors.kekeGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Ride type picker (Keke / Danfo / Okada)
                _RideTypePicker(),

                const SizedBox(height: 20),

                // Book button
                GestureDetector(
                  onTap: isBooking
                      ? null
                      : () {
                          if (user != null) notifier.bookRide(user.id);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: isBooking
                          ? AppColors.kekeGreen.withOpacity(0.6)
                          : AppColors.kekeGreen,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.kekeGreen.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isBooking
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_taxi,
                                    color: Colors.black, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Book Ride · ${estimate.fareDisplay}',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: AppTypography.label.copyWith(color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

// ── Ride Type Picker ──────────────────────────────────────────────────────────

class _RideTypePicker extends StatefulWidget {
  @override
  State<_RideTypePicker> createState() => _RideTypePickerState();
}

class _RideTypePickerState extends State<_RideTypePicker> {
  int _selected = 0;

  final _types = [
    _RideType('Keke', Icons.electric_rickshaw, '₦50 discount'),
    _RideType('Danfo', Icons.directions_bus, 'Cheapest'),
    _RideType('Okada', Icons.two_wheeler, 'Fastest'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_types.length, (i) {
        final t = _types[i];
        final isSelected = i == _selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < _types.length - 1 ? 10 : 0),
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.kekeGreen.withOpacity(0.12)
                    : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.kekeGreen
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    t.icon,
                    color: isSelected
                        ? AppColors.kekeGreen
                        : Colors.black45,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.name,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.black87 : Colors.black45,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    t.tag,
                    style: AppTypography.label.copyWith(
                      color: isSelected
                          ? AppColors.kekeGreen
                          : Colors.black26,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _RideType {
  final String name;
  final IconData icon;
  final String tag;
  const _RideType(this.name, this.icon, this.tag);
}
