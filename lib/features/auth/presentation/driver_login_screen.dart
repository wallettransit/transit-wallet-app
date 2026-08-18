import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_text_field.dart';
import '../../../core/components/tw_phone_prefix.dart';
import '../../../../core/components/tw_logo.dart';
import 'driver_registration_screen.dart';
import 'forgot_password_screen.dart';
import '../../driver_dashboard/presentation/driver_main_layout.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  bool _obscurePassword = true;
  bool _isPhoneLogin = true;

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
                              'DRIVER',
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
                          'Log in to sync with your wallet, check commissions, and cash out fares.',
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // form
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // login-method-toggle
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isPhoneLogin = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isPhoneLogin ? AppColors.kekeGreen.withOpacity(0.1) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _isPhoneLogin ? AppColors.kekeGreen : AppColors.borderStroke,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Phone',
                                      style: AppTypography.label.copyWith(
                                        color: _isPhoneLogin ? AppColors.kekeGreen : AppColors.muted,
                                        fontWeight: _isPhoneLogin ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isPhoneLogin = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isPhoneLogin ? AppColors.kekeGreen.withOpacity(0.1) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !_isPhoneLogin ? AppColors.kekeGreen : AppColors.borderStroke,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Email',
                                      style: AppTypography.label.copyWith(
                                        color: !_isPhoneLogin ? AppColors.kekeGreen : AppColors.muted,
                                        fontWeight: !_isPhoneLogin ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // dynamic-identity-field
                        _isPhoneLogin 
                          ? TWTextField(
                              label: 'Phone Number',
                              hintText: '802 899 1234',
                              keyboardType: TextInputType.phone,
                              prefixIcon: const TWPhonePrefix(),
                            )
                          : TWTextField(
                              label: 'Email Address',
                              hintText: 'example@email.com',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.muted, size: 20),
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
                        MaterialPageRoute(builder: (context) => const DriverMainLayout()),
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
                            MaterialPageRoute(builder: (context) => const DriverRegistrationScreen()),
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
