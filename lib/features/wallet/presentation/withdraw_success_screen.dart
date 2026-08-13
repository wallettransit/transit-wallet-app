import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';

class WithdrawSuccessScreen extends StatelessWidget {
  final double amount;
  
  const WithdrawSuccessScreen({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kekeGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Success Icon Animation
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 64,
                      color: AppColors.kekeGreen,
                    ),
                  ),
                ).animate()
                 .scale(curve: Curves.easeOutBack, duration: 600.ms)
                 .then()
                 .shimmer(duration: 1.seconds, color: AppColors.kekeGreen.withOpacity(0.5)),
              ),
              
              const SizedBox(height: 48),
              
              // Text Content
              Text(
                'Withdrawal\nSuccessful!',
                textAlign: TextAlign.center,
                style: AppTypography.heading1.copyWith(
                  color: AppColors.ink,
                  fontSize: 40,
                  height: 1.1,
                ),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              
              Text(
                '₦${amount.toStringAsFixed(2)} is on its way to your bank account. It usually takes less than 2 minutes to arrive.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.ink.withOpacity(0.8),
                  height: 1.5,
                ),
              ).animate().fade(delay: 600.ms).slideY(begin: 0.2, end: 0),
              
              const Spacer(),
              
              // Action
              TWButton(
                label: 'Back to Dashboard',
                variant: TWButtonVariant.secondary,
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ).animate().fade(delay: 800.ms).slideY(begin: 1.0, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
