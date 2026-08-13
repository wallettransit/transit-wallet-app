import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import 'passenger_group_chat_screen.dart';

class PassengerGroupConfirmedScreen extends StatelessWidget {
  const PassengerGroupConfirmedScreen({super.key});

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
              child: Row(
                children: [
                  _buildIconButton(
                    icon: Icons.close,
                    onTap: () {
                      // Pop all the way back to dashboard
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.kekeGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: AppColors.kekeGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 40, color: AppColors.ink),
                      ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.elasticOut),
                    ),
                  ).animate().fade(duration: 400.ms).scale(curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 32),
                  
                  // Text Content
                  Text(
                    'Seat Confirmed!',
                    style: GoogleFonts.outfit(
                      color: AppColors.paper,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fade(duration: 400.ms, delay: 300.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: 12),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'You are officially part of Amara\'s Group Ride. Your seat is secured.',
                      style: GoogleFonts.manrope(
                        color: AppColors.muted,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fade(duration: 400.ms, delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 48),

                  // Booking Details Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderStroke),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Booking Ref', '#TW-8492-GR'),
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.borderStroke, height: 1),
                          const SizedBox(height: 16),
                          _buildDetailRow('Route', 'Yaba → Lekki Phase 1'),
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.borderStroke, height: 1),
                          const SizedBox(height: 16),
                          _buildDetailRow('Departure', 'Today, 08:15 AM'),
                        ],
                      ),
                    ).animate().fade(duration: 400.ms, delay: 500.ms).slideY(begin: 0.1),
                  ),
                ],
              ),
            ),
            
            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: TWButton(
                      label: 'Track Group Status',
                      onPressed: () {
                        // Navigate back to home for now
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TWButton(
                      label: 'Chat with Group',
                      variant: TWButtonVariant.secondary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PassengerGroupChatScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ).animate().fade(duration: 400.ms, delay: 600.ms),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: AppColors.muted,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: AppColors.paper,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
