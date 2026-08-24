import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_text_field.dart';
import '../../../../core/components/tw_logo.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../providers/auth_provider.dart';
import 'passenger_registration_screen.dart';
import 'forgot_password_screen.dart';
import '../../wallet/presentation/passenger_main_layout.dart';
import '../../profile/presentation/passenger_kyc_screen.dart';
import '../data/auth_repository.dart';
import '../../../core/components/tw_snackbar.dart';
import '../../../core/utils/tw_error_handler.dart';

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

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  Map<String, String>? _savedCredentials;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final credentials = await SecureStorageService.getCredentials();
    if (credentials != null) {
      final canCheck = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      setState(() {
        _savedCredentials = credentials;
        _canCheckBiometrics = canCheck;
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_savedCredentials == null) return;
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Log in securely with biometrics',
        options: const AuthenticationOptions(stickyAuth: true),
      );

      if (didAuthenticate) {
        _emailController.text = _savedCredentials!['email']!;
        _passwordController.text = _savedCredentials!['password']!;
        _submitForm();
      }
    } catch (e) {
      if (mounted) {
        TWSnackbar.showError(context, 'Biometric authentication failed or canceled.');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Ensure the app doesn't immediately lock if there's a stale lock state from a previous session
      ref.read(isAppLockedProvider.notifier).state = false;

      await ref.read(authControllerProvider.notifier).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      final authState = ref.read(authControllerProvider);
      if (!authState.isLoading && authState.hasError) {
        if (mounted) {
          TWErrorHandler.handle(context, authState.error);
        }
      } else {
        // Fetch user profile to check KYC tier
        final user = ref.read(authRepositoryProvider).currentUser;
        if (user != null) {
          final profile = await ref.read(authRepositoryProvider).getUserProfile(user.id);
          if (mounted) {
            if (profile != null && profile['kyc_tier'] == 'tier_0') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const PassengerKycScreen()),
                (route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const PassengerMainLayout()),
                (route) => false,
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
                  Row(
                    children: [
                      Expanded(
                        child: TWButton(
                          label: 'Log In',
                          onPressed: isLoading ? () {} : _submitForm,
                          isLoading: isLoading,
                        ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: 2000.ms, color: Colors.white24),
                      ),
                      if (_canCheckBiometrics) ...[
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: isLoading ? null : _authenticateWithBiometrics,
                          child: Container(
                            height: 56, // Matches TWButton default height roughly
                            width: 56,
                            decoration: BoxDecoration(
                              color: AppColors.kekeGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.kekeGreen.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.fingerprint, color: AppColors.kekeGreen, size: 28),
                          ),
                        ).animate().fade().scale(),
                      ]
                    ],
                  ),
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
