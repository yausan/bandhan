// lib/core/api_client/api_endpoints.dart
class ApiEndpoints {
  ApiEndpoints._();

  // Android emulator - REMOVE /api from here!
  static const String baseUrl = 'http://10.0.2.2:3000';
  // NOT: 'http://10.0.2.2:3000/api'  ← THIS IS WRONG!

  // iOS simulator: 'http://localhost:3000'
  // Physical device: 'http://YOUR_IP:3000'

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints - Note: These are FULL paths from baseUrl
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String upload = '/api/upload'; // Add this

  // Test endpoints
  static const String test = '/api/test';
  static const String health = '/health';
}
