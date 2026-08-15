import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final scanRepositoryProvider = Provider((ref) {
  return ScanRepository(Supabase.instance.client);
});

class ScanRepository {
  final SupabaseClient _supabase;

  ScanRepository(this._supabase);

  /// Scans the QR payload and returns driver/route details and fare tiers
  Future<Map<String, dynamic>> scanDriverQr(String qrPayload) async {
    try {
      final response = await _supabase.rpc('fn_get_qr_ride_details', params: {
        'p_qr_payload': qrPayload,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Pays for the ride using the selected fare tier
  Future<Map<String, dynamic>> payForRide({
    required String passengerId,
    required String driverId,
    required String routeId,
    required String fareTierId,
  }) async {
    try {
      final response = await _supabase.rpc('fn_pay_for_ride', params: {
        'p_passenger_id': passengerId,
        'p_driver_id': driverId,
        'p_route_id': routeId,
        'p_fare_tier_id': fareTierId,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
