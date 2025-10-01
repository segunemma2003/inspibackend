import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class NotificationPage extends NyStatefulWidget {
  static RouteView path = ("/notification", (_) => NotificationPage());

  NotificationPage({super.key}) : super(child: () => _NotificationPageState());
}

class _NotificationPageState extends NyPage<NotificationPage> {
  List<Map<String, dynamic>> notifications = [
    {
      'title': 'New Connection Request',
      'message': 'James Williams wants to connect with you',
      'time': '2 minutes ago',
      'type': 'connection',
      'isRead': false,
    },
    {
      'title': 'Profile View',
      'message': 'Claudia Hill viewed your business profile',
      'time': '15 minutes ago',
      'type': 'profile_view',
      'isRead': false,
    },
    {
      'title': 'New Message',
      'message': 'You have a new message from Maria Park',
      'time': '1 hour ago',
      'type': 'message',
      'isRead': true,
    },
    {
      'title': 'Booking Confirmed',
      'message':
          'Your appointment with Luis Rodriguez is confirmed for tomorrow',
      'time': '2 hours ago',
      'type': 'booking',
      'isRead': true,
    },
    {
      'title': 'New Review',
      'message': 'Emma West left you a 5-star review',
      'time': '1 day ago',
      'type': 'review',
      'isRead': true,
    },
  ];

  @override
  get init => () {};

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
              child: _buildNotificationsList(),
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

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    IconData iconData;
    Color iconColor;

    switch (notification['type']) {
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

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification['isRead'] ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification['isRead'] ? Colors.grey[200]! : Color(0xFF00BFFF),
          width: notification['isRead'] ? 1 : 2,
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
              color: iconColor.withOpacity(0.1),
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
                  notification['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: notification['isRead']
                        ? FontWeight.w500
                        : FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  notification['time'],
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
          if (!notification['isRead'])
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
}
