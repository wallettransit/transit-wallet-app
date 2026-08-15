import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

final groupRideRepositoryProvider = Provider<GroupRideRepository>((ref) {
  return GroupRideRepository(Supabase.instance.client);
});

final availableGroupRidesStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final client = Supabase.instance.client;
  
  return client
      .from('group_rides')
      .stream(primaryKey: ['id'])
      .eq('status', 'open')
      .order('created_at', ascending: false)
      .map((data) => List<Map<String, dynamic>>.from(data));
});

final groupRideDetailsStreamProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, id) {
  return Supabase.instance.client
      .from('group_rides')
      .stream(primaryKey: ['id'])
      .eq('id', id)
      .map((data) => data.isNotEmpty ? data.first : null);
});

class GroupRideRepository {
  final SupabaseClient _client;

  GroupRideRepository(this._client);

  Future<List<Map<String, dynamic>>> getAvailableGroupRides({int limit = 20, int offset = 0}) async {
    final response = await _client
        .from('group_rides')
        .select('''
          *,
          users:creator_id ( full_name )
        ''')
        .eq('status', 'open')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
        
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createGroupRide({
    required String creatorId,
    required String pickupLocation,
    required String destination,
    required int capacity,
    required double farePerPerson,
  }) async {
    try {
      // 1. Insert the group ride (status defaults to 'open')
      final rideResponse = await _client.from('group_rides').insert({
        'creator_id': creatorId,
        'pickup_location': pickupLocation,
        'destination': destination,
        'capacity': capacity,
        'fare_per_person': farePerPerson,
      }).select('id').single();
      
      final String newRideId = rideResponse['id'] as String;

      // 2. Automatically join the creator to the ride members
      await _client.from('group_ride_members').insert({
        'group_ride_id': newRideId,
        'user_id': creatorId,
      });
      
      return {'success': true, 'data': rideResponse};
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
      await _client.from('group_ride_members').insert({
        'group_ride_id': groupRideId,
        'user_id': userId,
      });

      return {'success': true};
    } catch (e) {
      print('Error joining group ride: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> renameGroupRide(String groupId, String newName) async {
    try {
      await _client.from('group_rides').update({
        'group_name': newName,
      }).eq('id', groupId);
      return {'success': true};
    } catch (e) {
      print('Error renaming group ride: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteGroupRide(String groupId) async {
    try {
      await _client.from('group_rides').delete().eq('id', groupId);
      return {'success': true};
    } catch (e) {
      print('Error deleting group ride: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> acceptGroupRide({
    required String groupId,
    required String driverId,
  }) async {
    try {
      await _client.from('group_rides').update({
        'driver_id': driverId,
        'status': 'departed',
      }).eq('id', groupId);
      
      return {'success': true};
    } catch (e) {
      print('Error accepting group ride: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<Map<String, dynamic>>> getGroupRideMembers(String groupId) async {
    try {
      final response = await _client
          .from('group_ride_members')
          .select('''
            *,
            users:user_id ( full_name )
          ''')
          .eq('group_ride_id', groupId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching group ride members: $e');
      return [];
    }
  }
}

final groupRideMembersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, groupId) async {
  final repository = ref.read(groupRideRepositoryProvider);
  return repository.getGroupRideMembers(groupId);
});
