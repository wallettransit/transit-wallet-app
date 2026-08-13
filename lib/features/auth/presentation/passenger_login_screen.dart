import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_text_field.dart';
import '../../../../core/components/tw_logo.dart';
import 'passenger_registration_screen.dart';
import 'forgot_password_screen.dart';
import '../../wallet/presentation/passenger_wallet_screen.dart';

class PassengerLoginScreen extends StatefulWidget {
  const PassengerLoginScreen({super.key});

  @override
  State<PassengerLoginScreen> createState() => _PassengerLoginScreenState();
}

class _PassengerLoginScreenState extends State<PassengerLoginScreen> {
  bool _obscurePassword = true;

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
                        // phone-field
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
                        ),
                        const SizedBox(height: 20),
                        
                        // password-field
                        TWTextField(
                          label: 'Password',
                          hintText: '••••••••',
                          obscureText: _obscurePassword,
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
            
            // bottom-container
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TWButton(
                    label: 'Log In',
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const PassengerWalletScreen()),
                        (route) => false,
                      );
                    },
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
                          Navigator.pushReplacement(
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
