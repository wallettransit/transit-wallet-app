import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({super.key});

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
                        'Earnings Record',
                        style: GoogleFonts.outfit(
                          color: AppTheme.paper,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 25.2 / 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Verified income records for TransitWallet drivers',
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
            
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // chart-card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                          children: [
                            // chart-header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "THIS WEEK'S COLLECTION",
                                      style: GoogleFonts.manrope(
                                        color: AppTheme.muted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        height: 18.0 / 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₦114,750',
                                      style: GoogleFonts.manrope(
                                        color: AppTheme.kekeGreen,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        height: 30.1 / 22,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.kekeGreen.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.arrow_upward, size: 12, color: AppTheme.kekeGreen),
                                      const SizedBox(width: 4),
                                      Text(
                                        '+15% vs Last Week',
                                        style: GoogleFonts.manrope(
                                          color: AppTheme.kekeGreen,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          height: 16.5 / 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // chart
                            SizedBox(
                              height: 140,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildChartBar('M', 61, false, 0),
                                  const SizedBox(width: 10),
                                  _buildChartBar('T', 83, false, 1),
                                  const SizedBox(width: 10),
                                  _buildChartBar('W', 71, false, 2),
                                  const SizedBox(width: 10),
                                  _buildChartBar('T', 94, false, 3),
                                  const SizedBox(width: 10),
                                  _buildChartBar('F', 110, false, 4),
                                  const SizedBox(width: 10),
                                  _buildChartBar('S', 91, true, 5),
                                  const SizedBox(width: 10),
                                  _buildChartBar('S', 54, false, 6),
                                ],
                              ),
                            ),
                          ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // verified-block
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_user, size: 18, color: AppTheme.paper),
                              const SizedBox(width: 8),
                              Text(
                                'VERIFIED FINANCIAL PROFILE',
                                style: GoogleFonts.manrope(
                                  color: AppTheme.paper,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 21.0 / 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          
                          // stats-grid
                          Row(
                            children: [
                              Expanded(child: _buildStatBox('Total Trips', '1,432', Icons.directions_bus)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildStatBox('Total Earned', '₦4.2M', Icons.account_balance_wallet)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _buildStatBox('Rating', '4.9/5.0', Icons.star)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildStatBox('Dispute Rate', '< 0.5%', Icons.gavel)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40), // Spacing for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildChartBar(String day, double height, bool isHighlight, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 37,
          height: height,
          decoration: BoxDecoration(
            color: isHighlight ? AppTheme.danfoYellow : AppTheme.kekeGreen,
            borderRadius: BorderRadius.circular(4), // Assume slight radius
          ),
        ).animate(delay: (index * 100).ms).scaleY(begin: 0, end: 1, duration: 800.ms, curve: Curves.easeOutBack, alignment: Alignment.bottomCenter),
        const SizedBox(height: 8),
        Text(
          day,
          style: GoogleFonts.manrope(
            color: isHighlight ? AppTheme.danfoYellow : AppTheme.muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 16.5 / 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String title, String value, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: const EdgeInsets.all(14.0),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: AppTheme.muted),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      color: AppTheme.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.outfit(
                  color: AppTheme.paper,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 22.68 / 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
