import '/app/services/auth_service.dart';
import 'package:nylo_framework/nylo_framework.dart';

class BearerAuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Get token from AuthService instead of Keys.auth
      final token = await AuthService.instance.getToken();
      if (token != null) {
        options.headers.addAll({"Authorization": "Bearer $token"});
        print('🔑 BearerAuthInterceptor: Added token to request: $token');
        print(
            '🔑 BearerAuthInterceptor: Full headers being sent: ${options.headers}');
      } else {
        print('🔑 BearerAuthInterceptor: No token found');
      }
    } catch (e) {
      print('🔑 BearerAuthInterceptor: Error getting token: $e');
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      print('🔑 BearerAuthInterceptor: 401 Unauthorized error detected');

      try {
        // If server returns 401, the token is invalid/expired regardless of client-side check
        // Log out the user immediately to force re-authentication
        print(
            '🔑 BearerAuthInterceptor: Server rejected token, logging out user');
        await AuthService.instance.logout();
      } catch (e) {
        print('🔑 BearerAuthInterceptor: Error during logout: $e');
      }
    }

    handler.next(err);
  }
}
