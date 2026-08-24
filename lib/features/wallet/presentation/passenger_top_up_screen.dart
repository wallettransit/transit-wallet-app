import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/wallet_repository.dart';
import '../../../core/components/tw_snackbar.dart';

class PassengerTopUpScreen extends ConsumerStatefulWidget {
  const PassengerTopUpScreen({super.key});

  @override
  ConsumerState<PassengerTopUpScreen> createState() => _PassengerTopUpScreenState();
}

class _PassengerTopUpScreenState extends ConsumerState<PassengerTopUpScreen> with WidgetsBindingObserver {
  final TextEditingController _amountController = TextEditingController(text: '2000');
  int _selectedMethodIndex = 0;
  
  final List<int> _presets = [500, 1000, 2000, 5000];
  
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  String? _pendingReference;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _pendingReference != null) {
      _verifyPendingPayment();
    }
  }

  void _verifyPendingPayment() async {
    final reference = _pendingReference;
    _pendingReference = null; // Clear it so we don't verify twice

    // Add a slight delay to allow the browser's network stack to fully wake up on resume
    await Future.delayed(const Duration(milliseconds: 500));

    if (reference != null && mounted) {
      final repo = ref.read(walletRepositoryProvider);
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        final res = await repo.verifyTopup(user.id, reference);
        if (mounted) {
          if (res['success'] == true) {
            _showSuccessBottomSheet();
            ref.invalidate(walletBalanceProvider);
            ref.invalidate(transactionHistoryProvider);
          } else {
            if (res['message'] == 'Payment not successful or not found') {
               _showFailedBottomSheet('Payment was declined or cancelled.');
            } else {
               _showFailedBottomSheet(res['message'] ?? 'Payment verification failed');
            }
          }
        }
      }
    }
  }

  void _showFailedBottomSheet(String message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Failed',
              style: AppTypography.heading2.copyWith(color: AppColors.paper),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Dismiss bottom sheet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardBackground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Try Again', style: AppTypography.bodyLarge.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      final isHttpsMatch = uri.host == 'oyapay.app' && uri.path.contains('/topup/callback');
      final isCustomSchemeMatch = uri.scheme == 'oyapay' && uri.host == 'payment' && uri.path.contains('/callback');
      
      if (isHttpsMatch || isCustomSchemeMatch) {
        final reference = uri.queryParameters['reference'];
        if (reference != null && mounted) {
          final repo = ref.read(walletRepositoryProvider);
          final user = ref.read(authRepositoryProvider).currentUser;
          if (user != null) {
            final res = await repo.verifyTopup(user.id, reference);
            if (mounted) {
              if (res['success'] == true) {
                _showSuccessBottomSheet();
                ref.invalidate(walletBalanceProvider);
                ref.invalidate(transactionHistoryProvider);
              } else {
                TWSnackbar.showError(context, res['message'] ?? 'Payment verification failed');
              }
            }
          }
        }
      }
    });
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.kekeGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.kekeGreen, size: 80),
              ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 24),
              
              Text(
                'Top-Up Successful!',
                style: AppTypography.heading2.copyWith(color: AppColors.paper),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 12),
              
              Text(
                'Your wallet has been credited with ₦${_amountController.text}.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 40),
              
              SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: TWButton(
                    label: 'Done',
                    onPressed: () {
                      Navigator.pop(context); // close bottom sheet
                      Navigator.pop(context); // pop back to wallet screen
                    },
                  ),
                ).animate().fade(delay: 600.ms).slideY(begin: 0.2, end: 0),
              ),
            ],
          ),
        ).animate().slideY(begin: 1.0, end: 0.0, curve: Curves.easeOutQuart);
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  void _selectPreset(int amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  bool _isLoading = false;

  void _fundWallet() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      TWSnackbar.showError(context, 'Please enter a valid amount');
      return;
    }

    setState(() => _isLoading = true);
    
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    // KYC Tier Enforcement
    final profile = await ref.read(userProfileProvider.future);
    final kycTier = profile?['kyc_tier'] ?? 'tier_1';
    
    if (kycTier == 'tier_1' && amount > 10000) {
      setState(() => _isLoading = false);
      TWSnackbar.showError(context, 'Tier 1 accounts are limited to ₦10,000 max per top-up. Please verify your BVN to upgrade.');
      return;
    }

    final repo = ref.read(walletRepositoryProvider);
    final res = await repo.fundWallet(userId: user.id, amount: amount);

    if (mounted) {
      setState(() => _isLoading = false);
      if (res['success'] == true) {
        final checkoutUrl = res['checkout_url'];
        if (checkoutUrl != null) {
          _pendingReference = res['reference']; // Save reference to verify on resume
          final uri = Uri.parse(checkoutUrl);
          try {
            await launchUrl(uri, mode: LaunchMode.inAppWebView);
          } catch (e) {
            TWSnackbar.showError(context, 'Could not open payment link');
          }
        }
        // Do not pop here! The screen must remain active to receive the Deep Link callback or verify on resume!
      } else {
        TWSnackbar.showError(context, res['message'] ?? 'Funding failed');
      }
    }
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
          onPressed: () => Navigator.pop(context),
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
                      'Fund Wallet',
                      style: AppTypography.heading2.copyWith(color: AppColors.paper),
                    ).animate().fade().slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      'Instantly fund your wallet to avoid physical cash hassle.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
                    ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Amount Input
                    Text('Enter Custom Amount', style: AppTypography.label.copyWith(color: AppColors.muted)).animate().fade(delay: 200.ms),
                    const SizedBox(height: 8),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderStroke),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Text('₦', style: AppTypography.heading2.copyWith(color: AppColors.danfoYellow)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              style: AppTypography.heading2.copyWith(color: AppColors.paper),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (val) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 300.ms).slideX(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 12),
                    
                    // Presets
                    Row(
                      children: _presets.map((amount) {
                        final isSelected = _amountController.text == amount.toString();
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: amount == _presets.last ? 0 : 8.0),
                            child: GestureDetector(
                              onTap: () => _selectPreset(amount),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.kekeGreen : AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSelected ? AppColors.kekeGreen : AppColors.borderStroke),
                                ),
                                child: Text(
                                  '₦$amount',
                                  style: AppTypography.label.copyWith(
                                    color: isSelected ? AppColors.ink : AppColors.paper,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ).animate().fade(delay: 400.ms).slideX(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Payment Methods
                    Text('Choose Payment Method', style: AppTypography.label.copyWith(color: AppColors.muted)).animate().fade(delay: 500.ms),
                    const SizedBox(height: 8),
                    
                    _buildPaymentMethod(0, Icons.account_balance, 'Bank Transfer', 'Account 0123456789').animate().fade(delay: 600.ms).slideX(begin: 0.1, end: 0),
                    _buildPaymentMethod(1, Icons.credit_card, 'Debit Card', '**** 4567').animate().fade(delay: 700.ms).slideX(begin: 0.1, end: 0),
                    _buildPaymentMethod(2, Icons.phone_android, 'USSD', 'Dial *737#').animate().fade(delay: 800.ms).slideX(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Note Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.kekeGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.kekeGreen),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.kekeGreen, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('One top-up covers 10-15 rides', style: AppTypography.label.copyWith(color: AppColors.kekeGreen, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  'Save on micro-transaction fees. Keep your daily commute entirely seamless.',
                                  style: AppTypography.label.copyWith(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 900.ms).slideY(begin: 0.1, end: 0),
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
                label: 'Fund Wallet',
                onPressed: _isLoading ? () {} : _fundWallet,
                isLoading: _isLoading,
              ),
            ).animate().fade(delay: 1000.ms).slideY(begin: 1.0, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(int index, IconData icon, String title, String subtitle) {
    final isSelected = _selectedMethodIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethodIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.kekeGreen : AppColors.borderStroke,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.kekeGreen.withOpacity(0.2) : AppColors.ink,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? AppColors.kekeGreen : AppColors.paper, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AppTypography.label.copyWith(color: AppColors.muted)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.kekeGreen, size: 20),
          ],
        ),
      ),
    );
  }
}
