import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/auth_api_service.dart';
import '/resources/widgets/social_login_buttons.dart';
import 'package:flutter_app/config/keys.dart';

class SignUpPage extends NyStatefulWidget {
  static RouteView path = ("/sign-up", (_) => SignUpPage());

  SignUpPage({super.key}) : super(child: () => _SignUpPageState());
}

class _SignUpPageState extends NyPage<SignUpPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  get init => () {
        // Empty init - no async operations needed on page load
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Back arrow at top left
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Logo Section
                _buildLogoSection(),

                const SizedBox(height: 30),

                // Page Title
                _buildPageTitle(),

                const SizedBox(height: 20),

                // Tagline
                _buildTagline(),

                const SizedBox(height: 40),

                // Input Fields
                _buildInputFields(),

                const SizedBox(height: 30),

                // Terms and Policy Checkbox
                _buildTermsCheckbox(),

                const SizedBox(height: 40),

                // Create Account Button
                _buildCreateAccountButton(),

                const SizedBox(height: 30),

                // Divider
                _buildDivider(),

                const SizedBox(height: 30),

                // Social Login Buttons
                _buildSocialButtons(),

                const SizedBox(height: 30),

                // Sign In Link
                _buildSignInLink(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo image
        Image.asset(
          'logo.png',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ).localAsset(),

        const SizedBox(height: 20),

        // App name with second 'i' in yellow and 'r' in blue
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'insp',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF69B4), // Bright pink
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'i',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFD700), // Yellow
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'rtag',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00BFFF), // Blue
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageTitle() {
    return Text(
      'Create Account',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      'Join inspirtag and show self expression and inspire others todo the same and tag the pros that helped you with your style',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.black,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        // Full Name Field
        _buildTextField(
          controller: _fullNameController,
          hintText: 'Full Name',
          validator: _validateFullName,
        ),

        const SizedBox(height: 20),

        // Email Field
        _buildTextField(
          controller: _emailController,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),

        const SizedBox(height: 20),

        // Username Field
        _buildTextField(
          controller: _usernameController,
          hintText: 'Username',
          validator: _validateUsername,
        ),

        const SizedBox(height: 20),

        // Password Field
        _buildPasswordField(
          controller: _passwordController,
          hintText: 'Password',
          isVisible: _isPasswordVisible,
          validator: _validatePassword,
          onToggleVisibility: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),

        const SizedBox(height: 20),

        // Confirm Password Field
        _buildPasswordField(
          controller: _confirmPasswordController,
          hintText: 'Confirm Password',
          isVisible: _isConfirmPasswordVisible,
          validator: _validateConfirmPassword,
          onToggleVisibility: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[600],
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          activeColor: Color(0xFF00BFFF),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => routeTo('/terms-of-service'),
                    child: Text(
                      'Terms of Service',
                      style: TextStyle(
                        color: Color(0xFF00BFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                TextSpan(
                  text: ' and ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => routeTo('/privacy-policy'),
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Color(0xFF00BFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: !_isLoading ? _createAccount : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              !_isLoading ? const Color(0xFF00BFFF) : Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return GestureDetector(
      onTap: () {
        routeTo('/sign-in');
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: 'Sign In',
              style: TextStyle(
                color: Color(0xFF00BFFF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return SocialLoginButtons(
      onSuccess: () {
        print('✅ Social sign up successful');
      },
      onError: () {
        print('❌ Social sign up failed');
      },
    );
  }

  // Validation methods
  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.trim().length > 20) {
      return 'Username must be less than 20 characters';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value.trim())) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (value.length > 50) {
      return 'Password must be less than 50 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // API Integration
  Future<void> _createAccount() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      print('⚠️ SignUp Toast: Validation Error - Please fix the errors above');
      showToast(
          title: 'Validation Error',
          description: 'Please fix the errors above');
      return;
    }

    if (!_agreeToTerms) {
      print(
          '⚠️ SignUp Toast: Error - Please agree to the terms and conditions');
      showToast(
          title: 'Error',
          description: 'Please agree to the terms and conditions');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await api<AuthApiService>(
        (request) => request.register(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
          termsAccepted: _agreeToTerms,
        ),
      );

      print('🔐 SignUp: Raw API response type: ${response.runtimeType}');
      print('🔐 SignUp: Raw API response content: $response');

      // Check if response is valid
      if (response == null || !(response is Map<String, dynamic>)) {
        print(
            '⚠️ SignUp Toast: Error - An unexpected server response was received');
        if (mounted) {
          showToastNotification(
            context,
            title: "Error".tr(),
            description:
                "An unexpected server response was received. Please try again."
                    .tr(),
            style: ToastNotificationStyleType.danger,
          );
        }
        return;
      }

      // Process successful response
      if (response['success'] == true) {
        print('✅ SignUp: Registration successful, navigating to OTP...');

        if (mounted) {
          showToastNotification(
            context,
            title: "Registration Successful".tr(),
            description:
                'Please check your email (${_emailController.text.trim()}) for an OTP.'
                    .tr(),
            style: ToastNotificationStyleType.success,
          );

          // Small delay for toast visibility
          await Future.delayed(Duration(milliseconds: 800));

          // Navigate to OTP verification using Nylo route
          if (mounted) {
            routeTo(
              '/verify-otp',
              navigationType: NavigationType.pushReplace,
              queryParameters: {
                EmailKey: _emailController.text.trim(),
                OtpTypeKey: OtpTypeKey_Registration
              },
            );
          }
        }
        return;
      } else {
        // Handle API validation errors
        final message = response['message'] ?? 'Failed to create account'.tr();
        final errors = response['errors'];

        if (errors != null && mounted) {
          // Show specific field errors
          final fieldErrors = <String>[];
          (errors as Map<String, dynamic>).forEach((field, errorList) {
            if (errorList is List && errorList.isNotEmpty) {
              fieldErrors.add('${field.toUpperCase()}: ${errorList.first}');
            }
          });

          if (fieldErrors.isNotEmpty) {
            print(
                '❌ SignUp Toast: Validation Error - ${fieldErrors.join(', ')}');
            showToastNotification(
              context,
              title: "Validation Error".tr(),
              description: fieldErrors.join('\n'),
              style: ToastNotificationStyleType.danger,
            );
            return;
          }
        }

        if (mounted) {
          print('❌ SignUp Toast: Error - $message');
          showToastNotification(
            context,
            title: "Error".tr(),
            description: message,
            style: ToastNotificationStyleType.danger,
          );
        }
      }
    } on TypeError catch (e) {
      print('❌ SignUp TypeError: $e');
      if (mounted) {
        showToastNotification(
          context,
          title: "Error".tr(),
          description:
              "An unexpected data format was received. Please try again.".tr(),
          style: ToastNotificationStyleType.danger,
        );
      }
    } catch (e) {
      print('❌ SignUp Error: $e');
      if (mounted) {
        showToastNotification(
          context,
          title: "Error".tr(),
          description: 'Failed to create account: ${e.toString()}'.tr(),
          style: ToastNotificationStyleType.danger,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearFormFields() {
    _fullNameController.clear();
    _emailController.clear();
    _usernameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _agreeToTerms = false;
      _isPasswordVisible = false;
      _isConfirmPasswordVisible = false;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
