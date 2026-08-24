import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/components/tw_snackbar.dart';

enum _ForgotPinStep { requestOtp, verifyOtp, newPin, confirmPin }

class ForgotPinScreen extends ConsumerStatefulWidget {
  const ForgotPinScreen({super.key});

  @override
  ConsumerState<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends ConsumerState<ForgotPinScreen> {
  _ForgotPinStep _step = _ForgotPinStep.requestOtp;
  bool _isLoading = false;

  // OTP step
  final _otpController = TextEditingController();
  String _phoneHint = '';

  // New PIN step
  String _pin = '';
  String _newPin = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPhoneHint();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _loadPhoneHint() async {
    final user = Supabase.instance.client.auth.currentUser;
    final phone = user?.phone ?? user?.userMetadata?['phone'] as String?;
    if (phone != null && phone.length > 4) {
      setState(() => _phoneHint = '****${phone.substring(phone.length - 4)}');
    } else {
      setState(() => _phoneHint = 'your registered number');
    }
  }

  Future<void> _sendOtp() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final phone = user?.phone ?? user?.userMetadata?['phone'] as String?;
      if (phone == null || phone.isEmpty) {
        throw Exception('No phone number found on your account.');
      }
      await Supabase.instance.client.auth.signInWithOtp(phone: phone);
      if (mounted) {
        setState(() => _step = _ForgotPinStep.verifyOtp);
        TWSnackbar.showSuccess(context, 'OTP sent to $_phoneHint');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      setState(() => _error = 'Please enter the full 6-digit OTP.');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final phone = user?.phone ?? user?.userMetadata?['phone'] as String?;
      if (phone == null) throw Exception('No phone number found.');

      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: otp,
      );
      if (mounted) setState(() => _step = _ForgotPinStep.newPin);
    } catch (e) {
      if (mounted) setState(() => _error = 'Invalid OTP. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---- PIN Numpad logic ----
  void _onNumberTapped(String number) {
    HapticFeedback.selectionClick();
    if (_pin.length < 6) {
      setState(() { _error = null; _pin += number; });
      if (_pin.length == 6) {
        if (_step == _ForgotPinStep.newPin) {
          final err = SecureStorageService.validatePinStrength(_pin);
          if (err != null) {
            HapticFeedback.vibrate();
            setState(() { _error = err; _pin = ''; });
            return;
          }
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) setState(() { _newPin = _pin; _pin = ''; _step = _ForgotPinStep.confirmPin; });
          });
        } else if (_step == _ForgotPinStep.confirmPin) {
          _saveNewPin();
        }
      }
    }
  }

  void _onDeleteTapped() {
    HapticFeedback.lightImpact();
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _saveNewPin() async {
    if (_pin != _newPin) {
      HapticFeedback.vibrate();
      setState(() { _error = 'PINs do not match. Try again.'; _pin = ''; _step = _ForgotPinStep.newPin; _newPin = ''; });
      return;
    }
    setState(() => _isLoading = true);
    await SecureStorageService.savePin(_newPin);
    if (mounted) {
      TWSnackbar.showSuccess(context, 'PIN reset successfully!');
      Navigator.pop(context);
    }
  }

  // ---- UI Builders ----
  Widget _buildDot(bool isFilled) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 14, width: 14,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.kekeGreen : const Color(0xFFE2E8F0),
        shape: BoxShape.circle,
        boxShadow: isFilled ? [BoxShadow(color: AppColors.kekeGreen.withOpacity(0.4), blurRadius: 8)] : null,
      ),
    );
  }

  Widget _buildNumpadButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberTapped(number),
      child: Container(
        height: 68, width: 68,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Text(number,
              style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.paper)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.paper, size: 18),
          onPressed: () {
            if (_step == _ForgotPinStep.verifyOtp) {
              setState(() { _step = _ForgotPinStep.requestOtp; _otpController.clear(); _error = null; });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text('Reset PIN',
            style: GoogleFonts.outfit(color: AppColors.paper, fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case _ForgotPinStep.requestOtp:
        return _buildRequestOtpStep();
      case _ForgotPinStep.verifyOtp:
        return _buildVerifyOtpStep();
      case _ForgotPinStep.newPin:
      case _ForgotPinStep.confirmPin:
        return _buildPinStep();
    }
  }

  Widget _buildRequestOtpStep() {
    return Padding(
      key: const ValueKey('requestOtp'),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_android_outlined, color: AppColors.kekeGreen, size: 36),
          ).animate().scale(delay: 100.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text('Verify your identity', style: AppTypography.heading2.copyWith(color: AppColors.paper))
              .animate().fade().slideY(begin: 0.2),
          const SizedBox(height: 10),
          Text(
            'We\'ll send a one-time code to $_phoneHint to verify it\'s you before resetting your PIN.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.muted, height: 1.5),
          ).animate().fade(delay: 100.ms),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _buildErrorBox(_error!),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kekeGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Send Verification Code',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildVerifyOtpStep() {
    return Padding(
      key: const ValueKey('verifyOtp'),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFFDBEAFE), shape: BoxShape.circle),
            child: const Icon(Icons.sms_outlined, color: Color(0xFF2563EB), size: 36),
          ).animate().scale(delay: 100.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text('Enter the code', style: AppTypography.heading2.copyWith(color: AppColors.paper))
              .animate().fade(),
          const SizedBox(height: 10),
          Text('Enter the 6-digit code sent to $_phoneHint.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.muted)).animate().fade(),
          const SizedBox(height: 28),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            autofocus: true,
            style: GoogleFonts.outfit(
              fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.w700, color: AppColors.paper),
            decoration: InputDecoration(
              counterText: '',
              hintText: '------',
              hintStyle: TextStyle(color: Colors.grey[300], letterSpacing: 12),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.kekeGreen, width: 2),
              ),
            ),
            onChanged: (val) { if (val.length == 6) _verifyOtp(); },
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _buildErrorBox(_error!).animate().shake(),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kekeGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Verify Code',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _isLoading ? null : _sendOtp,
              child: Text('Resend code',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.kekeGreen, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPinStep() {
    final isConfirm = _step == _ForgotPinStep.confirmPin;
    return Padding(
      key: ValueKey(_step),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(isConfirm ? 'Confirm new PIN' : 'Create new PIN',
              style: AppTypography.heading2.copyWith(color: AppColors.paper))
              .animate().fade().slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text(isConfirm ? 'Re-enter your new PIN.' : 'Choose a strong 6-digit PIN.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.muted))
              .animate().fade(),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) => _buildDot(i < _pin.length)),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: AppColors.errorRed))
                .animate().shake(),
          ],
          const Spacer(),
          if (_isLoading)
            const CircularProgressIndicator(color: AppColors.kekeGreen)
          else
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
                      const SizedBox(width: 68),
                      _buildNumpadButton('0'),
                      GestureDetector(
                        onTap: _onDeleteTapped,
                        child: SizedBox(
                          height: 68, width: 68,
                          child: Center(child: Icon(Icons.backspace_outlined, color: AppColors.paper, size: 24)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorRed.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorRed, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: AppTypography.bodySmall.copyWith(color: AppColors.errorRed))),
        ],
      ),
    );
  }
}
