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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DriverVehicleSetupScreen()),
        );
      } else {
        setState(() => _errorMessage = result['message']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.kekeGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_outlined, color: AppColors.kekeGreen, size: 32),
              ).animate().scale(delay: 200.ms, duration: 400.ms),
              
              const SizedBox(height: 24),
              
              Text(
                'Verify your Identity',
                style: GoogleFonts.outfit(
                  color: AppColors.paper,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 8),
              
              Text(
                'To accept payouts directly to your bank account, we need your BVN or NIN as part of our secure onboarding.',
                style: GoogleFonts.manrope(
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
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.manrope(
                              color: Colors.redAccent,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(),

              TWTextField(
                label: 'BVN or NIN',
                controller: _bvnController,
                hintText: 'Enter 11-digit number',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.numbers, color: AppColors.paper, size: 20),
              ).animate().fade(delay: 500.ms).slideY(begin: 0.1),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: TWButton(
                  label: _isLoading ? 'Verifying...' : 'Verify & Continue',
                  onPressed: _isLoading ? () {} : _submitKYC,
                ),
              ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
