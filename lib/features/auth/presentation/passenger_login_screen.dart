import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_text_field.dart';
import '../../../../core/components/tw_logo.dart';
import '../providers/auth_provider.dart';
import 'passenger_registration_screen.dart';
import 'forgot_password_screen.dart';
import '../../wallet/presentation/passenger_main_layout.dart';
import '../../profile/presentation/passenger_kyc_screen.dart';
import '../data/auth_repository.dart';
import '../../../core/components/tw_snackbar.dart';

class PassengerLoginScreen extends ConsumerStatefulWidget {
  const PassengerLoginScreen({super.key});

  @override
  ConsumerState<PassengerLoginScreen> createState() => _PassengerLoginScreenState();
}

class _PassengerLoginScreenState extends ConsumerState<PassengerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      final authState = ref.read(authControllerProvider);
      if (authState.hasError) {
        if (mounted) {
          TWSnackbar.showError(context, authState.error.toString());
        }
      } else {
        // Fetch user profile to check KYC tier
        final user = ref.read(authRepositoryProvider).currentUser;
        if (user != null) {
          final profile = await ref.read(authRepositoryProvider).getUserProfile(user.id);
          if (mounted) {
            if (profile != null && profile['kyc_tier'] == 'tier_0') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PassengerKycScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PassengerMainLayout()),
              );
            }
          }
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
                      // brand-header
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TWLogo(size: 18, textColor: AppColors.paper),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.kekeGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.kekeGreen.withOpacity(0.5), width: 1),
                              ),
                              child: Text(
                                'RIDER',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.kekeGreen,
                                  fontSize: 11,
                                  height: 15.0 / 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // heading-block
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back.',
                            style: AppTypography.heading1,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Log in to check your wallet balance, top up, and pay for rides.',
                            style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // form
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // email-field
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
                          ),
                          const SizedBox(height: 20),
                          
                          // password-field
                          TWTextField(
                            label: 'Password',
                            hintText: '••••••••',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
                            suffixIcon: TextButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              child: Text(
                                _obscurePassword ? 'SHOW' : 'HIDE',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.kekeGreen,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // auxiliary-links
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.kekeGreen,
                                ),
                              ),
                            ),
                          ),
                        ].animate(interval: 100.ms, delay: 200.ms).fade(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // bottom-container
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TWButton(
                    label: 'Log In',
                    onPressed: isLoading ? () {} : _submitForm,
                    isLoading: isLoading,
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: 2000.ms, color: Colors.white24),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PassengerRegistrationScreen()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.kekeGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
