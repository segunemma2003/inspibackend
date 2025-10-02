import 'package:nylo_framework/nylo_framework.dart';

/// Authentication Service
/// Handles user authentication, session management, and token storage
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await Auth.isAuthenticated();
  }

  /// Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final isAuth = await isAuthenticated();
    print('🔑 AuthService: isAuthenticated() = $isAuth');
    if (!isAuth) return null;
    final authData = await Auth.data();
    print('🔑 AuthService: Auth.data() returned: $authData');
    return authData;
  }

  /// Get authentication token
  Future<String?> getToken() async {
    final authData = await getCurrentUser();
    print('🔑 AuthService: getCurrentUser() returned: $authData');
    final token = authData?['token'];
    print('🔑 AuthService: Extracted token: $token');
    return token;
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    final authData = await getCurrentUser();
    return authData?['user'];
  }

  /// Check if token is expired (optional - depends on your backend)
  Future<bool> isTokenExpired() async {
    final authData = await getCurrentUser();
    if (authData == null) return true;

    final authenticatedAt = authData['authenticated_at'];
    if (authenticatedAt == null) return true;

    final authTime = DateTime.parse(authenticatedAt);
    final now = DateTime.now();

    // Token expires after 24 hours (adjust as needed)
    return now.difference(authTime).inHours > 24;
  }

  /// Refresh authentication if needed
  Future<bool> refreshAuthIfNeeded() async {
    if (await isTokenExpired()) {
      await logout();
      return false;
    }
    return true;
  }

  /// Logout user
  Future<void> logout() async {
    await Auth.logout();
  }

  /// Get headers for API requests
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

  /// Update user profile data
  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    final authData = await getCurrentUser();
    if (authData != null) {
      authData['user'] = userData;
      await Auth.authenticate(data: authData);
    }
  }

  /// Clear all authentication data
  Future<void> clearAuth() async {
    await Auth.logout();
  }
}
