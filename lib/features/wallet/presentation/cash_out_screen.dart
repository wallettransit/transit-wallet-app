import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_bank_account_card.dart';
import 'bank_selection_screen.dart';
import 'withdraw_amount_screen.dart';

class CashOutScreen extends StatefulWidget {
  const CashOutScreen({super.key});

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  bool _isAutoSweepEnabled = true;
  final bool _isBankLinked = true; // Set to true to show withdrawal UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // screen-header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settle Fares',
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.paper,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Transfer your earnings to your bank account',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (!_isBankLinked)
                      // kyc-banner
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.danfoYellow.withOpacity(0.15),
                          border: Border(
                            bottom: BorderSide(color: AppColors.danfoYellow.withOpacity(0.5), width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.danfoYellow.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Center(
                                child: Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.danfoYellow),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Link Bank to Cash Out',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.danfoYellow,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Federal regulations require BVN/NIN verification before withdrawal.',
                                    style: AppTypography.label.copyWith(
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 400.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),
                    
                    // main-section
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // balance-card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderStroke, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AVAILABLE FOR IMMEDIATE CASH OUT',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '₦',
                                      style: AppTypography.heading3.copyWith(
                                        color: AppColors.danfoYellow,
                                        fontSize: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '18,450',
                                      style: AppTypography.heading1.copyWith(
                                        color: AppColors.paper,
                                        fontSize: 36,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // bank-account
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payout Destination',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_isBankLinked)
                                TWBankAccountCard(
                                  bankName: 'Guaranty Trust Bank',
                                  maskedAccountNumber: '**** **** 1234',
                                  accountName: 'ALHAJI KEHINDE',
                                  isVerified: true,
                                  actionLabel: 'Change',
                                  onActionTapped: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const BankSelectionScreen()),
                                    );
                                  },
                                )
                              else
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const BankSelectionScreen()),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: AppColors.highlightBackground,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.borderStroke, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.add_circle_outline, color: AppColors.kekeGreen),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Add a bank account',
                                          style: AppTypography.bodyLarge.copyWith(color: AppColors.kekeGreen),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // settlement-options
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Settlement Rules',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.borderStroke, width: 1),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Auto Daily Sweep',
                                            style: AppTypography.bodyLarge.copyWith(
                                              color: AppColors.paper,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Auto-transfer earnings to bank at 10 PM daily',
                                            style: AppTypography.label.copyWith(
                                              color: AppColors.muted,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Custom switch
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isAutoSweepEnabled = !_isAutoSweepEnabled;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        width: 48,
                                        height: 26,
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: _isAutoSweepEnabled ? AppColors.kekeGreen : AppColors.borderStroke,
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        alignment: _isAutoSweepEnabled ? Alignment.centerRight : Alignment.centerLeft,
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: const BoxDecoration(
                                            color: AppColors.paper,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40), // Spacing for bottom nav
                  ],
                ),
              ),
            ),
            
            // bottom-action
            Container(
              padding: const EdgeInsets.all(20.0),
              child: TWButton(
                label: _isBankLinked ? 'Withdraw Funds' : 'Verify BVN & Link Account',
                onPressed: () {
                  if (_isBankLinked) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WithdrawAmountScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BankSelectionScreen()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
