import UIKit
import Flutter
import flutter_local_notifications
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase
    FirebaseApp.configure()

    // Set up Firebase Messaging delegate
    Messaging.messaging().delegate = self

    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
       GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
       UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    // Request notification permissions
    if #available(iOS 10.0, *) {
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }

    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle APNs token registration
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }

  // Handle APNs token registration failure
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error)")
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔥 ===== FCM TOKEN RECEIVED ======")
    print("🔥 Firebase registration token: \(String(describing: fcmToken))")
    print("🔥 Token length: \(fcmToken?.count ?? 0)")
    print("🔥 ================================")
    
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate {
  // Handle notification when app is in foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("🔥 ===== iOS FOREGROUND NOTIFICATION ======")
    print("🔥 Notification ID: \(notification.request.identifier)")
    print("🔥 Title: \(notification.request.content.title)")
    print("🔥 Body: \(notification.request.content.body)")
    print("🔥 User Info: \(notification.request.content.userInfo)")
    print("🔥 Badge: \(notification.request.content.badge ?? 0)")
    print("🔥 Sound: \(notification.request.content.sound?.description ?? "default")")
    print("🔥 ========================================")
    
    // Show notification even when app is in foreground
    completionHandler([.alert, .badge, .sound])
  }
  
  // Handle notification tap
  override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    print("🔥 ===== iOS NOTIFICATION TAPPED ======")
    print("🔥 Notification ID: \(response.notification.request.identifier)")
    print("🔥 Title: \(response.notification.request.content.title)")
    print("🔥 Body: \(response.notification.request.content.body)")
    print("🔥 User Info: \(response.notification.request.content.userInfo)")
    print("🔥 Action Identifier: \(response.actionIdentifier)")
    print("🔥 =====================================")
    
    completionHandler()
  }
}
