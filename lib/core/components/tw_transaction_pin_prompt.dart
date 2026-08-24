import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../services/secure_storage_service.dart';

class TWTransactionPinPrompt extends StatefulWidget {
  final String title;
  final String subtitle;
  
  const TWTransactionPinPrompt({
    super.key,
    this.title = 'Enter Transaction PIN',
    this.subtitle = 'Please enter your 6-digit PIN to authorize this action.',
  });

  /// Shows the prompt as a bottom sheet and returns true if successful.
  static Future<bool> show(
    BuildContext context, {
    String title = 'Enter Transaction PIN',
    String subtitle = 'Please enter your 6-digit PIN to authorize this action.',
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TWTransactionPinPrompt(title: title, subtitle: subtitle),
    );
    return result == true;
  }

  @override
  State<TWTransactionPinPrompt> createState() => _TWTransactionPinPromptState();
}

class _TWTransactionPinPromptState extends State<TWTransactionPinPrompt> {
  String _pin = '';
  String? _errorMessage;
  int _lockoutSecondsRemaining = 0;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkLockout();
  }

  Future<void> _checkLockout() async {
    final lockoutUntil = await SecureStorageService.getPinLockoutUntil();
    if (lockoutUntil != null) {
      _startLockoutCountdown(lockoutUntil);
    }
  }

  void _onNumberTapped(String number) {
    if (_lockoutSecondsRemaining > 0 || _isChecking) return;
    HapticFeedback.selectionClick();
    if (_pin.length < 6) {
      setState(() {
        _errorMessage = null;
        _pin += number;
      });
      if (_pin.length == 6) _verifyPin();
    }
  }

  void _onDeleteTapped() {
    if (_isChecking) return;
    HapticFeedback.lightImpact();
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isChecking = true);
    
    // Check lockout first
    final lockoutUntil = await SecureStorageService.getPinLockoutUntil();
    if (lockoutUntil != null) {
      _startLockoutCountdown(lockoutUntil);
      setState(() { _pin = ''; _isChecking = false; });
      return;
    }

    final isValid = await SecureStorageService.verifyPin(_pin);
    if (isValid) {
      await SecureStorageService.resetPinFailedAttempts();
      if (mounted) Navigator.pop(context, true);
    } else {
      HapticFeedback.vibrate();
      final attempts = await SecureStorageService.recordPinFailedAttempt();
      final newLockout = await SecureStorageService.getPinLockoutUntil();
      if (newLockout != null) {
        _startLockoutCountdown(newLockout);
      }
      setState(() {
        _pin = '';
        _isChecking = false;
        _errorMessage = attempts < 5
            ? 'Incorrect PIN. ${5 - attempts} attempt${5 - attempts == 1 ? '' : 's'} remaining.'
            : 'Too many failed attempts.';
      });
    }
  }

  void _startLockoutCountdown(DateTime lockoutUntil) {
    final secondsLeft = lockoutUntil.difference(DateTime.now()).inSeconds;
    setState(() => _lockoutSecondsRemaining = secondsLeft < 0 ? 0 : secondsLeft);

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

  Widget _buildDot(bool isFilled) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 14,
      width: 14,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.kekeGreen : const Color(0xFFF1F5F9),
        shape: BoxShape.circle,
        border: isFilled ? null : Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: isFilled
            ? [BoxShadow(color: AppColors.kekeGreen.withOpacity(0.4), blurRadius: 8)]
            : null,
      ),
    );
  }

  Widget _buildNumpadButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberTapped(number),
      child: Container(
        height: 68,
        width: 68,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Center(
          child: Text(number,
              style: GoogleFonts.outfit(
                  fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.paper)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              height: 5,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(widget.title,
                      style: AppTypography.heading3.copyWith(color: AppColors.paper)),
                  const SizedBox(height: 8),
                  Text(widget.subtitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.muted)),
                  
                  const SizedBox(height: 32),
                  
                  // PIN dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) => _buildDot(i < _pin.length)),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Lockout banner or error message
                  if (_lockoutSecondsRemaining > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, color: AppColors.errorRed, size: 18),
                          const SizedBox(width: 8),
                          Text('Try again in $_lockoutSecondsRemaining seconds',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.errorRed)),
                        ],
                      ),
                    ).animate().fade().slideY(begin: 0.2)
                  else if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.errorRed.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.errorRed, size: 18),
                          const SizedBox(width: 8),
                          Text(_errorMessage!,
                              style: AppTypography.bodySmall.copyWith(color: AppColors.errorRed)),
                        ],
                      ),
                    ).animate().shake(duration: 400.ms),
                  
                  const SizedBox(height: 24),
                  
                  if (_isChecking)
                    const CircularProgressIndicator(color: AppColors.kekeGreen)
                  else
                    Column(
                      children: [
                        for (int i = 0; i < 3; i++) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (int j = 1; j <= 3; j++) _buildNumpadButton('${(i * 3) + j}'),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(width: 68),
                            _buildNumpadButton('0'),
                            GestureDetector(
                              onTap: _onDeleteTapped,
                              child: const SizedBox(
                                height: 68, width: 68,
                                child: Center(
                                    child: Icon(Icons.backspace_outlined,
                                        color: AppColors.paper, size: 24)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
