import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInPage extends NyStatefulWidget {
  static RouteView path = ("/sign-in", (_) => SignInPage());

  SignInPage({super.key}) : super(child: () => _SignInPageState());
}

class _SignInPageState extends NyPage<SignInPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
            onPressed: () {
              showToastSuccess(
                  title: "Forgot Password",
                  description: "Navigate to forgot password");
            },
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
        onPressed: () {
          showToastSuccess(description: "Login successful");
          routeTo('/base');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
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
    return Column(
      children: [
        // Google and Apple buttons
        Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    showToastSuccess(
                        title: "Google", description: "Sign in with Google");
                  },
                  icon: Text(
                    'G',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                  label: const Text(
                    'Google',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    showToastSuccess(
                        title: "Apple", description: "Sign in with Apple");
                  },
                  icon: Icon(
                    FontAwesomeIcons.apple,
                    size: 18,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Apple',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
