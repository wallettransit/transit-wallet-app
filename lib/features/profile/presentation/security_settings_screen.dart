import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/components/tw_snackbar.dart';
import '../../auth/presentation/change_pin_screen.dart';
import '../../auth/presentation/create_pin_screen.dart';
import 'trusted_devices_screen.dart';

/// Security Settings page — Device Lock, Biometric, Timeout, Change PIN.
class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  bool _isLoading = true;

  // Current state
  bool _deviceLockEnabled = false;
  bool _biometricEnabled = false;
  int _timeoutSeconds = 300;
  bool _hasPin = false;
  bool _biometricsAvailable = false;

  static const List<_TimeoutOption> _timeoutOptions = [
    _TimeoutOption(label: 'Immediately', seconds: 1),
    _TimeoutOption(label: 'After 30 seconds', seconds: 30),
    _TimeoutOption(label: 'After 1 minute', seconds: 60),
    _TimeoutOption(label: 'After 5 minutes', seconds: 300),
    _TimeoutOption(label: 'After 15 minutes', seconds: 900),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final deviceLock = await SecureStorageService.isDeviceLockEnabled();
    final biometric = await SecureStorageService.isBiometricUnlockEnabled();
    final timeout = await SecureStorageService.getLockTimeoutSeconds();
    final hasPin = await SecureStorageService.hasPin();

    // Check hardware biometric availability
    bool biometricsAvailable = false;
    try {
      final localAuth = LocalAuthentication();
      biometricsAvailable = await localAuth.canCheckBiometrics || await localAuth.isDeviceSupported();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _deviceLockEnabled = deviceLock;
        _biometricEnabled = biometric;
        _timeoutSeconds = timeout;
        _hasPin = hasPin;
        _biometricsAvailable = biometricsAvailable;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleDeviceLock(bool value) async {
    if (value && !_hasPin) {
      // Must create a PIN first
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CreatePinScreen(
            isDark: false,
            onPinCreated: () => Navigator.pop(context, true),
          ),
        ),
      );
      if (result != true) return;
      setState(() => _hasPin = true);
    }

    HapticFeedback.selectionClick();
    await SecureStorageService.setDeviceLockEnabled(value);
    setState(() => _deviceLockEnabled = value);

    if (!value) {
      // Disable biometrics too when device lock is off
      await SecureStorageService.setBiometricUnlockEnabled(false);
      setState(() => _biometricEnabled = false);
    }

    if (mounted) {
      TWSnackbar.showSuccess(
        context,
        value ? 'Device Lock enabled.' : 'Device Lock disabled.',
      );
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (!_deviceLockEnabled) {
      TWSnackbar.showError(context, 'Enable Device Lock first.');
      return;
    }
    if (value && !_biometricsAvailable) {
      TWSnackbar.showError(context, 'Biometrics not available on this device.');
      return;
    }
    HapticFeedback.selectionClick();
    await SecureStorageService.setBiometricUnlockEnabled(value);
    setState(() => _biometricEnabled = value);
  }

  Future<void> _setLockTimeout(int seconds) async {
    await SecureStorageService.setLockTimeoutSeconds(seconds);
    setState(() => _timeoutSeconds = seconds);
    if (mounted) Navigator.pop(context); // close bottom sheet
  }

  void _showTimeoutPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'Lock After',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.paper,
                  ),
                ),
              ),
              const Divider(height: 1),
              ..._timeoutOptions.map((opt) {
                final isSelected = _timeoutSeconds == opt.seconds;
                return ListTile(
                  onTap: () => _setLockTimeout(opt.seconds),
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? AppColors.kekeGreen : Colors.grey[400],
                  ),
                  title: Text(
                    opt.label,
                    style: GoogleFonts.outfit(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.kekeGreen : AppColors.paper,
                      fontSize: 15,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.kekeGreen, size: 20)
                      : null,
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String get _currentTimeoutLabel {
    return _timeoutOptions
        .firstWhere((o) => o.seconds == _timeoutSeconds,
            orElse: () => const _TimeoutOption(label: 'After 5 minutes', seconds: 300))
        .label;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.paper, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Security',
          style: GoogleFonts.outfit(
            color: AppColors.paper,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.kekeGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Device Lock Section ----
                  _buildSectionHeader(
                    icon: Icons.lock_outline,
                    title: 'Device Lock',
                    subtitle: 'Control who can open OyaPay on this device.',
                  ),
                  const SizedBox(height: 12),

                  _buildToggleCard(
                    icon: Icons.screen_lock_portrait_outlined,
                    iconColor: AppColors.kekeGreen,
                    bgColor: const Color(0xFFD1FAE5),
                    title: 'Enable Device Lock',
                    subtitle: 'Lock OyaPay when you leave the app.',
                    value: _deviceLockEnabled,
                    onChanged: _toggleDeviceLock,
                  ),

                  if (_deviceLockEnabled) ...[
                    const SizedBox(height: 10),
                    _buildToggleCard(
                      icon: Icons.fingerprint,
                      iconColor: const Color(0xFF2563EB),
                      bgColor: const Color(0xFFDBEAFE),
                      title: 'Biometric Unlock',
                      subtitle: _biometricsAvailable
                          ? 'Use Face ID or fingerprint to unlock.'
                          : 'Not available on this device.',
                      value: _biometricEnabled,
                      onChanged: _biometricsAvailable ? _toggleBiometric : null,
                    ),
                    const SizedBox(height: 10),
                    _buildActionCard(
                      icon: Icons.timer_outlined,
                      iconColor: const Color(0xFFD97706),
                      bgColor: const Color(0xFFFEF3C7),
                      title: 'Lock After',
                      trailing: Text(
                        _currentTimeoutLabel,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.kekeGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: _showTimeoutPicker,
                    ),
                    const SizedBox(height: 10),
                    _buildActionCard(
                      icon: Icons.devices_other,
                      iconColor: const Color(0xFF0284C7),
                      bgColor: const Color(0xFFE0F2FE),
                      title: 'Trusted Devices',
                      subtitle: 'Manage devices logged into your account.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TrustedDevicesScreen()),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 28),

                  // ---- PIN Section ----
                  _buildSectionHeader(
                    icon: Icons.pin_outlined,
                    title: 'PIN Management',
                    subtitle: 'Your PIN secures app access and authorizes transactions.',
                  ),
                  const SizedBox(height: 12),

                  if (!_hasPin)
                    _buildActionCard(
                      icon: Icons.add_circle_outline,
                      iconColor: AppColors.kekeGreen,
                      bgColor: const Color(0xFFD1FAE5),
                      title: 'Create OyaPay PIN',
                      subtitle: 'Set up a 6-digit PIN to protect your account.',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreatePinScreen(
                              isDark: false,
                              onPinCreated: () {
                                Navigator.pop(context);
                                setState(() => _hasPin = true);
                                TWSnackbar.showSuccess(context, 'PIN created!');
                              },
                            ),
                          ),
                        );
                      },
                    )
                  else
                    _buildActionCard(
                      icon: Icons.lock_reset_outlined,
                      iconColor: const Color(0xFF7C3AED),
                      bgColor: const Color(0xFFEDE9FE),
                      title: 'Change PIN',
                      subtitle: 'Update your 6-digit OyaPay PIN.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePinScreen()),
                        );
                      },
                    ),

                  const SizedBox(height: 10),

                  // Security Info Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Device Lock prevents unauthorized access to OyaPay. '
                            'Your PIN is encrypted and never stored in plaintext.',
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF1D4ED8),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ).animate().fade(duration: 300.ms).slideY(begin: 0.05),
            ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.kekeGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.kekeGreen, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.paper,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(
                        fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.paper)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.kekeGreen,
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.outfit(
                          fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.paper)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[trailing, const SizedBox(width: 4)],
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}

class _TimeoutOption {
  final String label;
  final int seconds;
  const _TimeoutOption({required this.label, required this.seconds});
}
