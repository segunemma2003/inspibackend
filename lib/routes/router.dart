import '/resources/pages/about_page.dart';
import '/resources/pages/base_navigation_hub.dart';
import '/resources/pages/businessprofile_page.dart';
import '/resources/pages/delete_account_page.dart';
import '/resources/pages/edit_profile_page.dart';
import '/resources/pages/home_page.dart';
import '/resources/pages/not_found_page.dart';
import '/resources/pages/notification_page.dart';
import '/resources/pages/privacy_page.dart';
import '/resources/pages/settings_page.dart';
import '/resources/pages/sign_in_page.dart';
import '/resources/pages/sign_up_page.dart';
import '/resources/pages/support_page.dart';
import '/resources/pages/tags_page.dart';
import '/resources/pages/terms_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

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
      // router.group(() => {
      //   "route_guards": [AuthRouteGuard()],
      //   "prefix": "/dashboard"
      // }, (router) {
      //
      // });
      router.add(NotFoundPage.path).unknownRoute();
      router.add(SignInPage.path);
      router.add(DeleteAccountPage.path);
      router.add(SignUpPage.path);
      router.add(EditProfilePage.path);
      router.add(TagsPage.path);
      router.add(BaseNavigationHub.path);
      router.add(NotificationPage.path);
      router.add(AboutPage.path);
      router.add(TermsPage.path);
      router.add(PrivacyPage.path);
      router.add(BusinessprofilePage.path);
      router.add(SettingsPage.path);
      router.add(SupportPage.path);
    });
