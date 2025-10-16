import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/config/decoders.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'dart:convert';

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
    final rawResponse = await network<dynamic>(
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

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
    if (rawResponse is String) {
      if (rawResponse.startsWith('{') && rawResponse.contains('}{')) {
        try {
          final parts = rawResponse.split('}{');
          if (parts.length == 2) {
            final firstPart = '${parts[0]}}';
            final secondPart = '{${parts[1]}';

            Map<String, dynamic> firstJson = {};
            Map<String, dynamic> secondJson = {};

            try {
              firstJson = jsonDecode(firstPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.getSavedPosts: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.getSavedPosts: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 SavedPostsApiService.getSavedPosts: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 SavedPostsApiService.getSavedPosts: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.getSavedPosts: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.getSavedPosts: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  /// Get user's liked posts
  Future<Map<String, dynamic>?> getLikedPosts({
    int page = 1,
    int perPage = 20,
  }) async {
    final rawResponse = await network<dynamic>(
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

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
    if (rawResponse is String) {
      if (rawResponse.startsWith('{') && rawResponse.contains('}{')) {
        try {
          final parts = rawResponse.split('}{');
          if (parts.length == 2) {
            final firstPart = '${parts[0]}}';
            final secondPart = '{${parts[1]}';

            Map<String, dynamic> firstJson = {};
            Map<String, dynamic> secondJson = {};

            try {
              firstJson = jsonDecode(firstPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.getLikedPosts: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.getLikedPosts: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 SavedPostsApiService.getLikedPosts: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 SavedPostsApiService.getLikedPosts: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.getLikedPosts: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.getLikedPosts: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  /// Like a post
  Future<Map<String, dynamic>?> likePost(int postId) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.post("/posts/$postId/like"),
    );

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
    if (rawResponse is String) {
      if (rawResponse.startsWith('{') && rawResponse.contains('}{')) {
        try {
          final parts = rawResponse.split('}{');
          if (parts.length == 2) {
            final firstPart = '${parts[0]}}';
            final secondPart = '{${parts[1]}';

            Map<String, dynamic> firstJson = {};
            Map<String, dynamic> secondJson = {};

            try {
              firstJson = jsonDecode(firstPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.likePost: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.likePost: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 SavedPostsApiService.likePost: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 SavedPostsApiService.likePost: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.likePost: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.likePost: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  /// Unlike a post
  Future<Map<String, dynamic>?> unlikePost(int postId) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.delete("/posts/$postId/like"),
    );

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
    if (rawResponse is String) {
      if (rawResponse.startsWith('{') && rawResponse.contains('}{')) {
        try {
          final parts = rawResponse.split('}{');
          if (parts.length == 2) {
            final firstPart = '${parts[0]}}';
            final secondPart = '{${parts[1]}';

            Map<String, dynamic> firstJson = {};
            Map<String, dynamic> secondJson = {};

            try {
              firstJson = jsonDecode(firstPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.unlikePost: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.unlikePost: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 SavedPostsApiService.unlikePost: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 SavedPostsApiService.unlikePost: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.unlikePost: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.unlikePost: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  /// Save a post
  Future<Map<String, dynamic>?> savePost(int postId) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.post("/posts/$postId/save"),
    );

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
    if (rawResponse is String) {
      if (rawResponse.startsWith('{') && rawResponse.contains('}{')) {
        try {
          final parts = rawResponse.split('}{');
          if (parts.length == 2) {
            final firstPart = '${parts[0]}}';
            final secondPart = '{${parts[1]}';

            Map<String, dynamic> firstJson = {};
            Map<String, dynamic> secondJson = {};

            try {
              firstJson = jsonDecode(firstPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.savePost: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.savePost: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 SavedPostsApiService.savePost: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 SavedPostsApiService.savePost: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.savePost: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.savePost: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  /// Unsave a post
  Future<Map<String, dynamic>?> unsavePost(int postId) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.delete("/posts/$postId/save"),
    );

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
    if (rawResponse is String) {
      if (rawResponse.startsWith('{') && rawResponse.contains('}{')) {
        try {
          final parts = rawResponse.split('}{');
          if (parts.length == 2) {
            final firstPart = '${parts[0]}}';
            final secondPart = '{${parts[1]}';

            Map<String, dynamic> firstJson = {};
            Map<String, dynamic> secondJson = {};

            try {
              firstJson = jsonDecode(firstPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.unsavePost: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.unsavePost: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 SavedPostsApiService.unsavePost: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 SavedPostsApiService.unsavePost: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.unsavePost: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.unsavePost: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  /// Get a single post
  Future<dynamic> getPost(int postId) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.get("/posts/$postId"),
      cacheKey: "post_$postId",
      cacheDuration: const Duration(minutes: 5),
    );

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
    if (rawResponse is String) {
      if (rawResponse.startsWith('{') && rawResponse.contains('}{')) {
        try {
          final parts = rawResponse.split('}{');
          if (parts.length == 2) {
            final firstPart = '${parts[0]}}';
            final secondPart = '{${parts[1]}';

            Map<String, dynamic> firstJson = {};
            Map<String, dynamic> secondJson = {};

            try {
              firstJson = jsonDecode(firstPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.getPost: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.getPost: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 SavedPostsApiService.getPost: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 SavedPostsApiService.getPost: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.getPost: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.getPost: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  /// Delete a post
  Future<Map<String, dynamic>?> deletePost(int postId) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.delete("/posts/$postId"),
    );

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
    if (rawResponse is String) {
      if (rawResponse.startsWith('{') && rawResponse.contains('}{')) {
        try {
          final parts = rawResponse.split('}{');
          if (parts.length == 2) {
            final firstPart = '${parts[0]}}';
            final secondPart = '{${parts[1]}';

            Map<String, dynamic> firstJson = {};
            Map<String, dynamic> secondJson = {};

            try {
              firstJson = jsonDecode(firstPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.deletePost: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 SavedPostsApiService.deletePost: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 SavedPostsApiService.deletePost: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 SavedPostsApiService.deletePost: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.deletePost: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 SavedPostsApiService.deletePost: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }
}
