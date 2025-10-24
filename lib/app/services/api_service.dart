import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/networking/api_config.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: ApiConfig.headers,
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Handle 401 Unauthorized
        if (e.response?.statusCode == 401) {
          // If token exists but still unauthorized, logout user
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            await logout();
          }
          // Try to refresh token
          try {
            await _refreshToken();
            // Retry the original request
            return handler.resolve(await _retry(e.requestOptions));
          } catch (e) {
            // If refresh fails, redirect to login
            // You can use a global key or event bus to handle this
            return handler.reject(e as DioException);
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<void> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      final response = await _dio.post(
        ApiConfig.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        await prefs.setString('auth_token', newToken);
        if (newRefreshToken != null) {
          await prefs.setString('refresh_token', newRefreshToken);
        }
      }
    } catch (e) {
      // Clear auth data if refresh fails
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      rethrow;
    }
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      ApiConfig.login,
      data: {'email': email, 'password': password},
    );

    // Save tokens
    if (response.data['access_token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response.data['access_token']);
      await prefs.setString('refresh_token', response.data['refresh_token']);
    }

    return response.data;
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      // Clear auth data regardless of API call result
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
    }
  }

  // User
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await _dio.get(ApiConfig.userProfile);
    return response.data;
  }

  // Posts
  Future<List<dynamic>> getFeed({int page = 1, int limit = 10}) async {
    final response = await _dio.get(
      ApiConfig.getFeed,
      queryParameters: {'page': page, 'limit': limit},
    );
    return response.data['data'];
  }

  Future<Map<String, dynamic>> createPost(String content,
      {List<String>? mediaUrls}) async {
    final response = await _dio.post(
      ApiConfig.createPost,
      data: {
        'content': content,
        if (mediaUrls != null) 'media_urls': mediaUrls,
      },
    );
    return response.data;
  }

  // Upload
  Future<List<String>> uploadMedia(List<String> filePaths) async {
    final formData = FormData();

    for (var filePath in filePaths) {
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(filePath),
        ),
      );
    }

    final response = await _dio.post(
      ApiConfig.uploadMedia,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    return List<String>.from(response.data['urls']);
  }
}
