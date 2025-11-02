import 'package:nylo_framework/nylo_framework.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:async'; // Added for StreamController

import '../../resources/pages/sign_in_page.dart'; // Used for routeTo after logout
import '/app/services/firebase_messaging_service.dart'; // For device registration

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _authTokenKey = 'authToken';
  static const String _authUserDataKey = 'authUserData';
  static const String _authAuthenticatedAtKey = 'authenticated_at';
  final StreamController<void> _authStateChangeController =
      StreamController<void>.broadcast();
  Stream<void> get authStateChanges => _authStateChangeController.stream;

  Future<void> storeAuthData(Map<String, dynamic> data) async {
    final token = data['token'];
    final user = data['user'];
    final authenticatedAt = data['authenticated_at'];
    print('🔑 AuthService.storeAuthData: Attempting to store:');
    print('  - Token: $token');
    print('  - User Data: ${jsonEncode(user)}');
    print('  - Authenticated At: $authenticatedAt');

    if (token != null) {
      await _secureStorage.write(key: _authTokenKey, value: token);
      print(
          '🔑 AuthService: Successfully wrote token to secure storage: $token');
      String? storedToken = await _secureStorage.read(key: _authTokenKey);
      print('🔑 AuthService: Immediately read back token: $storedToken');
    }
    if (user != null) {
      await _secureStorage.write(
          key: _authUserDataKey, value: jsonEncode(user));
      print(
          '🔑 AuthService: Successfully wrote user data to secure storage: ${jsonEncode(user)}');
      String? storedUserJson = await _secureStorage.read(key: _authUserDataKey);
      print('🔑 AuthService: Immediately read back user data: $storedUserJson');
    }
    if (authenticatedAt != null) {
      await _secureStorage.write(
          key: _authAuthenticatedAtKey, value: authenticatedAt);
      print(
          '🔑 AuthService: Successfully wrote authenticated_at to secure storage: $authenticatedAt');
      String? storedAuthenticatedAt =
          await _secureStorage.read(key: _authAuthenticatedAtKey);
      print(
          '🔑 AuthService: Immediately read back authenticated_at: $storedAuthenticatedAt');
    }

    _authStateChangeController
        .add(null); // Notify listeners of auth state change
  }

  Future<Map<String, dynamic>?> retrieveAuthData() async {
    print(
        '🔑 AuthService.retrieveAuthData: Attempting to retrieve all auth data.');
    final token = await _secureStorage.read(key: _authTokenKey);
    final userJson = await _secureStorage.read(key: _authUserDataKey);
    final authenticatedAt =
        await _secureStorage.read(key: _authAuthenticatedAtKey);

    print('🔑 AuthService: Raw retrieved token from secure storage: $token');
    print(
        '🔑 AuthService: Raw retrieved userJson from secure storage: $userJson');
    print(
        '🔑 AuthService: Raw retrieved authenticated_at from secure storage: $authenticatedAt');
    print(
        '🔑 AuthService.retrieveAuthData: After reading from secure storage:');
    print('  - Token: $token');
    print('  - UserJson: $userJson');
    print('  - Authenticated At: $authenticatedAt');

    if (token == null) return null;

    Map<String, dynamic>? userData;
    if (userJson != null) {
      try {
        userData = jsonDecode(userJson) as Map<String, dynamic>;
      } catch (e) {
        print(
            '🔑 AuthService: Failed to decode user data from secure storage: $e');
      }
    }

    return {
      'token': token,
      'user': userData,
      'authenticated_at': authenticatedAt,
    };
  }

  Future<bool> isAuthenticated() async {
    final authData = await retrieveAuthData();
    return authData != null && authData['token'] != null;
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    return await retrieveAuthData();
  }

  Future<String?> getToken() async {
    final authData = await retrieveAuthData();
    return authData?['token'];
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final authData = await getCurrentUser();
    return authData?['user'];
  }

  Future<bool> isTokenExpired() async {
    final authData = await getCurrentUser();
    if (authData == null) return true;

    final authenticatedAt = authData['authenticated_at'];
    if (authenticatedAt == null) return true;

    final authTime = DateTime.parse(authenticatedAt);
    final now = DateTime.now();

    return now.difference(authTime).inHours > 24;
  }

  Future<bool> refreshAuthIfNeeded() async {
    if (await isTokenExpired()) {
      await logout();
      return false;
    }
    return true;
  }

  Future<void> logout() async {
    await clearAuth();
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    print('🔑 AuthService: Getting token: $token');

    if (token == null) {
      print('❌ AuthService: No token found');
      return {};
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    print('🔑 AuthService: Headers: $headers');
    return headers;
  }

  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    final authData = await getCurrentUser();
    if (authData != null) {
      authData['user'] = userData;
      await storeAuthData(authData); // Store updated user data
      _authStateChangeController
          .add(null); // Notify listeners of auth state change
    }
  }

  Future<void> clearAuth() async {
    await _secureStorage.delete(key: _authTokenKey);
    print('🔑 AuthService: Attempted to delete authToken key.');
    await _secureStorage.delete(key: _authUserDataKey);
    print('🔑 AuthService: Attempted to delete authUserData key.');
    await _secureStorage.delete(key: _authAuthenticatedAtKey);
    print('🔑 AuthService: Attempted to delete authenticated_at key.');
    print('🔑 AuthService: Cleared all authentication data.');
    _authStateChangeController
        .add(null); // Notify listeners of auth state change
    routeTo(SignInPage.path,
        navigationType:
            NavigationType.pushAndForgetAll); // Redirect to sign-in page
  }
}

class CustomAuth extends Auth {
  Future<bool> authenticate({Map<String, dynamic>? data}) async {
    if (data != null) {
      await AuthService.instance.storeAuthData(data);

      try {
        await FirebaseMessagingService().registerDevice();
        print('📱 AuthService: Device registered for push notifications');
      } catch (e) {
        print('❌ AuthService: Failed to register device: $e');

      }

      return true;
    }
    return false;
  }

  Future<bool> logout() async {
    await AuthService.instance.clearAuth();
    return true;
  }

  Future<Map<String, dynamic>?> data() async {
    return await AuthService.instance.retrieveAuthData();
  }

  Future<bool> isAuthenticated() async {
    final authData = await AuthService.instance.retrieveAuthData();
    return authData != null &&
        authData['token'] !=
            null; // Re-implement isAuthenticated directly here to avoid circular dependency
  }
}

final Auth auth = CustomAuth();
