import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

// ── Service Provider ──────────────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Auth Stream (live auth state from Supabase) ───────────────────────────────
final authStreamProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// ── Current Supabase User ─────────────────────────────────────────────────────
final currentUserProvider = Provider<User?>((ref) {
  final asyncState = ref.watch(authStreamProvider);
  return asyncState.maybeWhen(
    data: (state) => state.session?.user,
    orElse: () => Supabase.instance.client.auth.currentUser,
  );
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// ── Auth Actions (sign in, sign up, sign out) ─────────────────────────────────
class AuthNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  AuthService get _authService => ref.read(authServiceProvider);

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.signInWithPassword(email: email, password: password),
    );
  }

  Future<void> signInAnonymously() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.signInAnonymously(),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.signUp(email: email, password: password, username: username),
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.signOut());
  }

  void reset() => state = const AsyncValue.data(null);
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<void>>(AuthNotifier.new);
