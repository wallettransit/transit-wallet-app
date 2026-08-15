import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

final groupRideRepositoryProvider = Provider<GroupRideRepository>((ref) {
  return GroupRideRepository(Supabase.instance.client);
});

class AvailableGroupRidesNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  int _page = 0;
  final int _limit = 20;
  bool hasMore = true;

  @override
  Future<List<Map<String, dynamic>>> build() async {
    _page = 0;
    hasMore = true;
    return await _fetchPage(_page);
  }

  Future<List<Map<String, dynamic>>> _fetchPage(int page) async {
    final repository = ref.read(groupRideRepositoryProvider);
    final newGroups = await repository.getAvailableGroupRides(limit: _limit, offset: page * _limit);
    if (newGroups.length < _limit) {
      hasMore = false;
    }
    return newGroups;
  }

  Future<void> loadMore() async {
    if (state.isLoading || !hasMore || state.hasError) return;
    
    final currentGroups = state.value ?? [];
    state = const AsyncValue.loading();
    
    try {
      _page++;
      final newGroups = await _fetchPage(_page);
      state = AsyncValue.data([...currentGroups, ...newGroups]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final availableGroupRidesProvider = AsyncNotifierProvider<AvailableGroupRidesNotifier, List<Map<String, dynamic>>>(() {
  return AvailableGroupRidesNotifier();
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
      final response = await _client.rpc('create_and_join_group_ride', params: {
        'p_creator_id': creatorId,
        'p_pickup_location': pickupLocation,
        'p_destination': destination,
        'p_capacity': capacity,
        'p_fare_per_person': farePerPerson,
      });
      
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
      await _client.rpc('join_group_ride', params: {
        'p_group_ride_id': groupRideId,
        'p_user_id': userId,
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
