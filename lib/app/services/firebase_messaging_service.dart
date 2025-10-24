import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/notification_api_service.dart';
import '/app/networking/device_api_service.dart';
import '/app/services/notification_counter_service.dart';
import '/app/services/notification_logging_service.dart';

/// Firebase Cloud Messaging Service
/// Handles push notifications, token management, and notification processing
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  bool _isInitialized = false;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Register device for push notifications
  Future<void> registerDevice() async {
    if (_fcmToken == null) {
      print(
          '📱 FirebaseMessagingService: No FCM token available for device registration');
      return;
    }

    try {
      print(
          '📱 FirebaseMessagingService: Registering device with token: $_fcmToken');

      final response = await api<DeviceApiService>(
        (request) => request.registerDevice(
          deviceToken: _fcmToken!,
          deviceType: DeviceApiService.getDeviceType(),
          deviceName: DeviceApiService.getDeviceName(),
          appVersion: '1.0.0', // You can get this from package_info_plus
          osVersion: DeviceApiService.getOsVersion(),
        ),
      );

      if (response != null && response['success'] == true) {
        print('📱 FirebaseMessagingService: Device registered successfully');
        NotificationLoggingService.logDeviceRegistration(
          event: 'registration_success',
          deviceToken: _fcmToken,
          deviceType: DeviceApiService.getDeviceType(),
          userId: 'current_user',
          success: true,
        );
      } else {
        print(
            '❌ FirebaseMessagingService: Failed to register device: $response');
        NotificationLoggingService.logDeviceRegistration(
          event: 'registration_failed',
          deviceToken: _fcmToken,
          deviceType: DeviceApiService.getDeviceType(),
          userId: 'current_user',
          success: false,
          error: 'Server response: $response',
        );
      }
    } catch (e) {
      print('❌ FirebaseMessagingService: Error registering device: $e');
      NotificationLoggingService.logDeviceRegistration(
        event: 'registration_error',
        deviceToken: _fcmToken,
        deviceType: DeviceApiService.getDeviceType(),
        userId: 'current_user',
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    if (_isInitialized) {
      print('🔥 Firebase Messaging already initialized');
      return;
    }

    try {
      print('🔥 ===== INITIALIZING FIREBASE MESSAGING =====');
      print('🔥 Platform: ${Platform.isIOS ? "iOS" : "Android"}');
      print('🔥 Firebase Messaging version: ${_firebaseMessaging.toString()}');

      // Request permission for notifications
      await _requestPermission();

      // Get FCM token
      await _getFCMToken();

      // Set up message handlers
      _setupMessageHandlers();

      // Set up token refresh listener
      _setupTokenRefreshListener();

      // Initialize notification counter
      await NotificationCounterService().initialize();

      _isInitialized = true;
      print('🔥 ===== FIREBASE MESSAGING INITIALIZED =====');
      print('✅ Firebase Messaging initialized successfully');
    } catch (e) {
      print('🔥 ===== FIREBASE MESSAGING INITIALIZATION FAILED =====');
      print('❌ Firebase Messaging initialization error: $e');
      print('🔥 ===================================================');
      rethrow;
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('🔥 ===== PERMISSION RESULTS =====');
      print('🔥 Authorization Status: ${settings.authorizationStatus}');
      print('🔥 Alert Setting: ${settings.alert}');
      print('🔥 Badge Setting: ${settings.badge}');
      print('🔥 Sound Setting: ${settings.sound}');
      print('🔥 Announcement Setting: ${settings.announcement}');
      print('🔥 Car Play Setting: ${settings.carPlay}');
      print('🔥 Critical Alert Setting: ${settings.criticalAlert}');
      // Provisional setting not available in this version
      print('🔥 =================================');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('⚠️ User denied notification permissions');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        print('✅ User granted notification permissions');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('🔔 User granted provisional notification permissions');
      }
    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
    }
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('🔑 FCM Token: $_fcmToken');

      if (_fcmToken != null) {
        NotificationLoggingService.logFCMTokenEvent(
          event: 'token_obtained',
          token: _fcmToken,
        );
      } else {
        NotificationLoggingService.logFCMTokenEvent(
          event: 'token_failed',
          error: 'Token is null',
        );
      }

      // Send token to server if user is authenticated
      if (await Auth.isAuthenticated()) {
        await _sendTokenToServer(_fcmToken);
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      NotificationLoggingService.logFCMTokenEvent(
        event: 'token_error',
        error: e.toString(),
      );
    }
  }

  /// Send FCM token to server
  Future<void> _sendTokenToServer(String? token) async {
    if (token == null) return;

    try {
      await api<NotificationApiService>((request) => request.registerFCMToken(
            fcmToken: token,
            deviceType: Platform.isIOS ? 'ios' : 'android',
          ));
      print('✅ FCM token sent to server successfully');
    } catch (e) {
      print('❌ Error sending FCM token to server: $e');
    }
  }

  /// Set up message handlers
  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle messages when app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle messages when app is terminated and opened via notification
    _handleTerminatedMessage();
  }

  /// Set up token refresh listener
  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((String token) async {
      print('🔄 FCM token refreshed: $token');
      _fcmToken = token;

      // Send new token to server if user is authenticated
      if (await Auth.isAuthenticated()) {
        _sendTokenToServer(token);
        // Also register device with new token
        await registerDevice();
      }
    });
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('🔥 ===== FOREGROUND NOTIFICATION RECEIVED =====');
    print('🔥 Timestamp: ${DateTime.now().toIso8601String()}');
    print('🔥 Message ID: ${message.messageId}');
    print('🔥 From: ${message.from}');
    print('🔥 Collapse Key: ${message.collapseKey}');
    print('🔥 Sent Time: ${message.sentTime}');
    print('🔥 TTL: ${message.ttl}');
    print('🔥 Notification Title: ${message.notification?.title}');
    print('🔥 Notification Body: ${message.notification?.body}');
    print('🔥 Notification Android: ${message.notification?.android}');
    print('🔥 Notification Apple: ${message.notification?.apple}');
    print('🔥 Data: ${message.data}');
    print('🔥 Data Keys: ${message.data.keys.toList()}');

    // Log detailed data payload
    if (message.data.isNotEmpty) {
      print('🔥 ===== NOTIFICATION DATA PAYLOAD =====');
      message.data.forEach((key, value) {
        print('🔥 Data[$key]: $value');
      });
      print('🔥 =====================================');
    }

    print('🔥 ===========================================');

    // Log notification received
    NotificationLoggingService.logNotificationReceived(
      messageId: message.messageId ?? 'unknown',
      from: message.from ?? 'unknown',
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      appState: 'foreground',
    );

    // Show local notification for foreground messages
    _showLocalNotification(message);

    // Increment notification counter
    await NotificationCounterService().incrementCount();
  }

  /// Handle background messages
  void _handleBackgroundMessage(RemoteMessage message) {
    print('🔥 ===== BACKGROUND NOTIFICATION RECEIVED =====');
    print('🔥 Timestamp: ${DateTime.now().toIso8601String()}');
    print('🔥 Message ID: ${message.messageId}');
    print('🔥 From: ${message.from}');
    print('🔥 Collapse Key: ${message.collapseKey}');
    print('🔥 Sent Time: ${message.sentTime}');
    print('🔥 TTL: ${message.ttl}');
    print('🔥 Notification Title: ${message.notification?.title}');
    print('🔥 Notification Body: ${message.notification?.body}');
    print('🔥 Notification Android: ${message.notification?.android}');
    print('🔥 Notification Apple: ${message.notification?.apple}');
    print('🔥 Data: ${message.data}');
    print('🔥 Data Keys: ${message.data.keys.toList()}');

    // Log detailed data payload
    if (message.data.isNotEmpty) {
      print('🔥 ===== BACKGROUND NOTIFICATION DATA PAYLOAD =====');
      message.data.forEach((key, value) {
        print('🔥 Data[$key]: $value');
      });
      print('🔥 ================================================');
    }

    print('🔥 ===========================================');

    // Log notification received
    NotificationLoggingService.logNotificationReceived(
      messageId: message.messageId ?? 'unknown',
      from: message.from ?? 'unknown',
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      appState: 'background',
    );

    // Handle navigation based on message data
    _handleMessageNavigation(message);

    // Increment notification counter
    NotificationCounterService().incrementCount();
  }

  /// Handle terminated messages
  Future<void> _handleTerminatedMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('🔥 ===== TERMINATED NOTIFICATION RECEIVED =====');
      print('🔥 Timestamp: ${DateTime.now().toIso8601String()}');
      print('🔥 Message ID: ${initialMessage.messageId}');
      print('🔥 From: ${initialMessage.from}');
      print('🔥 Collapse Key: ${initialMessage.collapseKey}');
      print('🔥 Sent Time: ${initialMessage.sentTime}');
      print('🔥 TTL: ${initialMessage.ttl}');
      print('🔥 Notification Title: ${initialMessage.notification?.title}');
      print('🔥 Notification Body: ${initialMessage.notification?.body}');
      print('🔥 Notification Android: ${initialMessage.notification?.android}');
      print('🔥 Notification Apple: ${initialMessage.notification?.apple}');
      print('🔥 Data: ${initialMessage.data}');
      print('🔥 Data Keys: ${initialMessage.data.keys.toList()}');

      // Log detailed data payload
      if (initialMessage.data.isNotEmpty) {
        print('🔥 ===== TERMINATED NOTIFICATION DATA PAYLOAD =====');
        initialMessage.data.forEach((key, value) {
          print('🔥 Data[$key]: $value');
        });
        print('🔥 ===============================================');
      }

      print('🔥 ===========================================');

      // Log notification received
      NotificationLoggingService.logNotificationReceived(
        messageId: initialMessage.messageId ?? 'unknown',
        from: initialMessage.from ?? 'unknown',
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        data: initialMessage.data,
        appState: 'terminated',
      );

      // Handle navigation based on message data
      _handleMessageNavigation(initialMessage);

      // Increment notification counter
      await NotificationCounterService().incrementCount();
    }
  }

  /// Show local notification for foreground messages
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Use Nylo's local notification system
    pushNotification(
      notification.title ?? 'New Notification',
      notification.body ?? '',
    ).send();
  }

  /// Handle navigation based on message data
  void _handleMessageNavigation(RemoteMessage message) {
    final data = message.data;

    // Handle different notification types
    if (data.containsKey('type')) {
      final type = data['type'];

      switch (type) {
        case 'post_like':
          _navigateToPost(data['post_id']);
          break;
        case 'post_comment':
          _navigateToPost(data['post_id']);
          break;
        case 'follow':
          _navigateToProfile(data['user_id']);
          break;
        case 'message':
          _navigateToMessages(data['conversation_id']);
          break;
        default:
          _navigateToHome();
      }
    } else {
      _navigateToHome();
    }
  }

  /// Navigate to specific post
  void _navigateToPost(String? postId) {
    if (postId != null) {
      // Navigate to post details
      routeTo('/post/$postId');
    } else {
      _navigateToHome();
    }
  }

  /// Navigate to user profile
  void _navigateToProfile(String? userId) {
    if (userId != null) {
      // Navigate to user profile
      routeTo('/profile/$userId');
    } else {
      _navigateToHome();
    }
  }

  /// Navigate to messages
  void _navigateToMessages(String? conversationId) {
    if (conversationId != null) {
      // Navigate to specific conversation
      routeTo('/messages/$conversationId');
    } else {
      // Navigate to messages list
      routeTo('/messages');
    }
  }

  /// Navigate to home
  void _navigateToHome() {
    routeTo('/');
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic $topic: $e');
    }
  }

  /// Send token to server when user logs in
  Future<void> onUserLogin() async {
    if (_fcmToken != null) {
      await _sendTokenToServer(_fcmToken);
    }
  }

  /// Clear token when user logs out
  Future<void> onUserLogout() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      print('✅ FCM token cleared on logout');
    } catch (e) {
      print('❌ Error clearing FCM token: $e');
    }
  }

  /// Debug method to test notification setup
  Future<void> debugNotificationSetup() async {
    print('🔍 ===== NOTIFICATION DEBUG INFO =====');
    print('🔍 FCM Token: $_fcmToken');
    print('🔍 Is Initialized: $_isInitialized');

    // Check notification permissions
    final settings = await _firebaseMessaging.getNotificationSettings();
    print('🔍 Authorization Status: ${settings.authorizationStatus}');
    print('🔍 Alert Setting: ${settings.alert}');
    print('🔍 Badge Setting: ${settings.badge}');
    print('🔍 Sound Setting: ${settings.sound}');

    // Check if device is registered
    if (_fcmToken != null) {
      print('🔍 Device Token Length: ${_fcmToken!.length}');
      print('🔍 Device Token Preview: ${_fcmToken!.substring(0, 20)}...');
    } else {
      print('🔍 ❌ No FCM token available');
    }

    print('🔍 =====================================');
  }

  /// Test method to send a local notification
  Future<void> testLocalNotification() async {
    try {
      print('🧪 ===== TESTING LOCAL NOTIFICATION =====');

      // Create a test message
      final testMessage = RemoteMessage(
        messageId: 'test_${DateTime.now().millisecondsSinceEpoch}',
        from: 'test_sender',
        data: {'test': 'true', 'timestamp': DateTime.now().toIso8601String()},
        notification: RemoteNotification(
          title: 'Test Notification',
          body: 'This is a test notification from the app',
        ),
      );

      // Simulate receiving the message
      await _handleForegroundMessage(testMessage);

      print('🧪 ======================================');
    } catch (e) {
      print('❌ Error testing local notification: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔥 ===== BACKGROUND HANDLER TRIGGERED =====');
  print('🔥 Timestamp: ${DateTime.now().toIso8601String()}');
  print('🔥 Message ID: ${message.messageId}');
  print('🔥 From: ${message.from}');
  print('🔥 Collapse Key: ${message.collapseKey}');
  print('🔥 Sent Time: ${message.sentTime}');
  print('🔥 TTL: ${message.ttl}');
  print('🔥 Notification Title: ${message.notification?.title}');
  print('🔥 Notification Body: ${message.notification?.body}');
  print('🔥 Notification Android: ${message.notification?.android}');
  print('🔥 Notification Apple: ${message.notification?.apple}');
  print('🔥 Data: ${message.data}');
  print('🔥 Data Keys: ${message.data.keys.toList()}');

  // Log detailed data payload
  if (message.data.isNotEmpty) {
    print('🔥 ===== BACKGROUND HANDLER DATA PAYLOAD =====');
    message.data.forEach((key, value) {
      print('🔥 Data[$key]: $value');
    });
    print('🔥 ===========================================');
  }

  print('🔥 ===========================================');

  // Initialize Firebase if not already done
  await Firebase.initializeApp();
  print('🔥 Firebase initialized in background handler');

  // Increment notification counter in background
  try {
    await NotificationCounterService().incrementCount();
    print('🔥 Notification counter incremented in background');
  } catch (e) {
    print('❌ Error incrementing notification counter in background: $e');
  }
}
