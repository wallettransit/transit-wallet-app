import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class PassengerMeScreen extends ConsumerWidget {
  const PassengerMeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(passengerStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 120.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Account',
                style: AppTypography.heading1.copyWith(color: AppColors.paper),
              ).animate().fade().slideY(begin: -0.2, end: 0),
              
              const SizedBox(height: 32),
              
              // Profile Header
              profileAsync.when(
                data: (profile) {
                  final String userName = profile?['full_name'] ?? 'User';
                  final String phoneNumber = profile?['phone_number'] ?? '';
                  final String rawTier = profile?['kyc_tier'] ?? 'tier_1';
                  final String kycTier = rawTier.replaceAll('_', ' ').replaceFirst('t', 'T'); // e.g. "Tier 1"
                  
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.kekeGreen.withOpacity(0.2),
                        child: Text(
                          userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U',
                          style: AppTypography.heading1.copyWith(color: AppColors.kekeGreen),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: AppTypography.heading2.copyWith(color: AppColors.paper),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              phoneNumber,
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.danfoYellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.danfoYellow.withOpacity(0.5)),
                        ),
                        child: Text(
                          kycTier,
                          style: AppTypography.label.copyWith(color: AppColors.danfoYellow),
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 100.ms).slideX(begin: -0.1, end: 0);
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.kekeGreen)),
                error: (_, __) => Text('Failed to load profile', style: AppTypography.bodyMedium.copyWith(color: AppColors.errorRed)),
              ),
              
              const SizedBox(height: 32),
              
              // Ride Stats
              statsAsync.when(
                data: (stats) {
                  final totalRides = stats?['total_rides']?.toString() ?? '0';
                  final totalSpentKobo = stats?['total_spent_kobo'] ?? 0;
                  final uniqueRoutes = stats?['unique_routes']?.toString() ?? '0';
                  
                  final spentFormatted = NumberFormat.compact().format(totalSpentKobo / 100);
                  
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Rides', totalRides),
                        Container(height: 40, width: 1, color: Colors.white.withOpacity(0.1)),
                        _buildStatItem('Total Spent', '₦$spentFormatted'),
                        Container(height: 40, width: 1, color: Colors.white.withOpacity(0.1)),
                        _buildStatItem('Routes', uniqueRoutes),
                      ],
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0);
                },
                loading: () => Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: CircularProgressIndicator(color: AppColors.kekeGreen)),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'Account',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.muted, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSettingsCard([
                _buildListTile(Icons.credit_card, 'Saved Payment Methods', trailing: const Icon(Icons.chevron_right, color: Colors.white54)),
                _buildListTile(Icons.verified_user_outlined, 'KYC Verification', subtitle: 'Upgrade to Tier 2', trailing: const Icon(Icons.chevron_right, color: Colors.white54)),
              ]).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 24),
              
              Text(
                'Security',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.muted, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSettingsCard([
                _buildListTile(Icons.fingerprint, 'Require Biometrics', trailing: Switch(value: true, onChanged: (v) {}, activeColor: AppColors.kekeGreen)),
                _buildListTile(Icons.pin_outlined, 'Change PIN', trailing: const Icon(Icons.chevron_right, color: Colors.white54)),
              ]).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 24),
              
              Text(
                'More',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.muted, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSettingsCard([
                _buildListTile(
                  Icons.card_giftcard, 
                  'Refer a Friend', 
                  subtitle: 'Earn ₦500 for every friend', 
                  iconColor: AppColors.danfoYellow,
                  trailing: const Icon(Icons.chevron_right, color: Colors.white54)
                ),
                _buildListTile(Icons.help_outline, 'Help & Support', trailing: const Icon(Icons.chevron_right, color: Colors.white54)),
              ]).animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 32),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    // Log out using provider
                    ref.read(authControllerProvider.notifier).signOut();
                    // Navigator routing is handled by the wrapper/AppLockScreen if needed,
                    // but we can manually push replacement to WelcomeScreen here to be safe.
                    // (Assuming you have a WelcomeScreen route).
                  },
                  icon: const Icon(Icons.logout, color: AppColors.errorRed),
                  label: Text(
                    'Log Out',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.errorRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.errorRed.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ).animate().fade(delay: 600.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.heading2.copyWith(color: AppColors.paper),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.label.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, {String? subtitle, Widget? trailing, Color? iconColor}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.paper).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? AppColors.paper, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.paper, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: AppTypography.label.copyWith(color: AppColors.muted),
      ) : null,
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
