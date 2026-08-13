import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import 'passenger_group_confirmed_screen.dart';

class PassengerGroupPaymentScreen extends StatefulWidget {
  const PassengerGroupPaymentScreen({super.key});

  @override
  State<PassengerGroupPaymentScreen> createState() => _PassengerGroupPaymentScreenState();
}

class _PassengerGroupPaymentScreenState extends State<PassengerGroupPaymentScreen> {
  int _selectedMethod = 0;

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
                        'Complete Payment',
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
                    'Select your preferred payment method to secure your seat.',
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
                      // Total Amount
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.highlightBackground,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.borderStroke),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Total Amount Due',
                              style: GoogleFonts.manrope(
                                color: AppColors.muted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₦384',
                              style: GoogleFonts.outfit(
                                color: AppColors.kekeGreen,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 400.ms, delay: 100.ms).scale(curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 32),

                      // Payment Methods
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method',
                            style: GoogleFonts.outfit(
                              color: AppColors.paper,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPaymentOption(
                            index: 0,
                            icon: Icons.account_balance_wallet,
                            title: 'TransitWallet Balance',
                            subtitle: 'Available: ₦1,850',
                          ),
                          const SizedBox(height: 16),
                          _buildPaymentOption(
                            index: 1,
                            icon: Icons.credit_card,
                            title: 'Pay with Card',
                            subtitle: 'Add a new debit/credit card',
                          ),
                        ].animate(interval: 100.ms, delay: 200.ms).fade(duration: 400.ms).slideY(begin: 0.1),
                      ),

                      const SizedBox(height: 48),
                      
                      SizedBox(
                        width: double.infinity,
                        child: TWButton(
                          label: 'Confirm & Pay ₦384',
                          icon: Icons.lock_outline,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PassengerGroupConfirmedScreen()),
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

  Widget _buildPaymentOption({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    bool isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kekeGreen.withOpacity(0.1) : AppColors.ink,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.kekeGreen : AppColors.borderStroke,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.kekeGreen : AppColors.highlightBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.ink : AppColors.paper,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: AppColors.paper,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.kekeGreen : AppColors.borderStroke,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.kekeGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
