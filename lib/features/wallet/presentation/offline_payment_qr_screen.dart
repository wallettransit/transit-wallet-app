import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';

class OfflinePaymentQrScreen extends StatelessWidget {
  const OfflinePaymentQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, this would be an encrypted payload with a timestamp
    final String offlinePayload = 'TW-OFFLINE-TX-${DateTime.now().millisecondsSinceEpoch}';

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Offline Payment',
          style: AppTypography.heading3.copyWith(color: AppColors.paper),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Alert banner
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.danfoYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.danfoYellow.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: AppColors.danfoYellow),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your network is unstable. Please hold this QR code up for your driver to scan to complete the fare deduction offline.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.danfoYellow),
                      ),
                    ),
                  ],
                ),
              ).animate().fade().slideY(begin: -0.1),
              
              const Spacer(),
              
              // QR Code
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.paper.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QrImageView(
                        data: offlinePayload,
                        version: QrVersions.auto,
                        size: 220.0,
                        backgroundColor: AppColors.paper,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.ink),
                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.ink),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Valid for 5 minutes',
                        style: AppTypography.label.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ).animate().fade(delay: 200.ms).scale(curve: Curves.easeOutBack, duration: 500.ms),
              ),
              
              const Spacer(),
              
              TWButton(
                label: 'Done',
                onPressed: () => Navigator.pop(context),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}
