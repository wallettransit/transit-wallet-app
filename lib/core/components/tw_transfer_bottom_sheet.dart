import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'tw_button.dart';

class TWTransferBottomSheet extends StatefulWidget {
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
  State<TWTransferBottomSheet> createState() => _TWTransferBottomSheetState();
}

class _TWTransferBottomSheetState extends State<TWTransferBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;
  bool _isSuccess = false;

  void _processTransfer() {
    if (_phoneController.text.isEmpty || _amountController.text.isEmpty) return;

    setState(() => _isProcessing = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isSuccess = true;
        });

        // Close after a brief moment showing success
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _isSuccess ? _buildSuccessState() : _buildFormState(),
        ),
      ),
    );
  }

  List<Widget> _buildFormState() {
    return [
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
      
      Text(
        'Transfer to Friend',
        style: GoogleFonts.outfit(
          color: AppColors.paper,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Send Transit Cash instantly to another user.',
        style: GoogleFonts.manrope(
          color: AppColors.muted,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 32),
      
      // Recipient Phone
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_outline, color: AppColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.manrope(color: AppColors.paper, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Recipient Phone Number',
                  hintStyle: GoogleFonts.manrope(color: AppColors.muted),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
      
      const SizedBox(height: 16),
      
      // Amount
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Row(
          children: [
            Text('₦', style: GoogleFonts.outfit(color: AppColors.muted, fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.outfit(color: AppColors.paper, fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: GoogleFonts.outfit(color: AppColors.muted),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
      
      const SizedBox(height: 32),
      
      TWButton(
        label: 'Send Funds',
        isLoading: _isProcessing,
        onPressed: _processTransfer,
      ),
    ];
  }

  List<Widget> _buildSuccessState() {
    return [
      const SizedBox(height: 32),
      Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.kekeGreen,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check, color: AppColors.ink, size: 40),
          ),
        ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
      ),
      const SizedBox(height: 24),
      Center(
        child: Text(
          'Transfer Successful!',
          style: GoogleFonts.outfit(
            color: AppColors.paper,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fade().slideY(begin: 0.2, end: 0),
      ),
      const SizedBox(height: 8),
      Center(
        child: Text(
          '₦${_amountController.text} sent successfully.',
          style: GoogleFonts.manrope(
            color: AppColors.muted,
            fontSize: 16,
          ),
        ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),
      ),
      const SizedBox(height: 48),
    ];
  }
}
