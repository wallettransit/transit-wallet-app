import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_profile_avatar.dart';
import '../../auth/presentation/welcome_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../../core/providers/network_provider.dart';
import '../../auth/presentation/create_pin_screen.dart';

class PassengerProfileScreen extends ConsumerWidget {
  const PassengerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(offlineStateProvider);
    final currentUser = ref.watch(authRepositoryProvider).currentUser;
    final metadata = currentUser?.userMetadata ?? {};
    final fullName = metadata['full_name'] as String? ?? 'Passenger';
    
    final email = currentUser?.email ?? '';
    final phone = currentUser?.phone ?? '';
    
    String initials = 'P';
    if (fullName.isNotEmpty && fullName != 'Passenger') {
      final parts = fullName.split(' ');
      if (parts.length > 1 && parts[1].isNotEmpty) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = fullName.substring(0, 1).toUpperCase();
      }
    }

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: CustomScrollView(
        slivers: [
          // Dynamic Glassmorphic App Bar
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height < 800 ? 260.0 : 280.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.ink,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.paper, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Abstract Background Gradients (Dark mode)
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.kekeGreen.withOpacity(0.15),
                      ),
                    ),
                  ).animate().scale(duration: 2.seconds, curve: Curves.easeInOut).fadeIn(),
                  Positioned(
                    top: 100,
                    left: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF071F13),
                      ),
                    ),
                  ).animate().scale(duration: 2.5.seconds, curve: Curves.easeInOut).fadeIn(),
                  
                  // Blur overlay
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(color: AppColors.ink.withOpacity(0.6)),
                  ),
                  
                  // Profile Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Glowing Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.kekeGreen.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.kekeGreen.withOpacity(0.5), width: 2),
                              ),
                              child: TWProfileAvatar(
                                initials: initials,
                                radius: 46.0,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.kekeGreen,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.ink, width: 3),
                              ),
                              child: const Icon(Icons.camera_alt, size: 14, color: AppColors.ink),
                            ).animate().scale(delay: 500.ms),
                          ],
                        ),
                      ).animate().fade(duration: 400.ms).scale(curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 16),
                      Text(
                        fullName,
                        style: GoogleFonts.outfit(
                          color: AppColors.paper,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                      
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.kekeGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.kekeGreen.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Verified Passenger',
                          style: GoogleFonts.manrope(
                            color: AppColors.kekeGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Scrollable Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Personal Information').animate().fade(delay: 400.ms),
                  const SizedBox(height: 16),
                  
                  // Glassmorphic Info Card (Dark)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        _buildProfileField(
                          icon: Icons.person_outline,
                          iconBg: AppColors.danfoYellow,
                          label: 'Full Name',
                          value: fullName,
                          isFirst: true,
                        ),
                        _buildProfileField(
                          icon: Icons.phone_outlined,
                          iconBg: Colors.blueAccent,
                          label: 'Phone Number',
                          value: phone.isNotEmpty ? phone : '+234 --- --- ----',
                        ),
                        _buildProfileField(
                          icon: Icons.email_outlined,
                          iconBg: AppColors.kekeGreen,
                          label: 'Email Address',
                          value: email,
                          isLast: true,
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 450.ms).slideY(begin: 0.1, curve: Curves.easeOutQuart),

                  const SizedBox(height: 32),
                  _buildSectionTitle('App Preferences').animate().fade(delay: 500.ms),
                  const SizedBox(height: 16),

                  // Preferences Card (Dark)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchField(
                          icon: Icons.wifi_off_rounded,
                          iconBg: Colors.purpleAccent,
                          label: 'Offline Status',
                          subtitle: isOffline ? 'You are offline' : 'You are online',
                          value: isOffline,
                          onChanged: (val) {},
                        ),
                        Divider(
                          height: 1,
                          color: Colors.white.withOpacity(0.05),
                          indent: 72,
                          endIndent: 20,
                        ),
                        _buildNavigationField(
                          context: context,
                          icon: Icons.lock_outline,
                          iconBg: Colors.orangeAccent,
                          label: 'Set Security PIN',
                          subtitle: 'Create a 4-digit PIN for your wallet',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreatePinScreen(
                                  onPinCreated: () => Navigator.pop(context),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 550.ms).slideY(begin: 0.1, curve: Curves.easeOutQuart),

                  const SizedBox(height: 48),

                  // Action Buttons
                  TWButton(
                    label: 'Save Changes',
                    onPressed: () {},
                  ).animate().fade(delay: 650.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 16),
                  
                  // Log Out Premium Red Button
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        await ref.read(authControllerProvider.notifier).signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                            (route) => false,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Log Out Securely',
                              style: GoogleFonts.outfit(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fade(delay: 750.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.heading3.copyWith(color: AppColors.paper),
    );
  }

  Widget _buildProfileField({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: iconBg.withOpacity(0.3)),
                ),
                child: Icon(icon, color: iconBg, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        color: AppColors.paper,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined, color: Colors.white24, size: 18),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.05),
            indent: 72,
            endIndent: 20,
          ),
      ],
    );
  }

  Widget _buildSwitchField({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: iconBg.withOpacity(0.3)),
            ),
            child: Icon(icon, color: iconBg, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.paper,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.kekeGreen,
            activeTrackColor: AppColors.kekeGreen.withOpacity(0.2),
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationField({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: iconBg.withOpacity(0.3)),
              ),
              child: Icon(icon, color: iconBg, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.paper,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 24),
          ],
        ),
      ),
    );
  }
}
