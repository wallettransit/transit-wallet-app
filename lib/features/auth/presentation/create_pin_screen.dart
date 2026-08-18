import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../core/components/tw_snackbar.dart';

class CreatePinScreen extends StatefulWidget {
  final VoidCallback onPinCreated;

  const CreatePinScreen({super.key, required this.onPinCreated});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isSaving = false;

  void _onNumberTapped(String number) {
    setState(() {
      if (!_isConfirming) {
        if (_pin.length < 4) _pin += number;
        if (_pin.length == 4) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) setState(() => _isConfirming = true);
          });
        }
      } else {
        if (_confirmPin.length < 4) _confirmPin += number;
        if (_confirmPin.length == 4) {
          _verifyAndSave();
        }
      }
    });
  }

  void _onDeleteTapped() {
    setState(() {
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
      setState(() {
        _confirmPin = '';
        _isConfirming = false;
      });
      if (mounted) {
        TWSnackbar.showError(context, 'PINs do not match. Try again.');
      }
    }
  }

  Widget _buildDot(bool isFilled) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 16,
      width: 16,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.kekeGreen : Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: AppColors.kekeGreen.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
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
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Center(
          child: Text(
            number,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _isConfirming
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isConfirming = false;
                    _confirmPin = '';
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              _isConfirming ? 'Confirm your PIN' : 'Create a PIN',
              style: AppTypography.heading2.copyWith(color: Colors.white),
            ).animate().fade().slideY(begin: 0.2),
            const SizedBox(height: 12),
            Text(
              'This will be used to unlock the app and authorize transfers.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: Colors.white54),
            ).animate().fade().slideY(begin: 0.2),
            const Spacer(),
            
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return _buildDot(index < currentPin.length)
                    .animate(target: index < currentPin.length ? 1 : 0)
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 150.ms)
                    .then()
                    .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 150.ms);
              }),
            ),
            
            const Spacer(),
            
            // Numpad
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
                          for (int j = 1; j <= 3; j++)
                            _buildNumpadButton('${(i * 3) + j}'),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 72), // Empty space
                        _buildNumpadButton('0'),
                        GestureDetector(
                          onTap: _onDeleteTapped,
                          child: Container(
                            height: 72,
                            width: 72,
                            child: const Center(
                              child: Icon(Icons.backspace_outlined, color: Colors.white, size: 28),
                            ),
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
