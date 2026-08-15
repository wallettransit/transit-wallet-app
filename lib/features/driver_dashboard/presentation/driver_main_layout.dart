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
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 24.0),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE), // Light grey background
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_filled, Icons.home_outlined),
                _buildNavItem(1, Icons.description, Icons.description_outlined),
                _buildNavItem(2, Icons.account_balance_wallet, Icons.account_balance_wallet_outlined),
                _buildNavItem(3, Icons.bar_chart, Icons.bar_chart_outlined),
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

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD6D6D6) : Colors.transparent, // Darker grey pill for active
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          color: Colors.black87, // Black icons for both states
          size: 26,
        ),
      ),
    );
  }
}
