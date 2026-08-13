import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_button.dart';
import 'passenger_wallet_screen.dart';

class PassengerPaymentConfirmationScreen extends StatelessWidget {
  final int amountPaid;

  const PassengerPaymentConfirmationScreen({
    super.key,
    required this.amountPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('9:41', style: AppTypography.label.copyWith(color: AppColors.paper)),
                  // Mock status icons could go here
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Checkmark
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.kekeGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.kekeGreen, width: 2),
                      ),
                      child: const Icon(Icons.check, size: 32, color: AppColors.ink),
                    ).animate().fade().scale(curve: Curves.easeOutBack, duration: 600.ms),
                    
                    const SizedBox(height: 24),
                    
                    // Status
                    Text(
                      'Payment Confirmed',
                      style: AppTypography.heading2.copyWith(color: AppColors.paper),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      'Fare successfully transferred to driver.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    // Receipt Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderStroke),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('FARE PAID', style: AppTypography.label.copyWith(color: AppColors.muted)),
                              Text('₦$amountPaid', style: AppTypography.heading2.copyWith(color: AppColors.kekeGreen)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text('ROUTE & TRIP', style: AppTypography.label.copyWith(color: AppColors.muted)),
                          const SizedBox(height: 4),
                          Text('Oshodi → CMS (Full Route)', style: AppTypography.bodySmall.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
                          
                          const SizedBox(height: 16),
                          Text('DRIVER PARTNER', style: AppTypography.label.copyWith(color: AppColors.muted)),
                          const SizedBox(height: 4),
                          Text('Alhaji Kehinde (Bus LAG-5847)', style: AppTypography.bodySmall.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
                          
                          const SizedBox(height: 16),
                          Text('TIMESTAMP', style: AppTypography.label.copyWith(color: AppColors.muted)),
                          const SizedBox(height: 4),
                          Text('26 Jan 2026 • 09:37 AM', style: AppTypography.bodySmall.copyWith(color: AppColors.paper)),
                        ],
                      ),
                    ).animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    // Remaining Balance
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.kekeGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Remaining Wallet Balance: ₦${4850 - amountPaid}',
                        style: AppTypography.label.copyWith(color: AppColors.kekeGreen, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fade(delay: 700.ms),
                  ],
                ),
              ),
            ),
            
            // Bottom Action
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.ink,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: TWButton(
                label: 'Done',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const PassengerWalletScreen()),
                    (route) => false,
                  );
                },
              ),
            ).animate().fade(delay: 900.ms).slideY(begin: 1.0, end: 0),
          ],
        ),
      ),
    );
  }
}
