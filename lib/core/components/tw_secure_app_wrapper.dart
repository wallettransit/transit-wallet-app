import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/biometric_service.dart';

class TWSecureAppWrapper extends StatefulWidget {
  final Widget child;

  const TWSecureAppWrapper({super.key, required this.child});

  @override
  State<TWSecureAppWrapper> createState() => _TWSecureAppWrapperState();
}

class _TWSecureAppWrapperState extends State<TWSecureAppWrapper> with WidgetsBindingObserver {
  bool _isLocked = false;
  DateTime? _pausedTime;
  
  // Set the timeout for auto-locking the app (e.g., 30 seconds)
  final Duration _lockTimeout = const Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_pausedTime == null && !_isLocked) {
        _pausedTime = DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedTime != null) {
        final timeInactive = DateTime.now().difference(_pausedTime!);
        if (timeInactive > _lockTimeout) {
          setState(() {
            _isLocked = true;
          });
          _authenticate();
        }
        _pausedTime = null;
      }
    }
  }

  Future<void> _authenticate() async {
    final success = await BiometricService.authenticate();
    if (success && mounted) {
      setState(() {
        _isLocked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isLocked)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: AppColors.ink.withOpacity(0.85),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: AppColors.kekeGreen,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'App Locked',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.paper,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verify your identity to continue',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppColors.muted,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton.icon(
                      onPressed: _authenticate,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Unlock with Biometrics'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kekeGreen,
                        foregroundColor: AppColors.ink,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
