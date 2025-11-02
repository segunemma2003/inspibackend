import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/notification_api_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  static RouteView path =
      ("/notification-settings", (_) => NotificationSettingsPage());

  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends NyState<NotificationSettingsPage> {
  bool _isLoading = true;

  bool _likesEnabled = true;
  bool _commentsEnabled = true;
  bool _followsEnabled = true;
  bool _messagesEnabled = true;
  bool _postsEnabled = true;
  bool _marketingEnabled = false;
  bool _pushEnabled = true;
  bool _emailEnabled = true;

  @override
  get init => () async {
        await _loadNotificationSettings();
      };

  Future<void> _loadNotificationSettings() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await api<NotificationApiService>(
        (request) => request.getNotificationSettings(),
      );

      if (response != null && response['success'] == true) {
        final settings = response['data'] ?? {};
        setState(() {
          _likesEnabled = settings['likes'] ?? true;
          _commentsEnabled = settings['comments'] ?? true;
          _followsEnabled = settings['follows'] ?? true;
          _messagesEnabled = settings['messages'] ?? true;
          _postsEnabled = settings['posts'] ?? true;
          _marketingEnabled = settings['marketing'] ?? false;
          _pushEnabled = settings['push'] ?? true;
          _emailEnabled = settings['email'] ?? true;
        });
      }
    } catch (e) {
      showToast(
        title: 'Error',
        description: 'Failed to load notification settings: $e',
        style: ToastNotificationStyleType.danger,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final settings = {
        'likes': _likesEnabled,
        'comments': _commentsEnabled,
        'follows': _followsEnabled,
        'messages': _messagesEnabled,
        'posts': _postsEnabled,
        'marketing': _marketingEnabled,
        'push': _pushEnabled,
        'email': _emailEnabled,
      };

      final response = await api<NotificationApiService>(
        (request) => request.updateNotificationSettings(settings: settings),
      );

      if (response != null && response['success'] == true) {
        showToast(
          title: 'Success',
          description: 'Notification settings updated successfully',
          style: ToastNotificationStyleType.success,
        );
      } else {
        showToast(
          title: 'Error',
          description: 'Failed to update notification settings',
          style: ToastNotificationStyleType.danger,
        );
      }
    } catch (e) {
      showToast(
        title: 'Error',
        description: 'Failed to update notification settings: $e',
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Notification Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Push Notifications'),
                  _buildSwitchTile(
                    'Enable Push Notifications',
                    'Receive notifications on your device',
                    _pushEnabled,
                    (value) => setState(() => _pushEnabled = value),
                  ),
                  SizedBox(height: 24),
                  _buildSectionHeader('Activity Notifications'),
                  _buildSwitchTile(
                    'Likes',
                    'When someone likes your posts',
                    _likesEnabled,
                    (value) => setState(() => _likesEnabled = value),
                  ),
                  _buildSwitchTile(
                    'Comments',
                    'When someone comments on your posts',
                    _commentsEnabled,
                    (value) => setState(() => _commentsEnabled = value),
                  ),
                  _buildSwitchTile(
                    'Follows',
                    'When someone follows you',
                    _followsEnabled,
                    (value) => setState(() => _followsEnabled = value),
                  ),
                  _buildSwitchTile(
                    'Messages',
                    'When you receive new messages',
                    _messagesEnabled,
                    (value) => setState(() => _messagesEnabled = value),
                  ),
                  _buildSwitchTile(
                    'Posts',
                    'When someone you follow posts new content',
                    _postsEnabled,
                    (value) => setState(() => _postsEnabled = value),
                  ),
                  SizedBox(height: 24),
                  _buildSectionHeader('Marketing'),
                  _buildSwitchTile(
                    'Marketing Emails',
                    'Receive promotional content and updates',
                    _marketingEnabled,
                    (value) => setState(() => _marketingEnabled = value),
                  ),
                  SizedBox(height: 24),
                  _buildSectionHeader('Email Notifications'),
                  _buildSwitchTile(
                    'Email Notifications',
                    'Receive notifications via email',
                    _emailEnabled,
                    (value) => setState(() => _emailEnabled = value),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF69B4),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
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

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFFFF69B4),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
