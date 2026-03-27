import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api_client.dart';
import 'auth_model.dart';
import 'auth_service.dart';

class AuthState {
  final String? token;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.token,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    String? token,
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearToken = false,
    bool clearError = false,
  }) {
    return AuthState(
      token: clearToken ? null : (token ?? this.token),
      user: clearToken ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(isLoading: true)) {
    _loadToken();
  }

  final _service = AuthService();
  final _googleSignIn = GoogleSignIn();

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _setAuthHeader(token);
      try {
        final user = await _service.getMe();
        state = AuthState(token: token, user: user);
        return;
      } catch (_) {
        await _clearToken();
      }
    }
    state = const AuthState();
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authToken = await _service.loginWithPassword(
        identifier: identifier,
        password: password,
      );
      await _persistToken(authToken.accessToken);
      final user = await _service.getMe();
      state = AuthState(token: authToken.accessToken, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
    }
  }

  Future<void> register({
    String? email,
    String? phone,
    required String password,
    String? fullName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.register(
        email: email,
        phone: phone,
        password: password,
        fullName: fullName,
      );
      await login(identifier: email ?? phone!, password: password);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('Google sign-in failed: no ID token');

      final authToken = await _service.loginWithGoogle(idToken);
      await _persistToken(authToken.accessToken);
      final user = await _service.getMe();
      state = AuthState(token: authToken.accessToken, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut().catchError((_) => null);
    await _clearToken();
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(clearError: true);

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _persistToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _setAuthHeader(token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    ApiClient().client.options.headers.remove('Authorization');
  }

  void _setAuthHeader(String token) {
    ApiClient().client.options.headers['Authorization'] = 'Bearer $token';
  }

  String _extractError(dynamic e) {
    if (e is DioException) {
      final detail = e.response?.data?['detail'];
      if (detail != null) return detail.toString();
      return e.message ?? 'Network error';
    }
    return e.toString();
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
