// lib/core/api_client/api_client.dart
import 'package:dio/dio.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Debug logging
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  // Test connection
  Future<Response> testConnection() async {
    try {
      return await _dio.get(ApiEndpoints.test);
    } on DioException catch (e) {
      throw Exception(
        (e.response?.data is Map<String, dynamic>)
            ? e.response?.data["message"] ?? "Connection failed"
            : e.response?.data.toString() ?? "Connection failed",
      );
    }
  }

  // Register user
  Future<Response> userRegister({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      return await _dio.post(
        ApiEndpoints.register,
        data: {"name": name, "email": email, "password": password},
      );
    } on DioException catch (e) {
      throw Exception(
        (e.response?.data is Map<String, dynamic>)
            ? e.response?.data["message"] ?? "Registration failed"
            : e.response?.data.toString() ?? "Registration failed",
      );
    }
  }

  // Login user
  Future<Response> userLogin({
    required String email,
    required String password,
  }) async {
    try {
      return await _dio.post(
        ApiEndpoints.login,
        data: {"email": email, "password": password},
      );
    } on DioException catch (e) {
      throw Exception(
        (e.response?.data is Map<String, dynamic>)
            ? e.response?.data["message"] ?? "Login failed"
            : e.response?.data.toString() ?? "Login failed",
      );
    }
  }
}
