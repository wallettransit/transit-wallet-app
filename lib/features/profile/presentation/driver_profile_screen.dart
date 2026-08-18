import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),
        title: Text(
          'Edit Profile',
          style: AppTypography.heading3.copyWith(color: AppColors.paper),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            center: Alignment(-0.8, -0.8),
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar section
                    Center(
                      child: TWProfileAvatar(
                        initials: 'AK',
                        radius: 48.0,
                        onUploadTapped: () {
                          // TODO: Trigger image picker
                        },
                      ),
                    ).animate().fade(duration: 400.ms).scale(curve: Curves.easeOutBack),
                    const SizedBox(height: 32),
                    
                    // Form fields
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: AppTypography.heading3.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
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
                        
                        const SizedBox(height: 24),
                        Text(
                          'Preferences',
                          style: AppTypography.heading3.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        // Language Dropdown
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedLanguage,
                                  dropdownColor: const Color(0xFF1E293B),
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.muted),
                                  style: AppTypography.bodyLarge.copyWith(color: AppColors.paper),
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
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Language changed to $newValue'),
                                          backgroundColor: AppColors.kekeGreen,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        Text(
                          'Vehicle Information',
                          style: AppTypography.heading3.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        const TWTextField(
                          label: 'Plate Number',
                          hintText: 'LND-123-XY',
                          prefixIcon: Icon(Icons.directions_car_outlined, color: AppColors.muted),
                        ),
                        const SizedBox(height: 48),
                        TWButton(
                          label: 'Save Changes',
                          onPressed: () {
                            // TODO: Save profile logic
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 16),
                        TWButton(
                          label: 'Log Out',
                          variant: TWButtonVariant.destructive,
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                              (route) => false,
                            );
                          },
                        ),
                      ].animate(interval: 50.ms, delay: 200.ms).fade(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
