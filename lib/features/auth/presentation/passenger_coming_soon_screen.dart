import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';

class PassengerComingSoonScreen extends StatelessWidget {
  const PassengerComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Animated Illustration / Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.kekeGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_subway_filled_outlined,
                    size: 64,
                    color: AppColors.kekeGreen,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                duration: 2.seconds,
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                curve: Curves.easeInOutSine,
              ),
              const SizedBox(height: 32),
              
              // Text Content
              Text(
                'Passenger App\nComing Soon',
                style: AppTypography.heading1,
                textAlign: TextAlign.center,
              ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              
              Text(
                'We are currently working hard to bring the TransitWallet experience to passengers. Stay tuned!',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.muted,
                ),
                textAlign: TextAlign.center,
              ).animate().fade(duration: 500.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
              
              const Spacer(),
              
              // Action
              TWButton(
                label: 'Back to Role Selection',
                variant: TWButtonVariant.secondary,
                onPressed: () => Navigator.pop(context),
              ).animate().fade(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
