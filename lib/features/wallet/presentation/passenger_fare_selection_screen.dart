import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_button.dart';
import '../../../core/utils/tw_error_handler.dart';
import '../providers/scan_provider.dart';
import '../data/wallet_repository.dart';
import '../data/ride_repository.dart';
import '../../auth/providers/auth_provider.dart';
import 'passenger_payment_confirmation_screen.dart';
import 'passenger_main_layout.dart';
import 'package:intl/intl.dart';

class PassengerFareSelectionScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> rideData;

  const PassengerFareSelectionScreen({
    super.key,
    required this.rideData,
  });

  @override
  ConsumerState<PassengerFareSelectionScreen> createState() => _PassengerFareSelectionScreenState();
}

class _PassengerFareSelectionScreenState extends ConsumerState<PassengerFareSelectionScreen> {
  int _selectedFareIndex = 0; // Default to first
  bool _isProcessing = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

  void _payNow(int fareAmount, String fareTierId) async {
    if (_isProcessing) return;

    final passengerId = ref.read(authRepositoryProvider).currentUser?.id;
    if (passengerId == null) return;

    setState(() {
      _isProcessing = true;
    });

    final success = await ref.read(scanControllerProvider.notifier).payForRide(
      passengerId: passengerId,
      driverId: widget.rideData['driver_id'],
      routeId: widget.rideData['route_id'],
      fareTierId: fareTierId,
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      if (success) {
        // PM NOTE: We MUST invalidate the cache here so the rest of the app knows the data changed!
        ref.invalidate(walletBalanceProvider);
        ref.invalidate(recentRidesProvider);
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PassengerPaymentConfirmationScreen(
              amountPaid: fareAmount,
            ),
          ),
        );
      } else {
        final error = ref.read(scanControllerProvider).error;
        TWErrorHandler.handle(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fareTiers = widget.rideData['fare_tiers'] as List<dynamic>? ?? [];
    final walletBalanceAsync = ref.watch(walletBalanceProvider);
    
    double currentBalance = walletBalanceAsync.value ?? 0.0;
    
    // Determine the amount for the selected tier
    int selectedFareKobo = 0;
    String selectedFareId = '';
    
    if (fareTiers.isNotEmpty && _selectedFareIndex < fareTiers.length) {
      selectedFareKobo = fareTiers[_selectedFareIndex]['fare_kobo'] ?? 0;
      selectedFareId = fareTiers[_selectedFareIndex]['id'] ?? '';
    }
    
    int selectedFareNaira = selectedFareKobo ~/ 100;
    int balanceNaira = currentBalance ~/ 100;
    bool hasSufficientBalance = balanceNaira >= selectedFareNaira;

    return Scaffold(
      backgroundColor: Colors.white, // Light theme background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      'Fare Selection',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ).animate().fade().slideY(begin: 0.1),
                    
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      'Confirm the detected route and choose your stop.',
                      style: AppTypography.bodyMedium.copyWith(color: Colors.grey[600]),
                    ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 24),
                    
                    // Driver Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50], // Very light grey
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFC107), // Yellow Avatar
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getInitials(widget.rideData['driver_name'] ?? 'Driver'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.rideData['driver_name'] ?? 'Unknown Driver',
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Route: ${widget.rideData['origin']} ➔ ${widget.rideData['destination']} • Bus No: ${widget.rideData['plate_number']}',
                                  style: AppTypography.bodySmall.copyWith(color: Colors.grey[600]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 32),
                    
                    Text(
                      'Select Your Destination',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 16),
                    
                    // Fare Options
                    if (fareTiers.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: Text("No fare options available for this route.")),
                      )
                    else
                      ...List.generate(fareTiers.length, (index) {
                        final tier = fareTiers[index];
                        final isSelected = _selectedFareIndex == index;
                        final amount = (tier['fare_kobo'] ?? 0) ~/ 100;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFareIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.kekeGreen : Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.kekeGreen : Colors.grey[200]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    tier['stop_name'] ?? 'Stop',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                Text(
                                  _currencyFormat.format(amount),
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fade(delay: Duration(milliseconds: 300 + (index * 100))).slideX(begin: 0.1);
                      }),
                      
                    const SizedBox(height: 24),
                    
                    // Wallet Balance Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Wallet Balance: ${_currencyFormat.format(balanceNaira)}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            hasSufficientBalance ? 'Covered' : 'Insufficient Funds',
                            style: AppTypography.bodyMedium.copyWith(
                              color: hasSufficientBalance ? AppColors.kekeGreen : AppColors.errorRed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: TWButton(
                    label: 'Pay Now (${_currencyFormat.format(selectedFareNaira)})',
                    isLoading: _isProcessing,
                    onPressed: (hasSufficientBalance && fareTiers.isNotEmpty) 
                        ? () => _payNow(selectedFareNaira, selectedFareId) 
                        : null, // Disabled if insufficient funds
                  ),
                ),
              ),
            ).animate().slideY(begin: 1.0, duration: 400.ms, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'D';
    List<String> parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
