import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SignUpPage extends NyStatefulWidget {
  static RouteView path = ("/sign-up", (_) => SignUpPage());

  SignUpPage({super.key}) : super(child: () => _SignUpPageState());
}

class _SignUpPageState extends NyPage<SignUpPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  get init => () {};

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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

              const SizedBox(height: 20),

              // Sign In Link
              _buildSignInLink(),

              const SizedBox(height: 20),
            ],
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
        ),

        const SizedBox(height: 20),

        // Email Field
        _buildTextField(
          controller: _emailController,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 20),

        // Username Field
        _buildTextField(
          controller: _usernameController,
          hintText: 'Username',
        ),

        const SizedBox(height: 20),

        // Password Field
        _buildPasswordField(
          controller: _passwordController,
          hintText: 'Password',
          isVisible: _isPasswordVisible,
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
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
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' and ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
        onPressed: _agreeToTerms
            ? () {
                showToastSuccess(description: "Account creation successful");
                routeTo('/base');
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _agreeToTerms ? Colors.grey[400] : Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Create Account',
          style: TextStyle(
            color: Colors.grey[700],
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
