import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return RideRepository(Supabase.instance.client);
});

final recentRidesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(rideRepositoryProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  
  if (user == null) return [];
  
  return await repository.getRecentRides(user.id);
});

class RideRepository {
  final SupabaseClient _client;

  RideRepository(this._client);

  Future<List<Map<String, dynamic>>> getRecentRides(String userId) async {
    try {
      final response = await _client
          .from('rides')
          .select()
          .eq('passenger_id', userId)
          .order('created_at', ascending: false)
          .limit(5);
          
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching recent rides: $e');
      return [];
    }
  }
}
