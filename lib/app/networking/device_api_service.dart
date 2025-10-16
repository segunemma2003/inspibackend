import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/config/decoders.dart';
import 'dart:convert';

class DeviceApiService extends NyApiService {
  DeviceApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'https://api.inspirtag.com/api');

  @override
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    print('🌐 DeviceApiService: Setting auth headers...');
    final authHeaders = await AuthService.instance.getAuthHeaders();
    print('🌐 DeviceApiService: Auth headers received: $authHeaders');
    headers.addAll(authHeaders);
    print('🌐 DeviceApiService: Final headers: ${headers.toString()}');
    return headers;
  }

  /// Register a new device for push notifications
  Future<Map<String, dynamic>?> registerDevice({
    required String deviceToken,
    required String deviceType,
    String? deviceName,
    String? appVersion,
    String? osVersion,
  }) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.post("/devices/register", data: {
        "device_token": deviceToken,
        "device_type": deviceType,
        if (deviceName != null) "device_name": deviceName,
        if (appVersion != null) "app_version": appVersion,
        if (osVersion != null) "os_version": osVersion,
      }),
    );

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
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
                  '🐛 DeviceApiService.registerDevice: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 DeviceApiService.registerDevice: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 DeviceApiService.registerDevice: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 DeviceApiService.registerDevice: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 DeviceApiService.registerDevice: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 DeviceApiService.registerDevice: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  /// Get user's devices
  Future<Map<String, dynamic>?> getDevices() async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.get("/devices"),
      cacheKey: "user_devices",
      cacheDuration: const Duration(minutes: 5),
    );

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
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
                  '🐛 DeviceApiService.getDevices: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 DeviceApiService.getDevices: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 DeviceApiService.getDevices: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 DeviceApiService.getDevices: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 DeviceApiService.getDevices: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 DeviceApiService.getDevices: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  /// Update device information
  Future<Map<String, dynamic>?> updateDevice({
    required int deviceId,
    String? deviceName,
    String? appVersion,
    String? osVersion,
    bool? isActive,
  }) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.put("/devices/$deviceId", data: {
        if (deviceName != null) "device_name": deviceName,
        if (appVersion != null) "app_version": appVersion,
        if (osVersion != null) "os_version": osVersion,
        if (isActive != null) "is_active": isActive,
      }),
    );

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
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
                  '🐛 DeviceApiService.updateDevice: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 DeviceApiService.updateDevice: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 DeviceApiService.updateDevice: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 DeviceApiService.updateDevice: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 DeviceApiService.updateDevice: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 DeviceApiService.updateDevice: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  /// Deactivate device
  Future<Map<String, dynamic>?> deactivateDevice(int deviceId) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.put("/devices/$deviceId/deactivate"),
    );

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
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
                  '🐛 DeviceApiService.deactivateDevice: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 DeviceApiService.deactivateDevice: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 DeviceApiService.deactivateDevice: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 DeviceApiService.deactivateDevice: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 DeviceApiService.deactivateDevice: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 DeviceApiService.deactivateDevice: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }

  /// Delete device
  Future<Map<String, dynamic>?> deleteDevice(int deviceId) async {
    final rawResponse = await network<dynamic>(
      request: (request) => request.delete("/devices/$deviceId"),
    );

    if (rawResponse == null) return null;

    Map<String, dynamic>? response;
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
                  '🐛 DeviceApiService.deleteDevice: Failed to decode first JSON part: $e');
            }
            try {
              secondJson = jsonDecode(secondPart) as Map<String, dynamic>;
            } catch (e) {
              print(
                  '🐛 DeviceApiService.deleteDevice: Failed to decode second JSON part: $e');
            }

            Map<String, dynamic> mergedJson = {};
            mergedJson.addAll(firstJson);
            mergedJson.addAll(secondJson);
            print(
                '🐛 DeviceApiService.deleteDevice: Fixed and merged JSON: $mergedJson');
            response = mergedJson;
          } else {
            print(
                '🐛 DeviceApiService.deleteDevice: Malformed but unhandled concatenated JSON format: $rawResponse');
          }
        } catch (e) {
          print(
              '🐛 DeviceApiService.deleteDevice: Error fixing concatenated JSON: $e');
        }
      }
      if (response == null) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 DeviceApiService.deleteDevice: Failed to decode plain string response as JSON: $e');
          return null;
        }
      }
    } else if (rawResponse is Map<String, dynamic>) {
      response = rawResponse;
    }
    return response;
  }
}
