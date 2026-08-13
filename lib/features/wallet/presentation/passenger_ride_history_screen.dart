import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'passenger_wallet_screen.dart';
import 'passenger_qr_scan_screen.dart';

class PassengerRideHistoryScreen extends StatelessWidget {
  const PassengerRideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('9:41', style: AppTypography.label.copyWith(color: AppColors.paper)),
                  // Mock status icons could go here
                ],
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Ride History & Expenses', style: AppTypography.bodyLarge.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Your automatic transport expense log', style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
                ],
              ),
            ).animate().fade().slideY(begin: -0.1, end: 0),
            
            // Monthly Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: _buildSummaryBox('TOTAL SPENT', '₦12,450', AppColors.danfoYellow, AppColors.cardBackground, false).animate().fade(delay: 100.ms)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSummaryBox('RIDES TAKEN', '38 Rides', AppColors.paper, AppColors.cardBackground, false).animate().fade(delay: 200.ms)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSummaryBox('AVG FARE', '₦325', AppColors.kekeGreen, AppColors.kekeGreen.withOpacity(0.1), true).animate().fade(delay: 300.ms)),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDateGroup('Today, 26 Jan', [
                    _buildHistoryItem('Oshodi → CMS', '09:37 AM', '₦350'),
                  ]).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  _buildDateGroup('Yesterday, 25 Jan', [
                    _buildHistoryItem('CMS → Lekki', '06:15 PM', '₦500'),
                    _buildHistoryItem('Ikeja → Oshodi', '08:20 AM', '₦350'),
                  ]).animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  _buildDateGroup('24 Jan', [
                    _buildHistoryItem('Lekki → CMS', '07:30 PM', '₦700'),
                  ]).animate().fade(delay: 600.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox(String label, String value, Color valueColor, Color bgColor, bool bordered) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: bordered ? Border.all(color: AppColors.kekeGreen) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.label.copyWith(color: bordered ? AppColors.kekeGreen : AppColors.muted, fontSize: 10), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.bodyMedium.copyWith(color: valueColor, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildDateGroup(String date, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(date, style: AppTypography.label.copyWith(color: AppColors.muted)),
        const SizedBox(height: 6),
        Column(
          children: items,
        ),
      ],
    );
  }

  Widget _buildHistoryItem(String route, String time, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.kekeGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_bus, size: 14, color: AppColors.ink),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(route, style: AppTypography.bodySmall.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
                  Text(time, style: AppTypography.label.copyWith(color: AppColors.muted)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(amount, style: AppTypography.bodyMedium.copyWith(color: AppColors.paper, fontWeight: FontWeight.w800)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Re-ride action
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.kekeGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.kekeGreen.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.replay, size: 12, color: AppColors.kekeGreen),
                      const SizedBox(width: 4),
                      Text('Ride Again', style: AppTypography.label.copyWith(color: AppColors.kekeGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
