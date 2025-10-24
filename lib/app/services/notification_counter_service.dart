import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/notification_api_service.dart';

/// Service to handle notification counting and badge management
class NotificationCounterService {
  static final NotificationCounterService _instance =
      NotificationCounterService._internal();
  factory NotificationCounterService() => _instance;
  NotificationCounterService._internal();

  int _unreadCount = 0;
  bool _isInitialized = false;

  /// Get current unread count
  int get unreadCount => _unreadCount;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the notification counter service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🔢 ===== INITIALIZING NOTIFICATION COUNTER =====');

      // Load initial notification count
      await _loadNotificationCount();

      _isInitialized = true;
      print('✅ Notification Counter Service initialized successfully');
      print('🔢 ================================================');
    } catch (e) {
      print('❌ Error initializing Notification Counter Service: $e');
      print('🔢 ================================================');
    }
  }

  /// Load notification count from server
  Future<void> _loadNotificationCount() async {
    try {
      final response = await api<NotificationApiService>(
        (request) => request.getNotifications(perPage: 1, page: 1),
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        final total = data['total'] ?? 0;
        final unread = data['unread_count'] ?? 0;

        _unreadCount = unread;

        print('🔢 Total notifications: $total');
        print('🔢 Unread notifications: $unread');

        // Update app badge
        await _updateAppBadge();
      }
    } catch (e) {
      print('❌ Error loading notification count: $e');
    }
  }

  /// Update app badge with current unread count
  Future<void> _updateAppBadge() async {
    try {
      // Update app badge count
      await pushNotification(
        'Notification Count',
        'You have $_unreadCount unread notifications',
      ).addBadgeNumber(_unreadCount).send();

      print('🔢 App badge updated: $_unreadCount');
    } catch (e) {
      print('❌ Error updating app badge: $e');
    }
  }

  /// Increment unread count (when new notification arrives)
  Future<void> incrementCount() async {
    _unreadCount++;
    print('🔢 Notification count incremented: $_unreadCount');
    await _updateAppBadge();
  }

  /// Decrement unread count (when notification is read)
  Future<void> decrementCount() async {
    if (_unreadCount > 0) {
      _unreadCount--;
      print('🔢 Notification count decremented: $_unreadCount');
      await _updateAppBadge();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final response = await api<NotificationApiService>(
        (request) => request.markAllNotificationsAsRead(),
      );

      if (response != null && response['success'] == true) {
        _unreadCount = 0;
        print('🔢 All notifications marked as read');
        await _updateAppBadge();
      }
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  /// Mark specific notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await api<NotificationApiService>(
        (request) =>
            request.markNotificationAsRead(notificationId: notificationId),
      );

      if (response != null && response['success'] == true) {
        await decrementCount();
        print('🔢 Notification $notificationId marked as read');
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  /// Refresh notification count from server
  Future<void> refreshCount() async {
    await _loadNotificationCount();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    _unreadCount = 0;
    await _updateAppBadge();
    print('🔢 All notifications cleared');
  }
}
