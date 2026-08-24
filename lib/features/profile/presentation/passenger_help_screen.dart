import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_text_field.dart';

class PassengerHelpScreen extends StatelessWidget {
  const PassengerHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'icon': Icons.account_balance_wallet_outlined, 'title': 'Fund Wallet', 'desc': 'How to add money to your account'},
      {'icon': Icons.directions_car_outlined, 'title': 'Rides', 'desc': 'Issues with finding or paying for rides'},
      {'icon': Icons.security_outlined, 'title': 'Account & Security', 'desc': 'Password reset and data privacy'},
      {'icon': Icons.campaign_outlined, 'title': 'Promotions', 'desc': 'Ride advance and promo codes'},
    ];

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: CustomScrollView(
        slivers: [
          // Glassmorphic App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.ink.withOpacity(0.9),
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.paper, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
              title: Text(
                'How can we help?',
                style: GoogleFonts.outfit(
                  color: AppColors.paper,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fade().slideX(begin: -0.2, end: 0),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: -50,
                    left: -20,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.danfoYellow.withOpacity(0.1),
                      ),
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(color: Colors.transparent),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TWTextField(
                      label: '', // Label is required by TWTextField
                      hintText: 'Search for help topics...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                    ),
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'Frequently Asked',
                    style: AppTypography.heading2.copyWith(color: AppColors.paper),
                  ).animate().fade(delay: 200.ms),
                  
                  const SizedBox(height: 16),
                  
                  // FAQs Grid
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: faqs.length,
                    itemBuilder: (context, index) {
                      final item = faqs[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.kekeGreen.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(item['icon'] as IconData, color: AppColors.kekeGreen, size: 24),
                            ),
                            const Spacer(),
                            Text(
                              item['title'] as String,
                              style: GoogleFonts.spaceGrotesk(
                                color: AppColors.paper,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['desc'] as String,
                              style: AppTypography.label.copyWith(color: AppColors.muted),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ).animate().fade(delay: (300 + (index * 100)).ms).scaleXY(begin: 0.9, end: 1.0);
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Contact Support
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F3A26), Color(0xFF071F13)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.kekeGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.kekeGreen.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.headset_mic, color: AppColors.kekeGreen, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need more help?',
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppColors.paper,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Chat with our support team.',
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 600.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
