import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_service.dart';

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth state
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

/// Auth state class
class AuthState {
  final AuthStatus status;
  final AuthTokens? tokens;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.tokens,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthTokens? tokens,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      tokens: tokens ?? this.tokens,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthNotifier(service);
});

/// Simple boolean for checking auth status
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;

  AuthNotifier(this._service) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final tokens = await _service.getStoredTokens();
    if (tokens != null && !tokens.isExpired) {
      state = AuthState(
        status: AuthStatus.authenticated,
        tokens: tokens,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tokens = await _service.login(email: email, password: password);
      state = AuthState(
        status: AuthStatus.authenticated,
        tokens: tokens,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tokens = await _service.signUp(
        name: name,
        email: email,
        password: password,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        tokens: tokens,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _service.requestPasswordReset(email);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
