import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // heading-block
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset Password',
                    style: AppTypography.heading1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your registered phone number to receive a 6-digit OTP to reset your password.',
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
                  ),
                ],
              ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: 40),
              
              // form
              TWTextField(
                label: 'Phone Number',
                hintText: '802 899 1234',
                keyboardType: TextInputType.phone,
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 16),
                    Text('+234', style: AppTypography.bodyMedium.copyWith(color: AppColors.muted, fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 24, color: AppColors.borderStroke),
                    const SizedBox(width: 12),
                  ],
                ),
              ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
              
              const Spacer(),
              
              // action
              TWButton(
                label: 'Send OTP',
                onPressed: () {
                  // TODO: Navigate to OTP screen for reset flow
                },
              ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
