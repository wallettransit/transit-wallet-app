import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import 'driver_dispute_screen.dart';

class DriverLedgerScreen extends StatelessWidget {
  const DriverLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            center: Alignment(-0.8, -0.8),
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: Column(
          children: [
            // screen-header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Ledger',
                        style: GoogleFonts.outfit(
                          color: AppTheme.paper,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 25.2 / 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Automated ledger of your transit earnings',
                        style: GoogleFonts.manrope(
                          color: AppTheme.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 19.5 / 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // summary-bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GROSS FARES',
                                style: GoogleFonts.manrope(
                                  color: AppTheme.muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  height: 15.0 / 10,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₦22,100',
                                style: GoogleFonts.manrope(
                                  color: AppTheme.paper,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  height: 19.1 / 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fade(duration: 400.ms).slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DEDUCTIONS',
                                style: GoogleFonts.manrope(
                                  color: AppTheme.muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  height: 15.0 / 10,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '-₦3,650',
                                style: GoogleFonts.manrope(
                                  color: AppColors.errorRed,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  height: 19.1 / 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fade(duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: AppTheme.kekeGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.kekeGreen.withOpacity(0.3), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NET EARNING',
                                style: GoogleFonts.manrope(
                                  color: AppTheme.kekeGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  height: 15.0 / 10,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₦18,450',
                                style: GoogleFonts.manrope(
                                  color: AppTheme.kekeGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  height: 19.1 / 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fade(duration: 400.ms).slideX(begin: 0.2, end: 0, curve: Curves.easeOut),
                  ),
                ],
              ),
            ),
            
            // ledger-lists
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  _buildLedgerGroup(
                    context,
                    'Today, 26 Jan',
                    [
                      _LedgerItemData('+₦700', 'Passenger Fare', 'Oshodi → CMS', isPositive: true),
                      _LedgerItemData('+₦300', 'Passenger Fare', 'Oshodi → CMS (Short)', isPositive: true),
                      _LedgerItemData('-₦200', 'Union Levy', 'Auto-deduction', isPositive: false),
                      _LedgerItemData('+₦700', 'Passenger Fare', 'Oshodi → CMS', isPositive: true),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLedgerGroup(
                    context,
                    'Yesterday, 25 Jan',
                    [
                      _LedgerItemData('+₦700', 'Passenger Fare', 'Oshodi → CMS', isPositive: true),
                      _LedgerItemData('-₦3,000', 'Fuel Advance Repayment', 'Auto-deduction', isPositive: false),
                    ],
                  ),
                  const SizedBox(height: 40), // spacing for bottom nav
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildLedgerGroup(BuildContext context, String date, List<_LedgerItemData> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: GoogleFonts.manrope(
            color: AppTheme.muted,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 21.0 / 14,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: items.map((item) {
            return GestureDetector(
              onTap: () {
                // For demonstration, clicking any ledger item opens dispute screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DriverDisputeScreen()),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                    ),
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: item.isPositive ? AppTheme.kekeGreen.withOpacity(0.2) : AppColors.errorRed.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Icon(
                              item.isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                              size: 16,
                              color: item.isPositive ? AppTheme.kekeGreen : AppColors.errorRed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.manrope(
                                color: AppTheme.paper,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              item.subtitle,
                              style: GoogleFonts.manrope(
                                color: AppTheme.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      item.amount,
                      style: GoogleFonts.manrope(
                        color: item.isPositive ? AppTheme.kekeGreen : AppColors.errorRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 19.1 / 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate(delay: (items.indexOf(item) * 100).ms).fade(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
          }).toList(),
        ),
      ],
    );
  }
}

class _LedgerItemData {
  final String amount;
  final String title;
  final String subtitle;
  final bool isPositive;

  _LedgerItemData(this.amount, this.title, this.subtitle, {required this.isPositive});
}
