import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TWQrBottomSheet extends StatelessWidget {
  final String paymentId;

  const TWQrBottomSheet({
    super.key,
    required this.paymentId,
  });

  static void show(BuildContext context, {required String paymentId}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TWQrBottomSheet(paymentId: paymentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Handle bar
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.muted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate().fade().slideY(begin: 1.0, end: 0),
          const SizedBox(height: 32),
          
          Text(
            'Scan to Pay',
            style: AppTypography.heading2.copyWith(color: AppColors.paper),
          ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          
          Text(
            'Passengers can scan this QR code to instantly transfer fares.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ).animate().fade(delay: 150.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 40),
          
          // QR Code Graphic Placeholder
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.paper.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: QrImageView(
                data: paymentId,
                version: QrVersions.auto,
                size: 150.0,
                backgroundColor: AppColors.paper,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.ink),
                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.ink),
              ),
            ),
          ).animate().fade(delay: 200.ms).scale(curve: Curves.easeOutBack, duration: 500.ms),
          
          const SizedBox(height: 40),
          
          // Payment ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderStroke, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAYMENT ID',
                      style: AppTypography.label.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paymentId,
                      style: AppTypography.heading3.copyWith(
                        color: AppColors.kekeGreen,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: paymentId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment ID copied!'),
                        backgroundColor: AppColors.kekeGreen,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.kekeGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.copy, size: 20, color: AppColors.kekeGreen),
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
