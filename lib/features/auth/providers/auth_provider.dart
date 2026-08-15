import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return AuthRepository(supabase);
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository, ref);
});

final isAppLockedProvider = StateProvider<bool>((ref) => false);

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  final user = authRepo.currentUser;
  if (user == null) return null;
  return authRepo.getUserProfile(user.id);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository, Ref ref) : super(const AsyncValue.data(null));

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      state = const AsyncValue.data(null);
    } on AuthException catch (e, st) {
      if (e.message.toLowerCase().contains('already registered')) {
        state = AsyncValue.error("This email is already registered. Please log in instead.", st);
      } else {
        // Try to parse JSON error message if it exists
        String cleanMessage = e.message;
        if (cleanMessage.startsWith('{') && cleanMessage.contains('"message"')) {
           final regex = RegExp(r'"message"\s*:\s*"([^"]+)"');
           final match = regex.firstMatch(cleanMessage);
           if (match != null) {
             cleanMessage = match.group(1) ?? cleanMessage;
           }
        }
        state = AsyncValue.error(cleanMessage, st);
      }
    } catch (e, st) {
      state = AsyncValue.error("An unexpected error occurred. Please try again.", st);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.resetPassword(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
