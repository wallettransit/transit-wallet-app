import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? subMessage;

  const EmptyState({super.key, required this.message, this.subMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      margin: const EdgeInsets.only(top: 32),
      child: Opacity(
        opacity: 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.do_not_disturb_alt, // Closest equivalent to FileX
              size: 48,
              color: AppTheme.ink,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.ink,
              ),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                subMessage!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppTheme.muted,
                ),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
