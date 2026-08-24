import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../core/components/tw_snackbar.dart';

class CreatePinScreen extends StatefulWidget {
  final VoidCallback onPinCreated;
  final bool isDark;

  const CreatePinScreen({
    super.key,
    required this.onPinCreated,
    this.isDark = true,
  });

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isSaving = false;
  String? _strengthError;

  Color get _textColor => widget.isDark ? Colors.white : AppColors.paper;
  Color get _mutedColor => widget.isDark ? Colors.white54 : AppColors.muted;
  Color get _keyBg => widget.isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF1F5F9);
  Color get _keyBorder => widget.isDark ? Colors.white.withOpacity(0.12) : Colors.grey.withOpacity(0.2);
  Color get _scaffoldBg => widget.isDark ? const Color(0xFF0F1612) : Colors.white;
  Color get _dotEmpty => widget.isDark ? Colors.white.withOpacity(0.12) : Colors.grey.withOpacity(0.2);

  void _onNumberTapped(String number) {
    HapticFeedback.selectionClick();
    setState(() {
      _strengthError = null;
      if (!_isConfirming) {
        if (_pin.length < 6) {
          _pin += number;
          if (_pin.length == 6) {
            final error = SecureStorageService.validatePinStrength(_pin);
            if (error != null) {
              // Shake and reset
              _strengthError = error;
              Future.delayed(const Duration(milliseconds: 600), () {
                if (mounted) setState(() => _pin = '');
              });
              return;
            }
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) setState(() => _isConfirming = true);
            });
          }
        }
      } else {
        if (_confirmPin.length < 6) {
          _confirmPin += number;
          if (_confirmPin.length == 6) _verifyAndSave();
        }
      }
    });
  }

  void _onDeleteTapped() {
    HapticFeedback.lightImpact();
    setState(() {
      _strengthError = null;
      if (!_isConfirming && _pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      } else if (_isConfirming && _confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      }
    });
  }

  Future<void> _verifyAndSave() async {
    if (_pin == _confirmPin) {
      setState(() => _isSaving = true);
      await SecureStorageService.savePin(_pin);
      if (mounted) {
        TWSnackbar.showSuccess(context, 'PIN created successfully!');
        widget.onPinCreated();
      }
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _confirmPin = '';
        _isConfirming = false;
      });
      if (mounted) TWSnackbar.showError(context, 'PINs do not match. Try again.');
    }
  }

  Widget _buildDot(bool isFilled) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 16,
      width: 16,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.kekeGreen : _dotEmpty,
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
        height: 72,
        width: 72,
        decoration: BoxDecoration(
          color: _keyBg,
          shape: BoxShape.circle,
          border: Border.all(color: _keyBorder),
        ),
        child: Center(
          child: Text(
            number,
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, color: _textColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _isConfirming
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: _textColor),
                onPressed: () => setState(() { _isConfirming = false; _confirmPin = ''; }),
              )
            : IconButton(
                icon: Icon(Icons.close, color: _textColor),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Header
            Text(
              _isConfirming ? 'Confirm your PIN' : 'Create a 6-digit PIN',
              style: AppTypography.heading2.copyWith(color: _textColor),
            ).animate().fade().slideY(begin: 0.2),
            const SizedBox(height: 10),
            Text(
              _isConfirming
                  ? 'Re-enter your PIN to confirm.'
                  : 'This PIN unlocks the app and authorizes transfers.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: _mutedColor),
            ).animate().fade().slideY(begin: 0.2),

            const Spacer(),

            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) => _buildDot(i < currentPin.length)),
            ),

            // Strength / mismatch error
            if (_strengthError != null) ...[
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _strengthError!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.errorRed),
                ).animate().shake(duration: 400.ms),
              ),
            ],

            const Spacer(),

            // Numpad or loading
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
                      const SizedBox(height: 20),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 72),
                        _buildNumpadButton('0'),
                        GestureDetector(
                          onTap: _onDeleteTapped,
                          child: SizedBox(
                            height: 72,
                            width: 72,
                            child: Center(child: Icon(Icons.backspace_outlined, color: _textColor, size: 26)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fade().slideY(begin: 0.1),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
