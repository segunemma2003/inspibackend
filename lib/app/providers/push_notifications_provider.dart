import 'package:nylo_framework/nylo_framework.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '/app/services/firebase_messaging_service.dart';

class PushNotificationsProvider implements NyProvider {
  @override
  boot(Nylo nylo) async {
    // Initialize local notifications
    nylo.useLocalNotifications();

    // Set up Firebase Cloud Messaging background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    return nylo;
  }

  @override
  afterBoot(Nylo nylo) async {
    // Initialize Firebase Messaging service
    try {
      await FirebaseMessagingService().initialize();
      print('✅ Push Notifications Provider initialized successfully');
    } catch (e) {
      print('❌ Error initializing Push Notifications Provider: $e');
    }
  }
}
