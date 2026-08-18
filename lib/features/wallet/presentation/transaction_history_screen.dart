import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../data/wallet_repository.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Transaction History',
          style: AppTypography.heading3.copyWith(color: AppColors.paper),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: AppColors.muted.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions yet',
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
                    ),
                  ],
                ).animate().fade().slideY(begin: 0.1, end: 0),
              );
            }

            return RefreshIndicator(
              color: AppColors.kekeGreen,
              onRefresh: () async {
                ref.invalidate(transactionHistoryProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return _buildTransactionItem(tx, index);
                },
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.kekeGreen),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Failed to load transactions',
              style: AppTypography.bodyMedium.copyWith(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx, int index) {
    // Parse amount from kobo to Naira
    final amountKobo = tx['amount_kobo'] ?? 0;
    final amountNaira = (amountKobo / 100).toStringAsFixed(2);
    
    final type = tx['type'] as String? ?? 'unknown';
    final status = tx['status'] as String? ?? 'pending';
    
    // Formatting date
    DateTime? date;
    if (tx['created_at'] != null) {
      date = DateTime.tryParse(tx['created_at'])?.toLocal();
    }
    final dateString = date != null ? DateFormat('MMM d, h:mm a').format(date) : 'Unknown time';

    IconData icon;
    Color iconColor;
    String title;
    bool isCredit;

    switch (type) {
      case 'deposit':
      case 'topup':
        icon = Icons.account_balance_wallet;
        iconColor = AppColors.kekeGreen;
        title = 'Wallet Top-Up';
        isCredit = true;
        break;
      case 'withdrawal':
      case 'payout':
        icon = Icons.account_balance;
        iconColor = AppColors.danfoYellow;
        title = 'Bank Withdrawal';
        isCredit = false;
        break;
      case 'payment':
        icon = Icons.directions_bus;
        iconColor = AppColors.paper;
        title = 'Ride Payment';
        isCredit = false;
        break;
      case 'transfer':
        icon = Icons.send;
        iconColor = AppColors.paper;
        title = 'Transfer';
        isCredit = amountKobo > 0; // Assuming positive kobo means credit if unified, otherwise need logic based on sender/receiver
        break;
      default:
        icon = Icons.swap_horiz;
        iconColor = AppColors.muted;
        title = 'Transaction';
        isCredit = true;
    }

    // Status colors
    Color statusColor = AppColors.muted;
    if (status == 'completed') statusColor = AppColors.kekeGreen;
    if (status == 'failed' || status == 'reversed') statusColor = Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  dateString,
                  style: AppTypography.label.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}₦$amountNaira',
                style: AppTypography.bodyLarge.copyWith(
                  color: isCredit ? AppColors.kekeGreen : AppColors.paper,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status.toUpperCase(),
                style: AppTypography.label.copyWith(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(delay: (50 * index.clamp(0, 10)).ms).slideX(begin: 0.1, end: 0);
  }
}
