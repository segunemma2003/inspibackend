import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/auth_api_service.dart';
import '/app/models/user.dart';
import '/app/services/auth_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static Future<User?> getCurrentUserWithFallback() async {
    try {
      print('🔍 UserService: Getting current user...');

      final cachedUser = await AuthService.instance.getUserProfile();
      if (cachedUser != null) {
        print(
            '✅ UserService: Found cached user: ${cachedUser['name'] ?? cachedUser['full_name']}');
        return User.fromJson(cachedUser);
      }

      print('⚠️ UserService: No cached user found, fetching from API...');

      final response = await api<AuthApiService>(
        (request) => request.getCurrentUser(),
      );

      if (response != null) {
        print('✅ UserService: API returned user data');

        User? user;
        if (response is User) {
          user = response;
        } else if (response is Map<String, dynamic>) {
          if (response.containsKey('data') &&
              response['data'] is Map<String, dynamic>) {
            final data = response['data'];
            if (data.containsKey('user') &&
                data['user'] is Map<String, dynamic>) {
              user = User.fromJson(data['user']);
            } else {
              user = User.fromJson(data);
            }
          } else if (response.containsKey('user') &&
              response['user'] is Map<String, dynamic>) {
            user = User.fromJson(response['user']);
          } else {
            user = User.fromJson(response);
          }
        }

        if (user != null) {
          print('✅ UserService: Successfully created user: ${user.fullName}');

          await AuthService.instance.updateUserProfile(user.toJson());
          return user;
        }
      }

      print('❌ UserService: Failed to get user from API');
      return null;
    } catch (e) {
      print('❌ UserService: Error getting current user: $e');
      return null;
    }
  }

  static Future<bool> isUserAuthenticated() async {
    try {
      final token = await AuthService.instance.getToken();
      if (token == null || token.isEmpty) {
        print('❌ UserService: No token found');
        await _handleUnauthenticatedUser();
        return false;
      }

      final user = await getCurrentUserWithFallback();
      if (user == null) {
        print('❌ UserService: Failed to get user data, token may be invalid');
        await _handleUnauthenticatedUser();
        return false;
      }

      return true;
    } catch (e) {
      print('❌ UserService: Error checking authentication: $e');
      await _handleUnauthenticatedUser();
      return false;
    }
  }

  static Future<void> _handleUnauthenticatedUser() async {
    try {
      print('🚪 UserService: Handling unauthenticated user...');

      await AuthService.instance.logout();

      routeTo('/sign-in');
    } catch (e) {
      print('❌ UserService: Error handling unauthenticated user: $e');

      routeTo('/sign-in');
    }
  }

  static Future<User?> refreshCurrentUser() async {
    try {
      print('🔄 UserService: Force refreshing user data...');

      await AuthService.instance.clearAuth();

      return await getCurrentUserWithFallback();
    } catch (e) {
      print('❌ UserService: Error refreshing user: $e');
      return null;
    }
  }

  static Future<User?> getCurrentUserWithAuthCheck() async {
    try {

      final isAuthenticated = await isUserAuthenticated();
      if (!isAuthenticated) {
        return null; // User will be redirected to sign-in
      }

      return await getCurrentUserWithFallback();
    } catch (e) {
      print('❌ UserService: Error in auth check: $e');
      await _handleUnauthenticatedUser();
      return null;
    }
  }

  static Future<bool> isTokenValid() async {
    try {
      final token = await AuthService.instance.getToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await api<AuthApiService>(
        (request) => request.getCurrentUser(),
      );

      return response != null;
    } catch (e) {
      print('❌ UserService: Token validation failed: $e');
      return false;
    }
  }
}
