import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_bank_account_card.dart';
import 'withdraw_success_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/wallet_repository.dart';
import '../../../../core/components/tw_snackbar.dart';
import '../../../../core/components/tw_transaction_pin_prompt.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../auth/presentation/create_pin_screen.dart';
import '../data/wallet_repository.dart';
import '../../../../core/components/tw_snackbar.dart';

class WithdrawConfirmScreen extends ConsumerStatefulWidget {
  final double amount;
  final String bankName;
  final String accountNumber;
  final String accountName;

  const WithdrawConfirmScreen({
    super.key,
    required this.amount,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });

  @override
  ConsumerState<WithdrawConfirmScreen> createState() => _WithdrawConfirmScreenState();
}

class _WithdrawConfirmScreenState extends ConsumerState<WithdrawConfirmScreen> {
  bool _isProcessing = false;

  void _processWithdrawal() async {
    setState(() => _isProcessing = true);
    
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      setState(() => _isProcessing = false);
      return;
    }

    // Step 1: Ensure user has a PIN
    final hasPin = await SecureStorageService.hasPin();
    if (!hasPin) {
      setState(() => _isProcessing = false);
      if (mounted) {
        TWSnackbar.showError(context, 'You must create a PIN before withdrawing.');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreatePinScreen(
              isDark: false,
              onPinCreated: () => Navigator.pop(context),
            ),
          ),
        );
      }
      return;
    }

    // Step 2: Show PIN prompt
    setState(() => _isProcessing = false); // Pause button spinner
    final bool isAuthorized = await TWTransactionPinPrompt.show(
      context,
      title: 'Authorize Withdrawal',
      subtitle: 'Enter your PIN to withdraw ₦${widget.amount.toStringAsFixed(2)}',
    );

    if (!isAuthorized) {
      return; // User cancelled or failed
    }

    setState(() => _isProcessing = true); // Resume spinner

    // Default to '011' First Bank or similar if bank code is not passed directly (assuming it's passed or mocked for now)
    // Note: The UI currently just passes bankName, not bankCode. Using a mock code '058' (GTB) for integration test.
    final repo = ref.read(walletRepositoryProvider);
    final res = await repo.requestDriverPayout(
      userId: user.id,
      amount: widget.amount,
      accountNumber: widget.accountNumber,
      bankCode: '058', // Mocking GTB code until Bank Selection UI passes it down
      accountName: widget.accountName,
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      
      if (res['success'] == true) {
        ref.invalidate(walletBalanceProvider);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WithdrawSuccessScreen(amount: widget.amount),
          ),
        );
      } else {
        TWSnackbar.showError(context, res['message'] ?? 'Withdrawal failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double fee = 50.0; // Flat fee
    final double totalDeduction = widget.amount + fee;

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Confirm Withdrawal',
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
                    // Summary Card
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.borderStroke, width: 1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Amount to Withdraw',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₦${widget.amount.toStringAsFixed(2)}',
                            style: AppTypography.heading1.copyWith(color: AppColors.paper, fontSize: 36),
                          ),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Divider(color: AppColors.borderStroke, height: 1),
                          ),
                          
                          _buildSummaryRow('Withdrawal Fee', '₦${fee.toStringAsFixed(2)}'),
                          const SizedBox(height: 16),
                          _buildSummaryRow(
                            'Total Deduction', 
                            '₦${totalDeduction.toStringAsFixed(2)}', 
                            isBold: true,
                          ),
                        ],
                      ),
                    ).animate().fade().slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    // Bank Destination
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destination Account',
                          style: AppTypography.heading3.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        TWBankAccountCard(
                          bankName: widget.bankName,
                          maskedAccountNumber: widget.accountNumber,
                          accountName: widget.accountName,
                          isVerified: true,
                        ),
                      ],
                    ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),
            ),
            
            // Action
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: AppColors.ink,
              ),
              child: TWButton(
                label: 'Swipe to Withdraw',
                isLoading: _isProcessing,
                onPressed: _isProcessing ? null : _processWithdrawal,
              ),
            ).animate().fade(delay: 200.ms).slideY(begin: 1.0, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isBold ? AppColors.paper : AppColors.muted,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.paper,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
