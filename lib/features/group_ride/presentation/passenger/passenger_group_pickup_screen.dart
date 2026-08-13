import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import 'passenger_group_destination_screen.dart';

class PassengerGroupPickupScreen extends StatelessWidget {
  const PassengerGroupPickupScreen({super.key});

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
                        'Where are you?',
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
                    'Select your pickup point to match you with groups nearby.',
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
                    // Map Placeholder
                    Container(
                      width: double.infinity,
                      height: 280,
                      decoration: const BoxDecoration(
                        color: AppColors.cardBackground,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.map_outlined,
                              size: 100,
                              color: AppColors.borderStroke,
                            ),
                          ),
                          Positioned(
                            bottom: 24,
                            left: 24,
                            right: 24,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.ink,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.kekeGreen, width: 2),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, color: AppColors.paper, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Yaba Active Zone...',
                                      style: GoogleFonts.manrope(
                                        color: AppColors.paper,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.my_location, color: AppColors.paper, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 400.ms, delay: 100.ms),

                    // Suggested Spots
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suggested Spots Near You',
                            style: GoogleFonts.outfit(
                              color: AppColors.paper,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...[
                            'Yaba Left (Near Terminal)',
                            'Unilag Main Gate',
                            'Sabo Bus Stop',
                            'Tejuosho Market Gate'
                          ].map((spot) => Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: _buildSpotItem(spot),
                          )),
                        ],
                      ),
                    ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: TWButton(
                          label: 'Confirm Pickup Point',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PassengerGroupDestinationScreen()),
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

  Widget _buildSpotItem(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 18, color: AppColors.paper),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                color: AppColors.paper,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.muted),
        ],
      ),
    );
  }
}
