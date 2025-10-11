import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/user.dart';
import '/app/services/auth_service.dart';
import '/config/decoders.dart';

class UserApiService extends NyApiService {
  UserApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'https://api.inspirtag.com/api');

  @override
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    print('🌐 UserApiService: Setting auth headers...');
    final authHeaders = await AuthService.instance.getAuthHeaders();
    print('🌐 UserApiService: Auth headers received: $authHeaders');
    headers.addAll(authHeaders);
    print('🌐 UserApiService: Final headers: ${headers.toString()}');
    return headers;
  }

  /// Get paginated list of users
  Future<Map<String, dynamic>?> getUsers({
    String? query,
    int perPage = 20,
    int page = 1,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/users", queryParameters: {
        if (query != null) "q": query,
        "per_page": perPage,
        "page": page,
      }),
      cacheKey: "users_${query ?? 'all'}_${page}",
      cacheDuration: const Duration(minutes: 3),
    );
  }

  /// Get specific user by ID
  Future<User?> getUser(int userId) async {
    return await network<User>(
      request: (request) => request.get("/users/$userId"),
      cacheKey: "user_$userId",
      cacheDuration: const Duration(minutes: 10),
    );
  }

  /// Update user profile
  Future<User?> updateProfile({
    String? fullName,
    String? username,
    String? bio,
    String? profession,
    List<String>? interests,
    File? profilePicture,
  }) async {
    final formData = FormData();

    if (fullName != null) formData.fields.add(MapEntry('full_name', fullName));
    if (username != null) formData.fields.add(MapEntry('username', username));
    if (bio != null) formData.fields.add(MapEntry('bio', bio));
    if (profession != null)
      formData.fields.add(MapEntry('profession', profession));
    if (interests != null) {
      for (String interest in interests) {
        formData.fields.add(MapEntry('interests[]', interest));
      }
    }
    if (profilePicture != null) {
      formData.files.add(MapEntry(
          'profile_picture',
          MultipartFile.fromFileSync(profilePicture.path,
              filename: 'profile.jpg')));
    }

    return await network<User>(
      request: (request) => request.put("/users/profile", data: formData),
      cacheKey: "user_profile",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Follow a user
  Future<Map<String, dynamic>?> followUser(int userId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/users/$userId/follow"),
      cacheKey: "follow_$userId",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Unfollow a user
  Future<Map<String, dynamic>?> unfollowUser(int userId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/users/$userId/unfollow"),
      cacheKey: "unfollow_$userId",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Get user followers
  Future<Map<String, dynamic>?> getUserFollowers(
    int userId, {
    int perPage = 20,
    int page = 1,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) =>
          request.get("/users/$userId/followers", queryParameters: {
        "per_page": perPage,
        "page": page,
      }),
      cacheKey: "followers_$userId" + "_$page",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Get user following
  Future<Map<String, dynamic>?> getUserFollowing(
    int userId, {
    int perPage = 20,
    int page = 1,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) =>
          request.get("/users/$userId/following", queryParameters: {
        "per_page": perPage,
        "page": page,
      }),
      cacheKey: "following_$userId" + "_$page",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Search users by interests
  Future<Map<String, dynamic>?> searchUsersByInterests({
    required List<String> interests,
    int perPage = 20,
    int page = 1,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/users/search/interests", data: {
        "interests": interests,
        "per_page": perPage,
        "page": page,
      }),
      cacheKey: "search_interests_${interests.join('_')}_$page",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Search users by profession
  Future<Map<String, dynamic>?> searchUsersByProfession({
    required String profession,
    String? username,
    int perPage = 20,
    int page = 1,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/users/search/profession", data: {
        "profession": profession,
        if (username != null) "username": username,
        "per_page": perPage,
        "page": page,
      }),
      cacheKey: "search_profession_$profession" + "_$page",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Get available interests
  Future<List<String>?> getInterests() async {
    final response = await network<Map<String, dynamic>>(
      request: (request) => request.get("/interests"),
      cacheKey: "interests_list",
      cacheDuration: const Duration(hours: 1),
    );

    if (response != null && response['success'] == true) {
      return List<String>.from(response['data'] ?? []);
    }
    return null;
  }
}
