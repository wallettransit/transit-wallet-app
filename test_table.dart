import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://shoehdyteenfeofqmsko.supabase.co';
  final supabaseKey = 'sb_publishable_I9jMQGv0GXQL7j8GEDFsAg_JJTVJxzc';
  
  final client = SupabaseClient(supabaseUrl, supabaseKey);
  
  try {
    // Just try to fetch from transactions to see if the table exists
    final response = await client.from('transactions').select('id').limit(1);
    print('Table exists, response: \$response');
  } catch (e) {
    print('Error: \$e');
  }
}
