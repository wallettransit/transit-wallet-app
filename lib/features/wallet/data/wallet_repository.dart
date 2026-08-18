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

final transactionHistoryProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  // Cache the transactions so they don't reload every time the user switches tabs
  ref.keepAlive();

  final repository = ref.watch(walletRepositoryProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  
  if (user == null) return [];
  
  return await repository.getTransactionHistory(user.id);
});

class WalletRepository {
  final SupabaseClient _client;

  WalletRepository(this._client);

  Future<double> getWalletBalance(String userId) async {
    try {
      final response = await _client
          .from('wallets')
          .select('balance_kobo')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['balance_kobo'] != null) {
        // Balance is stored in Kobo, so divide by 100 to get Naira
        return double.parse(response['balance_kobo'].toString()) / 100.0;
      }
      return 0.0;
    } catch (e) {
      print('Error fetching wallet balance: $e');
      return 0.0;
    }
  }

  Stream<double> watchWalletBalance(String userId) {
    return _client
        .from('wallets')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((events) {
          if (events.isNotEmpty && events.first['balance_kobo'] != null) {
            return double.parse(events.first['balance_kobo'].toString()) / 100.0;
          }
          return 0.0;
        });
  }

  Future<Map<String, dynamic>> transferToFriend({
    required String senderId,
    required String recipientPhone,
    required double amount,
  }) async {
    try {
      // Clean phone number (remove spaces, etc.)
      String cleanedPhone = recipientPhone.replaceAll(RegExp(r'\s+'), '');
      
      // Standardize phone number format (assuming Nigerian numbers)
      if (cleanedPhone.startsWith('0')) {
        cleanedPhone = '+234${cleanedPhone.substring(1)}';
      } else if (!cleanedPhone.startsWith('+')) {
        cleanedPhone = '+$cleanedPhone';
      }

      final response = await _client.rpc('fn_transfer_funds', params: {
        'p_sender_id': senderId,
        'p_recipient_phone': cleanedPhone,
        'p_amount_kobo': (amount * 100).toInt(),
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
    String? email,
  }) async {
    try {
      final response = await _client.functions.invoke('initiate-topup', body: {
        'user_id': userId,
        'amount_kobo': (amount * 100).toInt(),
        'email': email ?? '$userId@transitwallet.internal.com',
      });
      
      final data = response.data;
      if (data['success'] == true) {
        return {'success': true, 'checkout_url': data['checkout_url'], 'reference': data['reference']};
      }
      return {'success': false, 'message': data['error'] ?? 'Funding failed'};
    } on FunctionException catch (e) {
      String errorMessage = 'Funding failed';
      if (e.details != null && e.details is Map) {
         errorMessage = (e.details as Map)['error']?.toString() ?? errorMessage;
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      if (e.toString().contains('Failed to fetch') || e.toString().contains('ClientException')) {
        return {'success': false, 'message': 'Network error. Please check your connection or disable ad-blockers and try again.'};
      }
      return {'success': false, 'message': 'Funding failed: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyTopup(String userId, String reference) async {
    try {
      final response = await _client.functions.invoke('verify-topup', body: {
        'user_id': userId,
        'reference': reference,
      });
      
      final data = response.data;
      if (data['success'] == true) {
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'message': data['message'] ?? 'Verification failed'};
    } on FunctionException catch (e) {
      String errorMessage = 'Verification failed';
      if (e.details != null && e.details is Map) {
        final details = e.details as Map;
        if (details['message'] != null) {
          errorMessage = details['message'].toString();
        }
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Verification failed: $e'};
    }
  }

  Future<Map<String, dynamic>> requestDriverPayout({
    required String userId,
    required double amount,
    required String accountNumber,
    required String bankCode,
    required String accountName,
  }) async {
    try {
      final response = await _client.functions.invoke('request-payout', body: {
        'user_id': userId,
        'amount_kobo': (amount * 100).toInt(),
        'account_number': accountNumber,
        'bank_code': bankCode,
        'account_name': accountName,
      });
      
      final data = response.data;
      if (data['success'] == true) {
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'message': data['error'] ?? 'Payout failed'};
    } catch (e) {
      return {'success': false, 'message': 'Payout failed: $e'};
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
          .from('transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      
      if (response == null) return [];
      
      return (response as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }
}
