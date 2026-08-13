import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'components/tw_driver_matching_card.dart';
import 'driver_active_group_screen.dart';

class DriverGroupRequestsScreen extends StatefulWidget {
  const DriverGroupRequestsScreen({super.key});

  @override
  State<DriverGroupRequestsScreen> createState() => _DriverGroupRequestsScreenState();
}

class _DriverGroupRequestsScreenState extends State<DriverGroupRequestsScreen> {
  // Mock list of incoming group rides
  final List<Map<String, dynamic>> _incomingRequests = [
    {
      'id': 'REQ-101',
      'pickup': 'Oshodi Bus Stop, Agege Motor Road',
      'destination': 'Lekki Phase 1 Gate',
      'passengerCount': 4,
      'distance': '18.2 km',
      'time': '45 mins',
      'payout': 12500.0,
    },
    {
      'id': 'REQ-102',
      'pickup': 'Yaba Yabatech Gate',
      'destination': 'Ikeja City Mall',
      'passengerCount': 3,
      'distance': '12.5 km',
      'time': '30 mins',
      'payout': 8200.0,
    },
  ];

  void _removeRequest(String id) {
    setState(() {
      _incomingRequests.removeWhere((req) => req['id'] == id);
    });
  }

  void _acceptRequest(Map<String, dynamic> request) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DriverActiveGroupScreen(
          pickup: request['pickup'],
          destination: request['destination'],
          payout: request['payout'],
          passengerCount: request['passengerCount'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Group Requests',
          style: AppTypography.heading3.copyWith(color: AppColors.paper),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _incomingRequests.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(24.0),
                itemCount: _incomingRequests.length,
                itemBuilder: (context, index) {
                  final request = _incomingRequests[index];
                  return TWDriverMatchingCard(
                    pickup: request['pickup'],
                    destination: request['destination'],
                    passengerCount: request['passengerCount'],
                    distance: request['distance'],
                    time: request['time'],
                    guaranteedPayout: request['payout'],
                    onAccept: () => _acceptRequest(request),
                    onDecline: () => _removeRequest(request['id']),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.kekeGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.radar, size: 40, color: AppColors.kekeGreen),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            duration: 2.seconds,
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.1, 1.1),
            curve: Curves.easeInOutSine,
          ),
          const SizedBox(height: 24),
          Text(
            'Looking for Groups',
            style: AppTypography.heading2.copyWith(color: AppColors.paper),
          ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            'We are scanning your area for compatible\npassenger groups...',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
