import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_text_field.dart';
import '../../../../core/components/tw_vehicle_type_card.dart';
import 'driver_document_upload_screen.dart';

class DriverVehicleRegistrationScreen extends StatefulWidget {
  const DriverVehicleRegistrationScreen({super.key});

  @override
  State<DriverVehicleRegistrationScreen> createState() => _DriverVehicleRegistrationScreenState();
}

class _DriverVehicleRegistrationScreenState extends State<DriverVehicleRegistrationScreen> {
  String _selectedVehicleType = 'Danfo';

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.borderStroke,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Upload Vehicle Photo',
                  style: AppTypography.heading2.copyWith(color: AppColors.paper),
                ),
                const SizedBox(height: 24),
                _buildPickerOption(
                  icon: Icons.camera_alt,
                  label: 'Take a Photo',
                  onTap: () {
                    Navigator.pop(context);
                    // Handle camera logic
                  },
                ),
                const SizedBox(height: 12),
                _buildPickerOption(
                  icon: Icons.photo_library,
                  label: 'Choose from Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    // Handle gallery logic
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.borderStroke,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.kekeGreen, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTypography.heading3.copyWith(fontSize: 16, color: AppColors.paper),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // Stepper Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderStroke),
                          ),
                          child: const Icon(Icons.chevron_left, size: 20, color: AppColors.paper),
                        ),
                      ),
                      Text(
                        'Step 2 of 4',
                        style: AppTypography.heading3.copyWith(color: AppColors.kekeGreen, fontSize: 14),
                      ),
                      Text(
                        'Skip',
                        style: AppTypography.heading3.copyWith(color: AppColors.muted, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.borderStroke,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.kekeGreen,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ).animate().scaleX(begin: 0, end: 1, duration: 600.ms, curve: Curves.easeOutCubic, alignment: Alignment.centerLeft),
                  const SizedBox(height: 16),
                  Text(
                    'Register your vehicle',
                    style: AppTypography.heading1.copyWith(fontSize: 24, color: AppColors.paper),
                  ).animate().fade(delay: 200.ms).slideX(begin: -0.1, end: 0),
                ],
              ),
            ),

            // Form Fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Vehicle Type',
                      style: AppTypography.heading3.copyWith(fontSize: 14, color: AppColors.paper),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TWVehicleTypeCard(
                            label: 'Danfo',
                            icon: Icons.directions_bus,
                            isSelected: _selectedVehicleType == 'Danfo',
                            onTap: () => setState(() => _selectedVehicleType = 'Danfo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TWVehicleTypeCard(
                            label: 'Keke',
                            icon: Icons.electric_rickshaw,
                            isSelected: _selectedVehicleType == 'Keke',
                            onTap: () => setState(() => _selectedVehicleType = 'Keke'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TWVehicleTypeCard(
                            label: 'Private',
                            icon: Icons.directions_car,
                            isSelected: _selectedVehicleType == 'Private',
                            onTap: () => setState(() => _selectedVehicleType = 'Private'),
                          ),
                        ),
                      ],
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 20),
                    const TWTextField(
                      label: 'License Plate Number *',
                      hintText: 'EKO-588BA',
                      prefixIcon: Icon(Icons.file_present_rounded),
                    ).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TWTextField(
                                label: 'Vehicle Manufacturer *',
                                hintText: 'Toyota',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TWTextField(
                                label: 'Color *',
                                hintText: 'Yellow/Black',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 20),
                    Text(
                      'Vehicle Photo (External view)',
                      style: AppTypography.heading3.copyWith(fontSize: 14, color: AppColors.paper),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showImagePickerBottomSheet,
                      child: Container(
                        height: 130,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.borderStroke.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderStroke, width: 1.5, strokeAlign: BorderSide.strokeAlignInside),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: AppColors.borderStroke),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.camera_alt, color: AppColors.paper, size: 18),
                                const SizedBox(width: 8),
                                Text('Add Photo', style: AppTypography.heading3.copyWith(fontSize: 14, color: AppColors.paper)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate().fade(delay: 600.ms).slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.ink,
                border: Border(top: BorderSide(color: AppColors.borderStroke)),
              ),
              child: TWButton(
                label: 'Next: Document Upload',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverDocumentUploadScreen()),
                  );
                },
              ),
            ).animate().slideY(begin: 1, end: 0, duration: 400.ms, delay: 700.ms, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }

}
