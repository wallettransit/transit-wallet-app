import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_text_field.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar section
                    Center(
                      child: TWProfileAvatar(
                        initials: initials,
                        radius: 40.0,
                        onUploadTapped: () {
                          // TODO: Trigger image picker
                        },
                      ),
                    ).animate().fade(duration: 400.ms).scale(curve: Curves.easeOutBack),
                    const SizedBox(height: 24),
                    
                    // Form fields
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.paper),
                        ),
                        const SizedBox(height: 16),
                        TWTextField(
                          label: 'Full Name',
                          hintText: fullName,
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.muted),
                        ),
                        const SizedBox(height: 16),
                        TWTextField(
                          label: 'Phone Number',
                          hintText: currentUser?.phone ?? '+234 --- --- ----',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.muted),
                        ),
                        const SizedBox(height: 16),
                        TWTextField(
                          label: 'Email Address',
                          hintText: email,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.muted),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Preferences',
                          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.paper),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderStroke),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Simulate Offline Mode',
                                      style: AppTypography.bodyMedium.copyWith(color: AppColors.paper, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Test low connectivity flows',
                                      style: AppTypography.label.copyWith(color: AppColors.muted),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: isOffline,
                                activeColor: AppColors.kekeGreen,
                                onChanged: (value) {
                                  ref.read(offlineStateProvider.notifier).state = value;
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
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
    );
  }
}
