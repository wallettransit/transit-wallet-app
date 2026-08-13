import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

final groupRideRepositoryProvider = Provider<GroupRideRepository>((ref) {
  return GroupRideRepository(Supabase.instance.client);
});

final availableGroupRidesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(groupRideRepositoryProvider);
  return await repository.getAvailableGroupRides();
});

class GroupRideRepository {
  final SupabaseClient _client;

  GroupRideRepository(this._client);

  Future<List<Map<String, dynamic>>> getAvailableGroupRides() async {
    try {
      final response = await _client
          .from('group_rides')
          .select('''
            *,
            users:creator_id ( full_name )
          ''')
          .eq('status', 'open')
          .order('created_at', ascending: false);
          
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching group rides: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createGroupRide({
    required String creatorId,
    required String pickupLocation,
    required String destination,
    required int capacity,
    required double farePerPerson,
  }) async {
    try {
      final response = await _client.from('group_rides').insert({
        'creator_id': creatorId,
        'pickup_location': pickupLocation,
        'destination': destination,
        'capacity': capacity,
        'fare_per_person': farePerPerson,
      }).select().single();
      
      // Automatically add creator as a member
      await joinGroupRide(
        groupRideId: response['id'],
        userId: creatorId,
      );
      
      return {'success': true, 'data': response};
    } catch (e) {
      print('Error creating group ride: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> joinGroupRide({
    required String groupRideId,
    required String userId,
  }) async {
    try {
      // 1. Add to members table
      await _client.from('group_ride_members').insert({
        'group_ride_id': groupRideId,
        'user_id': userId,
      });

      // 2. Increment joined_count (optimistic/simple approach, realistically should use RPC to avoid race conditions)
      // For now, we fetch the current count and add 1
      final ride = await _client.from('group_rides').select('joined_count, capacity').eq('id', groupRideId).single();
      final currentCount = (ride['joined_count'] as num).toInt();
      final capacity = (ride['capacity'] as num).toInt();
      
      final newCount = currentCount + 1;
      final newStatus = newCount >= capacity ? 'full' : 'open';

      await _client.from('group_rides').update({
        'joined_count': newCount,
        'status': newStatus,
      }).eq('id', groupRideId);

      return {'success': true};
    } catch (e) {
      print('Error joining group ride: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
