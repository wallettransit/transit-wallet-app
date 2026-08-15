import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetRepository {
  final SupabaseClient _supabase;

  BudgetRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Map<String, dynamic>?> getActiveBudget(String passengerId) async {
    try {
      final response = await _supabase
          .from('budgets')
          .select()
          .eq('passenger_id', passengerId)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error fetching active budget: $e');
      return null;
    }
  }

  Future<void> createBudget({
    required String passengerId,
    required int amountKobo,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    try {
      // Deactivate any existing active budget
      await _supabase
          .from('budgets')
          .update({'is_active': false})
          .eq('passenger_id', passengerId)
          .eq('is_active', true);

      // Create new budget
      await _supabase.from('budgets').insert({
        'passenger_id': passengerId,
        'amount_kobo': amountKobo,
        'period_start': periodStart.toIso8601String().split('T')[0],
        'period_end': periodEnd.toIso8601String().split('T')[0],
        'is_active': true,
      });
    } catch (e) {
      print('Error creating budget: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getBudgetProgress(String budgetId) async {
    try {
      final response = await _supabase.rpc('fn_budget_progress', params: {
        'p_budget_id': budgetId,
      });
      if (response != null && response is List && response.isNotEmpty) {
        return response.first as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching budget progress: $e');
      return null;
    }
  }
}
