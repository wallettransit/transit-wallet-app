import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import 'passenger_group_payment_screen.dart';

class PassengerGroupFareReviewScreen extends StatelessWidget {
  const PassengerGroupFareReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIconButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.pop(context),
                      ),
                      Text(
                        'Review Fare & Terms',
                        style: GoogleFonts.outfit(
                          color: AppColors.paper,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      _buildIconButton(
                        icon: Icons.help_outline,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check final cost before confirming your shared seat.',
                    style: GoogleFonts.manrope(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fade(duration: 300.ms).slideY(begin: -0.1),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Subsidy Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.kekeGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.security, size: 18, color: AppColors.kekeGreen),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'TransitWallet Subsidy Applied',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.kekeGreen,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This route qualifies for Nigerian Commuter Subsidy initiative. TransitWallet covers 20% of remaining cost.',
                              style: GoogleFonts.manrope(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 400.ms, delay: 100.ms),
                      
                      const SizedBox(height: 20),

                      // Bill Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderStroke),
                        ),
                        child: Column(
                          children: [
                            _buildFareRow('Group Rate Fare', '₦480', AppColors.muted, AppColors.paper),
                            const SizedBox(height: 12),
                            _buildFareRow('TransitWallet Subsidy', '-₦96', AppColors.muted, AppColors.kekeGreen),
                            const SizedBox(height: 16),
                            const Divider(color: AppColors.borderStroke, height: 1),
                            const SizedBox(height: 16),
                            _buildFareRow('Final Amount', '₦384', AppColors.paper, AppColors.kekeGreen, isTotal: true),
                          ],
                        ),
                      ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),

                      const SizedBox(height: 20),

                      // Wallet Balance
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderStroke),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.account_balance_wallet_outlined, size: 18, color: AppColors.muted),
                                const SizedBox(width: 8),
                                Text(
                                  'TransitWallet Balance',
                                  style: GoogleFonts.manrope(
                                    color: AppColors.muted,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '₦1,850',
                              style: GoogleFonts.outfit(
                                color: AppColors.paper,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1),

                      const SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        child: TWButton(
                          label: 'Proceed to Payment',
                          icon: Icons.credit_card,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PassengerGroupPaymentScreen()),
                            );
                          },
                        ),
                      ).animate().fade(duration: 400.ms, delay: 400.ms),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Icon(icon, size: 20, color: AppColors.paper),
      ),
    );
  }

  Widget _buildFareRow(String title, String amount, Color titleColor, Color amountColor, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isTotal
              ? GoogleFonts.outfit(color: titleColor, fontSize: 18, fontWeight: FontWeight.w800)
              : GoogleFonts.manrope(color: titleColor, fontSize: 14),
        ),
        Text(
          amount,
          style: isTotal
              ? GoogleFonts.outfit(color: amountColor, fontSize: 24, fontWeight: FontWeight.w800)
              : GoogleFonts.manrope(color: amountColor, fontSize: 14),
        ),
      ],
    );
  }
}
