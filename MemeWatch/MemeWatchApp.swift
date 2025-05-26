import SwiftUI
import Firebase
import RevenueCat
import SuperwallKit
import FirebaseMessaging

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: Consts.shared.revenueCatApiKey)
        
        Superwall.configure(apiKey: Consts.shared.superwallApiKey, purchaseController: purchaseController)
        purchaseController.syncSubscriptionStatus()
        
        UNUserNotificationCenter.current().delegate = self
        
        Task {
            await handleNotificationPermissions(application: application)
        }
        
        return true
    }
    
    @MainActor
    private func handleNotificationPermissions(application: UIApplication) async {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
            print("Notification authorization granted: \(granted)")
        } catch {
            print("Notification authorization error: \(error.localizedDescription)")
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
    }
}


@main
struct MemeWatchApp: App {
    @ObservedObject private var appManager = AppManager.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appManager.showSplashView {
                    SplashView()
                        .preferredColorScheme(.light)
                        .zIndex(1)
                } else if appManager.showOnboarding {
                    OnboardingView()
                        .preferredColorScheme(.light)
                        .transition(.opacity)
                } else {
                    ContentView()
                        .preferredColorScheme(.light)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: appManager.showSplashView)
            .animation(.easeInOut, value: appManager.showOnboarding)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        return [[.badge, .sound]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        let coin = Coin(fromNotificationData: userInfo)
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        AppManager.shared.path.append(.coinDataView(coinId: coin.id))
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("No FCM token received")
            return
        }
        
        // TODO: register user
//        Consts.shared.setFcmToken(fcmToken)
        
        let dataDict: [String: String] = ["token": fcmToken]
        
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
