import 'package:mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'driver_vehicle_registration_screen.dart';
import '../../../../core/components/tw_logo.dart';

class DriverOtpScreen extends StatefulWidget {
  final String phone;
  final String? email;

  const DriverOtpScreen({
    super.key,
    required this.phone,
    this.email,
  });

  @override
  State<DriverOtpScreen> createState() => _DriverOtpScreenState();
}

class _DriverOtpScreenState extends State<DriverOtpScreen> {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  int _focusedIndex = 0;
  bool _useEmail = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {
            _focusedIndex = i;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // brand-header
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TWLogo(size: 18, textColor: AppTheme.paper),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.kekeGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.kekeGreen.withOpacity(0.5), width: 1),
                            ),
                            child: Text(
                              'SECURITY',
                              style: GoogleFonts.manrope(
                                color: AppTheme.kekeGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                height: 15.0 / 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // heading-block
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _useEmail ? 'Verify Your Email' : 'Verify Your Phone',
                          style: GoogleFonts.outfit(
                            color: AppTheme.paper,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 40.3 / 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We sent a 6-digit verification code to ${_useEmail ? widget.email : widget.phone}. Please enter it below.',
                          style: GoogleFonts.manrope(
                            color: AppTheme.muted,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 24.0 / 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // otp-row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) => _buildOtpBox(index).animate(delay: (index * 100).ms).scale(duration: 400.ms, curve: Curves.easeOutBack)),
                    ),
                    const SizedBox(height: 48),
                    
                    // resend-block
                    Column(
                      children: [
                        Text(
                          "Didn't receive a code?",
                          style: GoogleFonts.manrope(
                            color: AppTheme.muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 21.0 / 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Resend in 0:45',
                          style: GoogleFonts.manrope(
                            color: AppTheme.kekeGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 21.0 / 14,
                          ),
                        ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: 2000.ms, color: Colors.white30),
                        const SizedBox(height: 16),
                        if (widget.email != null && widget.email!.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _useEmail = !_useEmail;
                              });
                              // Add logic to trigger resend to the new destination if needed
                            },
                            child: Text(
                              _useEmail ? 'Send code to Phone instead?' : 'Send code to Email instead?',
                              style: GoogleFonts.manrope(
                                color: AppTheme.kekeGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: AppTheme.kekeGreen,
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const DriverVehicleRegistrationScreen()),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.kekeGreen,
                              foregroundColor: AppTheme.ink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Verify',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 20.2 / 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Use another phone number?",
                              style: GoogleFonts.manrope(
                                color: AppTheme.muted,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 21.0 / 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Go Back',
                                style: GoogleFonts.manrope(
                                  color: AppTheme.kekeGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 21.0 / 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    bool isFocused = _focusedIndex == index;
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? AppTheme.kekeGreen : AppColors.borderStroke,
          width: isFocused ? 2 : 1,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: AppTheme.paper,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 30.2 / 24,
          ),
          cursorColor: AppTheme.kekeGreen,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (val) => _onChanged(val, index),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
