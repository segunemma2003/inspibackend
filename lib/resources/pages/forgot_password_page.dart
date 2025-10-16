import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/networking/auth_api_service.dart';
import 'package:flutter_app/resources/pages/reset_password_page.dart';
import 'package:flutter_app/config/keys.dart';

class ForgotPasswordPage extends NyStatefulWidget {
  static RouteView path = ("/forgot-password", (_) => ForgotPasswordPage());

  ForgotPasswordPage({super.key})
      : super(child: () => _ForgotPasswordPageState());
}

class _ForgotPasswordPageState extends NyPage<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthApiService _authApiService = AuthApiService();
  bool _isLoading = false;

  @override
  get init => () {
        // No incoming data expected for this page from direct navigation
      };

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authApiService.forgotPassword(
        email: _emailController.text.trim(),
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
          description:
              response['message'] ?? "OTP sent to your email address.".tr(),
          style: ToastNotificationStyleType.success,
        );

        if (mounted) {
          routeTo(
            ResetPasswordPage.path,
            navigationType: NavigationType.pushReplace,
            data: {
              EmailKey: _emailController.text.trim(),
            },
          );
        }
        // Navigate to OTP verification page for password reset
      } else {
        final message =
            response['message'] ?? "Failed to request password reset.".tr();
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
      print('🔐 ForgotPassword: TypeError: $e');
      showToastNotification(
        context,
        title: "Error".tr(),
        description:
            "An unexpected data format was received from the server. Please try again."
                .tr(),
        style: ToastNotificationStyleType.danger,
      );
    } catch (e) {
      print('🔐 ForgotPassword: Error: $e');
      showToastNotification(
        context,
        title: "Error".tr(),
        description: 'Failed to request password reset: ${e.toString()}'.tr(),
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
        title: Text("Forgot Password".tr()),
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
                  "Enter your email to receive a password reset OTP".tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black, // Dark text color
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email Address".tr(),
                    labelText: 'Email'.tr(), // Label text
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
                    prefixIcon: Icon(Icons.email_outlined,
                        color: Colors.grey[600]), // Icon color
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email address".tr();
                    }
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email address'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _requestPasswordReset,
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
                        : Text("Request OTP".tr(),
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
