import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/services/firebase_messaging_service.dart';
import '/app/networking/notification_api_service.dart';

class DebugNotificationsPage extends StatefulWidget {
  static RouteView path =
      ("/debug-notifications", (_) => DebugNotificationsPage());

  const DebugNotificationsPage({super.key});

  @override
  State<DebugNotificationsPage> createState() => _DebugNotificationsPageState();
}

class _DebugNotificationsPageState extends State<DebugNotificationsPage> {
  String _fcmToken = 'Not available';
  bool _isLoading = false;
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
  }

  Future<void> _loadFCMToken() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messagingService = FirebaseMessagingService();
      final token = messagingService.fcmToken;
      setState(() {
        _fcmToken = token ?? 'No token available';
      });
      _addLog(
          'FCM Token loaded: ${token != null ? 'Available' : 'Not available'}');
    } catch (e) {
      _addLog('Error loading FCM token: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: $message');
    });
  }

  Future<void> _testNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('Testing notification settings...');
      final response = await api<NotificationApiService>(
        (request) => request.getNotificationSettings(),
      );

      if (response != null && response['success'] == true) {
        _addLog('✅ Notification settings retrieved successfully');
        _addLog('Settings: ${response['data']}');
      } else {
        _addLog('❌ Failed to get notification settings');
      }
    } catch (e) {
      _addLog('❌ Error testing notification settings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testFCMTokenRegistration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('Testing FCM token registration...');
      final messagingService = FirebaseMessagingService();
      final token = messagingService.fcmToken;

      if (token != null) {
        final response = await api<NotificationApiService>(
          (request) => request.registerFCMToken(
            fcmToken: token,
            deviceType: 'ios',
          ),
        );

        if (response != null && response['success'] == true) {
          _addLog('✅ FCM token registered successfully');
        } else {
          _addLog('❌ Failed to register FCM token');
        }
      } else {
        _addLog('❌ No FCM token available');
      }
    } catch (e) {
      _addLog('❌ Error testing FCM token registration: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('Testing notifications API...');
      final response = await api<NotificationApiService>(
        (request) => request.getNotifications(perPage: 5, page: 1),
      );

      if (response != null && response['success'] == true) {
        final notifications = response['data']['data'] ?? [];
        _addLog(
            '✅ Notifications retrieved: ${notifications.length} notifications');
        _addLog('Response: ${response['data']}');
      } else {
        _addLog('❌ Failed to get notifications');
      }
    } catch (e) {
      _addLog('❌ Error testing notifications: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('FCM Token'),
            _buildInfoCard('FCM Token', _fcmToken),
            SizedBox(height: 16),
            _buildSectionHeader('Test Actions'),
            _buildActionButton(
              'Refresh FCM Token',
              Icons.refresh,
              _loadFCMToken,
            ),
            _buildActionButton(
              'Test Notification Settings',
              Icons.settings,
              _testNotificationSettings,
            ),
            _buildActionButton(
              'Test FCM Token Registration',
              Icons.cloud_upload,
              _testFCMTokenRegistration,
            ),
            _buildActionButton(
              'Test Notifications API',
              Icons.notifications,
              _testNotifications,
            ),
            SizedBox(height: 16),
            _buildSectionHeader('Debug Logs'),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _logs
                      .map((log) => Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              log,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildActionButton(
              'Clear Logs',
              Icons.clear,
              () {
                setState(() {
                  _logs.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontFamily: 'monospace',
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: _isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF69B4),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

