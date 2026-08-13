import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_button.dart';
import 'passenger_welcome_screen.dart';
import '../../../core/components/tw_logo.dart';

class PassengerOtpVerificationScreen extends StatefulWidget {
  const PassengerOtpVerificationScreen({super.key});

  @override
  State<PassengerOtpVerificationScreen> createState() => _PassengerOtpVerificationScreenState();
}

class _PassengerOtpVerificationScreenState extends State<PassengerOtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    for (var n in _focusNodes) { n.dispose(); }
    super.dispose();
  }

  void _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 4) {
      setState(() => _isLoading = true);
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isLoading = false);
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PassengerWelcomeScreen(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 4-digit code'),
          backgroundColor: AppColors.errorRed,
        ),
      );
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
                      'We sent a 4-digit verification code to +234 *** *** 8903. Please enter it below.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
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
                          Text(
                            "Resend in 0:30",
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.kekeGreen, fontWeight: FontWeight.bold),
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
