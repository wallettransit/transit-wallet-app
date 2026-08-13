import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return DriverRepository(Supabase.instance.client);
});

class DriverRepository {
  final SupabaseClient _client;

  DriverRepository(this._client);

  Future<Map<String, dynamic>?> getDriverDetails(String driverId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', driverId)
          .eq('role', 'driver')
          .maybeSingle();
          
      return response;
    } catch (e) {
      print('Error fetching driver details: $e');
      return null;
    }
  }
}
