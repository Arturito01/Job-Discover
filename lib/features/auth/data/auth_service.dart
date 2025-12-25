import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Auth tokens
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

/// Authentication service (mock implementation)
class AuthService {
  static const _tokenKey = 'auth_tokens';
  final _storage = const FlutterSecureStorage();

  /// Mock login - in real app, this would call API
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock validation
    if (email.isEmpty || password.isEmpty) {
      throw AuthException('Email and password are required');
    }

    if (!email.contains('@')) {
      throw AuthException('Invalid email format');
    }

    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    // Mock successful login
    final tokens = AuthTokens(
      accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );

    await _saveTokens(tokens);
    return tokens;
  }

  /// Mock signup
  Future<AuthTokens> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (name.isEmpty) {
      throw AuthException('Name is required');
    }

    if (email.isEmpty || !email.contains('@')) {
      throw AuthException('Valid email is required');
    }

    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    // Mock email already exists check
    if (email == 'test@example.com') {
      throw AuthException('Email already exists');
    }

    final tokens = AuthTokens(
      accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );

    await _saveTokens(tokens);
    return tokens;
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isEmpty || !email.contains('@')) {
      throw AuthException('Valid email is required');
    }

    // Mock success - in real app, this would send an email
  }

  /// Logout
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Get stored tokens
  Future<AuthTokens?> getStoredTokens() async {
    final data = await _storage.read(key: _tokenKey);
    if (data == null) return null;

    try {
      // Simple parsing - in real app, use proper JSON
      final parts = data.split('|');
      return AuthTokens(
        accessToken: parts[0],
        refreshToken: parts[1],
        expiresAt: DateTime.parse(parts[2]),
      );
    } catch (_) {
      await _storage.delete(key: _tokenKey);
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final tokens = await getStoredTokens();
    return tokens != null && !tokens.isExpired;
  }

  Future<void> _saveTokens(AuthTokens tokens) async {
    final data = '${tokens.accessToken}|${tokens.refreshToken}|${tokens.expiresAt.toIso8601String()}';
    await _storage.write(key: _tokenKey, value: data);
  }
}

/// Auth exception
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}
