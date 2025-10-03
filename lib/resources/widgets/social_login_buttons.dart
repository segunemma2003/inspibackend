import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/services/firebase_auth_service.dart';

class SocialLoginButtons extends NyStatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  SocialLoginButtons({
    super.key,
    this.onSuccess,
    this.onError,
  });

  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends NyState<SocialLoginButtons> {
  bool _isLoadingGoogle = false;
  bool _isLoadingApple = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Google Sign In Button
        _buildGoogleButton(),
        const SizedBox(height: 16),

        // Apple Sign In Button
        _buildAppleButton(),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoadingGoogle ? null : _signInWithGoogle,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: _isLoadingGoogle
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.login,
                    size: 20,
                    color: Color(0xFF4285F4),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAppleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoadingApple ? null : _signInWithApple,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoadingApple
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.apple,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Apple',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoadingGoogle = true);

    try {
      final result = await FirebaseAuthService().signInWithGoogle();

      if (result != null) {
        showToast(
          title: 'Success',
          description: 'Signed in with Google successfully!',
        );
        widget.onSuccess?.call();
        routeTo('/base');
      } else {
        widget.onError?.call();
      }
    } catch (e) {
      print('Google sign in error: $e');
      showToast(
        title: 'Error',
        description: 'Google sign in failed: $e',
      );
      widget.onError?.call();
    } finally {
      setState(() => _isLoadingGoogle = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoadingApple = true);

    try {
      final result = await FirebaseAuthService().signInWithApple();

      if (result != null) {
        showToast(
          title: 'Success',
          description: 'Signed in with Apple successfully!',
        );
        widget.onSuccess?.call();
        routeTo('/base');
      } else {
        widget.onError?.call();
      }
    } catch (e) {
      print('Apple sign in error: $e');
      showToast(
        title: 'Error',
        description: 'Apple sign in failed: $e',
      );
      widget.onError?.call();
    } finally {
      setState(() => _isLoadingApple = false);
    }
  }
}
