import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../core/components/tw_snackbar.dart';

enum _ChangePinStep { currentPin, newPin, confirmPin }

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  _ChangePinStep _step = _ChangePinStep.currentPin;
  String _entered = '';
  String _newPin = '';
  bool _isSaving = false;
  String? _errorMessage;
  int _lockoutSecondsRemaining = 0;

  String get _title {
    switch (_step) {
      case _ChangePinStep.currentPin:
        return 'Enter current PIN';
      case _ChangePinStep.newPin:
        return 'Enter new PIN';
      case _ChangePinStep.confirmPin:
        return 'Confirm new PIN';
    }
  }

  String get _subtitle {
    switch (_step) {
      case _ChangePinStep.currentPin:
        return 'Verify your identity before changing your PIN.';
      case _ChangePinStep.newPin:
        return 'Must be 6 digits. Avoid simple sequences.';
      case _ChangePinStep.confirmPin:
        return 'Re-enter your new PIN to confirm.';
    }
  }

  void _onNumberTapped(String number) {
    if (_lockoutSecondsRemaining > 0) return;
    HapticFeedback.selectionClick();
    if (_entered.length < 6) {
      setState(() {
        _errorMessage = null;
        _entered += number;
      });
      if (_entered.length == 6) _onPinComplete();
    }
  }

  void _onDeleteTapped() {
    HapticFeedback.lightImpact();
    if (_entered.isNotEmpty) setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _onPinComplete() async {
    switch (_step) {
      case _ChangePinStep.currentPin:
        await _verifyCurrentPin();
        break;
      case _ChangePinStep.newPin:
        await _validateNewPin();
        break;
      case _ChangePinStep.confirmPin:
        await _saveNewPin();
        break;
    }
  }

  Future<void> _verifyCurrentPin() async {
    // Check for lockout first
    final lockoutUntil = await SecureStorageService.getPinLockoutUntil();
    if (lockoutUntil != null) {
      _startLockoutCountdown(lockoutUntil);
      setState(() => _entered = '');
      return;
    }

    final isValid = await SecureStorageService.verifyPin(_entered);
    if (isValid) {
      await SecureStorageService.resetPinFailedAttempts();
      setState(() { _step = _ChangePinStep.newPin; _entered = ''; _errorMessage = null; });
    } else {
      HapticFeedback.vibrate();
      final attempts = await SecureStorageService.recordPinFailedAttempt();
      final lockout = await SecureStorageService.getPinLockoutUntil();
      if (lockout != null) {
        _startLockoutCountdown(lockout);
      }
      setState(() {
        _errorMessage = attempts < 5
            ? 'Incorrect PIN. ${5 - attempts} attempts remaining.'
            : 'Incorrect PIN. Too many attempts.';
        _entered = '';
      });
    }
  }

  Future<void> _validateNewPin() async {
    final error = SecureStorageService.validatePinStrength(_entered);
    if (error != null) {
      HapticFeedback.vibrate();
      setState(() { _errorMessage = error; _entered = ''; });
      return;
    }
    // Optionally: disallow same as old PIN (we can check hash)
    _newPin = _entered;
    setState(() { _step = _ChangePinStep.confirmPin; _entered = ''; _errorMessage = null; });
  }

  Future<void> _saveNewPin() async {
    if (_entered != _newPin) {
      HapticFeedback.vibrate();
      setState(() { _errorMessage = 'PINs do not match. Try again.'; _entered = ''; _step = _ChangePinStep.newPin; });
      return;
    }
    setState(() => _isSaving = true);
    await SecureStorageService.savePin(_newPin);
    if (mounted) {
      TWSnackbar.showSuccess(context, 'PIN changed successfully!');
      Navigator.pop(context);
    }
  }

  void _startLockoutCountdown(DateTime lockoutUntil) {
    final secondsLeft = lockoutUntil.difference(DateTime.now()).inSeconds;
    setState(() => _lockoutSecondsRemaining = secondsLeft);

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      final remaining = lockoutUntil.difference(DateTime.now()).inSeconds;
      setState(() => _lockoutSecondsRemaining = remaining < 0 ? 0 : remaining);
      return remaining > 0;
    });
  }

  Widget _buildDot(bool isFilled) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 14,
      width: 14,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.kekeGreen : AppColors.paper.withOpacity(0.15),
        shape: BoxShape.circle,
        boxShadow: isFilled
            ? [BoxShadow(color: AppColors.kekeGreen.withOpacity(0.5), blurRadius: 8)]
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
          color: AppColors.paper.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.paper.withOpacity(0.1)),
        ),
        child: Center(
          child: Text(
            number,
            style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1612),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Change PIN', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Step indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _ChangePinStep.values.map((s) {
                final isActive = s.index <= _step.index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 4,
                  width: isActive ? 28 : 16,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.kekeGreen : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }).toList(),
            ).animate().fade(),

            const SizedBox(height: 28),

            Text(_title, style: AppTypography.heading2.copyWith(color: Colors.white))
                .animate(key: ValueKey(_step)).fade().slideY(begin: 0.2),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(_subtitle, textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white54))
                  .animate(key: ValueKey(_step)).fade(),
            ),

            const Spacer(),

            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) => _buildDot(i < _entered.length)),
            ),

            // Error / lockout message
            if (_lockoutSecondsRemaining > 0) ...[
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(12),
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
                    Text(
                      'Try again in $_lockoutSecondsRemaining seconds',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.errorRed),
                    ),
                  ],
                ),
              ),
            ] else if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(_errorMessage!, textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.errorRed))
                    .animate().shake(duration: 400.ms),
              ),
            ],

            const Spacer(),

            if (_isSaving)
              const CircularProgressIndicator(color: AppColors.kekeGreen)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
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
                        const SizedBox(width: 68),
                        _buildNumpadButton('0'),
                        GestureDetector(
                          onTap: _onDeleteTapped,
                          child: const SizedBox(
                            height: 68, width: 68,
                            child: Center(child: Icon(Icons.backspace_outlined, color: Colors.white, size: 24)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fade().slideY(begin: 0.1),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
