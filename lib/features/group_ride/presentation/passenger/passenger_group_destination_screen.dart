import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_text_field.dart';
import 'passenger_group_date_time_screen.dart';
import '../../providers/group_ride_draft_provider.dart';

class PassengerGroupDestinationScreen extends ConsumerStatefulWidget {
  const PassengerGroupDestinationScreen({super.key});

  @override
  ConsumerState<PassengerGroupDestinationScreen> createState() => _PassengerGroupDestinationScreenState();
}

class _PassengerGroupDestinationScreenState extends ConsumerState<PassengerGroupDestinationScreen> {
  final TextEditingController _destinationController = TextEditingController();

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        'Where are you heading?',
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
                    'Input destination to find groups traveling the same path.',
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
                child: Column(
                  children: [
                    // Input Blocks
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Column(
                        children: [
                          TWTextField(
                            label: 'From',
                            hintText: draft.pickupLocation.isEmpty ? 'Your pickup location' : draft.pickupLocation,
                            enabled: false,
                            prefixIcon: Icon(Icons.circle, color: AppColors.kekeGreen, size: 12),
                          ),
                          const SizedBox(height: 12),
                          TWTextField(
                            controller: _destinationController,
                            label: 'To',
                            hintText: 'Enter your destination...',
                            prefixIcon: Icon(Icons.stop_circle, color: AppColors.danfoYellow, size: 14),
                            onChanged: (val) {
                              ref.read(groupRideDraftProvider.notifier).setDestination(val);
                            },
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 400.ms, delay: 100.ms),

                    // Popular Destinations
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Popular & Recent Destinations',
                            style: GoogleFonts.outfit(
                              color: AppColors.paper,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              _destinationController.text = 'Lekki Toll Gate';
                              ref.read(groupRideDraftProvider.notifier).setDestination('Lekki Toll Gate');
                            },
                            child: _buildDestItem('Lekki Toll Gate', 'Lekki-Epe Expressway, Lagos', true),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              _destinationController.text = 'Victoria Island';
                              ref.read(groupRideDraftProvider.notifier).setDestination('Victoria Island');
                            },
                            child: _buildDestItem('Victoria Island', 'Adetokunbo Ademola St', true),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              _destinationController.text = 'Ikeja Along';
                              ref.read(groupRideDraftProvider.notifier).setDestination('Ikeja Along');
                            },
                            child: _buildDestItem('Ikeja Along', 'Agege Motor Road', false),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: TWButton(
                          label: 'Proceed to Date & Time',
                          onPressed: () {
                            if (_destinationController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a destination')),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PassengerGroupDateTimeScreen()),
                            );
                          },
                        ),
                      ),
                    ).animate().fade(duration: 400.ms, delay: 300.ms),
                    const SizedBox(height: 24),
                  ],
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

  Widget _buildDestItem(String title, String subtitle, bool isPopular) {
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPopular ? AppColors.danfoYellow.withOpacity(0.15) : AppColors.highlightBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.location_on_outlined, size: 18, color: isPopular ? AppColors.danfoYellow : AppColors.paper),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: AppColors.paper,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.danfoYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'POPULAR',
                style: GoogleFonts.manrope(
                  color: AppColors.paper,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
