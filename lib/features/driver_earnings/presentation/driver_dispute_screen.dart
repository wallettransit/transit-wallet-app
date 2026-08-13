import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';

class DriverDisputeScreen extends StatelessWidget {
  const DriverDisputeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: SafeArea(
        child: Column(
          children: [
            // screen-header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderStroke, width: 1),
                      ),
                      child: const Icon(Icons.arrow_back, color: AppTheme.paper, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fare Dispute',
                        style: GoogleFonts.outfit(
                          color: AppTheme.paper,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 25.2 / 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Review passenger reversal request',
                        style: GoogleFonts.manrope(
                          color: AppTheme.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 19.5 / 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // dispute-card
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.errorRed, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // card-header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorRed.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.errorRed),
                                      const SizedBox(width: 6),
                                      Text(
                                        'REVERSAL REQUEST',
                                        style: GoogleFonts.manrope(
                                          color: AppColors.errorRed,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          height: 16.5 / 11,
                                        ),
                                      ),
                                    ],
                                  ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: 2500.ms, color: AppColors.errorRed.withOpacity(0.5)),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 14, color: AppTheme.danfoYellow),
                                    const SizedBox(width: 4),
                                    Text(
                                      '02:45 remaining',
                                      style: GoogleFonts.manrope(
                                        color: AppTheme.danfoYellow,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        height: 18.0 / 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // ride-details
                            _buildDetailRow('Passenger Name', 'Chinedu Okafor', AppTheme.paper, isBold: true),
                            const SizedBox(height: 12),
                            _buildDetailRow('Fare Charged', '₦700', AppTheme.danfoYellow, isExtraBold: true),
                            const SizedBox(height: 12),
                            _buildDetailRow('Route Taken', 'Oshodi → CMS', AppTheme.paper, isBold: true),
                            const SizedBox(height: 12),
                            _buildDetailRow('Time Logged', '09:14 AM (Today)', AppTheme.paper, isBold: true),
                            const SizedBox(height: 16),
                            
                            // reason-box
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Passenger's Claim",
                                  style: GoogleFonts.manrope(
                                    color: AppTheme.muted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    height: 18.0 / 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '"Driver accidentally scanned me twice at the park for full route."',
                                  style: GoogleFonts.manrope(
                                    color: AppTheme.paper,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 19.5 / 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), curve: Curves.easeOutBack, duration: 600.ms).fade(duration: 400.ms),
                      const SizedBox(height: 20),
                      
                      Text(
                        'Note: Unanswered reversal requests automatically approve when the countdown timer expires to maintain trust in the park.',
                        style: GoogleFonts.manrope(
                          color: AppTheme.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 18.0 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // dispute-actions
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.highlightBackground,
                        foregroundColor: AppTheme.paper,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.close, size: 20, color: AppTheme.paper),
                          const SizedBox(width: 8),
                          Text(
                            'Decline Dispute',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 20.2 / 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorRed,
                        foregroundColor: AppTheme.paper,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.swap_horiz, size: 20, color: AppTheme.paper),
                          const SizedBox(width: 8),
                          Text(
                            'Confirm Reversal (Refund)',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 20.2 / 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor, {bool isBold = false, bool isExtraBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: AppTheme.muted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 19.5 / 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            color: valueColor,
            fontSize: 14,
            fontWeight: isExtraBold ? FontWeight.w800 : (isBold ? FontWeight.w700 : FontWeight.w500),
            height: isExtraBold ? (19.1 / 14) : (21.0 / 14),
          ),
        ),
      ],
    );
  }
}
