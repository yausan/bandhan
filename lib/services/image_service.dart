import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client/api_endpoints.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static final Dio _dio = Dio();

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
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
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
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  // Upload image to server
  static Future<Map<String, dynamic>> uploadProfilePicture(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      String fileName = imageFile.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      Response response = await _dio.post(
        '${ApiEndpoints.baseUrl}/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      print('Error uploading image: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Get full image URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    
    // Handle relative paths from server
    if (imagePath.startsWith('/uploads')) {
      return 'http://10.0.2.2:3000$imagePath';
    }
    
    return imagePath;
  }
}
