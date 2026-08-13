import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TWLiveTrackingMap extends StatefulWidget {
  final double height;
  const TWLiveTrackingMap({super.key, this.height = 200});

  @override
  State<TWLiveTrackingMap> createState() => _TWLiveTrackingMapState();
}

class _TWLiveTrackingMapState extends State<TWLiveTrackingMap> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true); // Move back and forth
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Grid background to simulate map
            CustomPaint(
              size: Size.infinite,
              painter: _GridMapPainter(),
            ),
            
            // Route line
            Center(
              child: Container(
                width: 250,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.kekeGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Destination marker
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 40.0),
                child: Icon(Icons.location_on, color: AppColors.errorRed, size: 32),
              ),
            ),

            // Animated Vehicle marker
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Animate horizontally from left to right along the center line
                final double progress = _controller.value;
                return Align(
                  alignment: Alignment(
                    -0.7 + (progress * 1.2), // moving from -0.7 to 0.5 horizontally
                    -0.08, // slightly offset to center on the line
                  ),
                  child: child,
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.danfoYellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.paper, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danfoYellow.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: const Icon(Icons.directions_bus, color: AppColors.ink, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderStroke.withOpacity(0.2)
      ..strokeWidth = 1;

    const double step = 20;
    
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
