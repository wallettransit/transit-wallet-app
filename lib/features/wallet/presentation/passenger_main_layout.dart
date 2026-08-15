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
          padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05), // True frosted glass effect
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(0, Icons.home_filled, Icons.home_outlined, 'Home'),
                    _buildNavItem(1, Icons.qr_code_scanner, Icons.qr_code_scanner, 'Scan'),
                    _buildNavItem(2, Icons.history, Icons.history, 'History'),
                    _buildNavItem(3, Icons.person, Icons.person_outline, 'Me'),
                  ],
                ),
              ),
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

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 20 : 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kekeGreen.withOpacity(0.2) : Colors.transparent, // Light green pill
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppColors.kekeGreen : Colors.white70,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  color: AppColors.kekeGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ).animate().fade(duration: 200.ms).slideX(begin: -0.2, end: 0),
            ]
          ],
        ),
      ),
    );
  }
}
