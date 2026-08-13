import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_button.dart';

class DriverInTripScreen extends StatefulWidget {
  final int initialPassengerCount;

  const DriverInTripScreen({
    super.key,
    required this.initialPassengerCount,
  });

  @override
  State<DriverInTripScreen> createState() => _DriverInTripScreenState();
}

class _DriverInTripScreenState extends State<DriverInTripScreen> {
  late List<bool> passengerDroppedOff;
  int get activePassengers => passengerDroppedOff.where((d) => !d).length;

  @override
  void initState() {
    super.initState();
    passengerDroppedOff = List.generate(widget.initialPassengerCount, (_) => false);
  }

  void _dropOffPassenger(int index) {
    setState(() {
      passengerDroppedOff[index] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Passenger ${index + 1} dropped off.'),
        backgroundColor: AppColors.kekeGreen,
      ),
    );
  }

  void _completeTrip() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip Completed!'),
        backgroundColor: AppColors.kekeGreen,
      ),
    );
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          // 1. Map Background Area (Top half)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Stack(
              children: [
                // Map Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/dark_map_lagos.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient overlay to fade into the bottom sheet
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.ink.withOpacity(0.1),
                          AppColors.ink.withOpacity(0.4),
                          AppColors.ink,
                        ],
                      ),
                    ),
                  ),
                ),
                // Back button overlay
                Positioned(
                  top: 50,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: AppColors.ink.withOpacity(0.7),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.paper),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Draggable Bottom Sheet for Trip Details
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 20),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.borderStroke,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    
                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Current Objective
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.borderStroke),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.danfoYellow.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.navigation_rounded, color: AppColors.danfoYellow),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Next Stop',
                                          style: AppTypography.label.copyWith(color: AppColors.muted),
                                        ),
                                        Text(
                                          'Lekki Phase 1 Gate',
                                          style: AppTypography.heading3.copyWith(color: AppColors.paper),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '2 min',
                                    style: AppTypography.bodyLarge.copyWith(color: AppColors.kekeGreen, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Passengers ($activePassengers/${widget.initialPassengerCount})',
                                  style: AppTypography.heading3.copyWith(color: AppColors.paper),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Passenger Roster
                            ...List.generate(widget.initialPassengerCount, (index) {
                              final isDroppedOff = passengerDroppedOff[index];
                              return AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: isDroppedOff ? 0.5 : 1.0,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.highlightBackground,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.borderStroke),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.paper.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.person, color: AppColors.paper),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Passenger ${index + 1}',
                                              style: AppTypography.bodyLarge.copyWith(color: AppColors.paper),
                                            ),
                                            if (isDroppedOff)
                                              Text(
                                                'Dropped Off',
                                                style: AppTypography.label.copyWith(color: AppColors.muted),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (!isDroppedOff)
                                        ElevatedButton(
                                          onPressed: () => _dropOffPassenger(index),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.cardBackground,
                                            foregroundColor: AppColors.paper,
                                            side: const BorderSide(color: AppColors.borderStroke),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: const Text('Drop Off'),
                                        )
                                      else
                                        const Icon(Icons.check_circle, color: AppColors.kekeGreen),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            
                            const SizedBox(height: 32),
                            
                            TWButton(
                              label: activePassengers == 0 ? 'Complete Trip' : 'End Trip Early',
                              onPressed: _completeTrip,
                              variant: activePassengers == 0 ? TWButtonVariant.primary : TWButtonVariant.secondary,
                            ),
                            
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  // SOS Action placeholder
                                },
                                icon: const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
                                label: Text(
                                  'Emergency / SOS',
                                  style: AppTypography.bodyMedium.copyWith(color: AppColors.errorRed),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
