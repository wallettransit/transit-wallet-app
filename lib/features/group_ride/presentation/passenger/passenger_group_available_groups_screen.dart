import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_profile_avatar.dart';
import 'passenger_group_details_screen.dart';

class PassengerGroupAvailableGroupsScreen extends StatelessWidget {
  const PassengerGroupAvailableGroupsScreen({super.key});

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
                        'Groups traveling today',
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
                    'Commutes matching Yaba Terminal to Lekki Phase 1',
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
                  children: [
                    // Groups Stack
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildGroupCard(
                            context,
                            matchPercent: '98%',
                            creatorInitials: 'AM',
                            creatorName: 'Amara',
                            groupType: 'Danfo Group',
                            seatsAvailable: '4 seats left',
                            departureTime: 'Departs 08:15 AM',
                            originalPrice: '₦1,200',
                            groupPrice: '₦450',
                          ),
                          const SizedBox(height: 16),
                          _buildGroupCard(
                            context,
                            matchPercent: '92%',
                            creatorInitials: 'JD',
                            creatorName: 'Jide',
                            groupType: 'Keke Group',
                            seatsAvailable: '2 seats left',
                            departureTime: 'Departs 08:30 AM',
                            originalPrice: '₦1,200',
                            groupPrice: '₦400',
                          ),
                          const SizedBox(height: 16),
                          _buildGroupCard(
                            context,
                            matchPercent: '85%',
                            creatorInitials: 'SO',
                            creatorName: 'Sola',
                            groupType: 'Danfo Group',
                            seatsAvailable: '10 seats left',
                            departureTime: 'Departs 09:00 AM',
                            originalPrice: '₦1,200',
                            groupPrice: '₦380',
                          ),
                        ].animate(interval: 100.ms).fade(duration: 400.ms).slideY(begin: 0.1),
                      ),
                    ),

                    // Footer Note
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          "Don't see a suitable group? Create one!",
                          style: GoogleFonts.manrope(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ).animate().fade(duration: 400.ms, delay: 400.ms),
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

  Widget _buildGroupCard(
    BuildContext context, {
    required String matchPercent,
    required String creatorInitials,
    required String creatorName,
    required String groupType,
    required String seatsAvailable,
    required String departureTime,
    required String originalPrice,
    required String groupPrice,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PassengerGroupDetailsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderStroke),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TWProfileAvatar(initials: creatorInitials, radius: 18),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$creatorName\'s Group',
                          style: GoogleFonts.outfit(
                            color: AppColors.paper,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          groupType,
                          style: GoogleFonts.manrope(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.kekeGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '$matchPercent Route Match',
                    style: GoogleFonts.manrope(
                      color: AppColors.kekeGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.borderStroke, height: 1),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.group_outlined, size: 14, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Text(
                          seatsAvailable,
                          style: GoogleFonts.manrope(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(Icons.schedule_outlined, size: 14, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Text(
                          departureTime,
                          style: GoogleFonts.manrope(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      originalPrice,
                      style: GoogleFonts.manrope(
                        color: AppColors.muted,
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      groupPrice,
                      style: GoogleFonts.outfit(
                        color: AppColors.kekeGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
