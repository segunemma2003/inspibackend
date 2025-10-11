import 'package:flutter/material.dart';
import '/config/decoders.dart';
import '/app/services/auth_service.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SavedPostsApiService extends NyApiService {
  SavedPostsApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'https://api.inspirtag.com/api');

  @override
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    final authHeaders = await AuthService.instance.getAuthHeaders();
    headers.addAll(authHeaders);
    return headers;
  }

  /// Get user's saved posts
  Future<Map<String, dynamic>?> getSavedPosts({
    int page = 1,
    int perPage = 20,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get(
        "/user-saved-posts",
        queryParameters: {
          "page": page,
          "per_page": perPage,
        },
      ),
      cacheKey: "saved_posts_$page",
      cacheDuration: const Duration(minutes: 3),
    );
  }

  /// Get user's liked posts
  Future<Map<String, dynamic>?> getLikedPosts({
    int page = 1,
    int perPage = 20,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get(
        "/liked-posts",
        queryParameters: {
          "page": page,
          "per_page": perPage,
        },
      ),
      cacheKey: "liked_posts_$page",
      cacheDuration: const Duration(minutes: 3),
    );
  }

  /// Like a post
  Future<Map<String, dynamic>?> likePost(int postId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/posts/$postId/like"),
    );
  }

  /// Unlike a post
  Future<Map<String, dynamic>?> unlikePost(int postId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/posts/$postId/like"),
    );
  }

  /// Save a post
  Future<Map<String, dynamic>?> savePost(int postId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/posts/$postId/save"),
    );
  }

  /// Unsave a post
  Future<Map<String, dynamic>?> unsavePost(int postId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/posts/$postId/save"),
    );
  }

  /// Get a single post
  Future<dynamic> getPost(int postId) async {
    return await network<dynamic>(
      request: (request) => request.get("/posts/$postId"),
      cacheKey: "post_$postId",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Delete a post
  Future<Map<String, dynamic>?> deletePost(int postId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/posts/$postId"),
    );
  }
}
