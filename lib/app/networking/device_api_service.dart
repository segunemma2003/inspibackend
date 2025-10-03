import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/services/auth_service.dart';
import '/config/decoders.dart';

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
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/devices/register", data: {
        "device_token": deviceToken,
        "device_type": deviceType,
        if (deviceName != null) "device_name": deviceName,
        if (appVersion != null) "app_version": appVersion,
        if (osVersion != null) "os_version": osVersion,
      }),
    );
  }

  /// Get user's devices
  Future<Map<String, dynamic>?> getDevices() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/devices"),
      cacheKey: "user_devices",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Update device information
  Future<Map<String, dynamic>?> updateDevice({
    required int deviceId,
    String? deviceName,
    String? appVersion,
    String? osVersion,
    bool? isActive,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.put("/devices/$deviceId", data: {
        if (deviceName != null) "device_name": deviceName,
        if (appVersion != null) "app_version": appVersion,
        if (osVersion != null) "os_version": osVersion,
        if (isActive != null) "is_active": isActive,
      }),
    );
  }

  /// Deactivate device
  Future<Map<String, dynamic>?> deactivateDevice(int deviceId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.put("/devices/$deviceId/deactivate"),
    );
  }

  /// Delete device
  Future<Map<String, dynamic>?> deleteDevice(int deviceId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/devices/$deviceId"),
    );
  }
}
