import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_text_field.dart';
import '../../data/driver_repository.dart';
import '../dashboard/driver_dashboard_screen.dart';

class DriverRouteSetupScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  const DriverRouteSetupScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<DriverRouteSetupScreen> createState() => _DriverRouteSetupScreenState();
}

class _DriverRouteSetupScreenState extends ConsumerState<DriverRouteSetupScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  
  // List of maps: { 'stop_name': string, 'fare': double, 'controller': TextEditingController }
  final List<Map<String, dynamic>> _stops = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize with one default stop for the destination
    _addStop();
  }

  void _addStop() {
    setState(() {
      _stops.add({
        'stop_name': TextEditingController(),
        'fare': 100.0, // Default 100 Naira
      });
    });
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
    });
  }

  Future<void> _submitRoute() async {
    final origin = _originController.text.trim();
    final destination = _destinationController.text.trim();

    if (origin.isEmpty || destination.isEmpty) {
      setState(() => _errorMessage = 'Please enter origin and destination');
      return;
    }

    if (_stops.isEmpty) {
      setState(() => _errorMessage = 'Please add at least one stop (e.g. the final destination)');
      return;
    }

    // Build the fare tiers list for the repository
    final List<Map<String, dynamic>> fareTiers = [];
    for (int i = 0; i < _stops.length; i++) {
      final name = (_stops[i]['stop_name'] as TextEditingController).text.trim();
      final fare = _stops[i]['fare'] as double;
      
      if (name.isEmpty) {
        setState(() => _errorMessage = 'Stop name cannot be empty');
        return;
      }
      
      fareTiers.add({
        'stop_name': name,
        'stop_order': i + 1,
        'fare': fare, // In Naira, repository will convert to Kobo
      });
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = ref.read(driverRepositoryProvider);
    final result = await repo.setupRoute(
      vehicleId: widget.vehicleId,
      origin: origin,
      destination: destination,
      fareTiers: fareTiers,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DriverDashboardScreen()),
          (route) => false, // Clear stack
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Define Route & Fares',
                    style: GoogleFonts.outfit(
                      color: AppColors.paper,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fade(duration: 400.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Set your starting point, final destination, and the prices for each stop along the way.',
                    style: GoogleFonts.manrope(
                      color: AppColors.muted,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

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
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Origin & Destination
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderStroke),
                        ),
                        child: Column(
                          children: [
                            TWTextField(
                              label: 'Origin (Start)',
                              controller: _originController,
                              hintText: 'e.g. Ikeja',
                              prefixIcon: const Icon(Icons.trip_origin, color: AppColors.kekeGreen, size: 20),
                            ),
                            const SizedBox(height: 16),
                            TWTextField(
                              label: 'Final Destination',
                              controller: _destinationController,
                              hintText: 'e.g. Yaba',
                              prefixIcon: const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                            ),
                          ],
                        ),
                      ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Stops & Fare Tiers',
                            style: GoogleFonts.outfit(
                              color: AppColors.paper,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addStop,
                            icon: const Icon(Icons.add_circle, color: AppColors.kekeGreen, size: 18),
                            label: Text(
                              'Add Stop',
                              style: GoogleFonts.manrope(color: AppColors.kekeGreen, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ).animate().fade(delay: 300.ms),

                      const SizedBox(height: 12),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _stops.length,
                        itemBuilder: (context, index) {
                          return _buildStopItem(index);
                        },
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: TWButton(
                  label: _isLoading ? 'Generating QR Code...' : 'Finish Setup',
                  icon: Icons.qr_code,
                  onPressed: _isLoading ? () {} : _submitRoute,
                ),
              ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.highlightBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.outfit(color: AppColors.paper, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Stop ${index + 1}',
                    style: GoogleFonts.outfit(color: AppColors.paper, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (_stops.length > 1)
                GestureDetector(
                  onTap: () => _removeStop(index),
                  child: const Icon(Icons.close, color: AppColors.muted, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TWTextField(
            label: 'Stop Name',
            controller: _stops[index]['stop_name'],
            hintText: 'e.g. Maryland Bus Stop',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Fare to this stop:',
                  style: GoogleFonts.manrope(color: AppColors.muted, fontSize: 14),
                ),
              ),
              Row(
                children: [
                  _buildCircleButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (_stops[index]['fare'] > 50) {
                        setState(() => _stops[index]['fare'] -= 50);
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '₦${_stops[index]['fare'].toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                      color: AppColors.kekeGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildCircleButton(
                    icon: Icons.add,
                    onTap: () {
                      if (_stops[index]['fare'] < 5000) {
                        setState(() => _stops[index]['fare'] += 50);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.highlightBackground,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.paper, size: 16),
      ),
    );
  }
}
