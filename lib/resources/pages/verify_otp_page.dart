import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/resources/pages/base_navigation_hub.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/networking/auth_api_service.dart';
import 'package:flutter_app/resources/pages/change_password_page.dart';
import 'package:flutter_app/config/keys.dart';
import 'package:flutter_app/app/services/firebase_auth_service.dart';
import 'package:flutter_app/app/services/auth_service.dart'; // Import AuthService

class VerifyOtpPage extends NyStatefulWidget {
  static RouteView path = ("/verify-otp", (_) => VerifyOtpPage());

  VerifyOtpPage({super.key}) : super(child: () => _VerifyOtpPageState());
}

class _VerifyOtpPageState extends NyPage<VerifyOtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final AuthApiService _authApiService = AuthApiService();
  bool _isLoading = false;

  String? email;
  String? type; // 'registration' or 'password_reset'
  Timer? _timer;
  int _start = 600; // 10 minutes in seconds

  @override
  get init => () {
        // Get query parameters from Nylo route
        final queryParams = queryParameters();
        email = queryParams != null ? queryParams[EmailKey] : null;
        type = queryParams != null ? queryParams[OtpTypeKey] : null;

        if (email == null) {
          // Schedule navigation for after build completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              pop();
            }
          });
          return;
        }
        startTimer();
      };

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void startTimer() {
    _start = 600;
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  String get _timerText {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authApiService.verifyOtp(
        email: email!,
        otp: _otpController.text,
        deviceType: Theme.of(context).platform == TargetPlatform.android
            ? "android"
            : "ios",
        deviceName: "Mobile App",
        appVersion: "1.0.0",
        osVersion: "1.0.0",
      );

      if (response == null) {
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

      if (response['success'] == true) {
        if (mounted) {
          showToastNotification(
            context,
            title: "Success".tr(),
            description:
                response['message'] ?? "Email verified successfully.".tr(),
            style: ToastNotificationStyleType.success,
          );

          // Small delay for toast visibility
          await Future.delayed(Duration(milliseconds: 800));

          if (type == OtpTypeKey_PasswordReset) {
            // Navigate to change password using Nylo route
            routeTo(
              ChangePasswordPage.path.$1,
              navigationType: NavigationType.pushReplace,
              queryParameters: {EmailKey: email!, OtpKey: _otpController.text},
            );
          } else {
            // Registration OTP verified - store authentication data
            print(
                '🔑 VerifyOtpPage: Registration OTP verified, storing authentication data:');
            print('  - Token: ${response['data']?['token']}');
            print('  - UserJson: ${response['data']?['user']}');
            print('  - AuthData map: ${response['data']}');
            final String? token = response['data']?['token'];
            final userJson = response['data']?['user'];

            if (token != null && userJson != null) {
              print(
                  '🔑 VerifyOtpPage: Preparing authData for Auth.authenticate:');
              print('  - Token: $token');
              print('  - UserJson: $userJson');
              await FirebaseAuthService()
                  .updateAuthStates(token, userJson as Map<String, dynamic>);
              print(
                  '🔑 VerifyOtpPage: Successfully updated auth states, navigating to dashboard.');
            }
            routeTo(BaseNavigationHub.path,
                navigationType: NavigationType.pushAndForgetAll);
          }
        }
      } else {
        final message = response['message'] ?? "Failed to verify OTP.".tr();
        final errors = response['errors'];

        if (errors != null && mounted) {
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
      print('🔐 VerifyOtp: TypeError: $e');
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
      print('🔐 VerifyOtp: Error: $e');
      if (mounted) {
        showToastNotification(
          context,
          title: "Error".tr(),
          description: 'Failed to verify OTP: ${e.toString()}'.tr(),
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
    _otpController.clear();
  }

  Future<void> _resendOtp() async {
    try {
      final response = await _authApiService.resendOtp(
        email: email!,
        type: type ?? OtpTypeKey_Registration,
      );

      if (response?['success'] == true) {
        if (mounted) {
          showToastNotification(
            context,
            title: "Success".tr(),
            description: response?['message'] ?? "OTP sent successfully.".tr(),
            style: ToastNotificationStyleType.success,
          );
          startTimer(); // Restart the timer
        }
      } else {
        if (mounted) {
          showToastNotification(
            context,
            title: "Error".tr(),
            description: response?['message'] ?? "Failed to resend OTP.".tr(),
            style: ToastNotificationStyleType.danger,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showToastNotification(
          context,
          title: "Error".tr(),
          description: e.toString(),
          style: ToastNotificationStyleType.danger,
        );
      }
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Verify OTP".tr()),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Please enter the 6-digit code sent to your email".tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (email != null)
                  Text(
                    email!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
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
                Text(
                  "OTP expires in: ${_timerText}".tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_start == 0 || _isLoading) ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_start == 0 || _isLoading)
                          ? Colors.grey[400]
                          : const Color(0xFF00BFFF),
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
                        : Text("Verify".tr(),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _start == 0 ? _resendOtp : null,
                  child: Text(
                    "Resend OTP".tr(),
                    style: TextStyle(
                      color: _start == 0
                          ? const Color(0xFF00BFFF)
                          : Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
