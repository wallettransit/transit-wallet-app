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

  Future<Map<String, dynamic>> fundWallet({
    required String userId,
    required double amount,
  }) async {
    try {
      final response = await _client.rpc('fund_wallet_mock', params: {
        'p_user_id': userId,
        'p_amount': amount,
      });
      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'message': 'Funding failed: $e'};
    }
  }

  Future<Map<String, dynamic>> processRidePayment({
    required String passengerId,
    required String driverId,
    required double amount,
    required String groupId,
  }) async {
    try {
      final response = await _client.rpc('process_ride_payment', params: {
        'p_passenger_id': passengerId,
        'p_driver_id': driverId,
        'p_amount': amount,
        'p_group_id': groupId,
      });
      
      if (response != null && response['success'] == true) {
        return {'success': true, 'message': response['message']};
      } else {
        return {'success': false, 'message': response != null ? response['message'] : 'Unknown error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Payment failed: $e'};
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory(String userId) async {
    try {
      final response = await _client
          .from('wallet_transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(20);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }
}
