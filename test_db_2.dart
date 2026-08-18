import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://shoehdyteenfeofqmsko.supabase.co';
  final supabaseKey = 'sb_publishable_I9jMQGv0GXQL7j8GEDFsAg_JJTVJxzc';
  
  final client = SupabaseClient(supabaseUrl, supabaseKey);
  
  final userId = '9199d683-f1d3-43e7-9bee-cc9208fc54bd';
  final reference = 'TW-TOPUP-6f97c5c8-734d-40d0-8513-30627d4725c6';
  
  print('Invoking verify-topup edge function...');
  
  try {
    final response = await client.functions.invoke('verify-topup', body: {
      'user_id': userId,
      'reference': reference,
    });
    
    print('Status: ' + response.status.toString());
    print('Data: ' + response.data.toString());
  } on FunctionException catch (e) {
    print('FunctionException: ' + e.status.toString() + ' ' + (e.details ?? '') + ' ' + (e.reasonPhrase ?? ''));
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
