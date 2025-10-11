import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nylo_framework/nylo_framework.dart';

import '/app/models/post.dart';
import '/app/services/auth_service.dart';
import '/config/decoders.dart';

class PostApiService extends NyApiService {
  PostApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'http://38.180.244.178/api');

  @override
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    print('🌐 PostApiService: Setting auth headers...');
    final authHeaders = await AuthService.instance.getAuthHeaders();
    print('🌐 PostApiService: Auth headers received: $authHeaders');
    headers.addAll(authHeaders);
    print('🌐 PostApiService: Final headers: ${headers.toString()}');
    return headers;
  }

  /// Get personalized feed with filters
  Future<Map<String, dynamic>?> getFeed({
    int perPage = 20,
    int page = 1,
    List<String>? tags,
    List<String>? creators,
    List<String>? categories,
    String? search,
    String? mediaType,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, dynamic>{
      "per_page": perPage,
      "page": page,
    };

    if (tags != null && tags.isNotEmpty) queryParams["tags"] = tags;
    if (creators != null && creators.isNotEmpty)
      queryParams["creators"] = creators;
    if (categories != null && categories.isNotEmpty)
      queryParams["categories"] = categories;
    if (search != null && search.isNotEmpty) queryParams["search"] = search;
    if (mediaType != null) queryParams["media_type"] = mediaType;
    if (sortBy != null) queryParams["sort_by"] = sortBy;
    if (sortOrder != null) queryParams["sort_order"] = sortOrder;

    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/posts", queryParameters: queryParams),
      cacheKey: "feed_${page}_${tags?.join('_') ?? 'all'}",
      cacheDuration: const Duration(minutes: 2),
    );
  }

  /// Create a new post (direct upload)
  Future<Post?> createPost({
    required String caption,
    required String media,
    required int categoryId,
    List<String>? tags,
    String? location,
  }) async {
    return await network<Post>(
      request: (request) => request.post("/posts", data: {
        "caption": caption,
        "media": media,
        "category_id": categoryId,
        if (tags != null) "tags": tags,
        if (location != null) "location": location,
      }),
    );
  }

  /// Get presigned URL for S3 upload (smart upload system)
  Future<Map<String, dynamic>?> getUploadUrl({
    required String filename,
    required String contentType,
    required int fileSize,
  }) async {
    final requestData = {
      "filename": filename,
      "content_type": contentType,
      "file_size": fileSize,
    };

    print('🌐 PostApiService: getUploadUrl Request:');
    print('🌐 PostApiService: - URL: POST /posts/upload-url');
    print('🌐 PostApiService: - Data: $requestData');
    print('🌐 PostApiService: - filename: "$filename"');
    print('🌐 PostApiService: - content_type: "$contentType"');
    print(
        '🌐 PostApiService: - file_size: $fileSize bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');

    final response = await network<Map<String, dynamic>>(
      request: (request) =>
          request.post("/posts/upload-url", data: requestData),
    );

    print('🌐 PostApiService: getUploadUrl Response:');
    print('🌐 PostApiService: - Response: $response');

    return response;
  }

  /// Get chunked upload URLs for large files
  Future<Map<String, dynamic>?> getChunkedUploadUrl({
    required String filename,
    required String contentType,
    required int totalSize,
    required int chunkSize,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/posts/chunked-upload-url", data: {
        "filename": filename,
        "content_type": contentType,
        "total_size": totalSize,
        "chunk_size": chunkSize,
      }),
    );
  }

  /// Complete chunked upload
  Future<Map<String, dynamic>?> completeChunkedUpload({
    required String filePath,
    required int totalChunks,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) =>
          request.post("/posts/complete-chunked-upload", data: {
        "file_path": filePath,
        "total_chunks": totalChunks,
      }),
    );
  }

  /// Create post after S3 upload
  Future<Map<String, dynamic>?> createPostFromS3({
    required String filePath,
    String? caption,
    required int categoryId,
    List<String>? tags,
    String? location,
    Map<String, dynamic>? mediaMetadata,
    String? thumbnailPath,
  }) async {
    try {
      return await network<Map<String, dynamic>>(
        request: (request) => request.post("/posts/create-from-s3", data: {
          'file_path': filePath,
          if (caption != null) 'caption': caption,
          'category_id': categoryId,
          if (tags != null && tags.isNotEmpty) 'tags': tags,
          if (location != null) 'location': location,
          if (mediaMetadata != null) 'media_metadata': mediaMetadata,
          if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
        }),
      );
    } catch (e) {
      print('❌ Error in createPostFromS3: $e');
      rethrow;
    }
  }

  /// Get post details
  Future<Post?> getPostDetails(int postId) async {
    return await network<Post>(
      request: (request) => request.get("/posts/$postId"),
      cacheKey: "post_details_$postId",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Like/Unlike a post
  Future<Map<String, dynamic>?> toggleLike(int postId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/posts/$postId/like"),
    );
  }

  /// Save/Unsave a post
  Future<Map<String, dynamic>?> toggleSave(int postId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/posts/$postId/save"),
    );
  }

  /// Get saved posts
  Future<Map<String, dynamic>?> getSavedPosts({
    int perPage = 20,
    int page = 1,
  }) async {
    print('📚 PostApiService: Fetching saved posts (page: $page)');
    try {
      final response = await network<Map<String, dynamic>>(
        request: (request) => request.get(
          "/user-saved-posts",
          queryParameters: {
            'per_page': perPage,
            'page': page,
          },
        ),
        cacheKey: "saved_posts_$page",
        cacheDuration: const Duration(minutes: 2),
      );

      if (response != null) {
        print(
            '✅ PostApiService: Successfully fetched ${response['data']?['data']?.length ?? 0} saved posts');
      } else {
        print('⚠️ PostApiService: No data received for saved posts');
      }

      return response;
    } catch (e) {
      print('❌ PostApiService: Error fetching saved posts: $e');
      rethrow;
    }
  }

  /// Get liked posts
  Future<Map<String, dynamic>?> getLikedPosts({
    int perPage = 20,
    int page = 1,
  }) async {
    print('❤️ PostApiService: Fetching liked posts (page: $page)');
    try {
      final response = await network<Map<String, dynamic>>(
        request: (request) => request.get(
          "/user-liked-posts",
          queryParameters: {
            'per_page': perPage,
            'page': page,
          },
        ),
        cacheKey: "liked_posts_$page",
        cacheDuration: const Duration(minutes: 5),
      );

      if (response != null) {
        print(
            '✅ PostApiService: Successfully fetched ${response['data']?['data']?.length ?? 0} liked posts');
      } else {
        print('⚠️ PostApiService: No data received for liked posts');
      }

      return response;
    } catch (e) {
      print('❌ PostApiService: Error fetching liked posts: $e');
      rethrow;
    }
  }

  /// Delete a post
  Future<Map<String, dynamic>?> deletePost(int postId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/posts/$postId"),
    );
  }

  /// Search posts by tags
  Future<Map<String, dynamic>?> searchPostsByTags({
    required List<String> tags,
    int perPage = 20,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/posts/search/tags", data: {
        "tags": tags,
        "per_page": perPage,
      }),
      cacheKey: "posts_by_tags_${tags.join('_')}",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// General search
  Future<Map<String, dynamic>?> search({
    required String query,
    required String type,
    int perPage = 20,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/search", queryParameters: {
        "q": query,
        "type": type,
        "per_page": perPage,
      }),
      cacheKey: "search_${type}_${query}",
      cacheDuration: const Duration(minutes: 3),
    );
  }

  // ==================== UPLOAD METHODS ====================

  // ==================== UPLOAD METHODS ====================

  /// Method 1: Direct Upload (≤ 50MB) - Traditional Laravel upload
  ///
  /// This method is suitable for files up to 50MB.
  /// For larger files, use the chunked upload methods.
  ///
  /// Parameters:
  /// - `mediaFile`: The file to upload (image or video)
  /// - `caption`: Post caption (optional, max 2000 chars)
  /// - `categoryId`: ID of the category this post belongs to
  /// - `tags`: Optional list of tags
  /// - `location`: Optional location string
  ///
  /// Returns: Post data on success, or error details on failure
  Future<Map<String, dynamic>?> createPostDirect({
    required File mediaFile,
    String? caption,
    required int categoryId,
    List<String>? tags,
    String? location,
  }) async {
    // Create form data
    final formData = FormData.fromMap({
      'media': await MultipartFile.fromFile(mediaFile.path),
      if (caption != null) 'caption': caption,
      'category_id': categoryId.toString(),
      if (tags != null) 'tags[]': tags,
      if (location != null) 'location': location,
    });

    return await network<Map<String, dynamic>>(
      request: (request) => request.post(
        "/posts",
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      ),
    );
  }

  /// Method 2: Presigned URL Upload (any size) - Direct to S3
  ///
  /// This method gets a presigned URL from the server and then uploads
  /// the file directly to S3. It handles both single PUT and chunked uploads
  /// automatically based on file size.
  ///
  /// Parameters:
  /// - `file`: The file to upload
  /// - `onProgress`: Callback for upload progress updates
  /// - `caption`: Post caption (optional)
  /// - `categoryId`: ID of the category
  /// - `tags`: Optional list of tags
  /// - `location`: Optional location string
  /// - `mediaMetadata`: Optional metadata like duration, resolution, etc.
  /// - `thumbnailPath`: Optional path to a thumbnail (for videos)
  ///
  /// Returns: Post data on success, or error details on failure
  Future<Map<String, dynamic>?> uploadWithPresignedUrl({
    required File file,
    required void Function(double) onProgress,
    String? caption,
    required int categoryId,
    List<String>? tags,
    String? location,
    Map<String, dynamic>? mediaMetadata,
    String? thumbnailPath,
  }) async {
    try {
      // Step 1: Get upload URL from server
      final fileSize = await file.length();
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      final mimeType = _getMimeType(fileExtension);

      print('🌐 Starting presigned URL upload for file: $fileName');
      print(
          '🌐 File size: ${fileSize} bytes (${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB)');

      final uploadUrlResponse = await getUploadUrl(
        filename: fileName,
        contentType: mimeType,
        fileSize: fileSize,
      );

      if (uploadUrlResponse == null || !uploadUrlResponse['success']) {
        throw Exception(
            'Failed to get upload URL: ${uploadUrlResponse?['message'] ?? 'Unknown error'}');
      }

      final uploadData = uploadUrlResponse['data'];
      final uploadMethod = uploadData['upload_method'];

      String filePath;

      if (uploadMethod == 'direct') {
        // Step 2a: Direct upload to S3 (single PUT)
        print('🌐 Using direct upload method');
        final uploadUrl = uploadData['upload_url'] as String;
        filePath = uploadData['file_path'] as String;

        // Upload the file directly to S3
        await _uploadToS3(
          file: file,
          uploadUrl: uploadUrl,
          contentType: mimeType,
          onProgress: onProgress,
        );
      } else if (uploadMethod == 'chunked') {
        // Step 2b: Chunked upload to S3
        print('🌐 Using chunked upload method');
        filePath = uploadData['file_path'] as String;
        final chunkSize = uploadData['recommended_chunk_size'] as int? ??
            5 * 1024 * 1024; // Default 5MB

        // Upload in chunks
        await _uploadInChunks(
          file: file,
          filePath: filePath,
          chunkSize: chunkSize,
          contentType: mimeType,
          onProgress: onProgress,
        );
      } else {
        throw Exception('Unknown upload method: $uploadMethod');
      }

      // Step 3: Create post with the uploaded file
      print('🌐 File upload complete, creating post...');
      final postResponse = await createPostFromS3(
        filePath: filePath,
        caption: caption,
        categoryId: categoryId,
        tags: tags,
        location: location,
        mediaMetadata: mediaMetadata,
        thumbnailPath: thumbnailPath,
      );

      return {
        'success': true,
        'message': 'Post created successfully',
        'data': postResponse,
      };
    } catch (e) {
      print('❌ Error in uploadWithPresignedUrl: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Helper method to upload a file directly to S3 using a presigned URL
  Future<void> _uploadToS3({
    required File file,
    required String uploadUrl,
    required String contentType,
    required void Function(double) onProgress,
  }) async {
    try {
      final fileSize = await file.length();
      int uploadedBytes = 0;

      // Open the file stream
      final fileStream = file.openRead();
      final bytesBuilder = BytesBuilder();

      // Read the entire file into memory (for small files)
      await for (var chunk in fileStream) {
        bytesBuilder.add(chunk);
        uploadedBytes += chunk.length;
        final progress = (uploadedBytes / fileSize).clamp(0.0, 1.0);
        onProgress(progress);
      }

      final bytes = bytesBuilder.toBytes();

      // Upload the file in a single PUT request
      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': contentType,
          'Content-Length': fileSize.toString(),
        },
        body: bytes,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'S3 upload failed with status ${response.statusCode}: ${response.body}');
      }

      print('✅ File uploaded to S3 successfully');
    } catch (e) {
      print('❌ Error uploading to S3: $e');
      rethrow;
    }
  }

  /// Helper method to upload a file in chunks using presigned URLs
  Future<void> _uploadInChunks({
    required File file,
    required String filePath,
    required int chunkSize,
    required String contentType,
    required void Function(double) onProgress,
  }) async {
    try {
      final fileSize = await file.length();
      final totalChunks = (fileSize / chunkSize).ceil();

      print(
          '📦 Starting chunked upload of $fileSize bytes in $totalChunks chunks');

      // Get chunked upload URLs from the server
      final chunkedUrlResponse = await getChunkedUploadUrl(
        filename: filePath.split('/').last,
        contentType: contentType,
        totalSize: fileSize,
        chunkSize: chunkSize,
      );

      if (chunkedUrlResponse == null || !chunkedUrlResponse['success']) {
        throw Exception(
            'Failed to get chunked upload URLs: ${chunkedUrlResponse?['message'] ?? 'Unknown error'}');
      }

      final chunkUrls = chunkedUrlResponse['data']['chunk_urls'] as List;

      // Upload each chunk
      final fileStream = file.openRead();
      int chunkIndex = 0;
      int uploadedBytes = 0;

      await for (var chunk in fileStream) {
        if (chunkIndex >= chunkUrls.length) {
          throw Exception(
              'More chunks than expected. Expected $totalChunks chunks but got more.');
        }

        final chunkUrl = chunkUrls[chunkIndex]['upload_url'] as String;
        print(
            '📤 Uploading chunk ${chunkIndex + 1}/$totalChunks (${chunk.length} bytes)');

        // Upload the chunk
        final response = await http.put(
          Uri.parse(chunkUrl),
          headers: {
            'Content-Type': 'application/octet-stream',
            'Content-Length': chunk.length.toString(),
          },
          body: chunk,
        );

        if (response.statusCode != 200 && response.statusCode != 204) {
          throw Exception(
              'Failed to upload chunk $chunkIndex: ${response.statusCode} ${response.body}');
        }

        uploadedBytes += chunk.length;
        final progress = (uploadedBytes / fileSize).clamp(0.0, 1.0);
        onProgress(progress);

        chunkIndex++;
      }

      // Complete the chunked upload
      print('✅ All chunks uploaded, completing upload...');
      final completeResponse = await completeChunkedUpload(
        filePath: filePath,
        totalChunks: totalChunks,
      );

      if (completeResponse == null || !completeResponse['success']) {
        throw Exception(
            'Failed to complete chunked upload: ${completeResponse?['message'] ?? 'Unknown error'}');
      }

      print('✅ Chunked upload completed successfully');
    } catch (e) {
      print('❌ Error in _uploadInChunks: $e');
      rethrow;
    }
  }

  /// Helper method to get MIME type from file extension
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      default:
        return 'application/octet-stream';
    }
  }
}
