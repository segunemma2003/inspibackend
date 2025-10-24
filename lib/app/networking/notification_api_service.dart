import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/services/auth_service.dart';
import '/config/decoders.dart';

class NotificationApiService extends NyApiService {
  NotificationApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'https://api.inspirtag.com/api');

  @override
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    print('🌐 NotificationApiService: Setting auth headers...');
    final authHeaders = await AuthService.instance.getAuthHeaders();
    print('🌐 NotificationApiService: Auth headers received: $authHeaders');
    headers.addAll(authHeaders);
    print('🌐 NotificationApiService: Final headers: ${headers.toString()}');
    return headers;
  }

  /// Get notifications with pagination
  Future<Map<String, dynamic>?> getNotifications({
    int perPage = 20,
    int page = 1,
    String? type,
    bool? isRead,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/notifications", queryParameters: {
        "per_page": perPage,
        "page": page,
        if (type != null) "type": type,
        if (isRead != null) "is_read": isRead,
      }),
      cacheKey:
          "notifications_$page" + "_${type ?? 'all'}" + "_${isRead ?? 'all'}",
      cacheDuration: const Duration(minutes: 2),
    );
  }

  /// Mark notification as read
  Future<Map<String, dynamic>?> markNotificationAsRead(
      int notificationId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.put("/notifications/$notificationId/read"),
      cacheKey: "notification_read_$notificationId",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Mark notification as unread
  Future<Map<String, dynamic>?> markNotificationAsUnread(
      int notificationId) async {
    return await network<Map<String, dynamic>>(
      request: (request) =>
          request.put("/notifications/$notificationId/unread"),
      cacheKey: "notification_unread_$notificationId",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Mark all notifications as read
  Future<Map<String, dynamic>?> markAllNotificationsAsRead() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.put("/notifications/mark-all-read"),
      cacheKey: "notifications_mark_all_read",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Mark multiple notifications as read
  Future<Map<String, dynamic>?> markMultipleAsRead(
      List<int> notificationIds) async {
    return await network<Map<String, dynamic>>(
      request: (request) =>
          request.put("/notifications/mark-multiple-read", data: {
        "notification_ids": notificationIds,
      }),
      cacheKey: "notifications_mark_multiple_read",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Get unread count
  Future<Map<String, dynamic>?> getUnreadCount() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/notifications/unread-count"),
      cacheKey: "notifications_unread_count",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Get notification statistics
  Future<Map<String, dynamic>?> getNotificationStatistics() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/notifications/statistics"),
      cacheKey: "notifications_statistics",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Delete notification
  Future<Map<String, dynamic>?> deleteNotification(int notificationId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/notifications/$notificationId"),
      cacheKey: "notification_delete_$notificationId",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Delete all notifications
  Future<Map<String, dynamic>?> deleteAllNotifications() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/notifications/"),
      cacheKey: "notifications_delete_all",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Send test notification
  Future<Map<String, dynamic>?> sendTestNotification() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/notifications/test"),
      cacheKey: "notifications_test",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Register FCM token
  Future<Map<String, dynamic>?> registerFCMToken({
    required String fcmToken,
    required String deviceType,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/notifications/register-fcm-token", data: {
        "fcm_token": fcmToken,
        "device_type": deviceType,
      }),
    );
  }

  /// Get notification settings
  Future<Map<String, dynamic>?> getNotificationSettings() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/notifications/settings"),
      cacheKey: "notification_settings",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Update notification settings
  Future<Map<String, dynamic>?> updateNotificationSettings({
    required Map<String, dynamic> settings,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.put("/notifications/settings", data: settings),
    );
  }
}
