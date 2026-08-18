import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://shoehdyteenfeofqmsko.supabase.co';
  final supabaseKey = 'sb_publishable_I9jMQGv0GXQL7j8GEDFsAg_JJTVJxzc';
  
  final client = SupabaseClient(supabaseUrl, supabaseKey);
  
  print('Running query to check enums...');
  try {
    // If we can't query pg_enum (due to permissions), we can just try to insert 'deposit' and see if it works
    final response = await client.rpc('fn_confirm_topup', params: {
      'p_user_id': '9199d683-f1d3-43e7-9bee-cc9208fc54bd',
      'p_amount_kobo': 200000, 
      'p_external_ref': 'TW-TOPUP-6f97c5c8-734d-40d0-8513-30627d4725c6-test2',
    });
    
    print('Raw response: ' + response.toString());
  } on PostgrestException catch (e) {
    print('PostgrestException: ' + e.message);
  } catch (e, stack) {
    print('Error: ' + e.toString());
  }
}
