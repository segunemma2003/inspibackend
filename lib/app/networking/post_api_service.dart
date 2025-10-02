import 'package:flutter/material.dart';
import '/config/decoders.dart';
import '/app/services/auth_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/post.dart';

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

  /// Get presigned URL for S3 upload (large files)
  Future<Map<String, dynamic>?> getUploadUrl({
    required String filename,
    required String contentType,
    required int fileSize,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/posts/upload-url", data: {
        "filename": filename,
        "content_type": contentType,
        "file_size": fileSize,
      }),
    );
  }

  /// Create post after S3 upload
  Future<Post?> createPostFromS3({
    required String filePath,
    String? caption,
    required int categoryId,
    List<String>? tags,
    String? location,
  }) async {
    return await network<Post>(
      request: (request) => request.post("/posts/create-from-s3", data: {
        "file_path": filePath,
        if (caption != null) "caption": caption,
        "category_id": categoryId,
        if (tags != null) "tags": tags,
        if (location != null) "location": location,
      }),
    );
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
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/posts/saved", queryParameters: {
        "per_page": perPage,
        "page": page,
      }),
      cacheKey: "saved_posts_$page",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Get liked posts
  Future<Map<String, dynamic>?> getLikedPosts({
    int perPage = 20,
    int page = 1,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/posts/liked", queryParameters: {
        "per_page": perPage,
        "page": page,
      }),
      cacheKey: "liked_posts_$page",
      cacheDuration: const Duration(minutes: 5),
    );
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
}
