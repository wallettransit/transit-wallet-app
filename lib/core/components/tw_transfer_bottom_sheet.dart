import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import 'tw_button.dart';
import 'tw_inline_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/wallet/data/wallet_repository.dart';
import '../../core/services/secure_storage_service.dart';
import 'dart:ui';

class TWTransferBottomSheet extends ConsumerStatefulWidget {
  const TWTransferBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TWTransferBottomSheet(),
    );
  }

  @override
  ConsumerState<TWTransferBottomSheet> createState() => _TWTransferBottomSheetState();
}

class _TWTransferBottomSheetState extends ConsumerState<TWTransferBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isProcessing = false;
  bool _isSuccess = false;
  bool _isVerifyingPin = false;

  String? _errorMessage;

  void _formatAmount() {
    String text = _amountController.text.replaceAll(',', '');
    if (text.isEmpty) return;
    
    // Check if it ends with a dot to allow decimal typing
    if (text.endsWith('.')) return;
    
    final value = double.tryParse(text);
    if (value != null) {
      final formatted = NumberFormat('#,##0.##').format(value);
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_formatAmount);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _initiateTransfer() {
    if (_phoneController.text.isEmpty || _amountController.text.isEmpty) return;

    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Please enter a valid amount.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isVerifyingPin = true;
    });
  }

  Future<void> _verifyPinAndTransfer() async {
    final pin = _pinController.text;
    if (pin.length < 4) {
      setState(() => _errorMessage = 'Please enter a 4-digit PIN.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final storedPin = await SecureStorageService.getPin();
    if (storedPin != null && storedPin != pin) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Incorrect PIN. Transfer cancelled.';
        _pinController.clear();
      });
      return;
    }

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Authentication error. Please login again.';
      });
      return;
    }

    final amount = double.parse(_amountController.text.replaceAll(',', ''));
    final repository = ref.read(walletRepositoryProvider);
    final result = await repository.transferToFriend(
      senderId: user.id,
      recipientPhone: _phoneController.text,
      amount: amount,
    );

    if (mounted) {
      if (result['success'] == true) {
        ref.invalidate(walletBalanceProvider);
        ref.invalidate(transactionHistoryProvider);
        
        setState(() {
          _isProcessing = false;
          _isSuccess = true;
          _isVerifyingPin = false;
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        setState(() {
          _isProcessing = false;
          _errorMessage = result['message'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        margin: EdgeInsets.only(bottom: bottomInset),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppColors.ink.withOpacity(0.85),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          border: Border(
            top: BorderSide(color: AppColors.paper.withOpacity(0.1), width: 1),
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isSuccess 
              ? _buildSuccessState() 
              : (_isVerifyingPin ? _buildPinVerificationState() : _buildFormState()),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Column(
      key: const ValueKey('form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderStroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ).animate().fade().slideY(),
        const SizedBox(height: 24),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Send Funds',
              style: GoogleFonts.outfit(
                color: AppColors.paper,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.kekeGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on, color: AppColors.kekeGreen, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Instant',
                    style: GoogleFonts.manrope(
                      color: AppColors.kekeGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fade(delay: 100.ms).slideX(),
        const SizedBox(height: 8),
        Text(
          'Transfer Transit Cash to anyone on the network. A small fee of ₦10 applies.',
          style: GoogleFonts.manrope(
            color: AppColors.muted,
            fontSize: 14,
          ),
        ).animate().fade(delay: 200.ms).slideX(),
        const SizedBox(height: 32),
        
        // Recipient Phone
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderStroke.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.paper.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: AppColors.paper, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.manrope(color: AppColors.paper, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Recipient Phone Number',
                    hintStyle: GoogleFonts.manrope(color: AppColors.muted, fontSize: 16),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
        
        const SizedBox(height: 20),
        
        // Amount
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderStroke.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.danfoYellow.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text('₦', style: GoogleFonts.outfit(color: AppColors.danfoYellow, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  style: GoogleFonts.outfit(color: AppColors.paper, fontSize: 32, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: GoogleFonts.outfit(color: AppColors.muted.withOpacity(0.5)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
        
        const SizedBox(height: 16),
        
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TWInlineError(message: _errorMessage!),
          ),
        
        const SizedBox(height: 16),
        
        TWButton(
          label: 'Continue',
          isLoading: _isProcessing,
          onPressed: _initiateTransfer,
        ).animate().fade(delay: 500.ms).scale(begin: const Offset(0.95, 0.95)),
      ],
    );
  }

  Widget _buildPinVerificationState() {
    return Column(
      key: const ValueKey('pin_verification'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderStroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isVerifyingPin = false;
                  _errorMessage = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.paper.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.paper, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Security PIN',
              style: GoogleFonts.outfit(
                color: AppColors.paper,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ).animate().fade().slideX(),
        
        const SizedBox(height: 16),
        Text(
          'Enter your 4-digit PIN to authorize the transfer of ₦${_amountController.text} to ${_phoneController.text}.',
          style: GoogleFonts.manrope(
            color: AppColors.muted,
            fontSize: 14,
          ),
        ).animate().fade(delay: 100.ms).slideX(),
        
        const SizedBox(height: 32),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderStroke.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.paper.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline, color: AppColors.paper, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  obscuringCharacter: '●',
                  maxLength: 4,
                  autofocus: true,
                  style: GoogleFonts.manrope(color: AppColors.paper, fontSize: 24, letterSpacing: 8),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '●●●●',
                    hintStyle: GoogleFonts.manrope(color: AppColors.muted.withOpacity(0.5), fontSize: 24, letterSpacing: 8),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    if (val.length == 4) {
                      _verifyPinAndTransfer();
                    }
                  },
                ),
              ),
            ],
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
        
        const SizedBox(height: 16),
        
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TWInlineError(message: _errorMessage!),
          ),
        
        const SizedBox(height: 16),
        
        TWButton(
          label: 'Confirm Transfer',
          isLoading: _isProcessing,
          onPressed: _verifyPinAndTransfer,
        ).animate().fade(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.kekeGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.kekeGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kekeGreen,
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: AppColors.ink, size: 32),
              ),
            ),
          ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
        ),
        const SizedBox(height: 32),
        Center(
          child: Text(
            'Transfer Successful!',
            style: GoogleFonts.outfit(
              color: AppColors.paper,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '₦${_amountController.text} has been sent.',
            style: GoogleFonts.manrope(
              color: AppColors.muted,
              fontSize: 16,
            ),
          ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}
