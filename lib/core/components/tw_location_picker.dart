import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/tw_error_handler.dart';

class TWLocationPicker extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String label;
  final ValueChanged<String>? onChanged;

  const TWLocationPicker({
    super.key,
    required this.controller,
    this.hintText = 'Enter your location',
    this.label = 'Location',
    this.onChanged,
  });

  @override
  ConsumerState<TWLocationPicker> createState() => _TWLocationPickerState();
}

class _TWLocationPickerState extends ConsumerState<TWLocationPicker> {
  bool _isLoading = false;

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final locationService = ref.read(locationServiceProvider);
      final address = await locationService.getCurrentAddress();
      
      if (address.isNotEmpty) {
        widget.controller.text = address;
        if (widget.onChanged != null) {
          widget.onChanged!(address);
        }
      }
    } catch (e) {
      if (mounted) {
        TWErrorHandler.handle(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.label.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              TextField(
                controller: widget.controller,
                style: GoogleFonts.outfit(color: AppColors.paper, fontSize: 16),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: AppColors.muted.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.muted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: widget.onChanged,
              ),
              Divider(height: 1, color: Colors.white.withOpacity(0.05)),
              InkWell(
                onTap: _isLoading ? null : _fetchCurrentLocation,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.kekeGreen),
                          ),
                        )
                      else
                        const Icon(Icons.my_location, color: AppColors.kekeGreen, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _isLoading ? 'Locating...' : 'Use Current Location',
                        style: GoogleFonts.outfit(
                          color: AppColors.kekeGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fade().slideY(begin: 0.1);
  }
}
