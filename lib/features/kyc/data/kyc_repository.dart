import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'kyc_service.dart';

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  return KycRepository(
    Supabase.instance.client,
    ref.read(kycServiceProvider),
  );
});

class KycRepository {
  final SupabaseClient _supabase;
  final MockKYCService _kycService;

  KycRepository(this._supabase, this._kycService);

  /// Submits the BVN for verification and upgrades the user to tier_2 upon success.
  Future<Map<String, dynamic>> verifyAndUpgradeTier({
    required String userId,
    required String bvn,
  }) async {
    try {
      // 1. Hit the KYC Service to verify BVN
      final kycResult = await _kycService.verifyBVN(bvn);
      
      if (kycResult['status'] != true) {
        return {'success': false, 'message': kycResult['message']};
      }

      // 2. If valid, update user tier in Supabase
      await _supabase.from('users').update({
        'bvn': bvn,
        'kyc_tier': 'tier_2',
      }).eq('id', userId);

      return {'success': true, 'message': 'Account verified and upgraded successfully!'};
    } on PostgrestException catch (e) {
      return {'success': false, 'message': 'Database error: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
}
