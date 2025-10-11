import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/auth_api_service.dart';
import '/app/models/user.dart';
import '/app/services/auth_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  /// Get current user with fallback to API
  static Future<User?> getCurrentUserWithFallback() async {
    try {
      print('🔍 UserService: Getting current user...');

      // First try to get from cache
      final cachedUser = await AuthService.instance.getUserProfile();
      if (cachedUser != null) {
        print(
            '✅ UserService: Found cached user: ${cachedUser['name'] ?? cachedUser['full_name']}');
        return User.fromJson(cachedUser);
      }

      print('⚠️ UserService: No cached user found, fetching from API...');

      // If no cached user, fetch from API using token
      final response = await api<AuthApiService>(
        (request) => request.getCurrentUser(),
      );

      if (response != null) {
        print('✅ UserService: API returned user data');

        // Handle different response structures
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
          // Update cache with fresh data
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

  /// Check if user is authenticated and has valid data
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

  /// Handle unauthenticated user - logout and redirect to sign-in
  static Future<void> _handleUnauthenticatedUser() async {
    try {
      print('🚪 UserService: Handling unauthenticated user...');

      // Clear all auth data
      await AuthService.instance.logout();

      // User will be redirected to sign-in page

      // Redirect to sign-in page
      routeTo('/sign-in');
    } catch (e) {
      print('❌ UserService: Error handling unauthenticated user: $e');
      // Force redirect even if there's an error
      routeTo('/sign-in');
    }
  }

  /// Force refresh user data from API
  static Future<User?> refreshCurrentUser() async {
    try {
      print('🔄 UserService: Force refreshing user data...');

      // Clear cache first
      await AuthService.instance.clearAuth();

      // Fetch fresh data
      return await getCurrentUserWithFallback();
    } catch (e) {
      print('❌ UserService: Error refreshing user: $e');
      return null;
    }
  }

  /// Validate token and get current user with automatic logout on failure
  static Future<User?> getCurrentUserWithAuthCheck() async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await isUserAuthenticated();
      if (!isAuthenticated) {
        return null; // User will be redirected to sign-in
      }

      // Get current user
      return await getCurrentUserWithFallback();
    } catch (e) {
      print('❌ UserService: Error in auth check: $e');
      await _handleUnauthenticatedUser();
      return null;
    }
  }

  /// Check if token is valid by making a test API call
  static Future<bool> isTokenValid() async {
    try {
      final token = await AuthService.instance.getToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      // Make a simple API call to validate token
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
