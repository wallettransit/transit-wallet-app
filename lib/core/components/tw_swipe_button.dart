import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TWSwipeButton extends StatefulWidget {
  final String label;
  final VoidCallback onSwipe;
  final Color backgroundColor;
  final Color thumbColor;

  const TWSwipeButton({
    super.key,
    required this.label,
    required this.onSwipe,
    this.backgroundColor = AppColors.ink,
    this.thumbColor = AppColors.kekeGreen,
  });

  @override
  State<TWSwipeButton> createState() => _TWSwipeButtonState();
}

class _TWSwipeButtonState extends State<TWSwipeButton> {
  double _dragPosition = 0.0;
  bool _isCompleted = false;
  final double _thumbSize = 56.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxDragPosition = maxWidth - _thumbSize - 8; // 4px padding on each side

        return Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.borderStroke, width: 1.5),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background Text
              Center(
                child: Text(
                  _isCompleted ? 'Accepted!' : widget.label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: _isCompleted ? widget.thumbColor : AppColors.paper.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate(target: _isCompleted ? 1 : 0).fade().scale(),
              ),
              
              // Pulsing Background (Urgency effect)
              if (!_isCompleted)
                Center(
                  child: Container(
                    width: maxWidth * 0.6,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.thumbColor.withOpacity(0.0),
                          widget.thumbColor.withOpacity(0.5),
                          widget.thumbColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ).animate(onPlay: (c) => c.repeat()).moveX(
                    begin: -maxWidth * 0.5,
                    end: maxWidth * 0.5,
                    duration: 1500.ms,
                  ),
                ),

              // Swipable Thumb
              AnimatedPositioned(
                duration: _dragPosition == 0 ? const Duration(milliseconds: 300) : Duration.zero,
                curve: Curves.easeOutBack,
                left: _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isCompleted) return;
                    setState(() {
                      _dragPosition += details.primaryDelta!;
                      if (_dragPosition < 0) _dragPosition = 0;
                      if (_dragPosition > maxDragPosition) _dragPosition = maxDragPosition;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isCompleted) return;
                    if (_dragPosition > maxDragPosition * 0.8) {
                      setState(() {
                        _dragPosition = maxDragPosition;
                        _isCompleted = true;
                      });
                      widget.onSwipe();
                    } else {
                      setState(() {
                        _dragPosition = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      color: widget.thumbColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.thumbColor.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_forward, color: AppColors.ink),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
