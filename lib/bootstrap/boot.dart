import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '/resources/widgets/splash_screen.dart';
import '/bootstrap/app.dart';
import '/config/providers.dart';
import '/app/services/firebase_messaging_service.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Boot
|--------------------------------------------------------------------------
| The boot class is used to initialize your application.
| Providers are booted in the order they are defined.
|-------------------------------------------------------------------------- */

class Boot {
  /// This method is called to initialize Inspiritag.
  static Future<Nylo> nylo() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (getEnv('SHOW_SPLASH_SCREEN', defaultValue: false)) {
      runApp(SplashScreen.app());
    }

    await _setup();
    return await bootApplication(providers);
  }

  /// This method is called after Inspiritag is initialized.
  static Future<void> finished(Nylo nylo) async {
    await bootFinished(nylo, providers);

    runApp(Main(nylo));
  }
}

/* Setup
|--------------------------------------------------------------------------
| You can use _setup to initialize classes, variables, etc.
| It's run before your app providers are booted.
|-------------------------------------------------------------------------- */

_setup() async {
  /// Initialize Firebase Core
  try {
    print('🔥 ===== INITIALIZING FIREBASE CORE =====');
    await Firebase.initializeApp();
    print('✅ Firebase Core initialized successfully');
    print('🔥 ======================================');
  } catch (e) {
    print('❌ Firebase Core initialization failed: $e');
    print('🔥 ======================================');
    rethrow;
  }

  /// Initialize Firebase Messaging for background notifications
  try {
    print('📱 ===== INITIALIZING FIREBASE MESSAGING =====');
    await FirebaseMessagingService().initialize();
    print('✅ Firebase Messaging initialized successfully');

    // Debug notification setup
    await FirebaseMessagingService().debugNotificationSetup();

    print('📱 ===========================================');
  } catch (e) {
    print('❌ Firebase Messaging initialization failed: $e');
    print('📱 ===========================================');
    // Don't rethrow here as messaging is not critical for app startup
  }

  /// Register device for push notifications if user is authenticated
  try {
    print('📱 ===== CHECKING FOR DEVICE REGISTRATION =====');
    // Check if user is authenticated and register device
    if (await Auth.isAuthenticated()) {
      print(
          '📱 User is authenticated, registering device for push notifications');
      await FirebaseMessagingService().registerDevice();
      print('✅ Device registered for push notifications');
    } else {
      print('📱 User not authenticated, skipping device registration');
    }
    print('📱 ===========================================');
  } catch (e) {
    print('❌ Device registration failed: $e');
    print('📱 ===========================================');
    // Don't rethrow here as device registration is not critical for app startup
  }

  /// Example: Initializing StorageConfig
  // StorageConfig.init(
  //   androidOptions: AndroidOptions(
  //     resetOnError: true,
  //     encryptedSharedPreferences: false
  //   )
  // );
}
