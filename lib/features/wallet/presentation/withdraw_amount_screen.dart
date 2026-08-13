import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_bank_account_card.dart';
import 'withdraw_confirm_screen.dart';

class WithdrawAmountScreen extends StatefulWidget {
  final double availableBalance;
  
  const WithdrawAmountScreen({
    super.key,
    this.availableBalance = 18450.0, // Mocked balance for now
  });

  @override
  State<WithdrawAmountScreen> createState() => _WithdrawAmountScreenState();
}

class _WithdrawAmountScreenState extends State<WithdrawAmountScreen> {
  final TextEditingController _amountController = TextEditingController();
  double _enteredAmount = 0.0;
  String? _errorText;

  void _validateAmount(String value) {
    if (value.isEmpty) {
      setState(() {
        _enteredAmount = 0;
        _errorText = null;
      });
      return;
    }

    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      setState(() => _errorText = 'Please enter a valid amount');
      return;
    }

    setState(() {
      _enteredAmount = amount;
      if (amount <= 0) {
        _errorText = 'Amount must be greater than zero';
      } else if (amount > widget.availableBalance) {
        _errorText = 'Insufficient balance';
      } else {
        _errorText = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = _enteredAmount > 0 && _enteredAmount <= widget.availableBalance;

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Withdraw',
          style: AppTypography.heading3.copyWith(color: AppColors.paper),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Balance Display
                    Text(
                      'Available Balance',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                    ).animate().fade().slideY(begin: -0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      '₦${widget.availableBalance.toStringAsFixed(2)}',
                      style: AppTypography.heading1.copyWith(color: AppColors.kekeGreen, fontSize: 32),
                    ).animate().fade(delay: 100.ms).slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 48),
                    
                    // Amount Input
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _errorText != null ? AppColors.errorRed : AppColors.borderStroke,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '₦',
                                style: AppTypography.heading2.copyWith(color: AppColors.muted),
                              ),
                              const SizedBox(width: 8),
                              IntrinsicWidth(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: AppTypography.heading1.copyWith(fontSize: 48),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0',
                                    hintStyle: TextStyle(color: AppColors.muted),
                                  ),
                                  onChanged: _validateAmount,
                                ),
                              ),
                            ],
                          ),
                          if (_errorText != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _errorText!,
                              style: AppTypography.label.copyWith(color: AppColors.errorRed),
                            ).animate().fade().slideY(begin: -0.5, end: 0),
                          ]
                        ],
                      ),
                    ).animate().fade(delay: 200.ms).scale(curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 48),
                    
                    // Selected Bank Summary
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Withdrawing to',
                          style: AppTypography.label.copyWith(color: AppColors.muted),
                        ),
                        const SizedBox(height: 12),
                        const TWBankAccountCard(
                          bankName: 'Guaranty Trust Bank',
                          maskedAccountNumber: '**** **** 1234',
                          accountName: 'ALHAJI KEHINDE',
                          isVerified: true,
                        ),
                      ],
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
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
                label: 'Continue',
                onPressed: isValid
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WithdrawConfirmScreen(
                              amount: _enteredAmount,
                              bankName: 'Guaranty Trust Bank',
                              accountNumber: '**** **** 1234',
                              accountName: 'ALHAJI KEHINDE',
                            ),
                          ),
                        );
                      }
                    : null,
              ),
            ).animate().fade(delay: 400.ms).slideY(begin: 1.0, end: 0),
          ],
        ),
      ),
    );
  }
}
