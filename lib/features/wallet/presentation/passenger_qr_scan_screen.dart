import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/tw_error_handler.dart';
import '../providers/scan_provider.dart';
import 'passenger_fare_selection_screen.dart';
import 'passenger_main_layout.dart';

class PassengerQrScanScreen extends ConsumerStatefulWidget {
  const PassengerQrScanScreen({super.key});

  @override
  ConsumerState<PassengerQrScanScreen> createState() => _PassengerQrScanScreenState();
}

class _PassengerQrScanScreenState extends ConsumerState<PassengerQrScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? payload = barcodes.first.rawValue;
      if (payload != null && payload.isNotEmpty) {
        setState(() {
          _isProcessing = true;
        });
        
        final success = await ref.read(scanControllerProvider.notifier).processQrCode(payload);
        
        if (mounted) {
          if (success) {
            final scanData = ref.read(scanControllerProvider).value;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PassengerFareSelectionScreen(rideData: scanData!)),
            );
          } else {
            final error = ref.read(scanControllerProvider).error;
            TWErrorHandler.handle(context, error);
            
            // Allow scanning again after 3 seconds if error
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _isProcessing = false;
                });
              }
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Background
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),
          
          // Overlay
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const PassengerMainLayout()),
                          );
                        },
                      ),
                      Text(
                        'Scan to Pay',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flash_on, color: Colors.white),
                        onPressed: () => _cameraController.toggleTorch(),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Scan Area Frame
                Builder(
                  builder: (context) {
                    final scanSize = MediaQuery.of(context).size.width * 0.7;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: scanSize,
                          height: scanSize,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.kekeGreen, width: 2),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    // Scanning Animation Line
                    AnimatedBuilder(
                      animation: _scanController,
                      builder: (context, child) {
                        return Positioned(
                          top: 20 + (_scanController.value * (scanSize - 40)),
                          child: Container(
                            width: scanSize - 40,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.kekeGreen,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.kekeGreen.withOpacity(0.5),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack);
              },
            ),
                
                const Spacer(),
                
                // Bottom Instructions
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.kekeGreen.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.qr_code, color: AppColors.kekeGreen),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isProcessing ? 'Processing QR code...' : 'Scan Driver QR',
                              style: AppTypography.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isProcessing ? 'Please wait' : 'Point camera at the code inside the vehicle',
                              style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      if (_isProcessing)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.kekeGreen),
                          ),
                        ),
                    ],
                  ),
                ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
