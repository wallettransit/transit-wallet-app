import 'package:mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'driver_login_screen.dart';
import 'driver_otp_screen.dart';
import '../../../../core/components/tw_logo.dart';
import '../../../core/components/tw_snackbar.dart';
import '../../../core/components/tw_phone_prefix.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  bool _agreed = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
                              'NEW ACCOUNT',
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
                    const SizedBox(height: 24),
                    
                    // heading-block
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Driver Account',
                          style: GoogleFonts.outfit(
                            color: AppTheme.paper,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 40.3 / 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join thousands of riders in Nigeria receiving fares directly into safe custodial ledger wallets.',
                          style: GoogleFonts.manrope(
                            color: AppTheme.muted,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 24.0 / 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // form
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField('Full Name', 'Alhaji Kehinde'),
                        const SizedBox(height: 16),
                        
                        // phone-field
                        Text(
                          'Phone Number',
                          style: GoogleFonts.manrope(
                            color: AppTheme.paper,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 21.0 / 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 56,
                          child: TextField(
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.manrope(color: AppTheme.paper, fontSize: 16, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: '812 345 6789',
                              hintStyle: GoogleFonts.manrope(color: AppTheme.muted, fontSize: 16),
                              filled: true,
                              fillColor: AppColors.cardBackground,
                              prefixIcon: const TWPhonePrefix(),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.borderStroke, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.kekeGreen, width: 1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildPasswordField('Choose Password', 'At least 8 characters', _obscurePassword, () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        }),
                        const SizedBox(height: 16),
                        
                        _buildPasswordField('Confirm Password', 'Re-enter password', _obscureConfirm, () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        }),
                        const SizedBox(height: 24),
                        
                        // terms-checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreed = !_agreed;
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  color: _agreed ? AppTheme.kekeGreen : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _agreed ? AppTheme.kekeGreen : AppTheme.muted.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: _agreed ? const Icon(Icons.check, size: 14, color: AppTheme.ink) : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "I agree to TransitWallet's Terms of Service and Privacy Policy.",
                                style: GoogleFonts.manrope(
                                  color: AppTheme.muted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 21.0 / 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ].animate(interval: 80.ms, delay: 200.ms).fade(duration: 400.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    ),
                  ],
                ),
              ),
            ),
            
            // bottom-container
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _agreed ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DriverOtpScreen()),
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.kekeGreen,
                        foregroundColor: AppTheme.ink,
                        disabledBackgroundColor: AppTheme.kekeGreen.withOpacity(0.3),
                        disabledForegroundColor: AppTheme.ink.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Create Account',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 20.2 / 16,
                        ),
                      ),
                    ).animate(target: _agreed ? 1 : 0).shimmer(duration: 2000.ms, color: Colors.white24).scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.02, 1.02),
                      curve: Curves.easeOut,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const DriverLoginScreen()),
                          );
                        },
                        child: Text(
                          'Log In',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: AppTheme.paper,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 21.0 / 14,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: TextField(
            style: GoogleFonts.manrope(color: AppTheme.paper, fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.manrope(color: AppTheme.muted, fontSize: 16),
              filled: true,
              fillColor: AppColors.cardBackground,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderStroke, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.kekeGreen, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, String hint, bool obscure, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: AppTheme.paper,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 21.0 / 14,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: TextField(
            obscureText: obscure,
            style: GoogleFonts.manrope(color: AppTheme.paper, fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.manrope(color: AppTheme.muted, fontSize: 16),
              filled: true,
              fillColor: AppColors.cardBackground,
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.muted,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderStroke, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.kekeGreen, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
