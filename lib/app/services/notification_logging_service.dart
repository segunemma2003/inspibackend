

class NotificationLoggingService {
  static final NotificationLoggingService _instance =
      NotificationLoggingService._internal();
  factory NotificationLoggingService() => _instance;
  NotificationLoggingService._internal();

  static void logNotificationSent({
    required String title,
    required String body,
    String? userId,
    String? deviceToken,
    Map<String, dynamic>? data,
    String? notificationType,
  }) {
    print('📤 ===== NOTIFICATION SENT FROM SERVER =====');
    print('📤 Timestamp: ${DateTime.now().toIso8601String()}');
    print('📤 Title: $title');
    print('📤 Body: $body');
    print('📤 User ID: $userId');
    print('📤 Device Token: ${deviceToken?.substring(0, 20)}...');
    print('📤 Notification Type: $notificationType');

    if (data != null && data.isNotEmpty) {
      print('📤 ===== NOTIFICATION DATA PAYLOAD =====');
      data.forEach((key, value) {
        print('📤 Data[$key]: $value');
      });
      print('📤 =====================================');
    }

    print('📤 ===========================================');
  }

  static void logNotificationReceived({
    required String messageId,
    required String from,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    String? appState,
  }) {
    print('📥 ===== NOTIFICATION RECEIVED BY APP =====');
    print('📥 Timestamp: ${DateTime.now().toIso8601String()}');
    print('📥 Message ID: $messageId');
    print('📥 From: $from');
    print('📥 Title: $title');
    print('📥 Body: $body');
    print('📥 App State: $appState');

    if (data != null && data.isNotEmpty) {
      print('📥 ===== RECEIVED DATA PAYLOAD =====');
      data.forEach((key, value) {
        print('📥 Data[$key]: $value');
      });
      print('📥 =================================');
    }

    print('📥 ===========================================');
  }

  static void logNotificationDelivery({
    required String messageId,
    required bool delivered,
    String? error,
    String? deviceToken,
  }) {
    print('📊 ===== NOTIFICATION DELIVERY STATUS =====');
    print('📊 Timestamp: ${DateTime.now().toIso8601String()}');
    print('📊 Message ID: $messageId');
    print('📊 Delivered: $delivered');
    print('📊 Device Token: ${deviceToken?.substring(0, 20)}...');
    if (error != null) {
      print('📊 Error: $error');
    }
    print('📊 =========================================');
  }

  static void logNotificationTapped({
    required String messageId,
    required String from,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    String? navigationRoute,
  }) {
    print('👆 ===== NOTIFICATION TAPPED =====');
    print('👆 Timestamp: ${DateTime.now().toIso8601String()}');
    print('👆 Message ID: $messageId');
    print('👆 From: $from');
    print('👆 Title: $title');
    print('👆 Body: $body');
    print('👆 Navigation Route: $navigationRoute');

    if (data != null && data.isNotEmpty) {
      print('👆 ===== TAPPED DATA PAYLOAD =====');
      data.forEach((key, value) {
        print('👆 Data[$key]: $value');
      });
      print('👆 ===============================');
    }

    print('👆 ===========================================');
  }

  static void logFCMTokenEvent({
    required String event,
    String? token,
    String? error,
  }) {
    print('🔑 ===== FCM TOKEN EVENT =====');
    print('🔑 Timestamp: ${DateTime.now().toIso8601String()}');
    print('🔑 Event: $event');
    print('🔑 Token: ${token?.substring(0, 20)}...');
    if (error != null) {
      print('🔑 Error: $error');
    }
    print('🔑 ===========================================');
  }

  static void logDeviceRegistration({
    required String event,
    String? deviceToken,
    String? deviceType,
    String? userId,
    bool? success,
    String? error,
  }) {
    print('📱 ===== DEVICE REGISTRATION EVENT =====');
    print('📱 Timestamp: ${DateTime.now().toIso8601String()}');
    print('📱 Event: $event');
    print('📱 Device Token: ${deviceToken?.substring(0, 20)}...');
    print('📱 Device Type: $deviceType');
    print('📱 User ID: $userId');
    print('📱 Success: $success');
    if (error != null) {
      print('📱 Error: $error');
    }
    print('📱 ===========================================');
  }

  static void logPermissionEvent({
    required String event,
    bool? granted,
    String? status,
    String? error,
  }) {
    print('🔐 ===== NOTIFICATION PERMISSION EVENT =====');
    print('🔐 Timestamp: ${DateTime.now().toIso8601String()}');
    print('🔐 Event: $event');
    print('🔐 Granted: $granted');
    print('🔐 Status: $status');
    if (error != null) {
      print('🔐 Error: $error');
    }
    print('🔐 ===========================================');
  }

  static void logCounterEvent({
    required String event,
    int? count,
    String? operation,
  }) {
    print('🔢 ===== NOTIFICATION COUNTER EVENT =====');
    print('🔢 Timestamp: ${DateTime.now().toIso8601String()}');
    print('🔢 Event: $event');
    print('🔢 Count: $count');
    print('🔢 Operation: $operation');
    print('🔢 ===========================================');
  }
}
