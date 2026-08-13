import '../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'driver_dashboard_screen.dart';
import '../../driver_earnings/presentation/driver_ledger_screen.dart';
import '../presentation/driver_dashboard_screen.dart';
import '../../driver_earnings/presentation/driver_earnings_screen.dart';
import '../../wallet/presentation/cash_out_screen.dart';

class DriverMainLayout extends StatefulWidget {
  final bool isPendingReview;

  const DriverMainLayout({super.key, this.isPendingReview = false});

  @override
  State<DriverMainLayout> createState() => _DriverMainLayoutState();
}

class _DriverMainLayoutState extends State<DriverMainLayout> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    DriverDashboardScreen(isPendingReview: widget.isPendingReview),
    const DriverLedgerScreen(),
    const CashOutScreen(),
    const DriverEarningsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.borderStroke, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_filled, 'Home'),
                _buildNavItem(1, Icons.description, 'Ledger'),
                _buildNavItem(2, Icons.account_balance_wallet, 'Cash Out'),
                _buildNavItem(3, Icons.bar_chart, 'Earnings'),
              ],
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.kekeGreen.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppTheme.kekeGreen : AppTheme.muted,
            ).animate(target: isSelected ? 1 : 0).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 200.ms,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  color: AppTheme.kekeGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fade(duration: 200.ms).slideX(begin: 0.2, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}
