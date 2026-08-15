import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(Supabase.instance.client);
});

final walletBalanceProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  
  if (user == null) return 0.0;
  
  return await repository.getWalletBalance(user.id);
});

class WalletRepository {
  final SupabaseClient _client;

  WalletRepository(this._client);

  Future<double> getWalletBalance(String userId) async {
    try {
      final response = await _client
          .from('wallets')
          .select('balance')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['balance'] != null) {
        // Balance is stored in Kobo, so divide by 100 to get Naira
        return double.parse(response['balance'].toString()) / 100.0;
      }
      return 0.0;
    } catch (e) {
      print('Error fetching wallet balance: $e');
      return 0.0;
    }
  }

  Future<Map<String, dynamic>> transferToFriend({
    required String senderId,
    required String recipientPhone,
    required double amount,
  }) async {
    try {
      // Clean phone number (remove spaces, etc.)
      final cleanedPhone = recipientPhone.replaceAll(RegExp(r'\s+'), '');
      
      final response = await _client.rpc('transfer_funds', params: {
        'p_sender_id': senderId,
        'p_recipient_phone': cleanedPhone,
        'p_amount': amount,
      });
      
      return {'success': true, 'message': 'Transfer successful'};
    } on PostgrestException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }
}
