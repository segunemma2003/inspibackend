import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreatePostController {
  /// Uploads a file to S3 using presigned URL
  /// Returns true if upload is successful, false otherwise
  Future<bool> uploadToS3({
    required File file,
    required String uploadUrl,
    required Map<String, String> fields,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
      // Add form fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
      ));
      
      // Send request
      final response = await request.send();
      
      if (response.statusCode == 204) {
        return true;
      } else {
        final responseData = await response.stream.bytesToString();
        print('S3 Upload Error: ${response.statusCode} - $responseData');
        return false;
      }
    } catch (e) {
      print('S3 Upload Exception: $e');
      return false;
    }
  }
  
  /// Validates the post data before submission
  bool validatePost({
    required String caption,
    required File? mediaFile,
  }) {
    if (caption.trim().isEmpty) {
      return false;
    }
    
    if (mediaFile == null) {
      return false;
    }
    
    return true;
  }
  
  /// Formats tags for the API
  List<String> formatTags(List<String> tags) {
    return tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
}
