import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_skeleton_loader.dart';
import '../../../core/components/tw_coming_soon_screen.dart';
import '../../auth/providers/auth_provider.dart';
import 'passenger_kyc_screen.dart';
import 'passenger_help_screen.dart';
import 'passenger_settings_screen.dart';

class PassengerMeScreen extends ConsumerWidget {
  const PassengerMeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final currentUser = ref.watch(authRepositoryProvider).currentUser;
    final metadata = currentUser?.userMetadata ?? {};

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 120.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account',
                style: AppTypography.heading1.copyWith(color: AppColors.paper, fontSize: 32),
              ).animate().fade().slideY(begin: -0.2, end: 0),
              
              const SizedBox(height: 24),
              
              // Profile Header
              profileAsync.when(
                data: (profile) {
                  final String userName = profile?['full_name'] ?? metadata['full_name'] ?? 'Passenger';
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: GoogleFonts.spaceGrotesk(color: AppColors.paper, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppColors.kekeGreen, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '4.9', // Hardcoded rating for UI placeholder
                                style: GoogleFonts.outfit(color: AppColors.paper, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.kekeGreen.withOpacity(0.5), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.kekeGreen.withOpacity(0.2),
                              child: Text(
                                userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U',
                                style: GoogleFonts.spaceGrotesk(color: AppColors.kekeGreen, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.ink, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: AppColors.paper, size: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fade(delay: 100.ms).slideX(begin: -0.1, end: 0);
                },
                loading: () => const TWSkeletonLoader(width: double.infinity, height: 80, borderRadius: 24),
                error: (_, __) => Text('Failed to load profile', style: AppTypography.bodyMedium.copyWith(color: AppColors.errorRed)),
              ),
              
              const SizedBox(height: 32),
              
              // Verification Banner
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerKycScreen())),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.kekeGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.kekeGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.kekeGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.security, color: AppColors.ink, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enjoy smoother and safer rides',
                              style: GoogleFonts.outfit(color: AppColors.paper, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Verify identity',
                              style: GoogleFonts.outfit(color: AppColors.kekeGreen, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 32),
              
              // Section 1: Main Actions
              _buildSettingsCard([
                _buildListTile(context, Icons.person_outline, 'Profile', () => _navToComingSoon(context, 'Profile')),
                _divider(),
                _buildListTile(context, Icons.payment_outlined, 'Payment', () => _navToComingSoon(context, 'Payment')),
                _divider(),
                _buildListTile(context, Icons.help_outline, 'Support', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerHelpScreen()))),
                _divider(),
                _buildListTile(context, Icons.health_and_safety_outlined, 'Safety', () => _navToComingSoon(context, 'Safety')),
                _divider(),
                _buildListTile(context, Icons.place_outlined, 'Saved places', () => _navToComingSoon(context, 'Saved places')),
                _divider(),
                _buildListTile(context, Icons.settings_outlined, 'Settings', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerSettingsScreen()))),
              ]).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 32),
              
              // Section 2: Secondary Actions
              _buildSettingsCard([
                _buildListTile(context, Icons.bolt_outlined, 'OyaPay Plus', () => _navToComingSoon(context, 'OyaPay Plus'), subtitle: 'Unlock exclusive benefits', iconBg: AppColors.kekeGreen),
                _divider(),
                _buildListTile(context, Icons.local_offer_outlined, 'Promotions', () => _navToComingSoon(context, 'Promotions'), subtitle: 'Promo codes, offers, and savings'),
                _divider(),
                _buildListTile(context, Icons.family_restroom_outlined, 'Family Profile', () => _navToComingSoon(context, 'Family Profile')),
              ]).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),
              
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
              ).animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  void _navToComingSoon(BuildContext context, String title) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => TWComingSoonScreen(title: '$title Coming Soon', featureName: title)));
  }

  Widget _divider() {
    return Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 56, endIndent: 16);
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

  Widget _buildListTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {String? subtitle, Color? iconBg}) {
    final effectiveIconBg = iconBg ?? Colors.white.withOpacity(0.05);
    final isColorIcon = iconBg != null;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isColorIcon ? effectiveIconBg : effectiveIconBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isColorIcon ? AppColors.ink : AppColors.paper, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(color: AppColors.paper, fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: AppTypography.label.copyWith(color: AppColors.muted),
      ) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }
}
