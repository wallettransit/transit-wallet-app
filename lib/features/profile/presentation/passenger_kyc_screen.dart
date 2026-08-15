import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_logo.dart';
import '../../auth/providers/auth_provider.dart';
import '../../wallet/presentation/passenger_main_layout.dart';
import '../../kyc/data/kyc_repository.dart';

class PassengerKycScreen extends ConsumerStatefulWidget {
  const PassengerKycScreen({super.key});

  @override
  ConsumerState<PassengerKycScreen> createState() => _PassengerKycScreenState();
}

class _PassengerKycScreenState extends ConsumerState<PassengerKycScreen> {
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _bvnController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _dobController.dispose();
    _addressController.dispose();
    _bvnController.dispose();
    super.dispose();
  }

  Future<void> _submitKyc() async {
    if (_dobController.text.isEmpty || 
        _addressController.text.isEmpty || 
        _bvnController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }

    if (_bvnController.text.length != 11) {
      setState(() => _errorMessage = 'BVN must be 11 digits.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = ref.read(kycRepositoryProvider);
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    final result = await repo.verifyAndUpgradeTier(
      userId: user.id,
      bvn: _bvnController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        // Navigate to Wallet upon success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PassengerMainLayout()),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Force them to complete it
        title: const TWLogo(size: 16),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Unlock Your Wallet',
                style: GoogleFonts.outfit(
                  color: AppColors.paper,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'CBN regulations require us to verify your identity before you can hold a balance or make transfers.',
                style: GoogleFonts.manrope(
                  color: AppColors.muted,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 40),

              // Date of Birth
              _buildInputField(
                controller: _dobController,
                label: 'Date of Birth (YYYY-MM-DD)',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),

              // Address
              _buildInputField(
                controller: _addressController,
                label: 'Residential Address',
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 20),

              // BVN
              _buildInputField(
                controller: _bvnController,
                label: 'Bank Verification Number (BVN)',
                icon: Icons.security,
                keyboardType: TextInputType.number,
                maxLength: 11,
              ),
              
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.manrope(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],

              const SizedBox(height: 48),
              
              TWButton(
                label: 'Verify & Upgrade to Tier 1',
                isLoading: _isLoading,
                onPressed: _submitKyc,
              ),
              
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 14, color: AppColors.muted),
                    const SizedBox(width: 6),
                    Text(
                      'Your data is encrypted and securely stored.',
                      style: GoogleFonts.manrope(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLength: maxLength,
              style: GoogleFonts.manrope(color: AppColors.paper, fontSize: 16),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: GoogleFonts.manrope(color: AppColors.muted),
                border: InputBorder.none,
                counterText: '', // Hide default counter for maxlength
              ),
            ),
          ),
        ],
      ),
    );
  }
}
