import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_text_field.dart';
import '../../../../core/components/tw_location_picker.dart';
import 'passenger_group_date_time_screen.dart';
import '../../../../core/components/tw_snackbar.dart';
import '../../providers/group_ride_draft_provider.dart';

class PassengerGroupRouteSetupScreen extends ConsumerStatefulWidget {
  const PassengerGroupRouteSetupScreen({super.key});

  @override
  ConsumerState<PassengerGroupRouteSetupScreen> createState() => _PassengerGroupRouteSetupScreenState();
}

class _PassengerGroupRouteSetupScreenState extends ConsumerState<PassengerGroupRouteSetupScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(groupRideDraftProvider.notifier).reset();
        }
      },
      child: Scaffold(
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
                          'Route Setup',
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
                      'Input your pickup and destination to find or create a group ride.',
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
                      // Interactive Map Placeholder
                      Container(
                        width: double.infinity,
                        height: 220,
                        decoration: const BoxDecoration(
                          color: AppColors.cardBackground,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.map_outlined,
                            size: 100,
                            color: AppColors.borderStroke,
                          ),
                        ),
                      ).animate().fade(duration: 400.ms, delay: 100.ms),

                      // Input Blocks
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.ink,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.borderStroke),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TWLocationPicker(
                                controller: _pickupController,
                                label: 'Pickup Location',
                                hintText: 'Enter pickup point...',
                                onChanged: (val) {
                                  ref.read(groupRideDraftProvider.notifier).setPickup(val);
                                },
                              ),
                              const SizedBox(height: 16),
                              TWTextField(
                                controller: _destinationController,
                                label: 'Destination',
                                hintText: 'Enter destination...',
                                prefixIcon: const Icon(Icons.stop_circle, color: AppColors.danfoYellow, size: 16),
                                onChanged: (val) {
                                  ref.read(groupRideDraftProvider.notifier).setDestination(val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),

                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: TWButton(
                            label: 'Proceed to Date & Time',
                            onPressed: () {
                              if (_pickupController.text.trim().isEmpty || _destinationController.text.trim().isEmpty) {
                                TWSnackbar.showError(context, 'Please enter both pickup and destination');
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
}
