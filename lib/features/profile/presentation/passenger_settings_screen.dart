import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_snackbar.dart';
import '../providers/settings_provider.dart';
import 'change_password_screen.dart';
import 'security_settings_screen.dart';

class PassengerSettingsScreen extends ConsumerWidget {
  const PassengerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: AppTypography.heading3.copyWith(color: AppColors.paper),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Security'),
              const SizedBox(height: 16),
              _buildActionRow(
                icon: Icons.security_outlined,
                title: 'Device Lock & PIN',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()));
                },
              ),
              _buildActionRow(
                icon: Icons.password,
                title: 'Change Password',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
                },
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Notifications'),
              const SizedBox(height: 16),
              _buildToggleRow(
                icon: Icons.notifications_active_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive updates about your rides',
                value: settings.pushNotifications,
                onChanged: (val) => settingsNotifier.setPushNotifications(val),
              ),
              _buildToggleRow(
                icon: Icons.receipt_long_outlined,
                title: 'Email Receipts',
                subtitle: 'Get receipts for your trips',
                value: settings.emailReceipts,
                onChanged: (val) => settingsNotifier.setEmailReceipts(val),
              ),
              _buildToggleRow(
                icon: Icons.sms_outlined,
                title: 'SMS Alerts',
                subtitle: 'Get text alerts for important updates',
                value: settings.smsAlerts,
                onChanged: (val) => settingsNotifier.setSmsAlerts(val),
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('App Preferences'),
              const SizedBox(height: 16),
              _buildToggleRow(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'App appearance',
                value: settings.isDarkMode,
                onChanged: (val) => settingsNotifier.setDarkMode(val),
              ),
              _buildActionRow(
                icon: Icons.language,
                title: 'Language',
                trailing: Text(
                  'English (UK)',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
                ),
                onTap: () {
                  TWSnackbar.showSuccess(context, 'Language selection coming soon.');
                },
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Account Management'),
              const SizedBox(height: 16),
              _buildActionRow(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                isDestructive: true,
                onTap: () {
                  TWSnackbar.showError(context, 'Account deletion flow coming soon.');
                },
              ),
              
              const SizedBox(height: 60),
            ],
          ).animate().fade(duration: 300.ms).slideY(begin: 0.1),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.kekeGreen,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.highlightBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.kekeGreen, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.paper,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.ink,
              activeTrackColor: AppColors.kekeGreen,
              inactiveThumbColor: AppColors.muted,
              inactiveTrackColor: AppColors.highlightBackground,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.danfoYellow : AppColors.kekeGreen;
    final textColor = isDestructive ? AppColors.danfoYellow : AppColors.paper;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDestructive 
                      ? color.withOpacity(0.1) 
                      : AppColors.highlightBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) ...[
                trailing,
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right,
                color: isDestructive ? color.withOpacity(0.5) : AppColors.muted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
