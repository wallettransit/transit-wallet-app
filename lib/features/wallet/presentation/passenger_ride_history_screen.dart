import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../profile/providers/profile_provider.dart';
import '../data/wallet_repository.dart';

class PassengerRideHistoryScreen extends ConsumerWidget {
  const PassengerRideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(passengerStatsProvider);
    final historyAsync = ref.watch(transactionHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text('History', style: AppTypography.label.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: AppColors.cardBackground, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white54, size: 20),
                    ),
                  )
                ],
              ),
            ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Ride History & Expenses', style: AppTypography.heading2.copyWith(color: AppColors.paper)),
                  const SizedBox(height: 4),
                  Text('Your automatic transport expense log', style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
                ],
              ),
            ).animate().fade(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
            
            // Monthly Summary (from stats provider)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: statsAsync.when(
                data: (stats) {
                  final totalRides = int.parse(stats?['total_rides']?.toString() ?? '0');
                  final totalSpentKobo = double.parse(stats?['total_spent_kobo']?.toString() ?? '0');
                  final totalSpentNaira = totalSpentKobo / 100;
                  final avgFare = totalRides > 0 ? (totalSpentNaira / totalRides) : 0.0;

                  final spentFormatted = NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(totalSpentNaira);
                  final avgFormatted = NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(avgFare);

                  return _buildUnifiedSummary(spentFormatted, '$totalRides', avgFormatted)
                      .animate().fade(delay: 200.ms, duration: 500.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack);
                },
                loading: () => Shimmer.fromColors(
                  baseColor: Colors.white12,
                  highlightColor: Colors.white24,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                  ),
                ),
                error: (_, __) => const SizedBox(),
              ),
            ),
            
            // Transactions List
            Expanded(
              child: historyAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white10),
                            ),
                            child: const Icon(Icons.history, size: 48, color: Colors.white24),
                          ),
                          const SizedBox(height: 24),
                          Text('No transactions yet.', style: AppTypography.bodyLarge.copyWith(color: Colors.white54, fontWeight: FontWeight.bold)),
                        ],
                      ).animate().fade(delay: 300.ms),
                    );
                  }

                  // Group transactions by date
                  final Map<String, List<Map<String, dynamic>>> grouped = {};
                  for (var tx in transactions) {
                    final dateStr = tx['created_at'] as String?;
                    if (dateStr == null) continue;
                    
                    final date = DateTime.parse(dateStr).toLocal();
                    final formattedDate = _formatDateHeader(date);
                    
                    if (!grouped.containsKey(formattedDate)) {
                      grouped[formattedDate] = [];
                    }
                    grouped[formattedDate]!.add(tx);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, index) {
                      final dateKey = grouped.keys.elementAt(index);
                      final txs = grouped[dateKey]!;
                      
                      return _buildDateGroup(
                        dateKey, 
                        txs.map((tx) => _buildTransactionItem(tx)).toList()
                      ).animate().fade(delay: Duration(milliseconds: 300 + (index * 100)), duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuart);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.kekeGreen)),
                error: (e, __) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today, ${DateFormat('dd MMM').format(date)}';
    } else if (checkDate == yesterday) {
      return 'Yesterday, ${DateFormat('dd MMM').format(date)}';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  Widget _buildUnifiedSummary(String spent, String rides, String avgFare) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3A26), Color(0xFF071F13)], // Deep elegant emerald to dark forest
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F3A26).withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 12)),
        ],
        border: Border.all(color: AppColors.kekeGreen.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatColumn('TOTAL SPENT', spent, Colors.white),
          Container(width: 1, height: 40, color: Colors.white10),
          _buildStatColumn('RIDES', rides, Colors.white70),
          Container(width: 1, height: 40, color: Colors.white10),
          _buildStatColumn('AVG FARE', avgFare, AppColors.kekeGreen),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label.copyWith(color: AppColors.kekeGreen.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.spaceGrotesk(color: valueColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      ],
    );
  }

  Widget _buildDateGroup(String date, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 4),
          child: Row(
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.kekeGreen, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(date, style: AppTypography.label.copyWith(color: Colors.white70, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Column(
          children: items,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final amountKobo = double.tryParse(tx['amount_kobo']?.toString() ?? '0') ?? 0;
    final amountNaira = (amountKobo / 100).abs();
    final isCredit = amountKobo > 0;
    
    final formattedAmount = NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(amountNaira);
    
    final type = tx['type'] as String? ?? 'unknown';
    String title = 'Transaction';
    IconData icon = Icons.receipt_long;
    Color iconBg = AppColors.kekeGreen;

    if (type == 'wallet_topup') {
      title = 'Wallet Top Up';
      icon = Icons.add;
      iconBg = AppColors.kekeGreen;
    } else if (type == 'ride_payment') {
      title = 'Ride Payment';
      icon = Icons.directions_bus;
      iconBg = AppColors.danfoYellow;
    } else if (type == 'transfer') {
      title = 'P2P Transfer';
      icon = Icons.send;
      iconBg = Colors.blueAccent;
    } else if (type == 'fee') {
      title = 'Transaction Fee';
      icon = Icons.money_off;
      iconBg = Colors.redAccent;
    }

    final dateStr = tx['created_at'] as String?;
    String timeStr = '';
    if (dateStr != null) {
      timeStr = DateFormat('hh:mm a').format(DateTime.parse(dateStr).toLocal());
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: iconBg.withOpacity(0.3)),
                ),
                child: Icon(icon, size: 20, color: iconBg),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(timeStr, style: AppTypography.label.copyWith(color: AppColors.muted)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '${isCredit ? '+' : '-'}$formattedAmount', 
                style: GoogleFonts.spaceGrotesk(
                  color: isCredit ? AppColors.kekeGreen : Colors.white, 
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                )
              ),
            ],
          ),
        ],
      ),
    );
  }
}
