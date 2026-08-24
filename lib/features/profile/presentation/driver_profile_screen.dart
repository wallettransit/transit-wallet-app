import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_text_field.dart';
import '../../../../core/components/tw_profile_avatar.dart';
import '../../auth/presentation/welcome_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.ink.withOpacity(0.5),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
            ),
          ),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.paper,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.paper, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Premium Background with subtle glowing orbs
          Positioned.fill(
            child: Container(color: AppColors.ink),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.danfoYellow.withOpacity(0.05),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(duration: 4.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.kekeGreen.withOpacity(0.05),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(duration: 5.seconds, begin: const Offset(1, 1), end: const Offset(1.3, 1.3)),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.danfoYellow.withOpacity(0.3), width: 2),
                          ),
                        ).animate(onPlay: (controller) => controller.repeat()).scale(duration: 2.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)).fade(begin: 1, end: 0),
                        TWProfileAvatar(
                          initials: 'AK',
                          radius: 48.0,
                          onUploadTapped: () {
                            // TODO: Trigger image picker
                          },
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 500.ms).scale(curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 40),
                  
                  // Form fields inside glassmorphic cards
                  _buildSectionHeader('Personal Information'),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    child: Column(
                      children: [
                        const TWTextField(
                          label: 'Full Name',
                          hintText: 'Alhaji Kehinde',
                          prefixIcon: Icon(Icons.person_outline, color: AppColors.muted),
                        ),
                        const SizedBox(height: 16),
                        const TWTextField(
                          label: 'Phone Number',
                          hintText: '802 899 1234',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icon(Icons.phone_outlined, color: AppColors.muted),
                        ),
                        const SizedBox(height: 16),
                        const TWTextField(
                          label: 'Email Address',
                          hintText: 'kehinde@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(Icons.email_outlined, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader('Preferences'),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Language', style: AppTypography.label.copyWith(color: AppColors.muted)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.ink.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLanguage,
                              dropdownColor: const Color(0xFF1E293B),
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
                              style: GoogleFonts.outfit(color: AppColors.paper, fontSize: 16, fontWeight: FontWeight.w500),
                              items: ['English', 'Pidgin (Beta)', 'Yoruba (Beta)', 'Hausa (Beta)']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.language, color: AppColors.kekeGreen, size: 20),
                                      const SizedBox(width: 12),
                                      Text(value),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedLanguage = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader('Vehicle Information'),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    child: const TWTextField(
                      label: 'Plate Number',
                      hintText: 'LND-123-XY',
                      prefixIcon: Icon(Icons.directions_car_outlined, color: AppColors.muted),
                    ),
                  ).animate().fade(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 48),
                  
                  // Buttons
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: AppColors.kekeGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: TWButton(
                          label: 'Save Changes',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                            (route) => false,
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Log Out',
                              style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        color: AppColors.danfoYellow,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: child,
        ),
      ),
    );
  }
}
