import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client/api_endpoints.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        print('📷 Picked image: ${image.path}');
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('❌ Gallery error: $e');
      return null;
    }
  }

  // Pick image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        print('📷 Camera image: ${image.path}');
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('❌ Camera error: $e');
      return null;
    }
  }

  // Upload image to server
  static Future<Map<String, dynamic>> uploadProfilePicture(
    File imageFile,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      print('🔑 Token exists: ${token.isNotEmpty}');
      print('📁 File: ${imageFile.path}');

      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      Dio dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl, // This is now http://10.0.2.2:3000
          connectTimeout: ApiEndpoints.connectionTimeout,
          receiveTimeout: ApiEndpoints.receiveTimeout,
        ),
      );

      // Use the correct endpoint from ApiEndpoints
      Response response = await dio.post(
        ApiEndpoints.upload, // This is '/api/upload'
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('✅ Upload successful! Status: ${response.statusCode}');
      print('📦 Response: ${response.data}');

      return {'success': true, 'data': response.data};
    } catch (e) {
      print('❌ Upload error: $e');
      if (e is DioException) {
        print('📊 Dio Error: ${e.type}');
        print('📄 Response: ${e.response?.data}');
      }
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get full image URL
  static String getImageUrl(String? imagePath) {
    // If no image, return empty string
    if (imagePath == null || imagePath.isEmpty) {
      print('🖼️ No profile picture');
      return '';
    }

    // If it's default profile image, return empty
    if (imagePath.contains('default-profile')) {
      print('🖼️ Default profile image requested');
      return '';
    }

    // If already a full URL, return as-is
    if (imagePath.startsWith('http')) {
      print('🖼️ Full URL: $imagePath');
      return imagePath;
    }

    // Handle relative paths
    if (imagePath.startsWith('/uploads')) {
      final url = '${ApiEndpoints.baseUrl}$imagePath';
      print('🖼️ Constructed URL: $url');
      return url;
    }

    // If it starts with / but not uploads
    if (imagePath.startsWith('/')) {
      final url = '${ApiEndpoints.baseUrl}$imagePath';
      print('🖼️ URL with slash: $url');
      return url;
    }

    // Default: assume it's in uploads folder
    final url = '${ApiEndpoints.baseUrl}/uploads/$imagePath';
    print('🖼️ Default URL: $url');
    return url;
  }
}
