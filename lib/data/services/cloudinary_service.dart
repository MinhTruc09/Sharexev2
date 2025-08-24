import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sharexev2/config/env.dart';

class CloudinaryService {
  static const String _uploadUrl = 'https://api.cloudinary.com/v1_1';
  
  // Upload image to Cloudinary
  Future<String> uploadImage(File imageFile, {String? folder}) async {
    try {
      if (Env.cloudinaryCloudName.isEmpty) {
        throw Exception('Cloudinary configuration not found');
      }
      
      final url = '$_uploadUrl/${Env.cloudinaryCloudName}/image/upload';
      
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['upload_preset'] = 'ml_default' // Use unsigned upload for simplicity
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      if (folder != null) {
        request.fields['folder'] = folder;
      }
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);
      
      if (response.statusCode == 200) {
        return jsonData['secure_url'] as String;
      } else {
        throw Exception('Upload failed: ${jsonData['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
  
  // Delete image from Cloudinary
  Future<bool> deleteImage(String publicId) async {
    try {
      if (Env.cloudinaryCloudName.isEmpty || 
          Env.cloudinaryApiKey.isEmpty || 
          Env.cloudinaryApiSecret.isEmpty) {
        throw Exception('Cloudinary configuration not found');
      }
      
      final url = '$_uploadUrl/${Env.cloudinaryCloudName}/image/destroy';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final response = await http.post(
        Uri.parse(url),
        body: {
          'public_id': publicId,
          'api_key': Env.cloudinaryApiKey,
          'timestamp': timestamp.toString(),
          'signature': _generateSignature(publicId, timestamp),
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
  
  String _generateSignature(String publicId, int timestamp) {
    // This is a simplified signature generation
    // In production, you should implement proper signature generation
    return 'signature_placeholder';
  }
}
