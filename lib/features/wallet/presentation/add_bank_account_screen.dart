import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_text_field.dart';
import '../../../../core/components/tw_bank_account_card.dart';

class AddBankAccountScreen extends StatefulWidget {
  final String bankName;

  const AddBankAccountScreen({
    super.key,
    required this.bankName,
  });

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final TextEditingController _accountController = TextEditingController();
  bool _isVerifying = false;
  bool _isVerified = false;

  void _verifyAccount() {
    if (_accountController.text.length < 10) return;

    setState(() {
      _isVerifying = true;
    });

    // Mock API Verification
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _isVerified = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Add Account',
          style: AppTypography.heading3.copyWith(color: AppColors.paper),
        ),
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
                    Text(
                      widget.bankName,
                      style: AppTypography.heading1.copyWith(fontSize: 28),
                    ).animate().fade().slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Enter your 10-digit account number below to verify and link your account.',
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
                    ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    TWTextField(
                      controller: _accountController,
                      label: 'Account Number',
                      hintText: '0123456789',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.numbers, color: AppColors.muted),
                      onChanged: (val) {
                        if (_isVerified) {
                          setState(() => _isVerified = false);
                        }
                        if (val.length == 10 && !_isVerifying && !_isVerified) {
                          _verifyAccount();
                        }
                      },
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    if (_isVerifying)
                      const Center(
                        child: CircularProgressIndicator(color: AppColors.kekeGreen),
                      ).animate().fade()
                    else if (_isVerified)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verified Account',
                            style: AppTypography.label.copyWith(color: AppColors.kekeGreen),
                          ),
                          const SizedBox(height: 12),
                          TWBankAccountCard(
                            bankName: widget.bankName,
                            maskedAccountNumber: _accountController.text,
                            accountName: 'ALHAJI KEHINDE',
                            isVerified: true,
                          ).animate().fade().scale(curve: Curves.easeOutBack),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            
            // Bottom Action
            if (_isVerified)
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: TWButton(
                  label: 'Save & Link Bank',
                  onPressed: () {
                    // Pop back to cash out screen
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ).animate().fade().slideY(begin: 1.0, end: 0),
          ],
        ),
      ),
    );
  }
}
