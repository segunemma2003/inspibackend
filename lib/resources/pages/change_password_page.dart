import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/networking/auth_api_service.dart';
import 'package:flutter_app/resources/pages/sign_in_page.dart'; // Navigate back to SignInPage
import 'package:flutter_app/config/keys.dart'; // For constants like EmailKey, OtpKey

class ChangePasswordPage extends NyStatefulWidget {
  static RouteView path = ("/change-password", (_) => ChangePasswordPage());

  ChangePasswordPage({super.key})
      : super(child: () => _ChangePasswordPageState());
}

class _ChangePasswordPageState extends NyPage<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthApiService _authApiService = AuthApiService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? email;
  String? otp;

  @override
  get init => () {
        final dynamic routeData = widget.data;
        if (routeData is Map<String, dynamic>) {
          email = routeData[EmailKey];
          otp = routeData[OtpKey];
        }

        if (email == null || otp == null) {
          // Handle case where email or OTP is not passed, maybe navigate back or show error
          Navigator.pop(context);
          return;
        }
      };

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required'.tr();
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters'.tr();
    }
    if (value.length > 50) {
      return 'Password must be less than 50 characters'.tr();
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password'.tr();
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match'.tr();
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authApiService.resetPassword(
        email: email!,
        otp: otp!,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      // Ensure the response is a Map before proceeding with specific error parsing
      if (response == null || !(response is Map<String, dynamic>)) {
        showToastNotification(
          context,
          title: "Error".tr(),
          description:
              "An unexpected server response was received. Please try again."
                  .tr(),
          style: ToastNotificationStyleType.danger,
        );
        return;
      }

      if (response['success'] == true) {
        showToastNotification(
          context,
          title: "Success".tr(),
          description: response['message'] ??
              "Password reset successfully. Please login with your new password."
                  .tr(),
          style: ToastNotificationStyleType.success,
        );
        Navigator.pushReplacementNamed(
          context,
          SignInPage.path.$1,
        ); // Navigate to login page
      } else {
        final message = response['message'] ?? "Failed to reset password.".tr();
        final errors = response['errors'];

        if (errors != null) {
          final fieldErrors = <String>[];
          errors.forEach((field, errorList) {
            if (errorList is List && errorList.isNotEmpty) {
              fieldErrors.add('${field.toUpperCase()}: ${errorList.first}');
            }
          });

          if (fieldErrors.isNotEmpty) {
            showToastNotification(
              context,
              title: "Validation Error".tr(),
              description: fieldErrors.join('\n'),
              style: ToastNotificationStyleType.danger,
            );
            return;
          }
        }

        showToastNotification(
          context,
          title: "Error".tr(),
          description: message,
          style: ToastNotificationStyleType.danger,
        );
      }
    } on TypeError catch (e) {
      print('🔐 ChangePassword: TypeError: $e');
      showToastNotification(
        context,
        title: "Error".tr(),
        description:
            "An unexpected data format was received from the server. Please try again."
                .tr(),
        style: ToastNotificationStyleType.danger,
      );
    } catch (e) {
      print('🔐 ChangePassword: Error: $e');
      showToastNotification(
        context,
        title: "Error".tr(),
        description: 'Failed to reset password: ${e.toString()}'.tr(),
        style: ToastNotificationStyleType.danger,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Consistent background color
      appBar: AppBar(
        title: Text("Change Password".tr()),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
        iconTheme: IconThemeData(color: Colors.black), // Dark icons
        titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold), // Dark title text
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40), // Increased spacing
                Text(
                  "Set your new password".tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black, // Dark text color
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "New Password".tr(),
                    labelText: 'New Password'.tr(), // Label text
                    hintStyle:
                        TextStyle(color: Colors.grey[600]), // Hint text color
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                      borderSide:
                          BorderSide(color: Colors.grey[300]!), // Light border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey[300]!), // Light border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Color(0xFF00BFFF)), // Focused border color
                    ),
                    prefixIcon: Icon(Icons.lock_outlined,
                        color: Colors.grey[600]), // Icon color
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "Confirm New Password".tr(),
                    labelText: 'Confirm New Password'.tr(), // Label text
                    hintStyle:
                        TextStyle(color: Colors.grey[600]), // Hint text color
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                      borderSide:
                          BorderSide(color: Colors.grey[300]!), // Light border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey[300]!), // Light border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Color(0xFF00BFFF)), // Focused border color
                    ),
                    prefixIcon: Icon(Icons.lock_reset_outlined,
                        color: Colors.grey[600]), // Icon color
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isLoading
                          ? const Color(0xFF00BFFF)
                          : Colors.grey[400], // Themed background
                      foregroundColor: Colors.white, // White text
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0, // No shadow
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text("Change Password".tr(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w600)), // Themed text style
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
