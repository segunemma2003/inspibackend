import 'package:nylo_framework/nylo_framework.dart';
import 'bootstrap/boot.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '/app/services/firebase_messaging_service.dart';
import '/app/services/auth_service.dart'; // Import auth instance

/// Inspiritag - Framework for Flutter Developers
/// Docs: https://inspiritag.dev/docs/6.x

/// Main entry point for the application.
void main() async {
  // Register background message handler

  await Nylo.init(
    setup: Boot.nylo,
    setupFinished: Boot.finished,

    // appLifecycle: {
    //   // Uncomment the code below to enable app lifecycle events
    //   AppLifecycleState.resumed: () {
    //     print("App resumed");
    //   },
    //   AppLifecycleState.paused: () {
    //     print("App paused");
    //   },
    // }

    // showSplashScreen: true,
    // Uncomment showSplashScreen to show the splash screen
    // File: lib/resources/widgets/splash_screen.dart
  );
}
