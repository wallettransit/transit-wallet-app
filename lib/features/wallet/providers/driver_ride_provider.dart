import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum DriverRideStatus {
  idle,
  reviewingRequest,
  enRouteToPickup,
  inProgress,
  completed
}

class DriverRideState {
  final DriverRideStatus status;
  final Map<String, dynamic>? currentRequest;

  DriverRideState({
    this.status = DriverRideStatus.idle,
    this.currentRequest,
  });

  DriverRideState copyWith({
    DriverRideStatus? status,
    Map<String, dynamic>? currentRequest,
  }) {
    return DriverRideState(
      status: status ?? this.status,
      currentRequest: currentRequest ?? this.currentRequest,
    );
  }
}

class DriverRideNotifier extends StateNotifier<DriverRideState> {
  final SupabaseClient _client;
  RealtimeChannel? _subscription;

  DriverRideNotifier(this._client) : super(DriverRideState());

  void startListeningForRequests(String vehicleType) {
    if (_subscription != null) return;

    _subscription = _client.channel('public:ride_requests').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'ride_requests',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'status',
        value: 'searching',
      ),
      callback: (payload) {
        final request = payload.newRecord;
        if (request['ride_type'] == vehicleType || request['ride_type'] == null) {
          // New request matches driver's vehicle type
          if (state.status == DriverRideStatus.idle) {
            state = state.copyWith(
              status: DriverRideStatus.reviewingRequest,
              currentRequest: request,
            );
          }
        }
      },
    ).subscribe();
  }

  void stopListening() {
    _subscription?.unsubscribe();
    _subscription = null;
    state = DriverRideState(); // reset
  }

  Future<void> acceptRide() async {
    if (state.currentRequest == null) return;
    
    final requestId = state.currentRequest!['id'];
    final driverId = _client.auth.currentUser!.id;

    try {
      // Claim the ride in Supabase
      await _client
          .from('ride_requests')
          .update({
            'status': 'driver_found',
            'driver_id': driverId,
          })
          .eq('id', requestId)
          .eq('status', 'searching'); // Optimistic concurrency

      state = state.copyWith(status: DriverRideStatus.enRouteToPickup);
    } catch (e) {
      // Failed to claim (e.g. another driver got it)
      declineRide();
    }
  }

  void declineRide() {
    state = state.copyWith(
      status: DriverRideStatus.idle,
      currentRequest: null,
    );
  }

  Future<void> startTrip() async {
    if (state.currentRequest == null) return;
    
    final requestId = state.currentRequest!['id'];

    try {
      await _client
          .from('ride_requests')
          .update({'status': 'in_progress'})
          .eq('id', requestId);

      state = state.copyWith(status: DriverRideStatus.inProgress);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> completeTrip() async {
    if (state.currentRequest == null) return;
    
    final requestId = state.currentRequest!['id'];

    try {
      await _client
          .from('ride_requests')
          .update({'status': 'completed'})
          .eq('id', requestId);

      state = state.copyWith(status: DriverRideStatus.completed);
      
      // Delay slightly, then return to idle to accept new rides
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(
        status: DriverRideStatus.idle,
        currentRequest: null,
      );
    } catch (e) {
      // Handle error
    }
  }
}

final driverRideProvider =
    StateNotifierProvider<DriverRideNotifier, DriverRideState>((ref) {
  return DriverRideNotifier(Supabase.instance.client);
});
