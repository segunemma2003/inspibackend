import 'package:flutter/material.dart';
import '/config/decoders.dart';
import '/app/services/auth_service.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SearchApiService extends NyApiService {
  SearchApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'https://api.inspirtag.com/api');

  @override
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    print('🌐 SearchApiService: Setting auth headers...');
    final authHeaders = await AuthService.instance.getAuthHeaders();
    print('🌐 SearchApiService: Auth headers received: $authHeaders');
    headers.addAll(authHeaders);
    print('🌐 SearchApiService: Final headers: ${headers.toString()}');
    return headers;
  }

  /// Search posts, users, or tags
  Future<Map<String, dynamic>?> search({
    required String query,
    String? type, // posts, users, tags
    int perPage = 20,
    int page = 1,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/search", queryParameters: {
        "q": query,
        if (type != null) "type": type,
        "per_page": perPage,
        "page": page,
      }),
      cacheKey: "search_${query}_${type ?? 'all'}_$page",
      cacheDuration: const Duration(minutes: 3),
    );
  }

  /// Get list of available interests
  Future<List<String>?> getInterests() async {
    return await network<List<String>>(
      request: (request) => request.get("/interests"),
      cacheKey: "interests_list",
      cacheDuration: const Duration(hours: 1),
    );
  }
}
