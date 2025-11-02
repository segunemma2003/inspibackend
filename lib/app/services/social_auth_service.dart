import 'package:firebase_auth/firebase_auth.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../networking/auth_api_service.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SocialAuthService {
  static final SocialAuthService _instance = SocialAuthService._internal();
  final AuthApiService _authApiService = AuthApiService();

  factory SocialAuthService() => _instance;
  SocialAuthService._internal();

  Future<UserCredential?> signInWithGoogle() async {
    try {

      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      final UserCredential userCredential =
          await _auth.signInWithProvider(googleProvider);
      final User? user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'sign-in-failed',
          message: 'Failed to sign in with Google',
        );
      }

      final String? idToken = await user.getIdToken();
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'sign-in-failed',
          message: 'Failed to get ID token from Google sign in',
        );
      }

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

        if (token != null) {

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

  Future<void> signOut() async {
    try {
      await _auth.signOut();

      await Auth.logout();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithApple() async {
    try {

      final appleProvider = OAuthProvider('apple.com');

      final UserCredential userCredential =
          await _auth.signInWithProvider(appleProvider);
      final User? user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'sign-in-failed',
          message: 'Failed to sign in with Apple',
        );
      }

      final String? idToken = await user.getIdToken();
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'sign-in-failed',
          message: 'Failed to get ID token from Apple sign in',
        );
      }

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
