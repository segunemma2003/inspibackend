import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/user.dart';
import 'package:flutter_app/config/decoders.dart';
import 'package:flutter_app/app/networking/dio/interceptors/bearer_auth_interceptor.dart';
import 'dart:convert'; // Added for jsonDecode

class UserApiService extends NyApiService {
  UserApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'https://api.inspirtag.com/api');

  @override
  Map<Type, Interceptor> get interceptors => {
        BearerAuthInterceptor: BearerAuthInterceptor(),
      };

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
      cacheKey: "users_${query ?? 'all'}_$page",
      cacheDuration: const Duration(minutes: 3),
    );
  }

  Future<User?> getUser(int userId) async {
    print('👤 UserApiService: Getting user with ID: $userId');
    final result = await network<User>(
      request: (request) => request.get("/users/$userId"),
      cacheKey: "user_$userId",
      cacheDuration: const Duration(minutes: 10),
    );
    print('👤 UserApiService: getUser result: $result');
    return result;
  }

  Future<User?> fetchCurrentUser() async {
    try {
      print('👤 UserApiService: Fetching current user profile...');

      final response = await network<Map<String, dynamic>>(
        request: (request) => request.get("/me"), // Corrected endpoint to /me
      );

      print('👤 UserApiService: Profile response: $response');

      if (response != null && response['success'] == true) {
        final userData = response['data']; // Access the nested 'user' object
        if (userData != null) {
          return User.fromJson(userData);
        }
      }

      return null;
    } catch (e) {
      print('❌ UserApiService: Error fetching current user: $e');
      rethrow;
    }
  }

  Future<User?> updateProfile({
    String? fullName,
    String? username,
    String? bio,
    String? profession,
    List<String>? interests,
    File? profilePicture,
  }) async {
    try {
      print('👤 UserApiService: Updating profile...');
      print('👤 UserApiService: fullName: $fullName');
      print('👤 UserApiService: username: $username');
      print('👤 UserApiService: bio: $bio');
      print('👤 UserApiService: profession: $profession');
      print('👤 UserApiService: interests: $interests');

      final data = <String, dynamic>{};

      if (fullName != null)
        data['full_name'] = fullName; // Changed 'name' to 'full_name'
      if (username != null) data['username'] = username;
      if (bio != null) data['bio'] = bio;
      if (profession != null) data['profession'] = profession;

      if (profilePicture != null) {
        final formData = FormData.fromMap(data); // Start with existing data
        if (interests != null && interests.isNotEmpty) {
          for (var interest in interests) {
            formData.files.add(MapEntry(
              'interests[]', // Use array notation for interests
              MultipartFile.fromString(interest),
            ));
          }
        }
        formData.files.add(MapEntry(
          'profile_picture',
          await MultipartFile.fromFile(
            profilePicture.path,
            filename: 'profile.jpg',
          ),
        ));

        final rawResponse = await network<dynamic>(
          request: (request) => request.post("/users/profile", data: formData),
        );

        print(
            '👤 UserApiService.updateProfile (FormData): Raw API Response: $rawResponse');

        if (rawResponse == null) {
          print(
              '👤 UserApiService.updateProfile (FormData): Raw response is null.');
          return null;
        }

        final response = _parseApiResponse(rawResponse, 'updateProfile');

        print(
            '👤 UserApiService.updateProfile (FormData): Parsed Response: $response');

        if (response != null && response['success'] == true) {
          final userData =
              response['data']; // Access the user object directly under 'data'
          if (userData != null) {
            print(
                '👤 UserApiService.updateProfile (FormData): Extracted User Data before fromJson: $userData');
            User? user = User.fromJson(userData);
            print(
                '👤 UserApiService.updateProfile (FormData): User object after fromJson: $user');
            return user;
          }
        } else {
          print(
              '👤 UserApiService.updateProfile (FormData): Response not successful or userData is null.');
        }
        return null;
      }

      final rawResponse = await network<dynamic>(
        request: (request) => request.post("/users/profile",
            data: data
              ..remove('profile_picture')
              ..['interests'] =
                  interests), // Pass interests as List<String> for JSON
      );

      print(
          '👤 UserApiService.updateProfile (JSON): Raw API Response: $rawResponse');

      if (rawResponse == null) {
        print('👤 UserApiService.updateProfile (JSON): Raw response is null.');
        return null;
      }

      final response = _parseApiResponse(rawResponse, 'updateProfile');

      print('👤 UserApiService: Update response: $response');

      print(
          '👤 UserApiService.updateProfile (JSON): Parsed Response: $response');

      if (response != null && response['success'] == true) {
        final userData =
            response['data']; // Access the user object directly under 'data'
        if (userData != null) {
          print(
              '👤 UserApiService.updateProfile (JSON): Extracted User Data before fromJson: $userData');
          User? user = User.fromJson(userData);
          print(
              '👤 UserApiService.updateProfile (JSON): User object after fromJson: $user');
          return user;
        }
      } else {
        print(
            '👤 UserApiService.updateProfile (JSON): Response not successful or userData is null.');
      }

      return null;
    } catch (e) {
      print('❌ UserApiService: Error updating profile: $e');
      rethrow;
    }
  }

  Map<String, dynamic>? _parseApiResponse(
      dynamic rawResponse, String methodName) {
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
                  '🐛 UserApiService.$methodName: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 UserApiService.$methodName: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 UserApiService.$methodName: Fixed and merged JSON: $mergedJson');
            return mergedJson;
          } else {
            print(
                '🐛 UserApiService.$methodName: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 UserApiService.$methodName: Error fixing concatenated JSON: $e');
        }
      }
      try {
        return jsonDecode(rawResponse) as Map<String, dynamic>;
      } catch (e) {
        print(
            '🐛 UserApiService.$methodName: Failed to decode plain string response as JSON: $e');
        return {
          "success": false,
          "message": "Failed to parse server response after initial attempt."
        };
      }
    } else if (rawResponse is Map<String, dynamic>) {
      return rawResponse;
    }
    return {
      "success": false,
      "message": "Unexpected response format from server."
    };
  }

  Future<Map<String, dynamic>?> followUser(int userId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/users/$userId/follow"),
    );
  }

  Future<Map<String, dynamic>?> unfollowUser(int userId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/users/$userId/unfollow"),
    );
  }

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
      cacheKey: "followers_${userId}_$page",
      cacheDuration: const Duration(minutes: 5),
    );
  }

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
      cacheKey: "following_${userId}_$page",
      cacheDuration: const Duration(minutes: 5),
    );
  }

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
      cacheKey: "search_profession_${profession}_$page",
      cacheDuration: const Duration(minutes: 5),
    );
  }

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
