import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/auth_api_service.dart';
import '/resources/widgets/social_login_buttons.dart';

class SignInPage extends NyStatefulWidget {
  static RouteView path = ("/sign-in", (_) => SignInPage());

  SignInPage({super.key}) : super(child: () => _SignInPageState());
}

class _SignInPageState extends NyPage<SignInPage> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  get init => () {};

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
                const SizedBox(height: 40),

                // Logo Section
                _buildLogoSection(),

                // Tagline
                _buildTagline(),

                const SizedBox(height: 40),

                // Input Fields
                _buildInputFields(),

                const SizedBox(height: 30),

                // Login Button
                _buildLoginButton(),

                const SizedBox(height: 30),

                // Divider
                _buildDivider(),

                const SizedBox(height: 30),

                // Social Login Buttons
                _buildSocialButtons(),

                const SizedBox(height: 40),

                // Sign Up Link
                _buildSignUpLink(),

                const SizedBox(height: 40),
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

  Widget _buildTagline() {
    return Text(
      'Where Self Expression Meets\nInspiration and Recognition',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        // Email Field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email address',
            prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF00BFFF)),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Password Field
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          validator: _validatePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF00BFFF)),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Forgot Password Link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgotPassword,
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: !_isLoading ? _signIn : null,
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
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
        print('✅ Social login successful');
      },
      onError: () {
        print('❌ Social login failed');
      },
    );
  }

  Widget _buildSignUpLink() {
    return GestureDetector(
      onTap: () {
        routeTo('/sign-up');
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'New user? ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
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

  // Validation methods
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  // API Integration
  Future<void> _signIn() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      showToast(
          title: 'Validation Error',
          description: 'Please fix the errors above');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await api<AuthApiService>(
        (request) => request.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );

      if (response != null && response['success'] == true) {
        // Store user data and token for session management
        if (response['data'] != null) {
          final userData = response['data']['user'];
          final token = response['data']['token'];

          print('🔐 SignIn: Storing authentication data...');
          print('🔐 SignIn: Token: $token');
          print('🔐 SignIn: User: $userData');

          // Store authentication data for session management
          await Auth.authenticate(data: {
            'token': token,
            'user': userData,
            'authenticated_at': DateTime.now().toIso8601String(),
          });

          print('🔐 SignIn: Authentication data stored successfully');

          showToast(
              title: 'Success',
              description: 'Welcome back, ${userData['name'] ?? 'User'}!');
        }

        // Navigate to main app
        routeTo('/base');
      } else {
        // Handle API validation errors
        final message = response?['message'] ?? 'Failed to sign in';
        final errors = response?['errors'];

        if (errors != null && errors is Map<String, dynamic>) {
          // Show specific field errors
          final fieldErrors = <String>[];
          errors.forEach((field, errorList) {
            if (errorList is List && errorList.isNotEmpty) {
              fieldErrors.add('${field.toUpperCase()}: ${errorList.first}');
            }
          });

          if (fieldErrors.isNotEmpty) {
            showToast(
                title: 'Validation Error', description: fieldErrors.join('\n'));
            return;
          }
        }

        showToast(title: 'Error', description: message);
      }
    } catch (e) {
      showToast(title: 'Error', description: 'Failed to sign in: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      showToast(
          title: 'Error', description: 'Please enter your email address first');
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      showToast(
          title: 'Error', description: 'Please enter a valid email address');
      return;
    }

    try {
      final response = await api<AuthApiService>(
        (request) =>
            request.forgotPassword(email: _emailController.text.trim()),
      );

      if (response != null && response['success'] == true) {
        showToast(
            title: 'Success',
            description: 'Password reset link sent to your email');
      } else {
        // Handle API validation errors
        final message = response?['message'] ?? 'Failed to send reset link';
        final errors = response?['errors'];

        if (errors != null && errors is Map<String, dynamic>) {
          // Show specific field errors
          final fieldErrors = <String>[];
          errors.forEach((field, errorList) {
            if (errorList is List && errorList.isNotEmpty) {
              fieldErrors.add('${field.toUpperCase()}: ${errorList.first}');
            }
          });

          if (fieldErrors.isNotEmpty) {
            showToast(
                title: 'Validation Error', description: fieldErrors.join('\n'));
            return;
          }
        }

        showToast(title: 'Error', description: message);
      }
    } catch (e) {
      showToast(title: 'Error', description: 'Failed to send reset link: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
