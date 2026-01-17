// lib/core/api_client/api_endpoints.dart

class ApiEndpoints {
  ApiEndpoints._();

  // Android emulator
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Student
  static const String studentRegister = '/students/register';
  static const String studentLogin = '/students/login';
}
