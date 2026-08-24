import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import '../providers/auth_provider.dart';
import '../../profile/presentation/passenger_kyc_screen.dart';
import '../../../core/components/tw_logo.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_typography.dart';
import 'passenger_welcome_screen.dart';
import '../../../../core/services/termii_service.dart';
import '../../../../core/components/tw_snackbar.dart';
import '../../../../core/services/email_otp_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PassengerOtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  
  const PassengerOtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<PassengerOtpVerificationScreen> createState() => _PassengerOtpVerificationScreenState();
}

class _PassengerOtpVerificationScreenState extends State<PassengerOtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;
  String? _pinId;
  bool _emailMode = false;
  
  Timer? _timer;
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _sendOtp();
  }

  Future<void> _sendOtp() async {
    if (_emailMode) {
      await _sendEmailOtp();
      return;
    }
    
    try {
      final pinId = await TermiiService.sendOtp(widget.phoneNumber);
      if (mounted) {
        setState(() {
          _pinId = pinId;
        });
      }
    } catch (e) {
      if (mounted) {
        TWSnackbar.showError(context, e.toString());
      }
    }
  }

  Future<void> _sendEmailOtp() async {
    try {
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email == null) throw Exception('No email found for current user');
      
      final pinId = await EmailOtpService.sendOtp(email);
      if (mounted) {
        setState(() {
          _pinId = pinId;
        });
        TWSnackbar.showSuccess(context, 'Testing OTP (1234) sent to email!');
      }
    } catch (e) {
      if (mounted) {
        TWSnackbar.showError(context, e.toString());
      }
    }
  }

  void _startTimer() {
    _secondsRemaining = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) { c.dispose(); }
    for (var n in _focusNodes) { n.dispose(); }
    super.dispose();
  }

  void _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 4) {
      if (_pinId == null) {
        TWSnackbar.showError(context, 'Wait for OTP to be sent before verifying.');
        return;
      }

      setState(() => _isLoading = true);
      
      try {
        final isValid = _emailMode 
            ? await EmailOtpService.verifyOtp(_pinId!, otp)
            : await TermiiService.verifyOtp(_pinId!, otp);
            
        if (mounted) {
          setState(() => _isLoading = false);
          if (isValid) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PassengerKycScreen()),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          TWSnackbar.showError(context, e.toString());
        }
      }
    } else {
      TWSnackbar.showError(context, 'Please enter a 4-digit code');
    }
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNodes[index].hasFocus ? AppColors.kekeGreen : AppColors.borderStroke,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppTypography.heading1.copyWith(color: AppColors.paper, fontSize: 32),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          }
          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TWLogo(size: 18, textColor: AppColors.paper),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.kekeGreen,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.kekeGreen),
                          ),
                          child: Text(
                            'SECURITY',
                            style: AppTypography.label.copyWith(color: AppColors.ink, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ).animate().fade().slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    // Title
                    Text(
                      'Verify Your Phone',
                      style: AppTypography.heading1.copyWith(color: AppColors.paper, fontSize: 32),
                    ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      _emailMode 
                          ? 'Enter the 4-digit code sent to your email.'
                          : 'Enter the 4-digit code sent to ${widget.phoneNumber}',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 48),
                    
                    // OTP Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (index) => _buildOtpBox(index)),
                    ).animate().fade(delay: 300.ms).slideX(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    // Resend
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Didn't receive a code?",
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _secondsRemaining == 0
                                ? () {
                                    _startTimer();
                                    _sendOtp();
                                    setState(() {});
                                  }
                                : null,
                            child: Text(
                              _secondsRemaining > 0 
                                  ? "Resend in 0:${_secondsRemaining.toString().padLeft(2, '0')}"
                                  : "Resend Code",
                              style: AppTypography.bodyMedium.copyWith(
                                color: _secondsRemaining > 0 ? AppColors.kekeGreen.withOpacity(0.5) : AppColors.kekeGreen, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 400.ms),
                  ],
                ),
              ),
            ),
            
            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TWButton(
                    label: 'Verify',
                    onPressed: _verifyOtp,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 20),
                  
                  if (!_emailMode)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _emailMode = true;
                        });
                        _startTimer();
                        _sendEmailOtp();
                      },
                      child: Text(
                        "Didn't receive SMS? Send OTP via Email",
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.kekeGreen, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Use another phone number? ",
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                      ),
                      Text(
                        "Go Back",
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.kekeGreen, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fade(delay: 500.ms).slideY(begin: 1.0, end: 0),
          ],
        ),
      ),
    );
  }
}
