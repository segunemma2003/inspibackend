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

  static Future<Nylo> nylo() async {
    WidgetsFlutterBinding.ensureInitialized();

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

    if (getEnv('SHOW_SPLASH_SCREEN', defaultValue: false)) {
      runApp(SplashScreen.app());
    }

    await _setup();
    return await bootApplication(providers);
  }

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

  print('✅ Boot setup completed');
}
