import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/config/decoders.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/app/models/category.dart';
import 'dart:convert';

class CategoryApiService extends NyApiService {
  CategoryApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'https://api.inspirtag.com/api');

  @override
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    print('🌐 CategoryApiService: Setting auth headers...');
    final authHeaders = await AuthService.instance.getAuthHeaders();
    print('🌐 CategoryApiService: Auth headers received: $authHeaders');
    headers.addAll(authHeaders);
    print('🌐 CategoryApiService: Final headers: ${headers.toString()}');
    return headers;
  }

  /// Get all categories
  Future<List<Category>?> getCategories() async {
    print('🌐 CategoryApiService: Starting getCategories request...');
    final rawResponse = await network<dynamic>(
      request: (request) => request.get("/categories"),
      cacheKey: "categories_list",
      cacheDuration: const Duration(hours: 1),
    );

    print('🌐 CategoryApiService: Raw response received: $rawResponse');
    if (rawResponse == null) {
      print('🌐 CategoryApiService: Raw response is null');
      return null;
    }

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
                  '🐛 CategoryApiService.getCategories: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 CategoryApiService.getCategories: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 CategoryApiService.getCategories: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 CategoryApiService.getCategories: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 CategoryApiService.getCategories: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 CategoryApiService.getCategories: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }

    if (response != null && response['success'] == true) {
      final List<dynamic> categoriesData = response['data'] ?? [];
      print(
          '🌐 CategoryApiService: Found ${categoriesData.length} categories in response');
      final categories =
          categoriesData.map((json) => Category.fromJson(json)).toList();
      print(
          '🌐 CategoryApiService: Parsed ${categories.length} categories successfully');
      return categories;
    }

    print('🌐 CategoryApiService: Response not successful or null');
    return null;
  }

  /// Create category (Admin only)
  Future<Category?> createCategory({
    required String name,
    required String description,
    required String color,
    required String icon,
  }) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.post("/categories", data: {
        "name": name,
        "description": description,
        "color": color,
        "icon": icon,
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
                  '🐛 CategoryApiService.createCategory: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 CategoryApiService.createCategory: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 CategoryApiService.createCategory: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 CategoryApiService.createCategory: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 CategoryApiService.createCategory: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 CategoryApiService.createCategory: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }

    if (response != null && response['success'] == true) {
      return Category.fromJson(response['data']);
    }

    return null;
  }

  /// Update category (Admin only)
  Future<Category?> updateCategory({
    required int categoryId,
    String? name,
    String? description,
    String? color,
    String? icon,
    bool? isActive,
  }) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.put("/categories/$categoryId", data: {
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (color != null) "color": color,
        if (icon != null) "icon": icon,
        if (isActive != null) "is_active": isActive,
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
                  '🐛 CategoryApiService.updateCategory: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 CategoryApiService.updateCategory: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 CategoryApiService.updateCategory: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 CategoryApiService.updateCategory: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 CategoryApiService.updateCategory: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 CategoryApiService.updateCategory: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }

    if (response != null && response['success'] == true) {
      return Category.fromJson(response['data']);
    }

    return null;
  }

  /// Delete category (Admin only)
  Future<Map<String, dynamic>?> deleteCategory(int categoryId) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.delete("/categories/$categoryId"),
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
                  '🐛 CategoryApiService.deleteCategory: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 CategoryApiService.deleteCategory: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 CategoryApiService.deleteCategory: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 CategoryApiService.deleteCategory: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 CategoryApiService.deleteCategory: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 CategoryApiService.deleteCategory: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }
}
