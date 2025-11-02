import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/app/services/social_auth_service.dart';

class FirebaseProvider implements NyProvider {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  boot(Nylo nylo) async {
    try {

      _isInitialized = true;
      print('✅ Firebase provider booted successfully');
    } catch (e) {
      print('❌ Firebase provider boot error: $e');
      rethrow;
    }
  }

  void _setupAuthStateListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        print('🔥 User is signed in: ${user.uid}');

        await Auth.authenticate(data: {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'isAnonymous': user.isAnonymous,
          'isEmailVerified': user.emailVerified,
          'providerData': user.providerData.map((e) => e.providerId).toList(),
          'authenticated_at': DateTime.now().toIso8601String(),
        });
      } else {
        print('👤 User is signed out');

        await Auth.logout();
      }
    });
  }

  Future<void> signOut() async {
    try {
      await SocialAuthService().signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ Signed out from Firebase');
    } catch (e) {
      print('❌ Error signing out: $e');
      rethrow;
    }
  }

  bool isUserSignedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  afterBoot(Nylo nylo) async {
    _setupAuthStateListener();
  }
}
