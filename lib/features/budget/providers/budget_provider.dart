import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

class BudgetState {
  final Map<String, dynamic>? budget;
  final Map<String, dynamic>? progress;
  final bool isLoading;

  BudgetState({this.budget, this.progress, this.isLoading = false});
}

class BudgetNotifier extends AsyncNotifier<BudgetState> {
  @override
  Future<BudgetState> build() async {
    return _fetchBudget();
  }

  Future<BudgetState> _fetchBudget() async {
    final user = ref.read(supabaseProvider).auth.currentUser;
    if (user == null) return BudgetState();

    final repo = ref.read(budgetRepositoryProvider);
    final budget = await repo.getActiveBudget(user.id);
    
    Map<String, dynamic>? progress;
    if (budget != null) {
      progress = await repo.getBudgetProgress(budget['budget_id']);
    }

    return BudgetState(budget: budget, progress: progress);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchBudget());
  }

  Future<void> setBudget(double targetAmount) async {
    final user = ref.read(supabaseProvider).auth.currentUser;
    if (user == null) return;
    
    state = const AsyncValue.loading();
    
    try {
      final repo = ref.read(budgetRepositoryProvider);
      
      final now = DateTime.now();
      // Pro-rated mid-month creation
      // Start is today, end is end of the month
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      
      final daysInMonth = lastDayOfMonth.day;
      final daysRemaining = daysInMonth - now.day + 1;
      
      // Calculate pro-rated amount based on remaining days if created mid-month
      double proRatedAmount = (targetAmount / daysInMonth) * daysRemaining;
      
      await repo.createBudget(
        passengerId: user.id,
        amountKobo: (proRatedAmount * 100).toInt(),
        periodStart: now,
        periodEnd: lastDayOfMonth,
      );
      
      state = await AsyncValue.guard(() => _fetchBudget());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final budgetProvider = AsyncNotifierProvider<BudgetNotifier, BudgetState>(() {
  return BudgetNotifier();
});
