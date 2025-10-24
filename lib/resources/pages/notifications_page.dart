import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/config/app_colors.dart';
import '/app/networking/notification_api_service.dart';
import '/app/models/notification.dart' as app_models;

class NotificationsPage extends StatefulWidget {
  static RouteView path = ("/notifications", (_) => NotificationsPage());
  const NotificationsPage({super.key});

  @override
  createState() => _NotificationsPageState();
}

class _NotificationsPageState extends NyState<NotificationsPage> {
  List<app_models.Notification> _notifications = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  int _unreadCount = 0;

  @override
  get init => () async {
        await _loadNotifications(1);
        await _loadUnreadCount();
      };

  Future<void> _loadNotifications(int page, {bool forceRefresh = false}) async {
    if (!_hasMore && page > 1) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await api<NotificationApiService>(
        (request) => request.getNotifications(
          perPage: 20,
          page: page,
        ),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> notificationsData = response['data']['data'] ?? [];
        final List<app_models.Notification> newNotifications = notificationsData
            .map((json) => app_models.Notification.fromJson(json))
            .toList();

        setState(() {
          if (page == 1) {
            _notifications = newNotifications;
          } else {
            _notifications.addAll(newNotifications);
          }
          _currentPage = response['data']['current_page'] ?? page;
          _hasMore = _currentPage < (response['data']['last_page'] ?? 1);
        });
      }
    } catch (e) {
      print("Error loading notifications: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final response = await api<NotificationApiService>(
        (request) => request.get("/notifications/unread-count"),
      );

      if (response != null && response['success'] == true) {
        setState(() {
          _unreadCount = response['data']['unread_count'] ?? 0;
        });
      }
    } catch (e) {
      print("Error loading unread count: $e");
    }
  }

  Future<void> _markAsRead(app_models.Notification notification) async {
    if (notification.isRead == true) return;

    try {
      final response = await api<NotificationApiService>(
        (request) => request.markNotificationAsRead(notification.id!),
      );

      if (response != null && response['success'] == true) {
        setState(() {
          notification.isRead = true;
          if (_unreadCount > 0) _unreadCount--;
        });
      }
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final response = await api<NotificationApiService>(
        (request) => request.markAllNotificationsAsRead(),
      );

      if (response != null && response['success'] == true) {
        setState(() {
          for (var notification in _notifications) {
            notification.isRead = true;
          }
          _unreadCount = 0;
        });
        showToast(
          title: "Success",
          description: "All notifications marked as read",
          style: ToastNotificationStyleType.success,
        );
      }
    } catch (e) {
      print("Error marking all notifications as read: $e");
      showToast(
        title: "Error",
        description: "Failed to mark all notifications as read",
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            GestureDetector(
              onTap: _markAllAsRead,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Mark All Read',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading && _notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationsList(),
    );
  }

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: () => _loadNotifications(1, forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            if (_hasMore) {
              _loadNotifications(_currentPage + 1);
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(app_models.Notification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (notification.isRead == true)
            ? AppColors.backgroundSecondary
            : AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (notification.isRead == true)
              ? AppColors.borderLight
              : AppColors.primaryPink,
          width: (notification.isRead == true) ? 1 : 2,
        ),
        boxShadow: (notification.isRead == true)
            ? null
            : [
                BoxShadow(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: GestureDetector(
        onTap: () => _markAsRead(notification),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(notification),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title ?? 'Notification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: (notification.isRead == true)
                          ? FontWeight.w500
                          : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: (notification.isRead == true)
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (notification.isRead != true) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryPink,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(app_models.Notification notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'user_tagged':
        iconData = Icons.person_add;
        iconColor = AppColors.primaryPink;
        break;
      case 'post_liked':
        iconData = Icons.favorite;
        iconColor = AppColors.likeRed;
        break;
      case 'post_saved':
        iconData = Icons.bookmark;
        iconColor = AppColors.saveBlue;
        break;
      case 'user_followed':
        iconData = Icons.person_add_alt_1;
        iconColor = AppColors.primaryGreen;
        break;
      case 'comment_added':
        iconData = Icons.comment;
        iconColor = AppColors.commentGreen;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppColors.primaryBlue;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none,
                size: 80, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            const Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You\'re all caught up! No new notifications.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
