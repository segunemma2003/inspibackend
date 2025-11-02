import 'package:nylo_framework/nylo_framework.dart';

class ApiConfig {
  static String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'https://api.inspirtag.com/api');

  static const Duration connectTimeout = Duration(seconds: 30); // 30 seconds
  static const Duration receiveTimeout = Duration(seconds: 30); // 30 seconds

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';

  static const String userProfile = '/users/me';
  static const String updateProfile = '/users/update-profile';
  static const String changePassword = '/users/change-password';

  static const String createPost = '/posts';
  static const String getFeed = '/posts/feed';
  static const String likePost = '/posts/{id}/like';
  static const String commentOnPost = '/posts/{id}/comments';

  static const String followUser = '/users/{userId}/follow';
  static const String unfollowUser = '/users/{userId}/unfollow';

  static const String getNotifications = '/notifications';
  static const String markNotificationAsRead = '/notifications/{id}/read';

  static const String uploadMedia = '/upload';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static String buildUrl(String path, {Map<String, dynamic>? params}) {
    String url = path;
    if (params != null) {
      params.forEach((key, value) {
        url = url.replaceAll('{$key}', value.toString());
      });
    }
    return url;
  }
}
