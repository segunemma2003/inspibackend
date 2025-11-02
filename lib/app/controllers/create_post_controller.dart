import 'dart:io';
import 'package:http/http.dart' as http;

class CreatePostController {

  Future<bool> uploadToS3({
    required File file,
    required String uploadUrl,
    required Map<String, String> fields,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
      ));

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

  List<String> formatTags(List<String> tags) {
    return tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
}
