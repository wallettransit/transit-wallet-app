import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_button.dart';
import '../../../core/components/tw_text_field.dart';
import '../../../core/components/tw_text_field.dart';
import '../../../core/components/tw_logo.dart';
import 'passenger_otp_verification_screen.dart';

class PassengerRegistrationScreen extends StatefulWidget {
  const PassengerRegistrationScreen({super.key});

  @override
  State<PassengerRegistrationScreen> createState() => _PassengerRegistrationScreenState();
}

class _PassengerRegistrationScreenState extends State<PassengerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isLoading = false);
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PassengerOtpVerificationScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TWLogo(size: 18, textColor: AppColors.paper),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.kekeGreen,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.kekeGreen),
                            ),
                            child: Text(
                              'NEW RIDER',
                              style: AppTypography.label.copyWith(color: AppColors.ink, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ).animate().fade().slideY(begin: -0.2, end: 0),
                      
                      const SizedBox(height: 32),
                      
                      // Title
                      Text(
                        'Create Rider Account',
                        style: AppTypography.heading1.copyWith(color: AppColors.paper, fontSize: 32),
                      ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        'No cash hassle. Sign up to load funds, pay instantly via QR, and travel smoothly.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                      ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 32),
                      
                      // Form Fields
                      const TWTextField(
                        label: 'Full Name',
                        hintText: 'Tunde Johnson',
                      ).animate().fade(delay: 300.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      const TWTextField(
                        label: 'Phone Number',
                        hintText: '803 123 4567',
                        prefixIcon: Icon(Icons.phone, color: AppColors.muted),
                        keyboardType: TextInputType.phone,
                      ).animate().fade(delay: 400.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      const TWTextField(
                        label: 'Email Address (Optional)',
                        hintText: 'tunde@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ).animate().fade(delay: 500.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      const TWTextField(
                        label: 'Choose Password',
                        hintText: 'At least 8 characters',
                        obscureText: true,
                      ).animate().fade(delay: 600.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      const TWTextField(
                        label: 'Confirm Password',
                        hintText: 'Re-enter password',
                        obscureText: true,
                      ).animate().fade(delay: 700.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 24),
                      
                      // Terms Checkbox (simplified)
                      Row(
                        children: [
                          const Icon(Icons.check_box, color: AppColors.kekeGreen, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "I agree to TransitWallet's Terms of Service and Privacy Policy.",
                              style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
                            ),
                          ),
                        ],
                      ).animate().fade(delay: 800.ms),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Action
            Container(
              padding: const EdgeInsets.all(24.0),
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
              child: Column(
                children: [
                  TWButton(
                    label: 'Create Account',
                    onPressed: _submitForm,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                      ),
                      Text(
                        "Log In",
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.kekeGreen, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fade(delay: 900.ms).slideY(begin: 1.0, end: 0),
          ],
        ),
      ),
    );
  }
}
