import '../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../driver_qr/presentation/driver_qr_screen.dart';

class DriverRouteSetupScreen extends StatefulWidget {
  const DriverRouteSetupScreen({super.key});

  @override
  State<DriverRouteSetupScreen> createState() => _DriverRouteSetupScreenState();
}

class _DriverRouteSetupScreenState extends State<DriverRouteSetupScreen> {
  final List<String> _routes = ['Oshodi → CMS', 'Berger → Ojota', 'Iyana Ipaja → Yaba'];
  final List<String> _routeDetails = [
    '18.2 km • 140+ active today',
    '9.5 km • 98 active today',
    '22.4 km • 110 active today'
  ];
  String? _selectedRoute = 'Oshodi → CMS';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: SafeArea(
        child: Column(
          children: [
            // screen-header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderStroke, width: 1),
                      ),
                      child: const Icon(Icons.arrow_back, color: AppTheme.paper, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Route Setup',
                        style: GoogleFonts.outfit(
                          color: AppTheme.paper,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 25.2 / 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Set your running route and pricing tiers',
                        style: GoogleFonts.manrope(
                          color: AppTheme.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 19.5 / 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // map-container equivalent
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(color: AppColors.cardBackground), // map placeholder
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.ink,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.kekeGreen, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on, color: AppTheme.kekeGreen, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Currently at Oshodi Terminal 3',
                                  style: GoogleFonts.manrope(
                                    color: AppTheme.paper,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    height: 18.0 / 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // suggestions
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Common Suggested Routes',
                            style: GoogleFonts.manrope(
                              color: AppTheme.muted,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 22.5 / 15,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(_routes.length, (index) {
                            final isSelected = _selectedRoute == _routes[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRoute = _routes[index];
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.kekeGreen : AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.kekeGreen : AppColors.borderStroke,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _routes[index],
                                          style: GoogleFonts.manrope(
                                            color: AppTheme.paper,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            height: 24.0 / 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _routeDetails[index],
                                          style: GoogleFonts.manrope(
                                            color: isSelected ? AppTheme.ink : AppTheme.muted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            height: 18.0 / 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppTheme.kekeGreen : AppColors.highlightBackground,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: isSelected ? const Icon(Icons.check, size: 14, color: AppTheme.ink) : null,
                                    ),
                                  ],
                                ),
                              ).animate(delay: (index * 100).ms).fade(duration: 400.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                            );
                          }),
                          
                          // fare-setting
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Text(
                                  'Fare Pricing Tiers',
                                  style: GoogleFonts.manrope(
                                    color: AppTheme.muted,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    height: 22.5 / 15,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTierInput('Short (e.g. 1-3 stops)', '₦300'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTierInput('Full Route Fare', '₦500'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // bottom-action
            Container(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _selectedRoute != null ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DriverQrScreen()),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.kekeGreen,
                    foregroundColor: AppTheme.ink,
                    disabledBackgroundColor: AppTheme.kekeGreen.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, size: 20, color: AppTheme.ink),
                      const SizedBox(width: 8),
                      Text(
                        'Confirm Route & Fares',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 20.2 / 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierInput(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: AppTheme.muted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 18.0 / 12,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: TextField(
            keyboardType: TextInputType.number,
            style: GoogleFonts.manrope(color: AppTheme.paper, fontSize: 16, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.manrope(color: AppTheme.paper, fontSize: 16, fontWeight: FontWeight.w700),
              filled: true,
              fillColor: AppColors.cardBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
