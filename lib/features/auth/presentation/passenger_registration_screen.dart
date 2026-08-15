import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_button.dart';
import '../../../core/components/tw_text_field.dart';
import '../../../core/components/tw_logo.dart';
import '../providers/auth_provider.dart';
import 'passenger_otp_verification_screen.dart';
import '../../../core/components/tw_snackbar.dart';
import '../../../core/components/tw_phone_prefix.dart';
import '../../../core/utils/tw_error_handler.dart';

class PassengerRegistrationScreen extends ConsumerStatefulWidget {
  const PassengerRegistrationScreen({super.key});

  @override
  ConsumerState<PassengerRegistrationScreen> createState() => _PassengerRegistrationScreenState();
}

class _PassengerRegistrationScreenState extends ConsumerState<PassengerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      
      final authState = ref.read(authControllerProvider);
      if (authState.hasError) {
        if (mounted) {
          TWErrorHandler.handle(context, authState.error);
        }
      } else {
        if (mounted) {
          // You might want to navigate to a "Check Email" screen or OTP screen
          // For now, we will navigate to the next screen.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PassengerOtpVerificationScreen(
                phoneNumber: _phoneController.text.trim(),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

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
                      TWTextField(
                        label: 'Full Name',
                        hintText: 'Tunde Johnson',
                        controller: _fullNameController,
                        validator: (value) => value == null || value.isEmpty ? 'Full name is required' : null,
                      ).animate().fade(delay: 300.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      TWTextField(
                        label: 'Phone Number',
                        hintText: '803 123 4567',
                        controller: _phoneController,
                        prefixIcon: const TWPhonePrefix(),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty ? 'Phone number is required' : null,
                      ).animate().fade(delay: 400.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      TWTextField(
                        label: 'Email Address',
                        hintText: 'tunde@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email is required';
                          if (!value.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ).animate().fade(delay: 500.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      TWTextField(
                        label: 'Choose Password',
                        hintText: 'At least 8 characters',
                        controller: _passwordController,
                        obscureText: true,
                        onChanged: (val) => setState(() {}),
                        validator: (value) => value != null && value.length < 8 ? 'Password must be at least 8 characters' : null,
                      ).animate().fade(delay: 600.ms).slideX(begin: 0.1, end: 0),
                      
                      _PasswordStrengthIndicator(password: _passwordController.text),
                      
                      const SizedBox(height: 16),
                      
                      TWTextField(
                        label: 'Confirm Password',
                        hintText: 'Re-enter password',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
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
              decoration: const BoxDecoration(
                color: AppColors.ink,
              ),
              child: Column(
                children: [
                  TWButton(
                    label: 'Create Account',
                    onPressed: isLoading ? () {} : _submitForm,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Log In",
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.kekeGreen, fontWeight: FontWeight.bold),
                        ),
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

class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  const _PasswordStrengthIndicator({required this.password});
  
  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#\$&*~_]'))) strength += 0.25;

    Color color = AppColors.errorRed;
    String text = 'Weak';
    
    if (strength <= 0.25) {
      color = AppColors.errorRed;
      text = 'Weak';
    } else if (strength <= 0.5) {
      color = Colors.orange;
      text = 'Fair';
    } else if (strength <= 0.75) {
      color = Colors.yellow;
      text = 'Good';
    } else {
      color = AppColors.kekeGreen;
      text = 'Strong';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: strength,
                backgroundColor: AppColors.cardBackground,
                color: color,
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(text, style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate().fade(duration: 200.ms);
  }
}
