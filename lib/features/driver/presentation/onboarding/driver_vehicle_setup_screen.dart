import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_text_field.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/driver_repository.dart';
import 'driver_route_setup_screen.dart';

class DriverVehicleSetupScreen extends ConsumerStatefulWidget {
  const DriverVehicleSetupScreen({super.key});

  @override
  ConsumerState<DriverVehicleSetupScreen> createState() => _DriverVehicleSetupScreenState();
}

class _DriverVehicleSetupScreenState extends ConsumerState<DriverVehicleSetupScreen> {
  final _plateController = TextEditingController();
  int _selectedVehicleIndex = 0; // 0=Danfo, 1=Keke, 2=Bus
  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _vehicleTypes = [
    {'id': 'danfo', 'label': 'Danfo', 'icon': Icons.directions_bus_filled_outlined},
    {'id': 'keke', 'label': 'Keke', 'icon': Icons.electric_rickshaw_outlined},
    {'id': 'bus', 'label': 'Bus (BRT)', 'icon': Icons.directions_bus_outlined},
  ];

  Future<void> _submitVehicle() async {
    final plateNumber = _plateController.text.trim();
    if (plateNumber.isEmpty) {
      setState(() => _errorMessage = 'Please enter your license plate number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) return;

    final repo = ref.read(driverRepositoryProvider);
    final vehicleType = _vehicleTypes[_selectedVehicleIndex]['id'] as String;
    
    final result = await repo.registerVehicle(
      driverId: currentUser.id, 
      plateNumber: plateNumber, 
      vehicleType: vehicleType,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DriverRouteSetupScreen(vehicleId: result['vehicle_id'])),
        );
      } else {
        setState(() => _errorMessage = result['message']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.paper, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register Vehicle',
                style: GoogleFonts.outfit(
                  color: AppColors.paper,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 8),
              
              Text(
                'Add your primary operating vehicle to receive a TransitWallet QR Code.',
                style: GoogleFonts.manrope(
                  color: AppColors.muted,
                  fontSize: 15,
                  height: 1.5,
                ),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.manrope(
                              color: Colors.redAccent,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(),

              // Vehicle Type Selector
              Text(
                'Vehicle Type',
                style: GoogleFonts.outfit(
                  color: AppColors.paper,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fade(delay: 200.ms),
              const SizedBox(height: 12),
              Row(
                children: _vehicleTypes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final type = entry.value;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index < 2 ? 10.0 : 0),
                      child: _buildVehicleCard(index, type['icon'], type['label']),
                    ),
                  );
                }).toList(),
              ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              TWTextField(
                label: 'License Plate Number',
                controller: _plateController,
                hintText: 'e.g. KJA-123-YB',
                prefixIcon: const Icon(Icons.pin_outlined, color: AppColors.paper, size: 20),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.1),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: TWButton(
                  label: _isLoading ? 'Registering...' : 'Continue to Route Setup',
                  onPressed: _isLoading ? () {} : _submitVehicle,
                ),
              ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(int index, IconData icon, String label) {
    bool isSelected = _selectedVehicleIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicleIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kekeGreen.withOpacity(0.1) : AppColors.ink,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.kekeGreen : AppColors.borderStroke, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppColors.paper),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: AppColors.paper,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
