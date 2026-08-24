import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'location_repository.dart';

// ── Fare/Route models ─────────────────────────────────────────────────────────

class TripEstimate {
  final double distanceKm;
  final int durationMinutes;
  final int fareNaira;
  final String fareDisplay;
  final String distanceDisplay;
  final String durationDisplay;
  final String polyline; // encoded polyline
  final LatLng origin;
  final LatLng destination;
  final PlacePrediction destinationPrediction;

  const TripEstimate({
    required this.distanceKm,
    required this.durationMinutes,
    required this.fareNaira,
    required this.fareDisplay,
    required this.distanceDisplay,
    required this.durationDisplay,
    required this.polyline,
    required this.origin,
    required this.destination,
    required this.destinationPrediction,
  });

  factory TripEstimate.fromJson(
    Map<String, dynamic> json, {
    required LatLng origin,
    required LatLng destination,
    required PlacePrediction prediction,
  }) {
    return TripEstimate(
      distanceKm: (json['distance_km'] as num).toDouble(),
      durationMinutes: json['duration_minutes'] as int,
      fareNaira: json['fare_naira'] as int,
      fareDisplay: json['fare_display'] as String,
      distanceDisplay: json['distance_display'] as String,
      durationDisplay: json['duration_display'] as String,
      polyline: json['polyline'] as String,
      origin: origin,
      destination: destination,
      destinationPrediction: prediction,
    );
  }
}

// ── Booking State ─────────────────────────────────────────────────────────────

enum BookingStatus { idle, estimating, preview, booking, booked, error }

class BookingState {
  final BookingStatus status;
  final TripEstimate? estimate;
  final String? errorMessage;
  final bool rideBooked;

  const BookingState({
    this.status = BookingStatus.idle,
    this.estimate,
    this.errorMessage,
    this.rideBooked = false,
  });

  BookingState copyWith({
    BookingStatus? status,
    TripEstimate? estimate,
    String? errorMessage,
    bool? rideBooked,
  }) {
    return BookingState(
      status: status ?? this.status,
      estimate: estimate ?? this.estimate,
      errorMessage: errorMessage ?? this.errorMessage,
      rideBooked: rideBooked ?? this.rideBooked,
    );
  }
}

// ── Riverpod Notifier ─────────────────────────────────────────────────────────

final rideBookingProvider =
    StateNotifierProvider<RideBookingNotifier, BookingState>(
  (ref) => RideBookingNotifier(
    Supabase.instance.client,
    ref.watch(locationRepositoryProvider),
  ),
);

class RideBookingNotifier extends StateNotifier<BookingState> {
  final SupabaseClient _client;
  final LocationRepository _locationRepo;

  RideBookingNotifier(this._client, this._locationRepo)
      : super(const BookingState());

  void reset() => state = const BookingState();

  /// Fetches place details for the prediction, then calls estimate-fare.
  Future<void> estimateTrip({
    required PlacePrediction prediction,
    required LatLng userLocation,
  }) async {
    state = state.copyWith(status: BookingStatus.estimating);
    try {
      // 1. Resolve lat/lng from place_id
      final details = await _locationRepo.getPlaceDetails(prediction.placeId);
      final destination = LatLng(details.lat, details.lng);

      // 2. Call estimate-fare edge function
      final response = await _client.functions.invoke(
        'estimate-fare',
        method: HttpMethod.get,
        queryParameters: {
          'origin_lat': userLocation.latitude.toString(),
          'origin_lng': userLocation.longitude.toString(),
          'dest_lat': destination.latitude.toString(),
          'dest_lng': destination.longitude.toString(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('error')) {
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: data['error'] as String,
        );
        return;
      }

      final estimate = TripEstimate.fromJson(
        data,
        origin: userLocation,
        destination: destination,
        prediction: prediction,
      );

      state = state.copyWith(
        status: BookingStatus.preview,
        estimate: estimate,
      );
    } catch (e) {
      state = state.copyWith(
        status: BookingStatus.error,
        errorMessage: 'Failed to estimate trip: $e',
      );
    }
  }

  /// Simulate booking a ride (real dispatch logic would connect to driver matching).
  Future<void> bookRide(String userId) async {
    if (state.estimate == null) return;
    state = state.copyWith(status: BookingStatus.booking);

    try {
      await Future.delayed(const Duration(seconds: 2)); // simulate network call

      // Log ride request to Supabase
      await _client.from('ride_requests').insert({
        'user_id': userId,
        'origin_lat': state.estimate!.origin.latitude,
        'origin_lng': state.estimate!.origin.longitude,
        'dest_lat': state.estimate!.destination.latitude,
        'dest_lng': state.estimate!.destination.longitude,
        'destination_name': state.estimate!.destinationPrediction.mainText,
        'fare_naira': state.estimate!.fareNaira,
        'distance_km': state.estimate!.distanceKm,
        'duration_minutes': state.estimate!.durationMinutes,
        'status': 'searching',
      });

      state = state.copyWith(
        status: BookingStatus.booked,
        rideBooked: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: BookingStatus.error,
        errorMessage: 'Booking failed: $e',
      );
    }
  }
}
