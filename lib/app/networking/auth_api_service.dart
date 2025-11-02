import 'package:flutter/material.dart';
import 'package:flutter_app/config/decoders.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/user.dart';
import 'package:flutter_app/app/networking/api_config.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'dart:convert'; // Added for jsonDecode
import '/app/networking/dio/interceptors/bearer_auth_interceptor.dart';

class AuthApiService extends NyApiService {
  AuthApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl => ApiConfig.baseUrl;

  @override
  get interceptors => {
        if (getEnv('APP_DEBUG') == true) PrettyDioLogger: PrettyDioLogger(),
        BearerAuthInterceptor: BearerAuthInterceptor(),
      };

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
    final rawResponse = await network<dynamic>(

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
    );

    if (rawResponse == null) return null;

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
                  '🐛 AuthApiService.register: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 AuthApiService.register: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 AuthApiService.register: Fixed and merged JSON: $mergedJson');
            return mergedJson;
          } else {
            print(
                '🐛 AuthApiService.register: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 AuthApiService.register: Error fixing concatenated JSON: $e');
        }
      }

      try {
        return jsonDecode(rawResponse) as Map<String, dynamic>;
      } catch (e) {
        print(
            '🐛 AuthApiService.register: Failed to decode plain string response as JSON: $e');
        return {
          "success": false,
          "message": "Failed to parse server response after initial attempt."
        }; // Return an error map
      }
    } else if (rawResponse is Map<String, dynamic>) {
      final String? token = rawResponse['data']?['token'];
      final Map<String, dynamic>? userJson = rawResponse['data']?['user'];
      if (token != null && userJson != null) {
        final Map<String, dynamic> authData = {
          'token': token,
          'user': userJson,
          'authenticated_at': DateTime.now().toIso8601String(),
        };
        print(
            '🔑 AuthApiService: Calling storeAuthData with authData: $authData');
      } else {}
      return rawResponse;
    }
    return {
      "success": false,
      "message": "Unexpected response format from server."
    };
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
    String? deviceToken,
    String? deviceType,
    String? deviceName,
    String? appVersion,
    String? osVersion,
  }) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.post("/login", data: {
        "email": email,
        "password": password,
        if (deviceToken != null) "device_token": deviceToken,
        if (deviceType != null) "device_type": deviceType,
        if (deviceName != null) "device_name": deviceName,
        if (appVersion != null) "app_version": appVersion,
        if (osVersion != null) "os_version": osVersion,
      }),
    );

    if (rawResponse == null) return null;

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
                  '🐛 AuthApiService.login: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 AuthApiService.login: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 AuthApiService.login: Fixed and merged JSON: $mergedJson');
            return mergedJson;
          } else {
            print(
                '🐛 AuthApiService.login: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print('🐛 AuthApiService.login: Error fixing concatenated JSON: $e');
        }
      }
      try {
        return jsonDecode(rawResponse) as Map<String, dynamic>;
      } catch (e) {
        print(
            '🐛 AuthApiService.login: Failed to decode plain string response as JSON: $e');
        return {
          "success": false,
          "message": "Failed to parse server response after initial attempt."
        };
      }
    } else if (rawResponse is Map<String, dynamic>) {
      final String? token = rawResponse['data']?['token'];
      final Map<String, dynamic>? userJson = rawResponse['data']?['user'];
      if (token != null && userJson != null) {
        final Map<String, dynamic> authData = {
          'token': token,
          'user': userJson,
          'authenticated_at': DateTime.now().toIso8601String(),
        };
        print(
            '🔑 AuthApiService: Calling storeAuthData with authData: $authData');
        await AuthService.instance.storeAuthData(authData);
      } else {

        await AuthService.instance.clearAuth();
      }
      return rawResponse;
    }
    return {
      "success": false,
      "message": "Unexpected response format from server."
    };
  }

  Future<Map<String, dynamic>?> logout() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/logout"),
    );
  }

  Future<Map<String, dynamic>?> forgotPassword({required String email}) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.post("/forgot-password", data: {
        "email": email,
      }),
    );

    if (rawResponse == null) return null;

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
                  '🐛 AuthApiService.forgotPassword: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 AuthApiService.forgotPassword: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 AuthApiService.forgotPassword: Fixed and merged JSON: $mergedJson');
            return mergedJson;
          } else {
            print(
                '🐛 AuthApiService.forgotPassword: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 AuthApiService.forgotPassword: Error fixing concatenated JSON: $e');
        }
      }
      try {
        return jsonDecode(rawResponse) as Map<String, dynamic>;
      } catch (e) {
        print(
            '🐛 AuthApiService.forgotPassword: Failed to decode plain string response as JSON: $e');
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

  Future<Map<String, dynamic>?> verifyOtp({
    required String email,
    required String otp,
    String? deviceToken,
    String? deviceType,
    String? deviceName,
    String? appVersion,
    String? osVersion,
  }) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.post("/verify-otp", data: {
        "email": email,
        "otp": otp,
        if (deviceToken != null) "device_token": deviceToken,
        if (deviceType != null) "device_type": deviceType,
        if (deviceName != null) "device_name": deviceName,
        if (appVersion != null) "app_version": appVersion,
        if (osVersion != null) "os_version": osVersion,
      }),
    );

    if (rawResponse == null) return null;

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
                  '🐛 AuthApiService.verifyOtp: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 AuthApiService.verifyOtp: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 AuthApiService.verifyOtp: Fixed and merged JSON: $mergedJson');
            return mergedJson;
          } else {
            print(
                '🐛 AuthApiService.verifyOtp: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 AuthApiService.verifyOtp: Error fixing concatenated JSON: $e');
        }
      }
      try {
        return jsonDecode(rawResponse) as Map<String, dynamic>;
      } catch (e) {
        print(
            '🐛 AuthApiService.verifyOtp: Failed to decode plain string response as JSON: $e');
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

  Future<Map<String, dynamic>?> resendOtp({
    required String email,
    required String type, // "registration" or "password_reset"
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/resend-otp", data: {
        "email": email,
        "type": type,
      }),
    );
  }

  Future<Map<String, dynamic>?> resetPassword({
    required String email,
    required String otp, // Changed from 'token' to 'otp'
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final rawResponse = await network<dynamic>(
        request: (request) => request.post("/reset-password", data: {
          "email": email,
          "otp": otp, // Changed from 'token' to 'otp'
          "password": password,
          "password_confirmation": passwordConfirmation,
        }),
      );

      if (rawResponse == null) {
        return {"success": false, "message": "Server returned no data."};
      }

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
                    '🐛 AuthApiService.resetPassword: Failed to decode first JSON part: $e');
              }
              try {
                secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
              } catch (e) {
                print(
                    '🐛 AuthApiService.resetPassword: Failed to decode second JSON part: $e');
              }

              Map<String, dynamic> mergedJson = {};
              mergedJson.addAll(firstJson);
              mergedJson.addAll(secondJson);
              print(
                  '🐛 AuthApiService.resetPassword: Fixed and merged JSON: $mergedJson');
              return mergedJson;
            } else {
              print(
                  '🐛 AuthApiService.resetPassword: Malformed but unhandled concatenated JSON format: $rawResponse');
            }
          } catch (e) {
            print(
                '🐛 AuthApiService.resetPassword: Error fixing concatenated JSON: $e');
          }
        }
        try {
          return jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 AuthApiService.resetPassword: Failed to decode plain string response as JSON: $e');
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
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {

        final errorResponse = e.response!.data;
        if (errorResponse is String) {
          try {
            return jsonDecode(errorResponse) as Map<String, dynamic>;
          } catch (jsonError) {
            print(
                '🐛 AuthApiService.resetPassword: Failed to decode DioException string response: $jsonError');
            return {"success": false, "message": errorResponse};
          }
        } else if (errorResponse is Map<String, dynamic>) {
          return errorResponse;
        }
      }
      print('🐛 AuthApiService.resetPassword: DioException: ${e.message}');
      return {
        "success": false,
        "message": e.message ?? "Network error occurred."
      };
    } catch (e) {
      print('🐛 AuthApiService.resetPassword: Generic error: $e');
      return {
        "success": false,
        "message": "An unknown error occurred: ${e.toString()}"
      };
    }
  }

  Future<Map<String, dynamic>?> verifyFirebaseToken({
    required String token,
    required String provider,
    required String email,
    required String name,
  }) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.post("/verify-firebase-token", data: {
        "firebase_token": token,
        "email": email,
        "provider": provider,
        "name": name,
      }),
    );

    if (rawResponse == null) return null;

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
                  '🐛 AuthApiService.verifyFirebaseToken: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 AuthApiService.verifyFirebaseToken: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 AuthApiService.verifyFirebaseToken: Fixed and merged JSON: $mergedJson');
            final String? token = mergedJson['data']?['token'];
            final Map<String, dynamic>? userJson = mergedJson['data']?['user'];
            if (token != null && userJson != null) {
              final Map<String, dynamic> authData = {
                'token': token,
                'user': userJson,
                'authenticated_at': DateTime.now().toIso8601String(),
              };
              print(
                  '🔑 AuthApiService: Calling storeAuthData for merged JSON in verifyFirebaseToken with authData: $authData');
              await AuthService.instance.storeAuthData(authData);
            }
            return mergedJson;
          } else {
            print(
                '🐛 AuthApiService.verifyFirebaseToken: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 AuthApiService.verifyFirebaseToken: Error fixing concatenated JSON: $e');
        }
      }
      try {
        Map<String, dynamic> parsedResponse =
            jsonDecode(rawResponse) as Map<String, dynamic>;
        final String? token = parsedResponse['data']?['token'];
        final Map<String, dynamic>? userJson = parsedResponse['data']?['user'];
        if (token != null && userJson != null) {
          final Map<String, dynamic> authData = {
            'token': token,
            'user': userJson,
            'authenticated_at': DateTime.now().toIso8601String(),
          };
          print(
              '🔑 AuthApiService: Calling storeAuthData for plain string response in verifyFirebaseToken with authData: $authData');
          await AuthService.instance.storeAuthData(authData);
        }
        return parsedResponse;
      } catch (e) {
        print(
            '🐛 AuthApiService.verifyFirebaseToken: Failed to decode plain string response as JSON: $e');
        return {
          "success": false,
          "message": "Failed to parse server response after initial attempt."
        };
      }
    } else if (rawResponse is Map<String, dynamic>) {
      final String? token = rawResponse['data']?['token'];
      final Map<String, dynamic>? userJson = rawResponse['data']?['user'];
      if (token != null && userJson != null) {
        final Map<String, dynamic> authData = {
          'token': token,
          'user': userJson,
          'authenticated_at': DateTime.now().toIso8601String(),
        };
        print(
            '🔑 AuthApiService: Calling storeAuthData for verifyFirebaseToken with authData: $authData');
        await AuthService.instance.storeAuthData(authData);
      }
      return rawResponse;
    }
    return {
      "success": false,
      "message": "Unexpected response format from server."
    };
  }

  Future<User?> getCurrentUser() async {
    return await network<User>(
      request: (request) => request.get("/me"),
      cacheKey: "current_user",
      cacheDuration: const Duration(minutes: 2),
    );
  }

  Future<Map<String, dynamic>?> deleteAccount() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/delete-account"),
    );
  }
}
