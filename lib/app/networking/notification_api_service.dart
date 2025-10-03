import 'package:flutter/material.dart';
import '/config/decoders.dart';
import '/app/services/auth_service.dart';
import 'package:nylo_framework/nylo_framework.dart';

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

  /// Get notifications with filtering
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
      cacheKey: "notifications_${type ?? 'all'}_${isRead ?? 'all'}_$page",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Mark notification as read
  Future<Map<String, dynamic>?> markNotificationAsRead(
      int notificationId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/notifications/$notificationId/read"),
    );
  }

  /// Mark all notifications as read
  Future<Map<String, dynamic>?> markAllNotificationsAsRead() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/notifications/read-all"),
    );
  }

  /// Get unread count
  Future<Map<String, dynamic>?> getUnreadCount() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/notifications/unread-count"),
      cacheKey: "unread_count",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Update notification preferences
  Future<Map<String, dynamic>?> updateNotificationPreferences({
    bool? notificationsEnabled,
    bool? likeNotifications,
    bool? followNotifications,
    bool? postNotifications,
    bool? bookingNotifications,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.put("/notifications/preferences", data: {
        if (notificationsEnabled != null)
          "notifications_enabled": notificationsEnabled,
        if (likeNotifications != null) "like_notifications": likeNotifications,
        if (followNotifications != null)
          "follow_notifications": followNotifications,
        if (postNotifications != null) "post_notifications": postNotifications,
        if (bookingNotifications != null)
          "booking_notifications": bookingNotifications,
      }),
    );
  }

  /// Update FCM token for push notifications
  Future<Map<String, dynamic>?> updateFcmToken(String fcmToken) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/notifications/fcm-token", data: {
        "fcm_token": fcmToken,
      }),
    );
  }

  /// Delete notification
  Future<Map<String, dynamic>?> deleteNotification(int notificationId) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/notifications/$notificationId"),
    );
  }

  /// Mark notification as unread
  Future<Map<String, dynamic>?> markNotificationAsUnread(
      int notificationId) async {
    return await network<Map<String, dynamic>>(
      request: (request) =>
          request.put("/notifications/$notificationId/unread"),
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
    );
  }

  /// Delete all notifications
  Future<Map<String, dynamic>?> deleteAllNotifications() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.delete("/notifications"),
    );
  }

  /// Get notification statistics
  Future<Map<String, dynamic>?> getNotificationStatistics() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/notifications/statistics"),
      cacheKey: "notification_stats",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Send test notification
  Future<Map<String, dynamic>?> sendTestNotification(String message) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/notifications/test", data: {
        "message": message,
      }),
    );
  }
}
