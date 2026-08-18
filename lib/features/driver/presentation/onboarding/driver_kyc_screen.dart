import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_text_field.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/driver_repository.dart';
import '../../../kyc/data/kyc_repository.dart';
import 'driver_vehicle_setup_screen.dart';

class DriverKYCScreen extends ConsumerStatefulWidget {
  const DriverKYCScreen({super.key});

  @override
  ConsumerState<DriverKYCScreen> createState() => _DriverKYCScreenState();
}

class _DriverKYCScreenState extends ConsumerState<DriverKYCScreen> {
  final _bvnController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitKYC() async {
    final bvn = _bvnController.text.trim();
    if (bvn.length < 11) {
      setState(() => _errorMessage = 'Please enter a valid 11-digit BVN or NIN');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not found. Please log in again.';
      });
      return;
    }

    final repo = ref.read(kycRepositoryProvider);
    final result = await repo.verifyAndUpgradeTier(userId: currentUser.id, bvn: bvn);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Identity verified successfully!'), backgroundColor: AppColors.kekeGreen),
        );
      } else {
        setState(() => _errorMessage = result['message']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24.0, 
            right: 24.0, 
            top: 16.0, 
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pill handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.kekeGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.kekeGreen.withOpacity(0.4)),
                ),
                child: const Icon(Icons.verified_user_outlined, color: AppColors.kekeGreen, size: 32),
              ).animate().scale(delay: 200.ms, duration: 400.ms),
              
              const SizedBox(height: 24),
              
              Text(
                'Verify your Identity',
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.paper,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 12),
              
              Text(
                'To accept payouts directly to your bank account, we need your BVN or NIN as part of our secure onboarding.',
                style: GoogleFonts.outfit(
                  color: AppColors.muted,
                  fontSize: 15,
                  height: 1.5,
                ),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 40),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.outfit(
                              color: Colors.redAccent,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(),

              Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    labelStyle: GoogleFonts.outfit(color: AppColors.muted),
                    hintStyle: GoogleFonts.outfit(color: Colors.white24),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.kekeGreen),
                    ),
                  ),
                ),
                child: TextField(
                  controller: _bvnController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.outfit(color: AppColors.paper, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'BVN or NIN',
                    hintText: 'Enter 11-digit number',
                    prefixIcon: Icon(Icons.numbers, color: AppColors.muted, size: 20),
                  ),
                ),
              ).animate().fade(delay: 500.ms).slideY(begin: 0.1),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? () {} : _submitKYC,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kekeGreen,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.ink, strokeWidth: 2))
                    : Text(
                        'Verify & Continue',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
