import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_button.dart';
import 'passenger_payment_confirmation_screen.dart';

import 'passenger_main_layout.dart';

class PassengerFareSelectionScreen extends StatefulWidget {
  const PassengerFareSelectionScreen({super.key});

  @override
  State<PassengerFareSelectionScreen> createState() => _PassengerFareSelectionScreenState();
}

class _PassengerFareSelectionScreenState extends State<PassengerFareSelectionScreen> {
  int _selectedFareIndex = 1; // Default to middle option
  final List<int> _fares = [200, 350, 500];

  void _payNow() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PassengerPaymentConfirmationScreen(
          amountPaid: _fares[_selectedFareIndex],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PassengerMainLayout()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      'Fare Selection',
                      style: AppTypography.heading2.copyWith(color: AppColors.paper),
                    ).animate().fade().slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      'Confirm the detected route and choose your stop.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
                    ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Driver Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderStroke),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.danfoYellow,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text('AK', style: AppTypography.label.copyWith(color: AppColors.ink, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Alhaji Kehinde (Driver)', style: AppTypography.bodySmall.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
                                Text('Route: Oshodi → CMS • Bus No: LAG-5847', style: AppTypography.label.copyWith(color: AppColors.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Fare Options
                    Text('Select Your Destination', style: AppTypography.label.copyWith(color: AppColors.muted)).animate().fade(delay: 300.ms),
                    const SizedBox(height: 8),
                    
                    ...List.generate(_fares.length, (index) {
                      return _buildFareOption(index, _fares[index]);
                    }).animate(interval: 100.ms).fade(delay: 400.ms).slideX(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Balance Reference
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Wallet Balance: ₦4,850', style: AppTypography.label.copyWith(color: AppColors.muted)),
                          Text('Covered', style: AppTypography.label.copyWith(color: AppColors.kekeGreen)),
                        ],
                      ),
                    ).animate().fade(delay: 700.ms).slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),
            ),
            
            // Bottom Action
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: AppColors.ink,
              ),
              child: TWButton(
                label: 'Pay Now (₦${_fares[_selectedFareIndex]})',
                onPressed: _payNow,
              ),
            ).animate().fade(delay: 800.ms).slideY(begin: 1.0, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildFareOption(int index, int amount) {
    final isSelected = _selectedFareIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFareIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kekeGreen : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.kekeGreen : AppColors.borderStroke,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.ink : AppColors.muted,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  index == 0 ? 'Short Stop' : (index == 1 ? 'Midway Stop' : 'Final Destination'),
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected ? AppColors.ink : AppColors.paper,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '₦$amount',
              style: AppTypography.bodyLarge.copyWith(
                color: isSelected ? AppColors.ink : AppColors.paper,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
