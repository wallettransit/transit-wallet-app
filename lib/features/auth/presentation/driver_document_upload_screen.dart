import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_document_upload_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../driver/data/driver_repository.dart';
import '../../../../core/components/tw_snackbar.dart';
import 'driver_onboarding_verification_screen.dart';

class DriverDocumentUploadScreen extends ConsumerStatefulWidget {
  const DriverDocumentUploadScreen({super.key});

  @override
  ConsumerState<DriverDocumentUploadScreen> createState() => _DriverDocumentUploadScreenState();
}

class _DriverDocumentUploadScreenState extends ConsumerState<DriverDocumentUploadScreen> {
  final Map<String, String> _uploadedDocs = {};
  bool _isLoading = false;

  void _handleDocUpload(String docType) {
    // Mocking file picker
    setState(() {
      _uploadedDocs[docType] = 'mock_path_for_$docType.jpg';
    });
  }

  void _submitDocuments() async {
    if (_uploadedDocs.length < 4) {
      TWSnackbar.showError(context, 'Please upload all 4 required documents.');
      return;
    }

    setState(() => _isLoading = true);

    final result = await ref.read(driverRepositoryProvider).uploadDriverDocuments(
      documents: _uploadedDocs,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DriverOnboardingVerificationScreen()),
        );
      }
    } else {
      TWSnackbar.showError(context, result['message'] ?? 'Upload failed');
    }
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
                        'Step 3 of 4',
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
                      widthFactor: 0.75,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.kekeGreen,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ).animate().scaleX(begin: 0.5, end: 1, duration: 600.ms, curve: Curves.easeOutCubic, alignment: Alignment.centerLeft),
                  const SizedBox(height: 16),
                  Text(
                    'Upload your documents',
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
                      'We require verified federal and state-level driver details to keep our transit platform secure and compliant.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),
                    
                    TWDocumentUploadTile(
                      label: 'Driver\'s License',
                      status: _uploadedDocs.containsKey('drivers_license') ? DocumentStatus.uploaded : DocumentStatus.pending,
                      documentIcon: Icons.badge_outlined,
                      onTap: () => _handleDocUpload('drivers_license'),
                    ).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 16),
                    
                    TWDocumentUploadTile(
                      label: 'Vehicle Papers (LASG / State)',
                      status: _uploadedDocs.containsKey('vehicle_papers') ? DocumentStatus.uploaded : DocumentStatus.pending,
                      documentIcon: Icons.description_outlined,
                      onTap: () => _handleDocUpload('vehicle_papers'),
                    ).animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 16),
                    
                    TWDocumentUploadTile(
                      label: 'Vehicle Insurance Policy',
                      status: _uploadedDocs.containsKey('insurance') ? DocumentStatus.uploaded : DocumentStatus.pending,
                      documentIcon: Icons.shield_outlined,
                      onTap: () => _handleDocUpload('insurance'),
                    ).animate().fade(delay: 600.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 16),
                    
                    TWDocumentUploadTile(
                      label: 'Road Worthiness Certificate',
                      status: _uploadedDocs.containsKey('road_worthiness') ? DocumentStatus.uploaded : DocumentStatus.pending,
                      documentIcon: Icons.verified_outlined,
                      onTap: () => _handleDocUpload('road_worthiness'),
                    ).animate().fade(delay: 700.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 32),
                    
                    // Security Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, size: 16, color: AppColors.muted),
                        const SizedBox(width: 8),
                        Text(
                          'LASG & FRSC regulatory compliant storage',
                          style: AppTypography.label.copyWith(fontSize: 12, color: AppColors.muted),
                        ),
                      ],
                    ).animate().fade(delay: 800.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),
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
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TWButton(
                    label: 'Submit Documents',
                    onPressed: _submitDocuments,
                  ),
            ).animate().slideY(begin: 1, end: 0, duration: 400.ms, delay: 900.ms, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}
