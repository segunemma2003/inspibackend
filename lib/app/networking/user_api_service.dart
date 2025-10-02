import 'package:flutter/material.dart';
import '/config/decoders.dart';
import '/app/services/auth_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/user.dart';

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

  /// Get user profile by ID
  Future<User?> getUserProfile(int userId) async {
    return await network<User>(
      request: (request) => request.get("/users/$userId"),
      cacheKey: "user_profile_$userId",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Update user profile
  Future<User?> updateProfile({
    String? fullName,
    String? username,
    String? bio,
    String? profession,
    String? profilePicture,
    List<String>? interests,
  }) async {
    return await network<User>(
      request: (request) => request.put("/users/profile", data: {
        if (fullName != null) "full_name": fullName,
        if (username != null) "username": username,
        if (bio != null) "bio": bio,
        if (profession != null) "profession": profession,
        if (profilePicture != null) "profile_picture": profilePicture,
        if (interests != null) "interests": interests,
      }),
    );
  }

  /// Follow a user
  Future<Map<String, dynamic>?> followUser(int userId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/users/$userId/follow"),
    );
  }

  /// Unfollow a user
  Future<Map<String, dynamic>?> unfollowUser(int userId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/users/$userId/unfollow"),
    );
  }

  /// Get user followers
  Future<Map<String, dynamic>?> getUserFollowers({
    required int userId,
    int page = 1,
    int perPage = 20,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) =>
          request.get("/users/$userId/followers", queryParameters: {
        "page": page,
        "per_page": perPage,
      }),
      cacheKey: "user_followers_${userId}_$page",
      cacheDuration: const Duration(minutes: 3),
    );
  }

  /// Get user following
  Future<Map<String, dynamic>?> getUserFollowing({
    required int userId,
    int page = 1,
    int perPage = 20,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) =>
          request.get("/users/$userId/following", queryParameters: {
        "page": page,
        "per_page": perPage,
      }),
      cacheKey: "user_following_${userId}_$page",
      cacheDuration: const Duration(minutes: 3),
    );
  }

  /// Get interests list
  Future<List<String>?> getInterests() async {
    return await network<List<String>>(
      request: (request) => request.get("/interests"),
      cacheKey: "interests_list",
      cacheDuration: const Duration(hours: 1),
    );
  }

  /// Search users by interests
  Future<Map<String, dynamic>?> searchUsersByInterests({
    required List<String> interests,
    int perPage = 20,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/users/search/interests", data: {
        "interests": interests,
        "per_page": perPage,
      }),
      cacheKey: "users_by_interests_${interests.join('_')}",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Search users by profession
  Future<Map<String, dynamic>?> searchUsersByProfession({
    required String profession,
    String? username,
    int perPage = 20,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/users/search/profession", data: {
        "profession": profession,
        if (username != null) "username": username,
        "per_page": perPage,
      }),
      cacheKey: "users_by_profession_${profession}_${username ?? 'all'}",
      cacheDuration: const Duration(minutes: 5),
    );
  }
}
