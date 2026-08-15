import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum TWButtonVariant { primary, secondary, destructive }

class TWButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final TWButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  const TWButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = TWButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<TWButton> createState() => _TWButtonState();
}

class _TWButtonState extends State<TWButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;

    switch (widget.variant) {
      case TWButtonVariant.primary:
        backgroundColor = AppColors.kekeGreen;
        foregroundColor = AppColors.ink;
        break;
      case TWButtonVariant.secondary:
        backgroundColor = AppColors.highlightBackground;
        foregroundColor = AppColors.paper;
        break;
      case TWButtonVariant.destructive:
        backgroundColor = AppColors.errorRed;
        foregroundColor = AppColors.paper;
        break;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (!widget.isLoading && widget.onPressed != null) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        if (!widget.isLoading && widget.onPressed != null) {
          widget.onPressed!();
        }
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: double.infinity,
          child: IgnorePointer(
            child: ElevatedButton(
              // We handle the tap in GestureDetector for the animation
              onPressed: (widget.isLoading || widget.onPressed == null) ? null : () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                disabledBackgroundColor: backgroundColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                // Remove the default splash to let the scale animation shine
                splashFactory: NoSplash.splashFactory,
              ),
              child: _buildContent(foregroundColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color foregroundColor) {
    if (widget.isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: foregroundColor,
          strokeWidth: 2,
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: AppTypography.heading3.copyWith(
              color: foregroundColor,
              fontSize: 16,
              height: 20.2 / 16,
            ),
          ),
          const SizedBox(width: 8),
          Icon(widget.icon, size: 20, color: foregroundColor),
        ],
      );
    }

    return Text(
      widget.label,
      style: AppTypography.heading3.copyWith(
        color: foregroundColor,
        fontSize: 16,
        height: 20.2 / 16,
      ),
    );
  }
}
