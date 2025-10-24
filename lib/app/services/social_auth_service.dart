import 'package:firebase_auth/firebase_auth.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../networking/auth_api_service.dart';

// Initialize Firebase Auth
final FirebaseAuth _auth = FirebaseAuth.instance;

class SocialAuthService {
  static final SocialAuthService _instance = SocialAuthService._internal();
  final AuthApiService _authApiService = AuthApiService();

  factory SocialAuthService() => _instance;
  SocialAuthService._internal();

  /// Signs in with Google using Firebase's built-in provider
  /// Returns null if the user cancels the sign-in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Create a new GoogleAuthProvider instance
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Optional: Add additional scopes if needed
      // googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');

      // Sign in with the Google provider
      final UserCredential userCredential =
          await _auth.signInWithProvider(googleProvider);
      final User? user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'sign-in-failed',
          message: 'Failed to sign in with Google',
        );
      }

      // Get the ID token for backend authentication
      final String? idToken = await user.getIdToken();
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'sign-in-failed',
          message: 'Failed to get ID token from Google sign in',
        );
      }

      // Send user data to backend
      await _sendToBackend(
        user: user,
        idToken: idToken,
        provider: 'google',
      );

      return userCredential;
    } catch (e) {
      print('Google sign in error: $e');
      rethrow;
    }
  }

  /// Verifies the Firebase token with the backend and handles the session
  Future<void> _sendToBackend({
    required User user,
    required String idToken,
    required String provider,
  }) async {
    try {
      final response = await _authApiService.verifyFirebaseToken(
        token: idToken,
        provider: provider,
        email: user!.email!,
        name: user!.displayName!,
      );

      if (response != null &&
          response['success'] == true &&
          response['data'] != null) {
        final token = response['data']['token'];
        // final userData = response['data']['user'];

        if (token != null) {
          // Update Nylo's auth state
          return;
        }
      }

      throw Exception(
          response?['message'] ?? 'Failed to authenticate with backend');
    } catch (e) {
      print('Authentication error: $e');
      rethrow;
    }
  }

  /// Signs out the current user from Firebase
  Future<void> signOut() async {
    try {
      await _auth.signOut();

      // Clear Nylo auth state
      await Auth.logout();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Signs in with Apple using Firebase's built-in provider
  Future<UserCredential?> signInWithApple() async {
    try {
      // Create a new OAuthProvider for Apple
      final appleProvider = OAuthProvider('apple.com');

      // Request the sign-in
      final UserCredential userCredential =
          await _auth.signInWithProvider(appleProvider);
      final User? user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'sign-in-failed',
          message: 'Failed to sign in with Apple',
        );
      }

      // Get the ID token for backend authentication
      final String? idToken = await user.getIdToken();
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'sign-in-failed',
          message: 'Failed to get ID token from Apple sign in',
        );
      }

      // Send user data to backend
      await _sendToBackend(
        user: user,
        idToken: idToken,
        provider: 'apple',
      );

      return userCredential;
    } catch (e) {
      print('Apple sign in error: $e');
      rethrow;
    }
  }
}
