import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import 'auth_model.dart';

class AuthService {
  final Dio _dio = ApiClient().client;

  Future<AuthToken> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    final resp = await _dio.post('/auth/login', data: {
      'identifier': identifier,
      'password': password,
    });
    return AuthToken.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<UserModel> register({
    String? email,
    String? phone,
    required String password,
    String? fullName,
  }) async {
    final resp = await _dio.post('/auth/register', data: {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'password': password,
      if (fullName != null) 'full_name': fullName,
    });
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<AuthToken> loginWithGoogle(String idToken) async {
    final resp = await _dio.post('/auth/google', data: {'token': idToken});
    return AuthToken.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<UserModel> getMe() async {
    final resp = await _dio.get('/auth/me');
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
