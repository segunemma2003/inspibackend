import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/config/decoders.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '/app/networking/dio/interceptors/bearer_auth_interceptor.dart';

class DeviceApiService extends NyApiService {
  DeviceApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'https://api.inspirtag.com/api');

  @override
  get interceptors => {
        if (getEnv('APP_DEBUG') == true) PrettyDioLogger: PrettyDioLogger(),
        BearerAuthInterceptor: BearerAuthInterceptor(),
      };

  // Authentication is now handled by BearerAuthInterceptor
  // No need for setAuthHeaders method

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

  /// Get device type (iOS or Android)
  static String getDeviceType() {
    return Platform.isIOS ? 'ios' : 'android';
  }

  /// Get device name
  static String getDeviceName() {
    if (Platform.isIOS) {
      return 'iOS Device';
    } else if (Platform.isAndroid) {
      return 'Android Device';
    } else {
      return 'Unknown Device';
    }
  }

  /// Get OS version
  static String getOsVersion() {
    return Platform.operatingSystemVersion;
  }
}
