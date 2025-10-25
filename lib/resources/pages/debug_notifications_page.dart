import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/services/firebase_messaging_service.dart';
import '/app/services/notification_counter_service.dart';

class DebugNotificationsPage extends NyStatefulWidget {
  static RouteView path =
      ("/debug-notifications", (_) => DebugNotificationsPage());

  DebugNotificationsPage({super.key})
      : super(child: () => _DebugNotificationsPageState());
}

class _DebugNotificationsPageState extends NyState<DebugNotificationsPage> {
  final FirebaseMessagingService _firebaseMessaging =
      FirebaseMessagingService();
  final NotificationCounterService _notificationCounter =
      NotificationCounterService();

  int _notificationCount = 0;
  bool _isLoading = false;

  @override
  get init => () async {
        await _loadNotificationCount();
      };

  Future<void> _loadNotificationCount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final count = await _notificationCounter.getCount();
      setState(() {
        _notificationCount = count;
      });
    } catch (e) {
      print('Error loading notification count: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Notifications'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Notification Counter'),
                  _buildInfoCard(
                    'Current Count',
                    _notificationCount.toString(),
                    Icons.notifications,
                  ),
                  SizedBox(height: 16),
                  _buildSectionTitle('Actions'),
                  _buildActionButton(
                    'Test Local Notification',
                    Icons.send,
                    () => _testLocalNotification(),
                  ),
                  _buildActionButton(
                    'Increment Counter',
                    Icons.add,
                    () => _incrementCounter(),
                  ),
                  _buildActionButton(
                    'Reset Counter',
                    Icons.refresh,
                    () => _resetCounter(),
                  ),
                  SizedBox(height: 24),
                  _buildSectionTitle('Firebase Messaging Debug'),
                  _buildActionButton(
                    'Debug Setup',
                    Icons.bug_report,
                    () => _debugFirebaseSetup(),
                  ),
                  _buildActionButton(
                    'Test Notification',
                    Icons.notifications_active,
                    () => _testFirebaseNotification(),
                  ),
                  _buildActionButton(
                    'Test Direct Display',
                    Icons.notification_important,
                    () => _testDirectNotification(),
                  ),
                  _buildActionButton(
                    'Check Permissions',
                    Icons.security,
                    () => _checkPermissions(),
                  ),
                  _buildActionButton(
                    'Get FCM Token',
                    Icons.key,
                    () => _getFCMToken(),
                  ),
                  _buildActionButton(
                    'Register Device',
                    Icons.phone_android,
                    () => _registerDevice(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _testLocalNotification() async {
    try {
      await _firebaseMessaging.testLocalNotification();
      showToast(
        title: 'Success',
        description: 'Test notification sent',
      );
    } catch (e) {
      showToast(
        title: 'Error',
        description: 'Failed to send test notification: $e',
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Future<void> _incrementCounter() async {
    try {
      await _notificationCounter.incrementCount();
      await _loadNotificationCount();
      showToast(
        title: 'Success',
        description: 'Counter incremented',
      );
    } catch (e) {
      showToast(
        title: 'Error',
        description: 'Failed to increment counter: $e',
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Future<void> _resetCounter() async {
    try {
      await _notificationCounter.resetCount();
      await _loadNotificationCount();
      showToast(
        title: 'Success',
        description: 'Counter reset',
      );
    } catch (e) {
      showToast(
        title: 'Error',
        description: 'Failed to reset counter: $e',
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Future<void> _debugFirebaseSetup() async {
    try {
      await _firebaseMessaging.debugNotificationSetup();
      showToast(
        title: 'Debug Info',
        description: 'Check console for debug information',
      );
    } catch (e) {
      showToast(
        title: 'Error',
        description: 'Failed to get debug info: $e',
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Future<void> _testFirebaseNotification() async {
    try {
      await _firebaseMessaging.testLocalNotification();
      showToast(
        title: 'Success',
        description: 'Firebase test notification sent',
      );
    } catch (e) {
      showToast(
        title: 'Error',
        description: 'Failed to send Firebase test notification: $e',
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Future<void> _testDirectNotification() async {
    try {
      await _firebaseMessaging.testNotificationDisplay();
      showToast(
        title: 'Success',
        description: 'Direct notification test sent',
      );
    } catch (e) {
      showToast(
        title: 'Error',
        description: 'Failed to send direct notification: $e',
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Future<void> _checkPermissions() async {
    try {
      await _firebaseMessaging.checkAndRequestPermissions();
      showToast(
        title: 'Success',
        description: 'Permission check completed - see console for details',
      );
    } catch (e) {
      showToast(
        title: 'Error',
        description: 'Failed to check permissions: $e',
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Future<void> _getFCMToken() async {
    try {
      final token = _firebaseMessaging.fcmToken;
      if (token != null) {
        showToast(
          title: 'FCM Token',
          description: 'Token: ${token.substring(0, 20)}...',
        );
        print('🔑 Full FCM Token: $token');
      } else {
        showToast(
          title: 'No Token',
          description: 'FCM token is null',
          style: ToastNotificationStyleType.danger,
        );
      }
    } catch (e) {
      showToast(
        title: 'Error',
        description: 'Failed to get FCM token: $e',
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Future<void> _registerDevice() async {
    try {
      await _firebaseMessaging.registerDevice();
      showToast(
        title: 'Success',
        description: 'Device registration completed - see console for details',
      );
    } catch (e) {
      showToast(
        title: 'Error',
        description: 'Failed to register device: $e',
        style: ToastNotificationStyleType.danger,
      );
    }
  }
}
