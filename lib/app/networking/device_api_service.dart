import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '/config/decoders.dart';

class DeviceApiService extends NyApiService {
  DeviceApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  /// Register device for push notifications
  Future<Map<String, dynamic>?> registerDevice({
    required String deviceToken,
    required String deviceType,
    String? deviceName,
    String? appVersion,
    String? osVersion,
  }) async {
    try {
      print('📱 DeviceApiService: Registering device with token: $deviceToken');

      final response = await network<dynamic>(
        request: (request) => request.post(
          "/devices/register",
          data: {
            'device_token': deviceToken,
            'device_type': deviceType,
            if (deviceName != null) 'device_name': deviceName,
            if (appVersion != null) 'app_version': appVersion,
            if (osVersion != null) 'os_version': osVersion,
          },
        ),
      );

      print('📱 DeviceApiService: Device registration response: $response');
      return response;
    } catch (e) {
      print('❌ DeviceApiService: Error registering device: $e');
      return null;
    }
  }

  /// Get user's devices
  Future<Map<String, dynamic>?> getDevices() async {
    try {
      print('📱 DeviceApiService: Getting user devices');

      final response = await network<dynamic>(
        request: (request) => request.get("/devices"),
      );

      print('📱 DeviceApiService: Get devices response: $response');
      return response;
    } catch (e) {
      print('❌ DeviceApiService: Error getting devices: $e');
      return null;
    }
  }

  /// Update device
  Future<Map<String, dynamic>?> updateDevice({
    required int deviceId,
    String? deviceName,
    String? appVersion,
    String? osVersion,
    bool? isActive,
  }) async {
    try {
      print('📱 DeviceApiService: Updating device $deviceId');

      final response = await network<dynamic>(
        request: (request) => request.put(
          "/devices/$deviceId",
          data: {
            if (deviceName != null) 'device_name': deviceName,
            if (appVersion != null) 'app_version': appVersion,
            if (osVersion != null) 'os_version': osVersion,
            if (isActive != null) 'is_active': isActive,
          },
        ),
      );

      print('📱 DeviceApiService: Update device response: $response');
      return response;
    } catch (e) {
      print('❌ DeviceApiService: Error updating device: $e');
      return null;
    }
  }

  /// Deactivate device
  Future<Map<String, dynamic>?> deactivateDevice(int deviceId) async {
    try {
      print('📱 DeviceApiService: Deactivating device $deviceId');

      final response = await network<dynamic>(
        request: (request) => request.put("/devices/$deviceId/deactivate"),
      );

      print('📱 DeviceApiService: Deactivate device response: $response');
      return response;
    } catch (e) {
      print('❌ DeviceApiService: Error deactivating device: $e');
      return null;
    }
  }

  /// Delete device
  Future<Map<String, dynamic>?> deleteDevice(int deviceId) async {
    try {
      print('📱 DeviceApiService: Deleting device $deviceId');

      final response = await network<dynamic>(
        request: (request) => request.delete("/devices/$deviceId"),
      );

      print('📱 DeviceApiService: Delete device response: $response');
      return response;
    } catch (e) {
      print('❌ DeviceApiService: Error deleting device: $e');
      return null;
    }
  }

  /// Get device type based on platform
  static String getDeviceType() {
    if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isAndroid) {
      return 'android';
    } else {
      return 'web';
    }
  }

  /// Get device name
  static String getDeviceName() {
    if (Platform.isIOS) {
      return 'iOS Device';
    } else if (Platform.isAndroid) {
      return 'Android Device';
    } else {
      return 'Web Device';
    }
  }

  /// Get OS version
  static String getOsVersion() {
    return Platform.operatingSystemVersion;
  }
}
