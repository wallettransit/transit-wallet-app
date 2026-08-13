import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_search_field.dart';
import 'add_bank_account_screen.dart';

class BankSelectionScreen extends StatefulWidget {
  const BankSelectionScreen({super.key});

  @override
  State<BankSelectionScreen> createState() => _BankSelectionScreenState();
}

class _BankSelectionScreenState extends State<BankSelectionScreen> {
  String _searchQuery = '';

  final List<String> _popularBanks = [
    'Guaranty Trust Bank',
    'Access Bank',
    'Zenith Bank',
    'United Bank for Africa',
    'First Bank of Nigeria',
    'Fidelity Bank',
    'Moniepoint Microfinance Bank',
    'Opay',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredBanks = _popularBanks
        .where((bank) => bank.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Select Bank',
          style: AppTypography.heading3.copyWith(color: AppColors.paper),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TWSearchField(
                hintText: 'Search for a bank...',
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0),
            ),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: filteredBanks.length + 1, // +1 for "Other Bank"
                itemBuilder: (context, index) {
                  if (index == filteredBanks.length) {
                    // Other Bank Option
                    return _buildBankTile(
                      bankName: 'Other Bank',
                      icon: Icons.account_balance,
                      isSpecial: true,
                    );
                  }
                  
                  return _buildBankTile(
                    bankName: filteredBanks[index],
                    icon: Icons.account_balance,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankTile({
    required String bankName,
    required IconData icon,
    bool isSpecial = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddBankAccountScreen(bankName: bankName),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.highlightBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSpecial ? AppColors.danfoYellow.withOpacity(0.5) : AppColors.borderStroke,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSpecial ? AppColors.danfoYellow.withOpacity(0.1) : AppColors.borderStroke,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: isSpecial ? AppColors.danfoYellow : AppColors.muted,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                bankName,
                style: AppTypography.bodyLarge.copyWith(
                  color: isSpecial ? AppColors.danfoYellow : AppColors.paper,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.muted.withOpacity(0.5)),
          ],
        ),
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
