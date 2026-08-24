import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PromoItem {
  final String title;
  final String description;
  final String ctaText;
  final Color backgroundColor;
  final Color accentColor;
  final String imagePath;
  final IconData icon;

  PromoItem({
    required this.title,
    required this.description,
    required this.ctaText,
    required this.backgroundColor,
    required this.accentColor,
    this.imagePath = '',
    required this.icon,
  });
}

class TWUpdatesCarousel extends StatefulWidget {
  final List<PromoItem> promos;

  const TWUpdatesCarousel({super.key, required this.promos});

  @override
  State<TWUpdatesCarousel> createState() => _TWUpdatesCarouselState();
}

class _TWUpdatesCarouselState extends State<TWUpdatesCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.93);
    
    // Auto-scroll logic
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < widget.promos.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Updates for You',
            style: AppTypography.heading2.copyWith(color: AppColors.paper, fontSize: 18),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: widget.promos.length,
            itemBuilder: (context, index) {
              return _buildPromoCard(widget.promos[index], index == _currentPage);
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.promos.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.kekeGreen : AppColors.muted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard(PromoItem promo, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
      decoration: BoxDecoration(
        color: promo.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: promo.accentColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Stack(
        children: [
          // Background abstract shape
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              promo.icon,
              size: 120,
              color: Colors.black.withOpacity(0.05),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: promo.accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          promo.title,
                          style: GoogleFonts.outfit(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        promo.description,
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            promo.ctaText,
                            style: GoogleFonts.outfit(
                              color: promo.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 10, color: promo.accentColor),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(promo.icon, size: 48, color: Colors.white),
                    ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 3.seconds, color: Colors.white.withOpacity(0.3)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PromoData {
  static List<PromoItem> get passengerPromos => [
    PromoItem(
      title: 'TRANSIT REWARDS',
      description: 'Load ₦5000 and get 10% cashback on your next 5 rides!',
      ctaText: 'Top Up Now',
      backgroundColor: const Color(0xFF6C3483), // Purple
      accentColor: const Color(0xFFE8DAEF), // Light Purple
      icon: Icons.account_balance_wallet,
    ),
    PromoItem(
      title: 'REFER & EARN',
      description: 'Invite a friend to OyaPayWallet. You both get a free ride!',
      ctaText: 'Share Link',
      backgroundColor: const Color(0xFF2874A6), // Blue
      accentColor: const Color(0xFFD4E6F1), // Light Blue
      icon: Icons.people_alt,
    ),
    PromoItem(
      title: 'NEW FEATURE',
      description: 'Group Rides are here! Share rides and pay less.',
      ctaText: 'Try Group Rides',
      backgroundColor: const Color(0xFF0F1612), // Dark Slate
      accentColor: const Color(0xFFFFCC00), // Danfo Yellow
      icon: Icons.directions_bus_filled,
    ),
    PromoItem(
      title: 'COMING SOON',
      description: 'Ride Advance! Get a ride now and pay later when you top up.',
      ctaText: 'Learn More',
      backgroundColor: const Color(0xFF1B263B), // Navy Blue
      accentColor: const Color(0xFF00FF87), // Keke Green
      icon: Icons.credit_score_rounded,
    ),
  ];

  static List<PromoItem> get driverPromos => [
    PromoItem(
      title: 'DAILY BONUS',
      description: 'Complete 20 rides today and get a ₦1000 cash bonus!',
      ctaText: 'View Progress',
      backgroundColor: const Color(0xFF1E8449), // Deep Green
      accentColor: const Color(0xFFD5F5E3), // Light Green
      icon: Icons.directions_car,
    ),
    PromoItem(
      title: 'FAST WITHDRAWALS',
      description: 'Cash outs are now instant. Get your earnings in seconds.',
      ctaText: 'Cash Out Now',
      backgroundColor: const Color(0xFF2874A6), // Blue
      accentColor: const Color(0xFFD4E6F1), // Light Blue
      icon: Icons.payments,
    ),
    PromoItem(
      title: 'ELITE DRIVER',
      description: 'Maintain a 5-star rating this week for lower commission rates.',
      ctaText: 'See Requirements',
      backgroundColor: const Color(0xFF884EA0), // Purple
      accentColor: const Color(0xFFE8DAEF), // Light Purple
      icon: Icons.star,
    ),
  ];
}
