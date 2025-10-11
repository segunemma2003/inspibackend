import 'package:flutter/material.dart';
import '/config/decoders.dart';
import '/app/services/auth_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/category.dart';

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
    final response = await network<Map<String, dynamic>>(
      request: (request) => request.get("/categories"),
      cacheKey: "categories_list",
      cacheDuration: const Duration(hours: 1),
    );

    if (response != null && response['success'] == true) {
      final List<dynamic> categoriesData = response['data'] ?? [];
      return categoriesData.map((json) => Category.fromJson(json)).toList();
    }

    return null;
  }

  /// Create category (Admin only)
  Future<Category?> createCategory({
    required String name,
    required String description,
    required String color,
    required String icon,
  }) async {
    return await network<Category>(
      request: (request) => request.post("/categories", data: {
        "name": name,
        "description": description,
        "color": color,
        "icon": icon,
      }),
    );
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
    return await network<Category>(
      request: (request) => request.put("/categories/$categoryId", data: {
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (color != null) "color": color,
        if (icon != null) "icon": icon,
        if (isActive != null) "is_active": isActive,
      }),
    );
  }

  /// Delete category (Admin only)
  Future<Map<String, dynamic>?> deleteCategory(int categoryId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/categories/$categoryId"),
    );
  }
}
