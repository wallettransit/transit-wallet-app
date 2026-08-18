import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://shoehdyteenfeofqmsko.supabase.co';
  final supabaseKey = 'sb_publishable_I9jMQGv0GXQL7j8GEDFsAg_JJTVJxzc';
  
  final client = SupabaseClient(supabaseUrl, supabaseKey);
  
  final userId = '9199d683-f1d3-43e7-9bee-cc9208fc54bd';
  
  print('Fetching transactions...');
  try {
    final response = await client
        .from('transactions')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
        
    print('Raw response: ' + response.toString());
  } catch (e, stack) {
    print('Error: ' + e.toString());
  }
}
