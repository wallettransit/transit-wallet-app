import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'driver_login_screen.dart';
import 'passenger_login_screen.dart';
import 'driver_registration_screen.dart';
import 'passenger_registration_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  final bool isLogin;
  const RoleSelectionScreen({super.key, this.isLogin = false});

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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                isLogin ? 'Log in to your account' : 'Choose your role',
                style: AppTypography.heading1,
              ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 8),
              
              Text(
                'Are you commuting or driving? Select how you want to use TransitWallet today.',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
              ).animate().fade(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 48),
              
              // Role Cards
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRoleCard(
                      context: context,
                      title: "I'm a Driver",
                      subtitle: "Accept fares & cash out instantly.",
                      icon: Icons.directions_bus_filled,
                      color: AppColors.danfoYellow,
                      onTap: () {
                        if (isLogin) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverLoginScreen()));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverRegistrationScreen()));
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildRoleCard(
                      context: context,
                      title: "I'm a Passenger",
                      subtitle: "Pay fares & track your trips.",
                      icon: Icons.person,
                      color: AppColors.kekeGreen,
                      onTap: () {
                        if (isLogin) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PassengerLoginScreen()));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PassengerRegistrationScreen()));
                        }
                      },
                    ),
                  ].animate(interval: 100.ms, delay: 200.ms).fade(duration: 500.ms).slideY(begin: 0.1, end: 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: color, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.heading3.copyWith(color: AppColors.paper),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: AppColors.muted.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}
