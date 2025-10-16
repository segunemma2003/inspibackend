import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../networking/auth_api_service.dart';
import 'package:flutter_app/app/services/auth_service.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  final AuthApiService _authApiService = AuthApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get current user
  User? get currentUser => _auth.currentUser;
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Create a new GoogleAuthProvider instance
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Add any additional scopes if needed
      // googleProvider.addScope('https://www.googleapis.com/auth/userinfo.email');
      // googleProvider.addScope('https://www.googleapis.com/auth/userinfo.profile');

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
          code: 'token-error',
          message: 'Failed to get ID token from Google',
        );
      }

      // Send to backend
      return await _sendToBackend(
        user: user,
        idToken: idToken,
        provider: 'google',
      );
    } catch (e) {
      print('Google sign in error: $e');
      rethrow;
    }
  }

  /// Sign in with Apple
  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw FirebaseAuthException(
          code: 'sign-in-failed',
          message: 'Failed to sign in with Apple',
        );
      }

      // Get the ID token for backend authentication
      final String? idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'token-error',
          message: 'Failed to get ID token from Apple',
        );
      }

      // Prepare user data for backend
      final userData = {
        'givenName': appleCredential.givenName,
        'familyName': appleCredential.familyName,
        'email': appleCredential.email,
      };

      // Send to backend
      return await _sendToBackend(
        user: userCredential.user!,
        idToken: idToken,
        provider: 'apple',
        additionalData: userData,
      );
    } catch (e) {
      print('Apple sign in error: $e');
      rethrow;
    }
  }

  /// Verifies the Firebase token with the backend and handles the session
  Future<Map<String, dynamic>> _sendToBackend({
    required User user,
    required String idToken,
    required String provider,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Get user email and name
      final email = user.email ?? additionalData?['email'];
      if (email == null) {
        throw Exception('Email is required but not provided');
      }

      final name = user.displayName ??
          '${additionalData?['givenName'] ?? ''} ${additionalData?['familyName'] ?? ''}'
              .trim();

      // Call backend API
      final response = await _authApiService.verifyFirebaseToken(
        token: idToken,
        provider: provider,
        email: email,
        name: name.isNotEmpty ? name : email.split('@')[0],
      );

      if (response == null || response['success'] != true) {
        throw Exception(response?['message'] ?? 'Authentication failed');
      }

      final token = response['data']?['token'];
      final userData = response['data']?['user'] ?? {};

      if (token == null) {
        throw Exception('No authentication token received');
      }

      // Save the auth token and update auth state
      await _updateAuthState(token, userData);

      return {
        'success': true,
        'user': userData,
        'token': token,
      };
    } catch (e) {
      print('Error in _sendToBackend: $e');
      rethrow;
    }
  }

  /// Updates the authentication state in the app
  Future<void> _updateAuthState(
      String token, Map<String, dynamic> userData) async {
    try {
      final Map<String, dynamic> authData = {
        'token': token,
        'user': userData,
        'authenticated_at': DateTime.now().toIso8601String(),
      };
      print(
          '🔑 FirebaseAuthService: Calling AuthService.instance.storeAuthData with authData: $authData');
      await AuthService.instance.storeAuthData(authData);
    } catch (e) {
      print('Error updating auth state: $e');
      rethrow;
    }
  }

  Future<void> updateAuthStates(
      String token, Map<String, dynamic> userData) async {
    try {
      final Map<String, dynamic> authData = {
        'token': token,
        'user': userData,
        'authenticated_at': DateTime.now().toIso8601String(),
      };
      print(
          '🔑 FirebaseAuthService: Calling AuthService.instance.storeAuthData with authData: $authData');
      await AuthService.instance.storeAuthData(authData);
    } catch (e) {
      print('Error updating auth state: $e');
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Clear Nylo auth state
      await AuthService.instance.clearAuth();
      cache().flush();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
}
