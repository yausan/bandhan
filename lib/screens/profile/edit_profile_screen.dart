import 'dart:io';
import 'dart:convert';
import 'package:bandhan/core/api_client/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/image_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  String? _profilePictureUrl;

  Future<void> _pickAndUploadImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final image = await ImageService.pickImageFromGallery();
    if (image == null) return;
    await _uploadImage(image);
  }

  Future<void> _pickImageFromCamera() async {
    final image = await ImageService.pickImageFromCamera();
    if (image == null) return;
    await _uploadImage(image);
  }

  Future<void> _uploadImage(File image) async {
    setState(() {
      _selectedImage = image;
      _isUploading = true;
    });

    print('📤 Uploading image to server...');

    final result = await ImageService.uploadProfilePicture(image);
    setState(() => _isUploading = false);

    if (result['success'] == true) {
      // Get the real server URL from response
      final imageUrl = result['data']['data']['profilePicture'];
      print('✅ Uploaded! Server URL: $imageUrl');
      print('🔗 Full URL: ${ImageService.getImageUrl(imageUrl)}');

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString != null) {
        final userData = json.decode(userString);
        userData['profilePicture'] = imageUrl;
        await prefs.setString('user', json.encode(userData));
        print('💾 Saved to SharedPreferences');
      }

      setState(() {
        _profilePictureUrl = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile picture uploaded to server!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Go back to profile
      Navigator.pop(context, {'profileUpdated': true});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${result['message'] ?? 'Upload failed'}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Profile Picture'),
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Profile Image
            GestureDetector(
              onTap: _isUploading ? null : _pickAndUploadImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.redAccent, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _getProfileImage(),
                      child: _isUploading
                          ? const CircularProgressIndicator()
                          : (_getProfileImage() == null
                                ? _buildInitialsPlaceholder()
                                : null),
                    ),
                  ),

                  // Camera Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Status
            Text(
              _isUploading ? 'Uploading to server...' : 'Tap to upload photo',
              style: TextStyle(
                color: _isUploading ? Colors.orange : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 30),

            // Preview Section
            if (_selectedImage != null)
              Column(
                children: [
                  const Text(
                    'Preview:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),

            // Server Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Server Information:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Base URL: ${ApiEndpoints.baseUrl}'),
                    Text('Upload Endpoint: /api/upload'),
                    Text('Images Folder: /uploads/'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsPlaceholder() {
    return const Center(
      child: Text(
        'U',
        style: TextStyle(
          fontSize: 60,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty) {
      final imageUrl = ImageService.getImageUrl(_profilePictureUrl);
      if (imageUrl.isNotEmpty) {
        return NetworkImage(imageUrl);
      }
    }
    return null;
  }
}
