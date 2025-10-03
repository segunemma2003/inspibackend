import 'package:flutter/material.dart';
import '/config/decoders.dart';
import '/app/services/auth_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/user.dart';

class AuthApiService extends NyApiService {
  AuthApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'https://api.inspirtag.com/api');

  @override
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    print('🌐 AuthApiService: Setting auth headers...');
    final authHeaders = await AuthService.instance.getAuthHeaders();
    print('🌐 AuthApiService: Auth headers received: $authHeaders');
    headers.addAll(authHeaders);
    print('🌐 AuthApiService: Final headers: ${headers.toString()}');
    return headers;
  }

  /// Register a new user
  Future<Map<String, dynamic>?> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
    required bool termsAccepted,
    String? deviceToken,
    String? deviceType,
    String? deviceName,
    String? appVersion,
    String? osVersion,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/register", data: {
        "full_name": fullName,
        "email": email,
        "username": username,
        "password": password,
        "password_confirmation": passwordConfirmation,
        "terms_accepted": termsAccepted,
        if (deviceToken != null) "device_token": deviceToken,
        if (deviceType != null) "device_type": deviceType,
        if (deviceName != null) "device_name": deviceName,
        if (appVersion != null) "app_version": appVersion,
        if (osVersion != null) "os_version": osVersion,
      }),
      cacheKey: "register_${email}",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Login user
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
    String? deviceToken,
    String? deviceType,
    String? deviceName,
    String? appVersion,
    String? osVersion,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/login", data: {
        "email": email,
        "password": password,
        if (deviceToken != null) "device_token": deviceToken,
        if (deviceType != null) "device_type": deviceType,
        if (deviceName != null) "device_name": deviceName,
        if (appVersion != null) "app_version": appVersion,
        if (osVersion != null) "os_version": osVersion,
      }),
      cacheKey: "login_${email}",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Logout user
  Future<Map<String, dynamic>?> logout() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/logout"),
    );
  }

  /// Forgot password (request OTP)
  Future<Map<String, dynamic>?> forgotPassword({
    required String email,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/forgot-password", data: {
        "email": email,
      }),
      cacheKey: "forgot_password_${email}",
      cacheDuration: const Duration(minutes: 2),
    );
  }

  /// Reset password with OTP
  Future<Map<String, dynamic>?> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/reset-password", data: {
        "email": email,
        "token": token,
        "password": password,
        "password_confirmation": passwordConfirmation,
      }),
    );
  }

  /// Verify Firebase token and create/update user
  Future<Map<String, dynamic>?> verifyFirebaseToken({
    required String token,
    required String email,
    required String name,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/verify-firebase-token", data: {
        "firebase_token": token,
        "email": email,
        "name": name,
      }),
    );
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    return await network<User>(
      request: (request) => request.get("/me"),
      cacheKey: "current_user",
      cacheDuration: const Duration(minutes: 2),
    );
  }

  /// Delete account
  Future<Map<String, dynamic>?> deleteAccount() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/delete-account"),
    );
  }
}
