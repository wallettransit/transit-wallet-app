import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  // Use user's env vars if possible, or just public anon key
  final url = 'https://shoehdyteenfeofqmsko.supabase.co/rest/v1/transactions?select=*';
  final anonKey = 'sb_publishable_I9jMQGv0GXQL7j8GEDFsAg_JJTVJxzc'; // from earlier investigation
  
  print('Querying Transactions...');
  final txRes = await http.get(Uri.parse(url), headers: {
    'apikey': anonKey,
    'Authorization': 'Bearer $anonKey',
  });
  print('Transactions: \${txRes.statusCode} \${txRes.body}');
  
  final walletsUrl = 'https://shoehdyteenfeofqmsko.supabase.co/rest/v1/wallets?select=*';
  print('\nQuerying Wallets...');
  final walletsRes = await http.get(Uri.parse(walletsUrl), headers: {
    'apikey': anonKey,
    'Authorization': 'Bearer $anonKey',
  });
  print('Wallets: \${walletsRes.statusCode} \${walletsRes.body}');
}
