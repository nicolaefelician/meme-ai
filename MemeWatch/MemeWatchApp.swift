import SwiftUI
import Firebase
import RevenueCat
import FirebaseMessaging
import FirebaseRemoteConfig

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        Consts.shared.loadContent()

        Purchases.configure(withAPIKey: Consts.shared.revenueCatApiKey, appUserID: Consts.shared.appUserId)

        SubscriptionManager.shared.fetchSubscriptionStatus()
        SubscriptionManager.shared.listenForSubscriptionUpdates()

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        return true
    }
}

@main
struct MemeWatchApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @ObservedObject private var appManager = AppManager.shared
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @ObservedObject private var onboardingConfig = OnboardingRemoteConfigManager.shared

    var body: some Scene {
        WindowGroup {
            ZStack {
                if appManager.showSplashView {
                    SplashView()
                        .preferredColorScheme(.light)
                        .zIndex(1)
                } else if appManager.showOnboarding {
                    if onboardingConfig.onboardingVariant == .b {
                        OnboardingVBView()
                            .preferredColorScheme(.dark)
                            .transition(.opacity)
                    } else {
                        OnboardingVAView()
                            .preferredColorScheme(.light)
                            .transition(.opacity)
                    }
                } else {
                    ContentView()
                        .preferredColorScheme(.light)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: appManager.showSplashView)
            .animation(.easeInOut, value: appManager.showOnboarding)
            .sheet(isPresented: $subscriptionManager.showPaywall) {
                PaywallView()
            }
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
        
        Task {
            do {
                print("Registering user with token: \(fcmToken)")
                try await UserApi.shared.registerUser(firebaseId: fcmToken)
            } catch {
                print("Failed to register user: \(error)")
            }
        }
        
        let dataDict: [String: String] = ["token": fcmToken]
        
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
