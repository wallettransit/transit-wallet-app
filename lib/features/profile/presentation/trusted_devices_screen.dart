import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_snackbar.dart';

// Mock Model
class DeviceSession {
  final String id;
  final String deviceName;
  final String osVersion;
  final String lastActive;
  final String location;
  final bool isCurrentDevice;

  DeviceSession({
    required this.id,
    required this.deviceName,
    required this.osVersion,
    required this.lastActive,
    required this.location,
    this.isCurrentDevice = false,
  });
}

// Mock Provider
final trustedDevicesProvider = StateNotifierProvider<TrustedDevicesNotifier, AsyncValue<List<DeviceSession>>>((ref) {
  return TrustedDevicesNotifier();
});

class TrustedDevicesNotifier extends StateNotifier<AsyncValue<List<DeviceSession>>> {
  TrustedDevicesNotifier() : super(const AsyncValue.loading()) {
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    // Mock network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final devices = [
      DeviceSession(
        id: 'dev_1',
        deviceName: 'iPhone 13 Pro',
        osVersion: 'iOS 17.1',
        lastActive: 'Active now',
        location: 'Lagos, Nigeria',
        isCurrentDevice: true,
      ),
      DeviceSession(
        id: 'dev_2',
        deviceName: 'Samsung Galaxy S22',
        osVersion: 'Android 14',
        lastActive: '2 days ago',
        location: 'Abuja, Nigeria',
      ),
      DeviceSession(
        id: 'dev_3',
        deviceName: 'Chrome on Windows',
        osVersion: 'Windows 11',
        lastActive: '1 week ago',
        location: 'Lagos, Nigeria',
      ),
    ];
    
    state = AsyncValue.data(devices);
  }

  Future<void> removeDevice(String id) async {
    final currentState = state.value;
    if (currentState == null) return;
    
    // Optimistic update
    state = AsyncValue.data(currentState.where((d) => d.id != id).toList());
    
    // In reality, we would call the backend here to revoke the session token
    // await Supabase.instance.client.functions.invoke('revoke-session', body: {'device_id': id});
  }
}

class TrustedDevicesScreen extends ConsumerWidget {
  const TrustedDevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesState = ref.watch(trustedDevicesProvider);

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
          'Trusted Devices',
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
      body: devicesState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.kekeGreen)),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (devices) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: devices.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    'You are currently logged in on these devices. If you don\'t recognize a device, remove it immediately to protect your account.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.muted, height: 1.4),
                  ).animate().fade().slideY(begin: 0.1),
                );
              }
              
              final device = devices[index - 1];
              return _buildDeviceCard(context, ref, device)
                  .animate()
                  .fade(delay: Duration(milliseconds: 100 * index))
                  .slideY(begin: 0.1);
            },
          );
        },
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, WidgetRef ref, DeviceSession device) {
    final IconData iconData;
    if (device.deviceName.toLowerCase().contains('iphone') || device.deviceName.toLowerCase().contains('ipad')) {
      iconData = Icons.phone_iphone;
    } else if (device.deviceName.toLowerCase().contains('windows') || device.deviceName.toLowerCase().contains('mac')) {
      iconData = Icons.computer;
    } else {
      iconData = Icons.smartphone;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: device.isCurrentDevice ? AppColors.kekeGreen.withOpacity(0.5) : Colors.grey[200]!),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: device.isCurrentDevice ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: device.isCurrentDevice ? AppColors.kekeGreen : AppColors.muted,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        device.deviceName,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.paper,
                        ),
                      ),
                    ),
                    if (device.isCurrentDevice)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Current',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.kekeGreen,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  device.osVersion,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(
                      device.location,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(
                      device.lastActive,
                      style: AppTypography.bodySmall.copyWith(
                        color: device.isCurrentDevice ? AppColors.kekeGreen : AppColors.muted,
                        fontWeight: device.isCurrentDevice ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!device.isCurrentDevice)
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.errorRed, size: 20),
              tooltip: 'Sign out of this device',
              onPressed: () {
                _confirmSignOut(context, ref, device);
              },
            ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref, DeviceSession device) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove Device', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.paper)),
        content: Text(
          'Are you sure you want to sign out of ${device.deviceName}? You will need to log in again on that device.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTypography.bodyMedium.copyWith(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () {
              ref.read(trustedDevicesProvider.notifier).removeDevice(device.id);
              Navigator.pop(ctx);
              TWSnackbar.showSuccess(context, 'Signed out of ${device.deviceName}');
            },
            child: Text('Remove', style: AppTypography.bodyMedium.copyWith(color: AppColors.errorRed, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
