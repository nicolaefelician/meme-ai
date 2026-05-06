import Combine
import SwiftUI
import RevenueCat

final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published var isSubscribed: Bool = false
    @Published var showPaywall: Bool = false

    @Published var weeklyPackage: Package?
    @Published var monthlyPackage: Package?

    private static let weeklyID  = "com.meme.ai.weekly.3.99"
    private static let monthlyID = "com.meme.ai.monthly.9.99"

    private init() {}

    func fetchSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { customerInfo, _ in
            DispatchQueue.main.async {
                let isActive = customerInfo?.entitlements.all["Pro"]?.isActive == true
                self.isSubscribed = isActive
                AppManager.shared.isPremiumUser = isActive
            }
        }
    }

    func listenForSubscriptionUpdates() {
        Task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                let isActive = customerInfo.entitlements.activeInCurrentEnvironment["Pro"] != nil
                await MainActor.run {
                    self.isSubscribed = isActive
                    AppManager.shared.isPremiumUser = isActive
                }
            }
        }
    }

    func loadOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            guard let packages = offerings.current?.availablePackages else { return }
            await MainActor.run {
                weeklyPackage  = packages.first { $0.storeProduct.productIdentifier == Self.weeklyID }
                monthlyPackage = packages.first { $0.storeProduct.productIdentifier == Self.monthlyID }
            }
        } catch {
            print("SubscriptionManager: failed to load offerings — \(error)")
        }
    }

    func purchase(package: Package) async -> Bool {
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if result.userCancelled { return false }
            await MainActor.run {
                self.isSubscribed = true
                AppManager.shared.isPremiumUser = true
                self.showPaywall = false
            }
            return true
        } catch {
            print("SubscriptionManager: purchase failed — \(error)")
            return false
        }
    }

    func restorePurchases() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            let isActive = !customerInfo.entitlements.active.isEmpty
            await MainActor.run {
                self.isSubscribed = isActive
                AppManager.shared.isPremiumUser = isActive
            }
            return isActive
        } catch {
            print("SubscriptionManager: restore failed — \(error)")
            return false
        }
    }
}
