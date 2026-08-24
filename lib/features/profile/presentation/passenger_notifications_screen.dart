import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class PassengerNotificationsScreen extends StatelessWidget {
  const PassengerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for now
    final notifications = [
      {
        'type': 'success',
        'title': 'Wallet Funded',
        'message': 'You successfully added ₦2,000 to your wallet.',
        'time': '2 mins ago',
        'icon': Icons.account_balance_wallet_outlined,
        'color': AppColors.kekeGreen,
      },
      {
        'type': 'alert',
        'title': 'Security Alert',
        'message': 'New login detected on a different device.',
        'time': '1 hr ago',
        'icon': Icons.security_outlined,
        'color': AppColors.errorRed,
      },
      {
        'type': 'promo',
        'title': 'Ride Advance Available',
        'message': 'You qualify for a ride advance! Tap to activate.',
        'time': '5 hrs ago',
        'icon': Icons.bolt_outlined,
        'color': AppColors.danfoYellow,
      },
      {
        'type': 'info',
        'title': 'System Maintenance',
        'message': 'Expect brief downtime tonight from 2 AM to 3 AM.',
        'time': '1 day ago',
        'icon': Icons.info_outline,
        'color': Colors.blueAccent,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: CustomScrollView(
        slivers: [
          // Glassmorphic App Bar
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.ink.withOpacity(0.9),
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.paper, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Mark all as read logic
                },
                child: Text(
                  'Mark all read',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.kekeGreen),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Notifications',
                style: GoogleFonts.outfit(
                  color: AppColors.paper,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fade().slideX(begin: -0.2, end: 0),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: -50,
                    right: -20,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.kekeGreen.withOpacity(0.1),
                      ),
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(color: Colors.transparent),
                  ),
                ],
              ),
            ),
          ),
          
          // Notifications List
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final notif = notifications[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Container
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (notif['color'] as Color).withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: (notif['color'] as Color).withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            notif['icon'] as IconData,
                            color: notif['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif['title'] as String,
                                      style: GoogleFonts.spaceGrotesk(
                                        color: AppColors.paper,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    notif['time'] as String,
                                    style: AppTypography.label.copyWith(color: AppColors.muted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notif['message'] as String,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.muted.withOpacity(0.8),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: (index * 100).ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
                },
                childCount: notifications.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
