import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import 'package:intl/intl.dart';
import 'passenger_group_available_groups_screen.dart';

class PassengerGroupDateTimeScreen extends StatefulWidget {
  const PassengerGroupDateTimeScreen({super.key});

  @override
  State<PassengerGroupDateTimeScreen> createState() => _PassengerGroupDateTimeScreenState();
}

class _PassengerGroupDateTimeScreenState extends State<PassengerGroupDateTimeScreen> {
  int _selectedDateIndex = 1; // Default to 'Tue 13'
  int _selectedTimeIndex = 1; // Default to '08:15 AM'
  int _selectedVehicleIndex = 0; // Default to 'Danfo'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIconButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.pop(context),
                      ),
                      Text(
                        'Schedule your commute',
                        style: GoogleFonts.outfit(
                          color: AppColors.paper,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      _buildIconButton(
                        icon: Icons.help_outline,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your travel window and vehicle type to discover active groups.',
                    style: GoogleFonts.manrope(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fade(duration: 300.ms).slideY(begin: -0.1),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Picker
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Date',
                            style: GoogleFonts.outfit(
                              color: AppColors.paper,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 68,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(5, (index) {
                                final date = DateTime.now().add(Duration(days: index));
                                final dayFormat = DateFormat('E');
                                final dateFormat = DateFormat('d');
                                return Padding(
                                  padding: EdgeInsets.only(right: index < 4 ? 10.0 : 0),
                                  child: _buildDateCard(index, dayFormat.format(date), dateFormat.format(date)),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 400.ms, delay: 100.ms),

                    // Time Slots
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Departure Time',
                            style: GoogleFonts.outfit(
                              color: AppColors.paper,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildTimeCard(0, '07:30 AM', 'Morning Rush'),
                              _buildTimeCard(1, '08:15 AM', 'Morning Rush'),
                              _buildTimeCard(2, '09:00 AM', 'Late Morning'),
                              _buildTimeCard(3, '12:30 PM', 'Afternoon'),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),

                    // Vehicle Selector
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Vehicle Type',
                            style: GoogleFonts.outfit(
                              color: AppColors.paper,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildVehicleCard(0, Icons.directions_bus_filled_outlined, 'Danfo')),
                              const SizedBox(width: 10),
                              Expanded(child: _buildVehicleCard(1, Icons.electric_rickshaw_outlined, 'Keke')),
                              const SizedBox(width: 10),
                              Expanded(child: _buildVehicleCard(2, Icons.directions_car_outlined, 'Private Car')),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: TWButton(
                          label: 'Find Available Groups',
                          icon: Icons.search,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PassengerGroupAvailableGroupsScreen()),
                            );
                          },
                        ),
                      ),
                    ).animate().fade(duration: 400.ms, delay: 400.ms),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Icon(icon, size: 20, color: AppColors.paper),
      ),
    );
  }

  Widget _buildDateCard(int index, String day, String date) {
    bool isSelected = _selectedDateIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedDateIndex = index),
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kekeGreen : AppColors.ink,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.kekeGreen : AppColors.borderStroke),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: GoogleFonts.manrope(
                color: isSelected ? AppColors.ink : AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: GoogleFonts.outfit(
                color: isSelected ? AppColors.ink : AppColors.paper,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(int index, String time, String label) {
    bool isSelected = _selectedTimeIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeIndex = index),
      child: Container(
        width: (MediaQuery.of(context).size.width - 58) / 2, // 2 columns
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.danfoYellow.withOpacity(0.15) : AppColors.ink,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.danfoYellow : AppColors.borderStroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: GoogleFonts.outfit(
                color: AppColors.paper,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.manrope(
                color: AppColors.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(int index, IconData icon, String label) {
    bool isSelected = _selectedVehicleIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicleIndex = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kekeGreen.withOpacity(0.1) : AppColors.ink,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.kekeGreen : AppColors.borderStroke, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.paper),
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
