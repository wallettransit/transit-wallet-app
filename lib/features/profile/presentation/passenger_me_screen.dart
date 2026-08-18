import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import 'passenger_kyc_screen.dart';

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
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.kekeGreen.withOpacity(0.5), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.kekeGreen.withOpacity(0.2),
                          child: Text(
                            userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U',
                            style: GoogleFonts.spaceGrotesk(color: AppColors.kekeGreen, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(end: 1.05, duration: 2.seconds),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: GoogleFonts.spaceGrotesk(color: AppColors.paper, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                          color: AppColors.danfoYellow.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.danfoYellow.withOpacity(0.4)),
                        ),
                        child: Text(
                          kycTier,
                          style: AppTypography.label.copyWith(color: AppColors.danfoYellow, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 100.ms).slideX(begin: -0.1, end: 0);
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.kekeGreen)),
                error: (_, __) => Text('Failed to load profile', style: AppTypography.bodyMedium.copyWith(color: AppColors.errorRed)),
              ),
              
              const SizedBox(height: 32),
              
              // Ride Stats Board (Glassmorphic)
              statsAsync.when(
                data: (stats) {
                  final totalRides = stats?['total_rides']?.toString() ?? '0';
                  final totalSpentKobo = double.tryParse(stats?['total_spent_kobo']?.toString() ?? '0') ?? 0;
                  final uniqueRoutes = stats?['unique_routes']?.toString() ?? '0';
                  
                  final spentFormatted = NumberFormat.compact().format(totalSpentKobo / 100);
                  
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F3A26), Color(0xFF071F13)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF0F3A26).withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 12)),
                      ],
                      border: Border.all(color: AppColors.kekeGreen.withOpacity(0.2), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('RIDES', totalRides, Colors.white70),
                        Container(height: 40, width: 1, color: Colors.white10),
                        _buildStatItem('TOTAL SPENT', '₦$spentFormatted', Colors.white),
                        Container(height: 40, width: 1, color: Colors.white10),
                        _buildStatItem('ROUTES', uniqueRoutes, AppColors.kekeGreen),
                      ],
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0);
                },
                loading: () => Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(child: CircularProgressIndicator(color: AppColors.kekeGreen)),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              
              const SizedBox(height: 40),
              
              Text(
                'Account',
                style: AppTypography.label.copyWith(color: AppColors.muted, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ).animate().fade(delay: 300.ms),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildListTile(Icons.credit_card, AppColors.kekeGreen, 'Saved Payment Methods', trailing: const Icon(Icons.chevron_right, color: Colors.white24)),
                Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 64, endIndent: 16),
                _buildListTile(
                  Icons.verified_user_outlined, 
                  Colors.blueAccent,
                  'KYC Verification', 
                  subtitle: 'Upgrade to Tier 2', 
                  trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerKycScreen())),
                ),
              ]).animate().fade(delay: 350.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 32),
              
              Text(
                'Security',
                style: AppTypography.label.copyWith(color: AppColors.muted, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ).animate().fade(delay: 450.ms),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildListTile(Icons.fingerprint, Colors.orangeAccent, 'Require Biometrics', trailing: Switch(value: true, onChanged: (v) {}, activeColor: AppColors.kekeGreen, activeTrackColor: AppColors.kekeGreen.withOpacity(0.2), inactiveTrackColor: Colors.white10, inactiveThumbColor: Colors.white54)),
                Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 64, endIndent: 16),
                _buildListTile(Icons.pin_outlined, Colors.purpleAccent, 'Change PIN', trailing: const Icon(Icons.chevron_right, color: Colors.white24)),
              ]).animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 32),
              
              Text(
                'More',
                style: AppTypography.label.copyWith(color: AppColors.muted, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ).animate().fade(delay: 600.ms),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildListTile(
                  Icons.card_giftcard, 
                  AppColors.danfoYellow,
                  'Refer a Friend', 
                  subtitle: 'Earn ₦500 for every friend', 
                  trailing: const Icon(Icons.chevron_right, color: Colors.white24)
                ),
                Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 64, endIndent: 16),
                _buildListTile(Icons.help_outline, Colors.cyan, 'Help & Support', trailing: const Icon(Icons.chevron_right, color: Colors.white24)),
              ]).animate().fade(delay: 650.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 48),
              
              // Premium Logout Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    ref.read(authControllerProvider.notifier).signOut();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Log Out Securely',
                          style: GoogleFonts.outfit(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fade(delay: 800.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(color: valueColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.label.copyWith(color: AppColors.kekeGreen.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile(IconData icon, Color iconBg, String title, {String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBg.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: iconBg.withOpacity(0.3)),
        ),
        child: Icon(icon, color: iconBg, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(color: AppColors.paper, fontSize: 14, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: AppTypography.label.copyWith(color: AppColors.muted),
      ) : null,
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}
