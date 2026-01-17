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

    // 🔹 Log everything for debugging
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  // ---------------- STUDENT REGISTER ----------------
  Future<Response> studentRegister({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      return await _dio.post(
        ApiEndpoints.studentRegister,
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

  // ---------------- STUDENT LOGIN ----------------
  Future<Response> studentLogin({
    required String email,
    required String password,
  }) async {
    try {
      return await _dio.post(
        ApiEndpoints.studentLogin,
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
