import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ProfileRepository(supabase);
});

final passengerStatsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final profileRepo = ref.watch(profileRepositoryProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  
  final user = authRepo.currentUser;
  if (user == null) return null;
  
  return profileRepo.getPassengerStats(user.id);
});
