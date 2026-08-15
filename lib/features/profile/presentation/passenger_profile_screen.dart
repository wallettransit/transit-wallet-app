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
      backgroundColor: const Color(0xFFF7F9FC), // Soft, premium off-white
      body: CustomScrollView(
        slivers: [
          // Dynamic Glassmorphic App Bar
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height < 800 ? 260.0 : 280.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.paper, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Abstract Background Gradients (Light mode)
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.kekeGreen.withOpacity(0.2),
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
                        color: const Color(0xFFE8F2F6), // Very light blue
                      ),
                    ),
                  ).animate().scale(duration: 2.5.seconds, curve: Curves.easeInOut).fadeIn(),
                  
                  // Blur overlay
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(color: Colors.white.withOpacity(0.4)),
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
                              color: AppColors.danfoYellow.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            TWProfileAvatar(
                              initials: initials,
                              radius: 50.0,
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.kekeGreen,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            ).animate().scale(delay: 500.ms),
                          ],
                        ),
                      ).animate().fade(duration: 400.ms).scale(curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 16),
                      Text(
                        fullName,
                        style: GoogleFonts.outfit(
                          color: AppColors.paper,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                      
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.kekeGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Verified Passenger',
                          style: GoogleFonts.manrope(
                            color: AppColors.kekeGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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
                  _buildSectionTitle('Personal Information'),
                  const SizedBox(height: 16),
                  
                  // Glassmorphic Info Card (Light)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black.withOpacity(0.03)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildProfileField(
                          icon: Icons.person_outline,
                          label: 'Full Name',
                          value: fullName,
                          isFirst: true,
                        ),
                        _buildProfileField(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          value: phone.isNotEmpty ? phone : '+234 --- --- ----',
                        ),
                        _buildProfileField(
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          value: email,
                          isLast: true,
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.1),

                  const SizedBox(height: 32),
                  _buildSectionTitle('App Preferences'),
                  const SizedBox(height: 16),

                  // Preferences Card (Light)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black.withOpacity(0.03)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: _buildSwitchField(
                      icon: Icons.wifi_off_rounded,
                      label: 'Offline Status',
                      subtitle: isOffline ? 'You are offline' : 'You are online',
                      value: isOffline,
                      onChanged: (val) {
                        // Managed automatically by connectivity_plus
                      },
                    ),
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.1),

                  const SizedBox(height: 48),

                  // Action Buttons
                  TWButton(
                    label: 'Save Changes',
                    onPressed: () {},
                  ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 16),
                  
                  // Log Out as a subtle text button
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        await ref.read(authControllerProvider.notifier).signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, color: AppColors.errorRed, size: 20),
                      label: Text(
                        'Log Out Securely',
                        style: GoogleFonts.outfit(
                          color: AppColors.errorRed,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: AppColors.errorRed.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ).animate().fade(delay: 700.ms).slideY(begin: 0.1),
                  
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
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.paper,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildProfileField({
    required IconData icon,
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
                  color: AppColors.highlightBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.muted, size: 20),
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
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppColors.paper,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined, color: AppColors.muted.withOpacity(0.5), size: 18),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Colors.black.withOpacity(0.05),
            indent: 64,
            endIndent: 20,
          ),
      ],
    );
  }

  Widget _buildSwitchField({
    required IconData icon,
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
              color: value ? AppColors.kekeGreen.withOpacity(0.1) : AppColors.highlightBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: value ? AppColors.kekeGreen : AppColors.muted,
              size: 20,
            ),
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
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.muted.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
