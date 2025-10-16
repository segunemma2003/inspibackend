import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/notification_api_service.dart';
import '/app/models/notification.dart' as app_models;

class NotificationPage extends NyStatefulWidget {
  static RouteView path = ("/notification", (_) => NotificationPage());

  NotificationPage({super.key}) : super(child: () => _NotificationPageState());
}

class _NotificationPageState extends NyPage<NotificationPage> {
  List<app_models.Notification> notifications = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMoreNotifications = true;

  @override
  get init => () async {
        await _loadNotifications();
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            const SizedBox(height: 20),

            // Logo Section
            _buildLogoSection(),

            const SizedBox(height: 30),

            // Notifications List
            Expanded(
              child: _isLoading && notifications.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              routeTo('/base');
            },
            child: Icon(
              Icons.arrow_back,
              size: 24,
              color: Colors.black,
            ),
          ),
          // Title
          Text(
            'NOTIFICATIONS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          // Settings Icon
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Notification Settings'),
                  content: Text('Manage your notification preferences here.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: Icon(
              Icons.settings_outlined,
              size: 24,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo image
        Image.asset(
          'logo.png',
          width: 60,
          height: 60,
          fit: BoxFit.contain,
        ).localAsset(),

        const SizedBox(height: 8),

        // App name with second 'i' in yellow and 'r' in blue
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'insp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF69B4), // Bright pink
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'i',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFD700), // Yellow
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'rtag',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00BFFF), // Blue
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList() {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification, index);
      },
    );
  }

  Widget _buildNotificationCard(
      app_models.Notification notification, int index) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'connection':
        iconData = Icons.person_add;
        iconColor = Color(0xFF00BFFF);
        break;
      case 'profile_view':
        iconData = Icons.visibility;
        iconColor = Color(0xFFFF69B4);
        break;
      case 'message':
        iconData = Icons.message;
        iconColor = Color(0xFFFFD700);
        break;
      case 'booking':
        iconData = Icons.event_available;
        iconColor = Colors.green;
        break;
      case 'review':
        iconData = Icons.star;
        iconColor = Color(0xFFFF9800);
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () => _markAsRead(notification),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.readAt != null ? Colors.grey[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.readAt != null
                ? Colors.grey[200]!
                : Color(0xFF00BFFF),
            width: notification.readAt != null ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(25), // Equivalent to 10% opacity
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title ?? 'Notification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: notification.readAt != null
                          ? FontWeight.w500
                          : FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    notification.message ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _formatTimestamp(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Unread indicator
            if (notification.readAt == null)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFF00BFFF),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'ll see your notifications here\nwhen you receive them',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Unknown time';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

  // API Methods
  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreNotifications = true;
      notifications.clear();
    }

    if (_isLoading || !_hasMoreNotifications) return;

    setState(() => _isLoading = true);

    try {
      print('📱 Notifications: Loading page $_currentPage...');

      final response = await api<NotificationApiService>(
        (request) => request.getNotifications(
          perPage: 20,
          page: _currentPage,
        ),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> notificationsData = response['data']['data'] ?? [];
        final List<app_models.Notification> newNotifications = notificationsData
            .map((json) => app_models.Notification.fromJson(json))
            .toList();

        setState(() {
          if (refresh) {
            notifications = newNotifications;
          } else {
            notifications.addAll(newNotifications);
          }
          _currentPage++;
          _hasMoreNotifications =
              newNotifications.length == 20; // Assuming 20 per page
        });

        print(
            '📱 Notifications: Loaded ${newNotifications.length} notifications');
      } else {
        print('❌ Notifications: Failed to load - ${response?['message']}');
        _hasMoreNotifications = false;
      }
    } catch (e) {
      print('❌ Notifications: Error loading: $e');
      _hasMoreNotifications = false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(app_models.Notification notification) async {
    try {
      final response = await api<NotificationApiService>(
        (request) => request.markNotificationAsRead(notification.id!),
      );

      if (response != null && response['success'] == true) {
        setState(() {
          notification.readAt = DateTime.now();
        });
        print('✅ Notification marked as read');
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }
}
