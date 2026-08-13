import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  User? get currentUser => _supabase.auth.currentUser;

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('full_name, phone_number, role, kyc_tier')
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Submit KYC data and upgrade user to Tier 1
  Future<Map<String, dynamic>> upgradeToTierOne({
    required String dob,
    required String address,
    required String bvn,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // TODO: Implement actual BVN verification API call here later
      // For now, simulate an API delay
      await Future.delayed(const Duration(seconds: 2));

      // Update the user's row in the database
      await _supabase.from('users').update({
        'dob': dob,
        'residential_address': address,
        'bvn': bvn,
        'kyc_tier': 'tier_1',
      }).eq('id', user.id);

      return {'success': true, 'message': 'Account upgraded successfully'};
    } on PostgrestException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone_number': phone,
      },
    );
  }

  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
