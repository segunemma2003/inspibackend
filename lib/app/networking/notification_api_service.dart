import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/services/auth_service.dart';
import '/config/decoders.dart';

class NotificationApiService extends NyApiService {
  NotificationApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'http://38.180.244.178/api');

  @override
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    print('🌐 NotificationApiService: Setting auth headers...');
    final authHeaders = await AuthService.instance.getAuthHeaders();
    print('🌐 NotificationApiService: Auth headers received: $authHeaders');
    headers.addAll(authHeaders);
    print('🌐 NotificationApiService: Final headers: ${headers.toString()}');
    return headers;
  }

  /// Register FCM token with the server
  Future<Map<String, dynamic>?> registerFCMToken({
    required String fcmToken,
    String? deviceType,
    String? deviceId,
  }) async {
    try {
      print('📱 NotificationApiService: Registering FCM token...');

      final requestData = {
        'fcm_token': fcmToken,
        'device_type': deviceType ?? 'mobile',
        'device_id': deviceId,
      };

      final rawResponse = await network<dynamic>(
        request: (request) =>
            request.post("/notifications/register-token", data: requestData),
      );

      if (rawResponse == null) return null;

      Map<String, dynamic>? response;
      if (rawResponse is String) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 NotificationApiService.registerFCMToken: Failed to decode response: $e');
          return null;
        }
      } else if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      }

      print('✅ NotificationApiService: FCM token registered successfully');
      return response;
    } catch (e) {
      print('❌ NotificationApiService: Error registering FCM token: $e');
      return null;
    }
  }

  /// Update FCM token
  Future<Map<String, dynamic>?> updateFCMToken({
    required String fcmToken,
    String? deviceType,
    String? deviceId,
  }) async {
    try {
      print('📱 NotificationApiService: Updating FCM token...');

      final requestData = {
        'fcm_token': fcmToken,
        'device_type': deviceType ?? 'mobile',
        'device_id': deviceId,
      };

      final rawResponse = await network<dynamic>(
        request: (request) =>
            request.put("/notifications/update-token", data: requestData),
      );

      if (rawResponse == null) return null;

      Map<String, dynamic>? response;
      if (rawResponse is String) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 NotificationApiService.updateFCMToken: Failed to decode response: $e');
          return null;
        }
      } else if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      }

      print('✅ NotificationApiService: FCM token updated successfully');
      return response;
    } catch (e) {
      print('❌ NotificationApiService: Error updating FCM token: $e');
      return null;
    }
  }

  /// Unregister FCM token
  Future<Map<String, dynamic>?> unregisterFCMToken({
    required String fcmToken,
  }) async {
    try {
      print('📱 NotificationApiService: Unregistering FCM token...');

      final requestData = {
        'fcm_token': fcmToken,
      };

      final rawResponse = await network<dynamic>(
        request: (request) => request.delete("/notifications/unregister-token",
            data: requestData),
      );

      if (rawResponse == null) return null;

      Map<String, dynamic>? response;
      if (rawResponse is String) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 NotificationApiService.unregisterFCMToken: Failed to decode response: $e');
          return null;
        }
      } else if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      }

      print('✅ NotificationApiService: FCM token unregistered successfully');
      return response;
    } catch (e) {
      print('❌ NotificationApiService: Error unregistering FCM token: $e');
      return null;
    }
  }

  /// Get notification settings
  Future<Map<String, dynamic>?> getNotificationSettings() async {
    try {
      print('📱 NotificationApiService: Getting notification settings...');

      final rawResponse = await network<dynamic>(
        request: (request) => request.get("/notifications/settings"),
        cacheKey: "notification_settings",
        cacheDuration: const Duration(minutes: 5),
      );

      if (rawResponse == null) return null;

      Map<String, dynamic>? response;
      if (rawResponse is String) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 NotificationApiService.getNotificationSettings: Failed to decode response: $e');
          return null;
        }
      } else if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      }

      print(
          '✅ NotificationApiService: Notification settings retrieved successfully');
      return response;
    } catch (e) {
      print(
          '❌ NotificationApiService: Error getting notification settings: $e');
      return null;
    }
  }

  /// Update notification settings
  Future<Map<String, dynamic>?> updateNotificationSettings({
    required Map<String, dynamic> settings,
  }) async {
    try {
      print('📱 NotificationApiService: Updating notification settings...');

      final rawResponse = await network<dynamic>(
        request: (request) =>
            request.put("/notifications/settings", data: settings),
      );

      if (rawResponse == null) return null;

      Map<String, dynamic>? response;
      if (rawResponse is String) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 NotificationApiService.updateNotificationSettings: Failed to decode response: $e');
          return null;
        }
      } else if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      }

      print(
          '✅ NotificationApiService: Notification settings updated successfully');
      return response;
    } catch (e) {
      print(
          '❌ NotificationApiService: Error updating notification settings: $e');
      return null;
    }
  }

  /// Subscribe to notification topic
  Future<Map<String, dynamic>?> subscribeToTopic({
    required String topic,
  }) async {
    try {
      print('📱 NotificationApiService: Subscribing to topic: $topic');

      final requestData = {
        'topic': topic,
      };

      final rawResponse = await network<dynamic>(
        request: (request) =>
            request.post("/notifications/subscribe-topic", data: requestData),
      );

      if (rawResponse == null) return null;

      Map<String, dynamic>? response;
      if (rawResponse is String) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 NotificationApiService.subscribeToTopic: Failed to decode response: $e');
          return null;
        }
      } else if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      }

      print('✅ NotificationApiService: Subscribed to topic successfully');
      return response;
    } catch (e) {
      print('❌ NotificationApiService: Error subscribing to topic: $e');
      return null;
    }
  }

  /// Unsubscribe from notification topic
  Future<Map<String, dynamic>?> unsubscribeFromTopic({
    required String topic,
  }) async {
    try {
      print('📱 NotificationApiService: Unsubscribing from topic: $topic');

      final requestData = {
        'topic': topic,
      };

      final rawResponse = await network<dynamic>(
        request: (request) =>
            request.post("/notifications/unsubscribe-topic", data: requestData),
      );

      if (rawResponse == null) return null;

      Map<String, dynamic>? response;
      if (rawResponse is String) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 NotificationApiService.unsubscribeFromTopic: Failed to decode response: $e');
          return null;
        }
      } else if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      }

      print('✅ NotificationApiService: Unsubscribed from topic successfully');
      return response;
    } catch (e) {
      print('❌ NotificationApiService: Error unsubscribing from topic: $e');
      return null;
    }
  }

  /// Get user notifications
  Future<Map<String, dynamic>?> getNotifications({
    int perPage = 20,
    int page = 1,
  }) async {
    try {
      print('📱 NotificationApiService: Getting notifications...');

      final rawResponse = await network<dynamic>(
        request: (request) => request.get(
          "/notifications",
          queryParameters: {
            'per_page': perPage,
            'page': page,
          },
        ),
        cacheKey: "notifications_$page",
        cacheDuration: const Duration(minutes: 2),
      );

      if (rawResponse == null) return null;

      Map<String, dynamic>? response;
      if (rawResponse is String) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 NotificationApiService.getNotifications: Failed to decode response: $e');
          return null;
        }
      } else if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      }

      print('✅ NotificationApiService: Notifications retrieved successfully');
      return response;
    } catch (e) {
      print('❌ NotificationApiService: Error getting notifications: $e');
      return null;
    }
  }

  /// Mark notification as read
  Future<Map<String, dynamic>?> markNotificationAsRead({
    required int notificationId,
  }) async {
    try {
      print('📱 NotificationApiService: Marking notification as read...');

      final rawResponse = await network<dynamic>(
        request: (request) => request.put(
          "/notifications/$notificationId/read",
        ),
      );

      if (rawResponse == null) return null;

      Map<String, dynamic>? response;
      if (rawResponse is String) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 NotificationApiService.markNotificationAsRead: Failed to decode response: $e');
          return null;
        }
      } else if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      }

      print(
          '✅ NotificationApiService: Notification marked as read successfully');
      return response;
    } catch (e) {
      print('❌ NotificationApiService: Error marking notification as read: $e');
      return null;
    }
  }

  /// Mark all notifications as read
  Future<Map<String, dynamic>?> markAllNotificationsAsRead() async {
    try {
      print('📱 NotificationApiService: Marking all notifications as read...');

      final rawResponse = await network<dynamic>(
        request: (request) => request.put(
          "/notifications/mark-all-read",
        ),
      );

      if (rawResponse == null) return null;

      Map<String, dynamic>? response;
      if (rawResponse is String) {
        try {
          response = jsonDecode(rawResponse) as Map<String, dynamic>;
        } catch (e) {
          print(
              '🐛 NotificationApiService.markAllNotificationsAsRead: Failed to decode response: $e');
          return null;
        }
      } else if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      }

      print(
          '✅ NotificationApiService: All notifications marked as read successfully');
      return response;
    } catch (e) {
      print(
          '❌ NotificationApiService: Error marking all notifications as read: $e');
      return null;
    }
  }
}
