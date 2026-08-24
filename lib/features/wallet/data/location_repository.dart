import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String description;

  const PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.description,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] as String,
      mainText: json['main_text'] as String? ?? json['description'] as String,
      secondaryText: json['secondary_text'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class PlaceDetails {
  final String name;
  final String formattedAddress;
  final double lat;
  final double lng;

  const PlaceDetails({
    required this.name,
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      name: json['name'] as String,
      formattedAddress: json['formatted_address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

// ── Repository ────────────────────────────────────────────────────────────────

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository(Supabase.instance.client);
});

class LocationRepository {
  final SupabaseClient _client;
  final String _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();

  LocationRepository(this._client);

  /// Fetch autocomplete predictions for a search query.
  Future<List<PlacePrediction>> autocomplete(String input) async {
    try {
      final response = await _client.functions.invoke(
        'places-autocomplete',
        method: HttpMethod.get,
        queryParameters: {
          'action': 'autocomplete',
          'input': input,
          'sessiontoken': _sessionToken,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final rawList = data['predictions'] as List<dynamic>? ?? [];
      return rawList
          .map((e) => PlacePrediction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch autocomplete: $e');
    }
  }

  /// Fetch full place details (lat/lng) by place_id.
  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    try {
      final response = await _client.functions.invoke(
        'places-autocomplete',
        method: HttpMethod.get,
        queryParameters: {
          'action': 'details',
          'place_id': placeId,
          'sessiontoken': _sessionToken,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return PlaceDetails.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch place details: $e');
    }
  }
}
