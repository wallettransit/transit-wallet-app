import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_logo.dart';
import 'role_selection_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TWLogo(size: 20, textColor: AppColors.paper),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.kekeGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.kekeGreen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'NG',
                          style: AppTypography.label.copyWith(
                            color: AppColors.kekeGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Image Card
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height < 800 ? 240 : 320,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/driver_hero.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.account_balance_wallet_outlined, color: AppColors.kekeGreen, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Earn up to ₦250k/wk',
                                      style: AppTypography.label.copyWith(
                                        color: AppColors.paper,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fade(delay: 300.ms).slideX(begin: -0.1, end: 0),
                            ),
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.danfoYellow,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Lagos · Abuja · Ibadan',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ).animate().fade(delay: 500.ms).slideX(begin: 0.1, end: 0),
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 500.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOut),
                      
                      const SizedBox(height: 32),
                      
                      // Text Content
                      Text(
                        'DRIVE & PROSPER',
                        style: AppTypography.label.copyWith(
                          color: AppColors.kekeGreen,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 12),
                      Text(
                        'Start earning with\nTransitWallet',
                        style: AppTypography.heading1.copyWith(
                          fontSize: 36,
                          height: 1.1,
                          color: AppColors.paper,
                        ),
                      ).animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 16),
                      Text(
                        'Join thousands of Danfo, Keke, and private car partners navigating Nigerian roads smarter, collecting digital fares instantly.',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.muted,
                          height: 1.5,
                        ),
                      ).animate().fade(delay: 600.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TWButton(
                    label: 'Register as a Partner',
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RoleSelectionScreen(isLogin: false)),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RoleSelectionScreen(isLogin: true)),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have a profile? ',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                        children: [
                          TextSpan(
                            text: 'Log In',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.kekeGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
