import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import 'passenger_wallet_screen.dart';
import 'passenger_qr_scan_screen.dart';
import 'passenger_ride_history_screen.dart';
import '../../profile/presentation/passenger_me_screen.dart';

class PassengerMainLayout extends StatefulWidget {
  final int initialIndex;
  
  const PassengerMainLayout({super.key, this.initialIndex = 0});

  @override
  State<PassengerMainLayout> createState() => _PassengerMainLayoutState();
}

class _PassengerMainLayoutState extends State<PassengerMainLayout> {
  late int _currentIndex;

  late final List<Widget> _screens = [
    const PassengerWalletScreen(),
    const PassengerQrScanScreen(),
    const PassengerRideHistoryScreen(),
    const PassengerMeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
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
                _buildNavItem(1, Icons.qr_code_scanner, Icons.qr_code_scanner),
                _buildNavItem(2, Icons.history, Icons.history),
                _buildNavItem(3, Icons.person, Icons.person_outline),
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
