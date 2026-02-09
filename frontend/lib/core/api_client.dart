import 'package:dio/dio.dart';

import 'constants.dart';

class ApiClient {
  ApiClient._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.apiBaseUrl,
            headers: {'Content-Type': 'application/json'},
          ),
        );

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  final Dio _dio;

  Dio get client => _dio;
}

