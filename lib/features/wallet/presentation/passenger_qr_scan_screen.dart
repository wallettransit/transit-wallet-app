import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'passenger_fare_selection_screen.dart';
import 'passenger_wallet_screen.dart';
import 'passenger_ride_history_screen.dart';

class PassengerQrScanScreen extends StatefulWidget {
  const PassengerQrScanScreen({super.key});

  @override
  State<PassengerQrScanScreen> createState() => _PassengerQrScanScreenState();
}

class _PassengerQrScanScreenState extends State<PassengerQrScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Simulate finding a QR code after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PassengerFareSelectionScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Scan Driver QR', style: AppTypography.bodyLarge.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const PassengerWalletScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('Cancel', style: AppTypography.label.copyWith(color: AppColors.muted)),
                    ),
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: -0.2, end: 0),
            
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Camera Viewport Mock
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.kekeGreen, width: 3),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.qr_code_scanner, size: 80, color: AppColors.muted),
                        AnimatedBuilder(
                          animation: _scanController,
                          builder: (context, child) {
                            return Positioned(
                              top: 200 * _scanController.value,
                              child: Container(
                                width: 180,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: AppColors.kekeGreen,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.kekeGreen.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
                  
                  const SizedBox(height: 32),
                  
                  // Instruction Area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          "Point at the driver's code",
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ).animate().fade(delay: 400.ms),
                        const SizedBox(height: 8),
                        Text(
                          "Hold your phone steady in front of the printed QR code displayed on the driver's dashboard or windshield.",
                          style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
                          textAlign: TextAlign.center,
                        ).animate().fade(delay: 500.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

}
