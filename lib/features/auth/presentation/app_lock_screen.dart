import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_button.dart';
import '../providers/auth_provider.dart';
import 'welcome_screen.dart';
import '../../../../core/services/secure_storage_service.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _errorMessage = '';
  bool _showPinFallback = false;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }
  
  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        setState(() {
          _showPinFallback = true;
          _isAuthenticating = false;
        });
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock Transit Wallet',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (didAuthenticate) {
        _unlock();
      } else {
        setState(() {
          _errorMessage = 'Authentication failed. Try again or use PIN.';
          _showPinFallback = true;
        });
      }
    } on PlatformException catch (e) {
      // Handle MissingPluginException specifically (happens on Windows/Desktop test environments)
      setState(() {
        _errorMessage = 'Biometrics unavailable on this device.';
        _showPinFallback = true; // Fallback to PIN seamlessly
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please use PIN.';
        _showPinFallback = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }
  
  void _unlock() {
    ref.read(isAppLockedProvider.notifier).state = false;
  }

  Future<void> _verifyPin() async {
    final enteredPin = _pinController.text;
    if (enteredPin.length < 4) return;
    
    // In a production app, the stored PIN is checked securely.
    final storedPin = await SecureStorageService.getPin();
    
    if (storedPin == null) {
      // Edge case: No PIN was ever set, let them through or force setup.
      // For now, if no PIN is set, allow them in so they aren't locked out.
      _unlock();
      return;
    }

    if (enteredPin == storedPin) {
      _unlock();
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Please try again.';
        _pinController.clear();
      });
    }
  }

  void _logout() async {
    await ref.read(authControllerProvider.notifier).signOut();
    ref.read(isAppLockedProvider.notifier).state = false;
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Make background completely transparent to allow blurring the app behind it!
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Glassmorphic Blur Effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              color: Colors.black.withOpacity(0.65), // Dark overlay
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Glowing Lock Icon
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.kekeGreen.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_person_rounded,
                      size: 64,
                      color: AppColors.kekeGreen,
                    ),
                  ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'Transit Wallet is Locked',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'To protect your wallet and account details, we locked the app due to inactivity.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(color: Colors.white70, height: 1.5),
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: 40),
                  
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: AppTypography.bodySmall.copyWith(color: AppColors.errorRed),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade().slideY(begin: 0.2),
                    
                  if (_showPinFallback) ...[
                    // PIN Fallback UI
                    TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        letterSpacing: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '••••',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.kekeGreen),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.length == 4) _verifyPin();
                      },
                    ).animate().fade().slideY(begin: 0.2),
                    const SizedBox(height: 24),
                  ],
                  
                  TWButton(
                    label: _showPinFallback ? 'Unlock with PIN' : 'Unlock with Biometrics',
                    isLoading: _isAuthenticating,
                    onPressed: _showPinFallback ? _verifyPin : _authenticate,
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.2),
                  
                  const Spacer(),
                  
                  TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.white54, size: 20),
                    label: Text(
                      'Log out completely',
                      style: AppTypography.bodyMedium.copyWith(color: Colors.white54),
                    ),
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
