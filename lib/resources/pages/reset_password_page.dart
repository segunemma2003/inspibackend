import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/networking/auth_api_service.dart';
import 'package:flutter_app/resources/pages/sign_in_page.dart';
import 'package:flutter_app/config/keys.dart';
// import 'dart:convert'; // Removed - no longer needed

class ResetPasswordPage extends NyStatefulWidget {
  static RouteView path = (
    "/reset-password",
    (_) => ResetPasswordPage(),
  );

  ResetPasswordPage({super.key})
      : super(child: () => _ResetPasswordPageState());
}

class _ResetPasswordPageState extends NyPage<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final AuthApiService _authApiService = AuthApiService();
  bool _isLoading = false;
  String? email;
  bool _isInitialized = false;

  @override
  get init => () {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // Use the data() method from NyPage instead of widget.data
          final pageData = await data();
          email = pageData?[EmailKey] as String?;

          if (email == null && mounted) {
            showToastNotification(
              context,
              title: "Error".tr(),
              description: "Email address is required".tr(),
              style: ToastNotificationStyleType.danger,
            );
            pop();
          } else if (mounted) {
            setState(() {
              _isInitialized = true;
            });
          }
        });
      };

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (email == null) {
      if (mounted) {
        showToastNotification(
          context,
          title: "Error".tr(),
          description:
              "Email address is missing. Please go back and try again.".tr(),
          style: ToastNotificationStyleType.danger,
        );
        setState(() => _isLoading = false);
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authApiService.resetPassword(
        email: email!,
        otp: _otpController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmationController.text,
      );

      print('🔐 ResetPassword: Response type: ${response.runtimeType}');
      print('🔐 ResetPassword: Response: $response');

      // AuthApiService.resetPassword is expected to return Map<String, dynamic>?
      final Map<String, dynamic>? responseData = response;

      if (responseData == null) {
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

      // Check for success
      final isSuccess = responseData['success'] == true ||
          (responseData['message'] != null &&
              responseData['message']
                  .toString()
                  .toLowerCase()
                  .contains('success'));

      if (isSuccess) {
        if (mounted) {
          showToastNotification(
            context,
            title: "Success".tr(),
            description:
                responseData['message'] ?? "Password reset successfully.".tr(),
            style: ToastNotificationStyleType.success,
          );
        }

        await Future.delayed(Duration(milliseconds: 800));

        if (mounted) {
          routeTo(
            SignInPage.path,
            navigationType: NavigationType.pushAndForgetAll,
          );
        }
      } else {
        final message =
            responseData['message'] ?? "Failed to reset password.".tr();
        final errors = responseData['errors'];

        if (errors != null) {
          final fieldErrors = <String>[];

          if (errors is Map) {
            errors.forEach((field, errorList) {
              if (errorList is List && errorList.isNotEmpty) {
                fieldErrors.add(
                    '${field.toString().toUpperCase()}: ${errorList.first}');
              } else if (errorList is String) {
                fieldErrors
                    .add('${field.toString().toUpperCase()}: $errorList');
              }
            });
          }

          if (fieldErrors.isNotEmpty && mounted) {
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
          showToastNotification(
            context,
            title: "Error".tr(),
            description: message,
            style: ToastNotificationStyleType.danger,
          );
        }
      }
    } on TypeError catch (e) {
      print('🔐 ResetPassword: TypeError: $e');
      if (mounted) {
        showToastNotification(
          context,
          title: "Error".tr(),
          description:
              "An unexpected data format was received from the server. Please try again."
                  .tr(),
          style: ToastNotificationStyleType.danger,
        );
      }
    } catch (e) {
      print('🔐 ResetPassword: Error: $e');
      if (mounted) {
        showToastNotification(
          context,
          title: "Error".tr(),
          description: 'Failed to reset password: ${e.toString()}'.tr(),
          style: ToastNotificationStyleType.danger,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget view(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BFFF)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Reset Password".tr()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Corrected: Use MainAxisSize.min
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Enter the OTP sent to ${email ?? 'your email'} and your new password"
                      .tr(), // Corrected string interpolation
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: "Enter OTP".tr(),
                    labelText: 'OTP'.tr(),
                    hintStyle: TextStyle(color: Colors.grey[600]),
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
                    prefixIcon:
                        Icon(Icons.vpn_key_outlined, color: Colors.grey[600]),
                    counterText: "",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter OTP".tr();
                    }
                    if (value.length != 6) {
                      return "OTP must be 6 digits".tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "New Password".tr(),
                    labelText: 'New Password'.tr(),
                    hintStyle: TextStyle(color: Colors.grey[600]),
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
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Colors.grey[600]),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your new password".tr();
                    }
                    if (value.length < 8) {
                      return "Password must be at least 8 characters".tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordConfirmationController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Confirm New Password".tr(),
                    labelText: 'Confirm New Password'.tr(),
                    hintStyle: TextStyle(color: Colors.grey[600]),
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
                    prefixIcon: Icon(Icons.lock_reset_outlined,
                        color: Colors.grey[600]),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please confirm your new password".tr();
                    }
                    if (value != _passwordController.text) {
                      return "Passwords do not match".tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isLoading
                          ? const Color(0xFF00BFFF)
                          : Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text("Reset Password".tr(),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                // Spacer(), // Removed Spacer as it conflicts with MainAxisSize.min
              ],
            ),
          ),
        ),
      ),
    );
  }
}
