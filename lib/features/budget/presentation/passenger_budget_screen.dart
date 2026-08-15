import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_button.dart';
import '../providers/budget_provider.dart';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PassengerBudgetScreen extends ConsumerStatefulWidget {
  const PassengerBudgetScreen({super.key});

  @override
  ConsumerState<PassengerBudgetScreen> createState() => _PassengerBudgetScreenState();
}

class _PassengerBudgetScreenState extends ConsumerState<PassengerBudgetScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isSettingBudget = false;
  String? _inputError;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    if (_inputError != null) {
      setState(() => _inputError = null);
    }
    
    // Format with commas as user types
    if (value.isNotEmpty) {
      // Remove all non-digits
      final numericOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (numericOnly.isNotEmpty) {
        final number = int.tryParse(numericOnly) ?? 0;
        final formatted = NumberFormat('#,###').format(number);
        
        if (formatted != value) {
          _amountController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      }
    }
  }

  void _submitBudget() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText);
    
    if (amount == null || amount <= 0) {
      setState(() => _inputError = 'Please enter a valid amount greater than zero.');
      return;
    }
    
    if (amount > 10000000) {
      setState(() => _inputError = 'Budget cannot exceed ₦10,000,000.');
      return;
    }
    
    setState(() {
      _isSettingBudget = true;
      _inputError = null;
    });
    
    await ref.read(budgetProvider.notifier).setBudget(amount);
    
    setState(() => _isSettingBudget = false);
  }

  @override
  Widget build(BuildContext context) {
    final budgetStateAsync = ref.watch(budgetProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Transport Budget', style: AppTypography.heading3.copyWith(color: AppColors.paper)),
      ),
      body: SafeArea(
        child: budgetStateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.danfoYellow)),
          error: (err, stack) => Center(
            child: Text('Error: $err', style: AppTypography.bodyMedium.copyWith(color: AppColors.errorRed)),
          ),
          data: (state) {
            if (state.budget == null) {
              return _buildSetupView();
            } else {
              return _buildDashboardView(state);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSetupView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.highlightBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet, size: 48, color: AppColors.paper),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
          const SizedBox(height: 32),
          Text(
            'Set Your Monthly Target',
            style: AppTypography.heading2.copyWith(color: AppColors.paper),
          ).animate().fade().slideY(),
          const SizedBox(height: 12),
          Text(
            'Keep your transport spending on track automatically. We\'ll notify you before you overspend.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
          ).animate().fade().slideY(),
          const SizedBox(height: 48),
          
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _inputError != null ? AppColors.errorRed : Colors.white.withOpacity(0.1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text('₦', style: AppTypography.heading2.copyWith(color: AppColors.paper)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: AppTypography.heading2.copyWith(color: AppColors.paper),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: _onAmountChanged,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: AppTypography.heading2.copyWith(color: AppColors.muted),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fade().slideY(),
          
          if (_inputError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Text(
                _inputError!,
                style: AppTypography.label.copyWith(color: AppColors.errorRed),
              ).animate().fade(),
            ),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            child: TWButton(
              label: 'Set Budget',
              isLoading: _isSettingBudget,
              onPressed: _submitBudget,
            ),
          ).animate().fade().slideY(),
        ],
      ),
    );
  }

  Widget _buildDashboardView(BudgetState state) {
    final budgetAmount = (state.budget?['amount_kobo'] ?? 0) / 100.0;
    final spentAmount = (state.progress?['spent_kobo'] ?? 0) / 100.0;
    final pctUsed = (state.progress?['pct_used'] ?? 0).toDouble();
    
    // Calculate remaining amount, bounded at 0
    final remaining = (budgetAmount - spentAmount).clamp(0.0, double.infinity);
    
    // Calculate days remaining
    final periodEnd = DateTime.parse(state.budget!['period_end']);
    final daysRemaining = periodEnd.difference(DateTime.now()).inDays.clamp(0, 31);
    
    // Determine status color and message
    Color statusColor = AppColors.kekeGreen;
    String statusMessage = "You're on track";
    bool overBudget = false;
    
    if (pctUsed >= 100) {
      statusColor = AppColors.errorRed;
      statusMessage = "Over budget";
      overBudget = true;
    } else if (pctUsed >= 80) {
      statusColor = AppColors.danfoYellow;
      statusMessage = "Approaching limit";
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current Period', style: AppTypography.bodyMedium.copyWith(color: AppColors.muted)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$daysRemaining days left',
                    style: AppTypography.label.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Main Progress Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spent so far', style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₦${spentAmount.toStringAsFixed(0)}', style: AppTypography.heading1.copyWith(color: AppColors.paper)),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text('/ ₦${budgetAmount.toStringAsFixed(0)}', style: AppTypography.bodyMedium.copyWith(color: AppColors.muted)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (pctUsed / 100).clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: AppColors.ink,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status', style: AppTypography.label.copyWith(color: AppColors.muted)),
                          const SizedBox(height: 4),
                          Text(statusMessage, style: AppTypography.bodyMedium.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Remaining', style: AppTypography.label.copyWith(color: AppColors.muted)),
                          const SizedBox(height: 4),
                          Text('₦${remaining.toStringAsFixed(0)}', style: AppTypography.bodyMedium.copyWith(color: AppColors.paper, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: 0.1),
            
            const SizedBox(height: 24),
            
            // Suggestion Card (if approaching/over budget)
            if (pctUsed >= 80)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danfoYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.danfoYellow.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.danfoYellow.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lightbulb, color: AppColors.danfoYellow, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Budget Tip', style: AppTypography.label.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            overBudget 
                                ? 'Consider using Shared Rides for the rest of the month to minimize your spend.'
                                : 'You are close to your limit. Try booking Shared Rides to stretch your remaining budget.',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fade().slideY(begin: 0.1),
              
            // Recent Spend placeholder (UC-BG4)
            Text('Recent Trips', style: AppTypography.heading3.copyWith(color: AppColors.paper)),
            const SizedBox(height: 16),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, color: AppColors.muted.withOpacity(0.5), size: 48),
                    const SizedBox(height: 16),
                    Text('Your trip breakdown will appear here.', style: AppTypography.bodyMedium.copyWith(color: AppColors.muted)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
