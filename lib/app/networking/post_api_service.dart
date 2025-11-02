import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nylo_framework/nylo_framework.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:flutter_app/app/models/post.dart';
import 'package:flutter_app/config/decoders.dart';
import '/app/networking/dio/interceptors/bearer_auth_interceptor.dart';
import '/config/cache.dart';

class PostApiService extends NyApiService {
  PostApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'http://38.180.244.178/api');

  @override
  get interceptors => {
        if (getEnv('APP_DEBUG') == true) PrettyDioLogger: PrettyDioLogger(),
        BearerAuthInterceptor: BearerAuthInterceptor(),
      };

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
    bool forceRefresh = false, // Add forceRefresh parameter
  }) async {
    final queryParams = <String, dynamic>{
      "per_page": perPage,
      "page": page,
    };

    if (tags != null && tags.isNotEmpty) {
      for (var tag in tags) {
        queryParams.putIfAbsent('tags[]', () => []).add(tag);
      }
    }
    if (creators != null && creators.isNotEmpty) {
      for (var creator in creators) {
        queryParams.putIfAbsent('creators[]', () => []).add(creator);
      }
    }
    if (categories != null && categories.isNotEmpty) {
      for (var category in categories) {
        queryParams.putIfAbsent('categories[]', () => []).add(category);
      }
    }
    if (search != null && search.isNotEmpty) queryParams["search"] = search;
    if (mediaType != null) queryParams["media_type"] = mediaType;
    if (sortBy != null) queryParams["sort_by"] = sortBy;
    if (sortOrder != null) queryParams["sort_order"] = sortOrder;

    print(
        '📡 PostApiService: Sending getFeed request with queryParams: $queryParams'); // Add this line

    final rawResponse = await network<dynamic>(
      request: (request) => request.get("/posts", queryParameters: queryParams),
      cacheKey:
          "feed_${page}_${tags?.join('_') ?? 'all'}_${categories?.join('_') ?? 'all'}${forceRefresh ? '_' + DateTime.now().millisecondsSinceEpoch.toString() : ''}", // Include forceRefresh in cache key
      cacheDuration: const Duration(minutes: 2),
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
                  '🐛 PostApiService.getFeed: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 PostApiService.getFeed: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 PostApiService.getFeed: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 PostApiService.getFeed: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 PostApiService.getFeed: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 PostApiService.getFeed: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  Future<Post?> createPost({
    required String caption,
    required String media,
    required int categoryId,
    List<String>? tags,
    String? location,
    List<int>? taggedUsers,
  }) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.post("/posts", data: {
        "caption": caption,
        "media": media,
        "category_id": categoryId,
        if (tags != null) "tags": tags,
        if (location != null) "location": location,
        if (taggedUsers != null) "tagged_users": taggedUsers,
      }),
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
                  '🐛 PostApiService.createPost: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 PostApiService.createPost: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 PostApiService.createPost: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 PostApiService.createPost: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 PostApiService.createPost: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 PostApiService.createPost: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }

    if (response != null && response['success'] == true) {

      await CacheConfig.clearPostCache();
      return Post.fromJson(response['data']);
    }
    return null;
  }

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

    final rawResponse = await network<dynamic>(
      request: (request) =>
          request.post("/posts/upload-url", data: requestData),
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
                  '🐛 PostApiService.getUploadUrl: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 PostApiService.getUploadUrl: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 PostApiService.getUploadUrl: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 PostApiService.getUploadUrl: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 PostApiService.getUploadUrl: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 PostApiService.getUploadUrl: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }

    print('🌐 PostApiService: getUploadUrl Response:');
    print('🌐 PostApiService: - Response: $response');

    return response;
  }

  Future<Map<String, dynamic>?> getChunkedUploadUrl({
    required String filename,
    required String contentType,
    required int totalSize,
    required int chunkSize,
  }) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.post("/posts/chunked-upload-url", data: {
        "filename": filename,
        "content_type": contentType,
        "total_size": totalSize,
        "chunk_size": chunkSize,
      }),
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
                  '🐛 PostApiService.getChunkedUploadUrl: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 PostApiService.getChunkedUploadUrl: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 PostApiService.getChunkedUploadUrl: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 PostApiService.getChunkedUploadUrl: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 PostApiService.getChunkedUploadUrl: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 PostApiService.getChunkedUploadUrl: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  Future<Map<String, dynamic>?> completeChunkedUpload({
    required String filePath,
    required int totalChunks,
  }) async {
    final rawResponse = await network<dynamic>(
      request: (request) =>
          request.post("/posts/complete-chunked-upload", data: {
        "file_path": filePath,
        "total_chunks": totalChunks,
      }),
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
                  '🐛 PostApiService.completeChunkedUpload: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 PostApiService.completeChunkedUpload: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 PostApiService.completeChunkedUpload: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 PostApiService.completeChunkedUpload: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 PostApiService.completeChunkedUpload: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 PostApiService.completeChunkedUpload: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  Future<Map<String, dynamic>?> createPostFromS3({
    required String filePath,
    String? caption,
    required int categoryId,
    List<String>? tags,
    String? location,
    Map<String, dynamic>? mediaMetadata,
    String? thumbnailPath,
    List<int>? taggedUsers,
  }) async {
    try {
      final rawResponse = await network<dynamic>(
        request: (request) => request.post("/posts/create-from-s3", data: {
          'file_path': filePath,
          if (caption != null) 'caption': caption,
          'category_id': categoryId,
          if (tags != null && tags.isNotEmpty) 'tags': tags,
          if (location != null) 'location': location,
          if (mediaMetadata != null) 'media_metadata': mediaMetadata,
          if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
          if (taggedUsers != null && taggedUsers.isNotEmpty)
            'tagged_users': taggedUsers,
        }),
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
                    '🐛 PostApiService.createPostFromS3: Failed to decode first JSON part: $e');
              }
              try {
                secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
              } catch (e) {
                print(
                    '🐛 PostApiService.createPostFromS3: Failed to decode second JSON part: $e');
              }

              Map<String, dynamic> mergedJson = {};
              mergedJson.addAll(firstJson);
              mergedJson.addAll(secondJson);
              print(
                  '🐛 PostApiService.createPostFromS3: Fixed and merged JSON: $mergedJson');
              response = mergedJson;
            } else {
              print(
                  '🐛 PostApiService.createPostFromS3: Malformed but unhandled concatenated JSON format: $rawResponse');
            }
          } catch (e) {
            print(
                '🐛 PostApiService.createPostFromS3: Error fixing concatenated JSON: $e');
          }
        }
        if (response == null) {
          try {
            response = jsonDecode(rawResponse) as Map<String, dynamic>;
          } catch (e) {
            print(
                '🐛 PostApiService.createPostFromS3: Failed to decode plain string response as JSON: $e');
            return null;
          }
        }
      } else if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      }

      if (response != null) {

        await CacheConfig.clearPostCache();
      }

      return response;
    } catch (e) {
      print('❌ Error in createPostFromS3: $e');
      rethrow;
    }
  }

  Future<Post?> getPostDetails(int postId) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.get("/posts/$postId"),
      cacheKey: "post_details_$postId",
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
                  '🐛 PostApiService.getPostDetails: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 PostApiService.getPostDetails: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 PostApiService.getPostDetails: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 PostApiService.getPostDetails: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 PostApiService.getPostDetails: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 PostApiService.getPostDetails: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }

    if (response != null && response['success'] == true) {
      return Post.fromJson(response['data']);
    }
    return null;
  }

  Future<Map<String, dynamic>?> toggleLike(int postId) async {
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
                  '🐛 PostApiService.toggleLike: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 PostApiService.toggleLike: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 PostApiService.toggleLike: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 PostApiService.toggleLike: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 PostApiService.toggleLike: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 PostApiService.toggleLike: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }

    if (response != null) {

      await cache().clear("post_details_$postId");
    }

    return response;
  }

  Future<Map<String, dynamic>?> toggleSave(int postId) async {
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
                  '🐛 PostApiService.toggleSave: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 PostApiService.toggleSave: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 PostApiService.toggleSave: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 PostApiService.toggleSave: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 PostApiService.toggleSave: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 PostApiService.toggleSave: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }

    if (response != null) {

      await cache().clear("post_details_$postId");
    }

    return response;
  }

  Future<Map<String, dynamic>?> getSavedPosts({
    int perPage = 20,
    int page = 1,
  }) async {
    print('📚 PostApiService: Fetching saved posts (page: $page)');
    try {
      final rawResponse = await network<dynamic>(
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
                    '🐛 PostApiService.getSavedPosts: Failed to decode first JSON part: $e');
              }
              try {
                secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
              } catch (e) {
                print(
                    '🐛 PostApiService.getSavedPosts: Failed to decode second JSON part: $e');
              }

              Map<String, dynamic> mergedJson = {};
              mergedJson.addAll(firstJson);
              mergedJson.addAll(secondJson);
              print(
                  '🐛 PostApiService.getSavedPosts: Fixed and merged JSON: $mergedJson');
              response = mergedJson;
            } else {
              print(
                  '🐛 PostApiService.getSavedPosts: Malformed but unhandled concatenated JSON format: $rawResponse');
            }
          } catch (e) {
            print(
                '🐛 PostApiService.getSavedPosts: Error fixing concatenated JSON: $e');
          }
        }
        if (response == null) {
          try {
            response = jsonDecode(rawResponse) as Map<String, dynamic>;
          } catch (e) {
            print(
                '🐛 PostApiService.getSavedPosts: Failed to decode plain string response as JSON: $e');
            return null;
          }
        }
      } else if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      }

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

  Future<Map<String, dynamic>?> getLikedPosts({
    int perPage = 20,
    int page = 1,
  }) async {
    print('❤️ PostApiService: Fetching liked posts (page: $page)');
    try {
      final rawResponse = await network<dynamic>(
        request: (request) => request.get(
          "/user-liked-posts",
          queryParameters: {
            'per_page': perPage,
            'page': page,
          },
        ),

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
                    '🐛 PostApiService.getLikedPosts: Failed to decode first JSON part: $e');
              }
              try {
                secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
              } catch (e) {
                print(
                    '🐛 PostApiService.getLikedPosts: Failed to decode second JSON part: $e');
              }

              Map<String, dynamic> mergedJson = {};
              mergedJson.addAll(firstJson);
              mergedJson.addAll(secondJson);
              print(
                  '🐛 PostApiService.getLikedPosts: Fixed and merged JSON: $mergedJson');
              response = mergedJson;
            } else {
              print(
                  '🐛 PostApiService.getLikedPosts: Malformed but unhandled concatenated JSON format: $rawResponse');
            }
          } catch (e) {
            print(
                '🐛 PostApiService.getLikedPosts: Error fixing concatenated JSON: $e');
          }
        }
        if (response == null) {
          try {
            response = jsonDecode(rawResponse) as Map<String, dynamic>;
          } catch (e) {
            print(
                '🐛 PostApiService.getLikedPosts: Failed to decode plain string response as JSON: $e');
            return null;
          }
        }
      } else if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      }

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
                  '🐛 PostApiService.deletePost: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 PostApiService.deletePost: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 PostApiService.deletePost: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 PostApiService.deletePost: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 PostApiService.deletePost: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 PostApiService.deletePost: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }

    if (response != null && response['success'] == true) {

      await CacheConfig.clearPostCache();
    }

    return response;
  }

  Future<Map<String, dynamic>?> searchPostsByTags({
    required List<String> tags,
    int perPage = 20,
  }) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.post("/posts/search/tags", data: {
        "tags": tags,
        "per_page": perPage,
      }),
      cacheKey: "posts_by_tags_${tags.join('_')}",
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
                  '🐛 PostApiService.searchPostsByTags: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 PostApiService.searchPostsByTags: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 PostApiService.searchPostsByTags: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 PostApiService.searchPostsByTags: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 PostApiService.searchPostsByTags: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 PostApiService.searchPostsByTags: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  Future<Map<String, dynamic>?> search({
    required String query,
    required String type,
    int perPage = 20,
  }) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.get("/search", queryParameters: {
        "q": query,
        "type": type,
        "per_page": perPage,
      }),
      cacheKey: "search_${type}_${query}",
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
                  '🐛 PostApiService.search: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 PostApiService.search: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 PostApiService.search: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 PostApiService.search: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print('🐛 PostApiService.search: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 PostApiService.search: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  Future<Map<String, dynamic>?> createPostDirect({
    required File mediaFile,
    String? caption,
    required int categoryId,
    List<String>? tags,
    String? location,
  }) async {

    final formData = FormData.fromMap({
      'media': await MultipartFile.fromFile(mediaFile.path),
      if (caption != null) 'caption': caption,
      'category_id': categoryId.toString(),
      if (tags != null) 'tags[]': tags,
      if (location != null) 'location': location,
    });

    final rawResponse = await network<dynamic>(
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
                  '🐛 PostApiService.createPostDirect: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 PostApiService.createPostDirect: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 PostApiService.createPostDirect: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 PostApiService.createPostDirect: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 PostApiService.createPostDirect: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 PostApiService.createPostDirect: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }

    if (response != null) {

      await CacheConfig.clearPostCache();
    }

    return response;
  }

  Future<Map<String, dynamic>?> uploadWithPresignedUrl({
    required File file,
    required void Function(double) onProgress,
    String? caption,
    required int categoryId,
    List<String>? tags,
    String? location,
    Map<String, dynamic>? mediaMetadata,
    String? thumbnailPath,
    List<int>? taggedUsers,
  }) async {
    try {

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

        print('🌐 Using direct upload method');
        final uploadUrl = uploadData['upload_url'] as String;
        filePath = uploadData['file_path'] as String;

        await _uploadToS3(
          file: file,
          uploadUrl: uploadUrl,
          contentType: mimeType,
          onProgress: onProgress,
        );
      } else if (uploadMethod == 'chunked') {

        print('🌐 Using chunked upload method');
        filePath = uploadData['file_path'] as String;
        final chunkSize = uploadData['recommended_chunk_size'] as int? ??
            5 * 1024 * 1024; // Default 5MB

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

      print('🌐 File upload complete, creating post...');
      final postResponse = await createPostFromS3(
        filePath: filePath,
        caption: caption,
        categoryId: categoryId,
        tags: tags,
        location: location,
        mediaMetadata: mediaMetadata,
        thumbnailPath: thumbnailPath,
        taggedUsers: taggedUsers,
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

  Future<void> _uploadToS3({
    required File file,
    required String uploadUrl,
    required String contentType,
    required void Function(double) onProgress,
  }) async {
    try {
      final fileSize = await file.length();
      int uploadedBytes = 0;

      final fileStream = file.openRead();
      final bytesBuilder = BytesBuilder();

      await for (var chunk in fileStream) {
        bytesBuilder.add(chunk);
        uploadedBytes += chunk.length;
        final progress = (uploadedBytes / fileSize).clamp(0.0, 1.0);
        onProgress(progress);
      }

      final bytes = bytesBuilder.toBytes();

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

  Future<Map<String, dynamic>?> getPostsByUser({
    required int userId,
    int perPage = 20,
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final queryParams = <String, dynamic>{
      "per_page": perPage,
      "page": page,
    };

    print('📡 PostApiService: Sending getPostsByUser request for user $userId');

    final rawResponse = await network<dynamic>(
      request: (request) =>
          request.get("/users/$userId/posts", queryParameters: queryParams),
      cacheKey:
          "user_posts_${userId}_$page${forceRefresh ? '_' + DateTime.now().millisecondsSinceEpoch.toString() : ''}",
      cacheDuration: const Duration(minutes: 2),
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
                  '🐛 PostApiService.getPostsByUser: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 PostApiService.getPostsByUser: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 PostApiService.getPostsByUser: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 PostApiService.getPostsByUser: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 PostApiService.getPostsByUser: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 PostApiService.getPostsByUser: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  Future<Map<String, dynamic>?> getUserLikedPosts({
    required int userId,
    int perPage = 20,
    int page = 1,
  }) async {
    print(
        '❤️ PostApiService: Fetching liked posts for user $userId (page: $page)');

    final queryParams = <String, dynamic>{
      "per_page": perPage,
      "page": page,
    };

    final rawResponse = await network<dynamic>(
      request: (request) => request.get("/users/$userId/liked-posts",
          queryParameters: queryParams),
      cacheKey: "user_liked_posts_${userId}_$page",
      cacheDuration: const Duration(minutes: 5),
    );

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
    if (rawResponse is String) {
      try {
        response = jsonDecode(rawResponse) as Map<String, dynamic>;
      } catch (e) {
        print(
            '🐛 PostApiService.getUserLikedPosts: Failed to decode response: $e');
        return null;
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  Future<Map<String, dynamic>?> getUserSavedPosts({
    required int userId,
    int perPage = 20,
    int page = 1,
  }) async {
    print(
        '📚 PostApiService: Fetching saved posts for user $userId (page: $page)');

    final queryParams = <String, dynamic>{
      "per_page": perPage,
      "page": page,
    };

    final rawResponse = await network<dynamic>(
      request: (request) => request.get("/users/$userId/saved-posts",
          queryParameters: queryParams),
      cacheKey: "user_saved_posts_${userId}_$page",
      cacheDuration: const Duration(minutes: 5),
    );

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
    if (rawResponse is String) {
      try {
        response = jsonDecode(rawResponse) as Map<String, dynamic>;
      } catch (e) {
        print(
            '🐛 PostApiService.getUserSavedPosts: Failed to decode response: $e');
        return null;
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

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

  Future<List<Map<String, dynamic>>?> searchUsersForTagging({
    required String query,
    int limit = 10,
  }) async {
    final response = await network<Map<String, dynamic>>(
      request: (request) => request.get("/tag-suggestions", queryParameters: {
        "q": query,
        "limit": limit,
      }),
    );

    if (response != null && response['success'] == true) {
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    }
    return null;
  }

  Future<Map<String, dynamic>?> tagUsersInPost({
    required int postId,
    required List<int> userIds,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/posts/$postId/tag-users", data: {
        "user_ids": userIds,
      }),
    );
  }

  Future<Map<String, dynamic>?> untagUsersFromPost({
    required int postId,
    required List<int> userIds,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/posts/$postId/untag-users", data: {
        "user_ids": userIds,
      }),
    );
  }

  Future<Map<String, dynamic>?> getTaggedPosts({
    int perPage = 20,
    int page = 1,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/tagged-posts", queryParameters: {
        "per_page": perPage,
        "page": page,
      }),
      cacheKey: "tagged_posts_$page",
      cacheDuration: const Duration(minutes: 5),
    );
  }
}
