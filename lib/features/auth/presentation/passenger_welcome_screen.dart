import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_button.dart';
import '../../wallet/presentation/passenger_main_layout.dart';

class PassengerWelcomeScreen extends StatelessWidget {
  const PassengerWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Illustration / Icon
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.kekeGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: AppColors.kekeGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 40, color: AppColors.ink),
                          ),
                        ),
                      ).animate().fade().scale(curve: Curves.easeOutBack, duration: 600.ms),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Welcome Text
                    Text(
                      'Welcome to\nTransitWallet!',
                      style: AppTypography.heading1.copyWith(
                        color: AppColors.paper,
                        fontSize: 36,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Your account has been successfully verified. You are now ready to top up and tap to pay for your daily commutes.',
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ),
            
            // Bottom Action
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: AppColors.ink,
              ),
              child: TWButton(
                label: 'Go to Dashboard',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const PassengerMainLayout()),
                    (route) => false,
                  );
                },
              ),
            ).animate().fade(delay: 800.ms).slideY(begin: 1.0, end: 0),
          ],
        ),
      ),
    );
  }
}
