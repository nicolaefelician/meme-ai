import Foundation
import SuperwallKit
import RevenueCat
import SwiftUI

final class Utilities {
    static let shared = Utilities()
    
    private init() {}
    
    func convertImageToBase64(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        return imageData.base64EncodedString()
    }
    
    func formatNumber(_ number: Double) -> String {
        func formatWithSuffix(_ value: Double, _ suffix: String) -> String {
            return value < 10 ? String(format: "%.2f%@", value, suffix) : String(format: "%.1f%@", value, suffix)
        }
        
        if number >= 1_000_000_000_000_000 {
            return formatWithSuffix(number / 1_000_000_000_000_000, "Q")
        } else if number >= 1_000_000_000_000 {
            return formatWithSuffix(number / 1_000_000_000_000, "T")
        } else if number >= 1_000_000_000 {
            return formatWithSuffix(number / 1_000_000_000, "B")
        } else if number >= 1_000_000 {
            let formatted = number / 1_000_000
            
            if abs(formatted - round(formatted)) < 0.001 {
                return String(format: "%.0fM", round(formatted))
            }
            return String(format: "%.2fM", formatted)
        } else if number >= 1_000 {
            return formatWithSuffix(number / 1_000, "K")
        } else {
            return String(format: "%.0f", number)
        }
    }
    
    func formatDate(_ date: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        
        guard let date = isoFormatter.date(from: date) else {
            return ""
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMM yyyy 'at' HH:mm"
        outputFormatter.locale = Locale(identifier: "en_US")
        outputFormatter.timeZone = TimeZone.current
        
        return outputFormatter.string(from: date)
    }
}

enum ApiError: Error {
    case invalidResponse
    case decodingFailded
    case encodingFailded
}

func safeSession() -> URLSession {
    if #available(iOS 18.4, *) {
        let config = URLSessionConfiguration.ephemeral
        return URLSession(configuration: config)
    } else {
        return URLSession.shared
    }
}

let purchaseController = SubscriptionController()

private enum PurchasingError: LocalizedError {
    case sk2ProductNotFound
    
    var errorDescription: String? {
        switch self {
        case .sk2ProductNotFound:
            return "Superwall didn't pass a StoreKit 2 product to purchase. Are you sure you're not "
            + "configuring Superwall with a SuperwallOption to use StoreKit 1?"
        }
    }
}

final class SubscriptionController: PurchaseController  {
    func syncSubscriptionStatus() {
        assert(Purchases.isConfigured, "You must configure RevenueCat before calling this method.")
        Task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                let superwallEntitlements = customerInfo.entitlements.activeInCurrentEnvironment.keys.map {
                    Entitlement(id: $0)
                }
                await MainActor.run { [superwallEntitlements] in
                    Superwall.shared.subscriptionStatus = .active(Set(superwallEntitlements))
                    AppManager.shared.isPremiumUser = Superwall.shared.subscriptionStatus.isActive
                }
            }
        }
    }
    
    func purchase(product: SuperwallKit.StoreProduct) async -> PurchaseResult {
        do {
            guard let sk2Product = product.sk2Product else {
                throw PurchasingError.sk2ProductNotFound
            }
            let storeProduct = RevenueCat.StoreProduct(sk2Product: sk2Product)
            let revenueCatResult = try await Purchases.shared.purchase(product: storeProduct)
            if revenueCatResult.userCancelled {
                return .cancelled
            } else {
                AppManager.shared.isPremiumUser = true
                return .purchased
            }
        } catch let error as ErrorCode {
            if error == .paymentPendingError {
                return .pending
            } else {
                return .failed(error)
            }
        } catch {
            return .failed(error)
        }
    }
    
    func restorePurchases() async -> RestorationResult {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            let entitlements = customerInfo.entitlements.active
            
            AppManager.shared.isPremiumUser = !entitlements.isEmpty
            
            var alreadyRestoredIds = UserDefaults.standard.array(forKey: "restoredProductIds") as? [String] ?? []
            
            for (_, entitlement) in entitlements {
                let productId = entitlement.productIdentifier
                
                if !alreadyRestoredIds.contains(productId) {
                    alreadyRestoredIds.append(productId)
                }
            }
            
            UserDefaults.standard.set(alreadyRestoredIds, forKey: "restoredProductIds")
            
            return .restored
        } catch {
            return .failed(error)
        }
    }
}
