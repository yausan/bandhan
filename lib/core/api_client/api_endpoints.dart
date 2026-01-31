// lib/core/api_client/api_endpoints.dart
class ApiEndpoints {
  ApiEndpoints._();

  // Android emulator
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // iOS simulator: 'http://localhost:3000/api'
  // Physical device: 'http://YOUR_IP:3000/api'

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints - MATCHING YOUR BACKEND
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // Test endpoint
  static const String test = '/test';
  static const String health = '/health';
}
