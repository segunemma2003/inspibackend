import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/auth_api_service.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Sign in with Google
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('🔐 FirebaseAuth: Starting Google sign in...');

      // Use Firebase Auth Google provider directly
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Sign in to Firebase with Google
      final UserCredential userCredential =
          await _auth.signInWithProvider(googleProvider);
      final User? user = userCredential.user;

      if (user != null) {
        print('✅ FirebaseAuth: Firebase user created: ${user.email}');

        // Get the Firebase ID token
        final String? idToken = await user.getIdToken();

        if (idToken != null) {
          // Send to your backend for verification and user creation
          final response = await _verifyFirebaseToken(idToken, user);
          return response;
        }
      }

      return null;
    } catch (e) {
      print('❌ FirebaseAuth: Google sign in error: $e');
      return null;
    }
  }

  /// Sign in with Apple
  Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      print('🔐 FirebaseAuth: Starting Apple sign in...');

      // Request Apple ID credential
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print('✅ FirebaseAuth: Apple credential obtained');

      // Create Firebase credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // Sign in to Firebase with Apple credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);
      final User? user = userCredential.user;

      if (user != null) {
        print('✅ FirebaseAuth: Firebase user created: ${user.email}');

        // Get the Firebase ID token
        final String? idToken = await user.getIdToken();

        if (idToken != null) {
          // Send to your backend for verification and user creation
          final response = await _verifyFirebaseToken(idToken, user);
          return response;
        }
      }

      return null;
    } catch (e) {
      print('❌ FirebaseAuth: Apple sign in error: $e');
      return null;
    }
  }

  /// Verify Firebase token with your backend
  Future<Map<String, dynamic>?> _verifyFirebaseToken(
      String idToken, User user) async {
    try {
      print('🔐 FirebaseAuth: Verifying token with backend...');

      final response = await api<AuthApiService>(
        (request) => request.verifyFirebaseToken(
          token: idToken,
          email: user.email ?? '',
          name: user.displayName ?? user.email ?? 'User',
        ),
      );

      if (response != null && response['success'] == true) {
        print('✅ FirebaseAuth: Backend verification successful');

        // Store authentication data in Nylo Auth
        await Auth.authenticate(data: {
          'token': response['data']['token'],
          'user': response['data']['user'],
          'authenticated_at': DateTime.now().toIso8601String(),
        });

        return response['data'];
      }

      return null;
    } catch (e) {
      print('❌ FirebaseAuth: Backend verification failed: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      print('🔐 FirebaseAuth: Signing out...');

      // Sign out from Firebase
      await _auth.signOut();

      // Clear Nylo Auth
      await Auth.logout();

      print('✅ FirebaseAuth: Sign out successful');
    } catch (e) {
      print('❌ FirebaseAuth: Sign out error: $e');
    }
  }

  /// Get user profile from Firebase
  Map<String, dynamic>? getFirebaseUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return {
      'id': user.uid,
      'email': user.email,
      'name': user.displayName,
      'photo_url': user.photoURL,
      'email_verified': user.emailVerified,
    };
  }
}
