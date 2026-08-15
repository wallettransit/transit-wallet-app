import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return DriverRepository(Supabase.instance.client);
});

class DriverRepository {
  final SupabaseClient _client;

  DriverRepository(this._client);

  Future<Map<String, dynamic>> submitKYC({
    required String userId,
    required String bvnOrNin,
  }) async {
    try {
      await _client
          .from('users')
          .update({
            'bvn_or_nin': bvnOrNin,
            'role': 'driver',
          })
          .eq('id', userId);
          
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': 'Failed to submit KYC: $e'};
    }
  }

  Future<Map<String, dynamic>> registerVehicle({
    required String driverId,
    required String plateNumber,
    required String vehicleType,
  }) async {
    try {
      final response = await _client
          .from('vehicles')
          .insert({
            'driver_id': driverId,
            'plate_number': plateNumber,
            'vehicle_type': vehicleType.toLowerCase(),
          })
          .select('id')
          .single();
          
      return {'success': true, 'vehicle_id': response['id']};
    } catch (e) {
      return {'success': false, 'message': 'Failed to register vehicle: $e'};
    }
  }

  Future<Map<String, dynamic>> setupRoute({
    required String vehicleId,
    required String origin,
    required String destination,
    required List<Map<String, dynamic>> fareTiers,
  }) async {
    try {
      // 1. Create Route
      final routeResponse = await _client
          .from('routes')
          .insert({
            'vehicle_id': vehicleId,
            'origin': origin,
            'destination': destination,
            'status': 'active',
          })
          .select('id')
          .single();
          
      final String routeId = routeResponse['id'];

      // 2. Create Fare Tiers (convert Naira to Kobo before inserting)
      final List<Map<String, dynamic>> tiersToInsert = fareTiers.map((tier) {
        return {
          'route_id': routeId,
          'stop_name': tier['stop_name'],
          'stop_order': tier['stop_order'],
          'fare_kobo': ((tier['fare'] as double) * 100).toInt(),
        };
      }).toList();

      await _client.from('fare_tiers').insert(tiersToInsert);
      
      // 3. Generate Driver QR Code
      final String qrPayload = 'TW-DRIVER-${DateTime.now().millisecondsSinceEpoch}';
      
      final codeResponse = await _client
          .from('driver_codes')
          .insert({
            'vehicle_id': vehicleId,
            'route_id': routeId,
            'qr_payload': qrPayload,
          })
          .select('id, qr_payload')
          .single();

      return {
        'success': true, 
        'route_id': routeId,
        'code_id': codeResponse['id'],
        'qr_payload': codeResponse['qr_payload'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to setup route: $e'};
    }
  }

  // Used by the dashboard
  Future<Map<String, dynamic>?> getActiveDriverProfile(String driverId) async {
    try {
      final vehicle = await _client
          .from('vehicles')
          .select('id, plate_number, vehicle_type, routes(id, origin, destination, driver_codes(qr_payload))')
          .eq('driver_id', driverId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
          
      return vehicle;
    } catch (e) {
      print('Error fetching driver profile: $e');
      return null;
    }
  }
}
