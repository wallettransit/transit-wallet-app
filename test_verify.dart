import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final userId = '9199d683-f1d3-43e7-9bee-cc9208fc54bd';
  final url = 'https://shoehdyteenfeofqmsko.supabase.co/functions/v1/verify-topup';
  
  final paystackKey = 'sk_test_2fdf8489511016547d2097da79caf611a18cf575';
  
  try {
    final psRes = await http.get(
      Uri.parse('https://api.paystack.co/transaction'),
      headers: {'Authorization': 'Bearer $paystackKey'}
    );
    
    if (psRes.statusCode == 200) {
      final data = jsonDecode(psRes.body);
      final txs = data['data'] as List;
      if (txs.isNotEmpty) {
        final lastTx = txs.first;
        final ref = lastTx['reference'];
        print('Latest Reference: $ref');
        
        print('Calling verify-topup edge function...');
        final verifyRes = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': userId,
            'reference': ref
          })
        );
        print('Verify Response Status: \${verifyRes.statusCode}');
        print('Verify Response Body: \${verifyRes.body}');
      } else {
        print('No transactions in Paystack');
      }
    } else {
      print('Paystack error: \${psRes.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
