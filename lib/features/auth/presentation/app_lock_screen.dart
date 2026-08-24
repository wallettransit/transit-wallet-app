import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import 'welcome_screen.dart';
import '../../../../core/services/secure_storage_service.dart';
import 'forgot_pin_screen.dart';
import '../../../../main.dart' show navigatorKey;

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  bool _showPinFallback = false;
  String _pin = '';
  String? _errorMessage;
  int _lockoutSecondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkLockoutBeforeAuth();
    });
  }

  Future<void> _checkLockoutBeforeAuth() async {
    final lockoutUntil = await SecureStorageService.getPinLockoutUntil();
    if (lockoutUntil != null) {
      _startLockoutCountdown(lockoutUntil);
      setState(() => _showPinFallback = true);
      return;
    }

    // Check if biometric unlock is enabled by the user
    final biometricEnabled = await SecureStorageService.isBiometricUnlockEnabled();
    if (biometricEnabled) {
      await _authenticate();
    } else {
      setState(() => _showPinFallback = true);
    }
  }

  Future<void> _authenticate() async {
    final hasPin = await SecureStorageService.hasPin();
    if (!hasPin) {
      _unlock();
      return;
    }

    setState(() { _isAuthenticating = true; _errorMessage = null; });

    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        setState(() { _showPinFallback = true; _isAuthenticating = false; });
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock OyaPay',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
      );

      if (didAuthenticate) {
        await SecureStorageService.resetPinFailedAttempts();
        _unlock();
      } else {
        setState(() {
          _errorMessage = 'Authentication failed. Use PIN instead.';
          _showPinFallback = true;
        });
      }
    } on PlatformException {
      setState(() { _errorMessage = 'Biometrics unavailable.'; _showPinFallback = true; });
    } catch (_) {
      setState(() { _errorMessage = 'An error occurred. Use PIN.'; _showPinFallback = true; });
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  void _unlock() {
    ref.read(isAppLockedProvider.notifier).state = false;
  }

  void _onNumberTapped(String number) {
    if (_lockoutSecondsRemaining > 0) return;
    HapticFeedback.selectionClick();
    if (_pin.length < 6) {
      setState(() { _errorMessage = null; _pin += number; });
      if (_pin.length == 6) _verifyPin();
    }
  }

  void _onDeleteTapped() {
    HapticFeedback.lightImpact();
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verifyPin() async {
    // Check lockout first
    final lockoutUntil = await SecureStorageService.getPinLockoutUntil();
    if (lockoutUntil != null) {
      _startLockoutCountdown(lockoutUntil);
      setState(() => _pin = '');
      return;
    }

    final isValid = await SecureStorageService.verifyPin(_pin);
    if (isValid) {
      await SecureStorageService.resetPinFailedAttempts();
      _unlock();
    } else {
      HapticFeedback.vibrate();
      final attempts = await SecureStorageService.recordPinFailedAttempt();
      final newLockout = await SecureStorageService.getPinLockoutUntil();
      if (newLockout != null) {
        _startLockoutCountdown(newLockout);
      }
      setState(() {
        _pin = '';
        _errorMessage = attempts < 5
            ? 'Incorrect PIN. ${5 - attempts} attempt${5 - attempts == 1 ? '' : 's'} remaining.'
            : 'Too many failed attempts.';
      });
    }
  }

  void _startLockoutCountdown(DateTime lockoutUntil) {
    final secondsLeft = lockoutUntil.difference(DateTime.now()).inSeconds;
    setState(() { _lockoutSecondsRemaining = secondsLeft < 0 ? 0 : secondsLeft; });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      final remaining = lockoutUntil.difference(DateTime.now()).inSeconds;
      setState(() => _lockoutSecondsRemaining = remaining < 0 ? 0 : remaining);
      if (remaining <= 0) {
        setState(() => _errorMessage = null);
      }
      return remaining > 0;
    });
  }

  void _logout() async {
    final lockedNotifier = ref.read(isAppLockedProvider.notifier);
    await ref.read(authControllerProvider.notifier).signOut();
    
    // Use saved notifier to avoid ref lookup after unmount
    lockedNotifier.state = false;
    
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  Widget _buildDot(bool isFilled) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 9),
      height: 15,
      width: 15,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.kekeGreen : Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
        boxShadow: isFilled
            ? [BoxShadow(color: AppColors.kekeGreen.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)]
            : null,
      ),
    );
  }

  Widget _buildNumpadButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberTapped(number),
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Center(
          child: Text(number,
              style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Glassmorphic blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(color: Colors.black.withOpacity(0.70)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Lock icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(color: AppColors.kekeGreen.withOpacity(0.2), blurRadius: 40, spreadRadius: 8),
                      ],
                    ),
                    child: const Icon(Icons.lock_person_rounded, size: 56, color: AppColors.kekeGreen),
                  ).animate().scale(delay: 200.ms, duration: 450.ms, curve: Curves.easeOutBack),

                  const SizedBox(height: 28),

                  Text('OyaPay Locked',
                      style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
                      textAlign: TextAlign.center)
                      .animate().fade(delay: 300.ms).slideY(begin: 0.2),

                  const SizedBox(height: 8),

                  Text('Authenticate to access your account.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(color: Colors.white60))
                      .animate().fade(delay: 400.ms),

                  const SizedBox(height: 36),

                  // Lockout banner
                  if (_lockoutSecondsRemaining > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.errorRed.withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, color: AppColors.errorRed, size: 20),
                          const SizedBox(width: 10),
                          Text('Try again in $_lockoutSecondsRemaining seconds',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.errorRed)),
                        ],
                      ),
                    ).animate().fade().slideY(begin: 0.2)
                  else if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.errorRed, size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_errorMessage!,
                              style: AppTypography.bodySmall.copyWith(color: AppColors.errorRed))),
                        ],
                      ),
                    ).animate().shake(duration: 400.ms),

                  // PIN input (if in fallback mode)
                  if (_showPinFallback) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (i) => _buildDot(i < _pin.length)),
                    ),
                    const SizedBox(height: 32),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          for (int i = 0; i < 3; i++) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for (int j = 1; j <= 3; j++) _buildNumpadButton('${(i * 3) + j}'),
                              ],
                            ),
                            const SizedBox(height: 18),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Biometric quick-switch button
                              GestureDetector(
                                onTap: _authenticate,
                                child: Container(
                                  height: 70, width: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                                  ),
                                  child: const Center(child: Icon(Icons.fingerprint, color: Colors.white, size: 30)),
                                ),
                              ),
                              _buildNumpadButton('0'),
                              GestureDetector(
                                onTap: _onDeleteTapped,
                                child: const SizedBox(
                                  height: 70, width: 70,
                                  child: Center(child: Icon(Icons.backspace_outlined, color: Colors.white, size: 24)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.15),

                    const SizedBox(height: 16),
                    // Forgot PIN
                    TextButton(
                      onPressed: () {
                        navigatorKey.currentState!.push(
                          MaterialPageRoute(builder: (_) => const ForgotPinScreen()),
                        );
                      },
                      child: Text('Forgot PIN?',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.kekeGreen,
                            fontWeight: FontWeight.w600,
                          )),
                    ),

                  ] else ...[
                    // Biometric prompt button
                    if (_isAuthenticating)
                      const CircularProgressIndicator(color: AppColors.kekeGreen)
                    else
                      GestureDetector(
                        onTap: _authenticate,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.kekeGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.kekeGreen.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.fingerprint, color: AppColors.kekeGreen, size: 52),
                        ),
                      ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => setState(() => _showPinFallback = true),
                      child: Text('Use PIN instead',
                          style: AppTypography.bodyMedium.copyWith(color: Colors.white54)),
                    ),
                  ],

                  const Spacer(),

                  TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.white38, size: 18),
                    label: Text('Log out completely',
                        style: AppTypography.bodySmall.copyWith(color: Colors.white38)),
                  ).animate().fade(delay: 600.ms),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
