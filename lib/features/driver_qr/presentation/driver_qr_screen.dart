import '../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../driver_dashboard/presentation/driver_main_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class DriverQrScreen extends StatelessWidget {
  const DriverQrScreen({super.key});

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
                        color: AppColors.cardBackground, // asphalt
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
                        'My Passenger QR',
                        style: GoogleFonts.outfit(
                          color: AppTheme.paper,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 25.2 / 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Passengers scan this to pay instantly',
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
                      // driver-identity
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderStroke, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.danfoYellow,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Center(
                                child: Text(
                                  'AK',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.ink,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    height: 22.7 / 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Alhaji Kehinde',
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.paper,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      height: 22.7 / 18,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Oshodi → CMS (Active)',
                                    style: GoogleFonts.manrope(
                                      color: AppTheme.kekeGreen,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      height: 19.5 / 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // qr-card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: AppTheme.paper,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            // card-logo
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.directions_bus, size: 20, color: AppTheme.ink),
                                const SizedBox(width: 6),
                                Text(
                                  'TransitWallet Pay',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.ink,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    height: 17.6 / 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // qr-graphic (placeholder)
                            Builder(
                              builder: (context) {
                                final qrSize = MediaQuery.of(context).size.width * 0.55;
                                return Container(
                                  width: qrSize,
                                  height: qrSize,
                                  color: AppTheme.ink,
                                  child: Center(
                                    child: Icon(Icons.qr_code_2, size: qrSize * 0.8, color: AppTheme.paper),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // safety-text
                            Column(
                              children: [
                                Text(
                                  'PAYMENT ID: TW-819-CMS',
                                  style: GoogleFonts.manrope(
                                    color: const Color(0xFF5E5E5B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    height: 18.0 / 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Please display clearly in your vehicle for passengers',
                                  style: GoogleFonts.manrope(
                                    color: const Color(0xFF828282),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    height: 16.5 / 11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 500.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutBack),
                      const SizedBox(height: 20),
                      
                      // fare-display-row
                      Row(
                        children: [
                          Expanded(child: _buildFareBox('Short Stop', '₦300')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildFareBox('Full Route', '₦700')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // bottom-action
            Container(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const DriverMainLayout()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.kekeGreen,
                    foregroundColor: AppTheme.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.share, size: 20, color: AppTheme.ink),
                      const SizedBox(width: 8),
                      Text(
                        'Share / Download QR',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareBox(String label, String amount) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              color: AppTheme.muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 16.5 / 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.manrope(
              color: AppTheme.danfoYellow,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 24.6 / 18,
            ),
          ),
        ],
      ),
    );
  }
}
