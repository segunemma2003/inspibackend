import 'package:flutter/material.dart';
import 'package:flutter_app/routes/guards/auth_route_guard.dart';

import 'package:flutter_app/resources/pages/about_page.dart';
import 'package:flutter_app/resources/pages/base_navigation_hub.dart';
import 'package:flutter_app/resources/pages/businessprofile_page.dart';
import 'package:flutter_app/resources/pages/delete_account_page.dart';
import 'package:flutter_app/resources/pages/edit_profile_page.dart';
import 'package:flutter_app/resources/pages/home_page.dart';
import 'package:flutter_app/resources/pages/forgot_password_page.dart';
import 'package:flutter_app/resources/pages/change_password_page.dart';
import 'package:flutter_app/resources/pages/verify_otp_page.dart';
import 'package:flutter_app/resources/pages/not_found_page.dart';
import 'package:flutter_app/resources/pages/notification_page.dart';
import 'package:flutter_app/resources/pages/notification_settings_page.dart';
import 'package:flutter_app/resources/pages/debug_notifications_page.dart';
import 'package:flutter_app/resources/pages/search_page.dart';
import 'package:flutter_app/resources/pages/tagged_posts_page.dart';
import 'package:flutter_app/resources/pages/notifications_page.dart';
import 'package:flutter_app/resources/pages/business_accounts_page.dart';
import 'package:flutter_app/resources/pages/privacy_page.dart';
import 'package:flutter_app/resources/pages/privacy_policy_page.dart';
import 'package:flutter_app/resources/pages/privacy_settings_page.dart';
import 'package:flutter_app/resources/pages/settings_page.dart';
import 'package:flutter_app/resources/pages/sign_in_page.dart';
import 'package:flutter_app/resources/pages/sign_up_page.dart';
import 'package:flutter_app/resources/pages/support_page.dart';
import 'package:flutter_app/resources/pages/tags_page.dart';
import 'package:flutter_app/resources/pages/terms_page.dart';
import 'package:flutter_app/resources/pages/terms_of_service_page.dart';
import 'package:flutter_app/resources/pages/community_guidelines_page.dart';
import 'package:flutter_app/resources/pages/intellectual_property_policy_page.dart';
import 'package:flutter_app/resources/pages/help_center_page.dart';
import 'package:flutter_app/resources/pages/online_safety_act_page.dart';
import 'package:flutter_app/resources/pages/open_source_notice_page.dart';
import 'package:flutter_app/resources/pages/reset_password_page.dart'; // Import ResetPasswordPage
import 'package:flutter_app/resources/pages/user_profile_page.dart'; // Import UserProfilePage
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/services/auth_service.dart';

/* App Router
|--------------------------------------------------------------------------
| * [Tip] Create pages faster 🚀
| Run the below in the terminal to create new a page.
| "dart run nylo_framework:main make:page profile_page"
|
| * [Tip] Add authentication 🔑
| Run the below in the terminal to add authentication to your project.
| "dart run scaffold_ui:main auth"
|
| * [Tip] Add In-app Purchases 💳
| Run the below in the terminal to add In-app Purchases to your project.
| "dart run scaffold_ui:main iap"
|
| Learn more https://nylo.dev/docs/6.x/router
|-------------------------------------------------------------------------- */

appRouter() => nyRoutes((router) {
      router.add(HomePage.path).initialRoute();

      // Add your routes here ...
      // router.add(NewPage.path, transitionType: TransitionType.fade());

      // Example using grouped routes
      router.group(
          () => {
                "route_guards": [AuthRouteGuard()],
                "prefix": "/dashboard",
              }, (router) {
        router.add(DeleteAccountPage.path);

        router.add(EditProfilePage.path);
        router.add(TagsPage.path);
        router.add(BaseNavigationHub.path);
        router.add(NotificationPage.path);
        router.add(NotificationSettingsPage.path);
        router.add(DebugNotificationsPage.path);
        router.add(UserProfilePage.path);
        router.add(SearchPage.path);
        router.add(TaggedPostsPage.path);
        router.add(NotificationsPage.path);
        router.add(BusinessAccountsPage.path);
        router.add(AboutPage.path);
        router.add(TermsPage.path);
        router.add(TermsOfServicePage.path);
        router.add(PrivacyPage.path);
        router.add(PrivacyPolicyPage.path);
        router.add(PrivacySettingsPage.path);
        router.add(CommunityGuidelinesPage.path);
        router.add(IntellectualPropertyPolicyPage.path);
        router.add(HelpCenterPage.path);
        router.add(OnlineSafetyActPage.path);
        router.add(OpenSourceNoticePage.path);
        router.add(BusinessprofilePage.path);
        router.add(SettingsPage.path);
        router.add(SupportPage.path);

        router.add(
          (
            "/logout",
            (context) => FutureBuilder(
                // Use FutureBuilder to show loading while logging out
                future: AuthService.instance
                    .logout()
                    .then((_) => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SignInPage()), // Navigate to SignInPage
                          (route) => false, // Remove all routes from the stack
                        )),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Scaffold(
                        body: Center(child: CircularProgressIndicator()));
                  } else {
                    return SizedBox.shrink(); // Widget to hide after navigation
                  }
                })
          ),
        );
      });
      router.add(NotFoundPage.path).unknownRoute();
      router.add(SignInPage.path);
      router.add(ResetPasswordPage.path); // New Reset Password Page
      router.add(VerifyOtpPage.path);
      router.add(ChangePasswordPage.path);
      router.add(SignUpPage.path);
      router.add(ForgotPasswordPage.path);
    });
