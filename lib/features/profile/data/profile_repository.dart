import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  Future<Map<String, dynamic>?> getPassengerStats(String userId) async {
    try {
      final response = await _supabase.rpc('fn_get_passenger_stats', params: {'p_user_id': userId});
      if (response is List) {
        return response.isNotEmpty ? response.first as Map<String, dynamic> : null;
      }
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching passenger stats: $e');
      return null;
    }
  }
}
