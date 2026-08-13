import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import 'passenger_group_payment_screen.dart';
import '../../providers/group_ride_draft_provider.dart';

class PassengerGroupCreateScreen extends ConsumerStatefulWidget {
  const PassengerGroupCreateScreen({super.key});

  @override
  ConsumerState<PassengerGroupCreateScreen> createState() => _PassengerGroupCreateScreenState();
}

class _PassengerGroupCreateScreenState extends ConsumerState<PassengerGroupCreateScreen> {
  int _capacity = 4;
  double _fare = 384.0;

  @override
  Widget build(BuildContext context) {
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
                        'Create Group Ride',
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
                    'Set the capacity and fare to invite fellow commuters to join you.',
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Capacity Selector
                      Text(
                        'Total Capacity (including you)',
                        style: GoogleFonts.outfit(
                          color: AppColors.paper,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderStroke),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCircleButton(
                              icon: Icons.remove,
                              onTap: () {
                                if (_capacity > 2) setState(() => _capacity--);
                              },
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$_capacity',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.kekeGreen,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    'Seats',
                                    style: GoogleFonts.manrope(
                                      color: AppColors.muted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _buildCircleButton(
                              icon: Icons.add,
                              onTap: () {
                                if (_capacity < 18) setState(() => _capacity++);
                              },
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1),

                      const SizedBox(height: 32),

                      // Fare Selector
                      Text(
                        'Fare per Person',
                        style: GoogleFonts.outfit(
                          color: AppColors.paper,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderStroke),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildCircleButton(
                                  icon: Icons.remove,
                                  onTap: () {
                                    if (_fare > 50) setState(() => _fare -= 50);
                                  },
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '₦',
                                        style: GoogleFonts.outfit(
                                          color: AppColors.kekeGreen,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _fare.toStringAsFixed(0),
                                      style: GoogleFonts.outfit(
                                        color: AppColors.paper,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                _buildCircleButton(
                                  icon: Icons.add,
                                  onTap: () {
                                    if (_fare < 5000) setState(() => _fare += 50);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.highlightBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 16, color: AppColors.muted),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Suggested fare based on typical route pricing.',
                                      style: GoogleFonts.manrope(
                                        color: AppColors.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),

                      const SizedBox(height: 48),

                      SizedBox(
                        width: double.infinity,
                        child: TWButton(
                          label: 'Review & Pay',
                          icon: Icons.arrow_forward_ios,
                          onPressed: () {
                            // Save to draft state
                            ref.read(groupRideDraftProvider.notifier).setCapacity(_capacity);
                            ref.read(groupRideDraftProvider.notifier).setFare(_fare);
                            
                            // Navigate to payment
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PassengerGroupPaymentScreen()),
                            );
                          },
                        ),
                      ).animate().fade(duration: 400.ms, delay: 300.ms),
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

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.highlightBackground,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.paper, size: 20),
      ),
    );
  }
}
