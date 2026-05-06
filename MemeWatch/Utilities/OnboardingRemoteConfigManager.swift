import Foundation
import FirebaseRemoteConfig
import SwiftUI
import Combine
import RevenueCat

enum OnboardingABVariant: String {
    case a = "a"
    case b = "b"
}

final class OnboardingRemoteConfigManager: ObservableObject {
    static let shared = OnboardingRemoteConfigManager()
    private let parameterKey = "onboarding_variant"

    @Published var onboardingVariant: OnboardingABVariant = .b

    func fetchAndActivateConfig() async {
        do {
            let remoteConfig = RemoteConfig.remoteConfig()
            let settings = RemoteConfigSettings()
            settings.minimumFetchInterval = 0
            remoteConfig.configSettings = settings

            _ = try await remoteConfig.fetch()
            _ = try await remoteConfig.activate()

            let value = remoteConfig.configValue(forKey: parameterKey).stringValue.lowercased()
            guard let variant = OnboardingABVariant(rawValue: value) else { return }

            await MainActor.run {
                self.onboardingVariant = variant
            }

            Purchases.shared.attribution.setAttributes(["onboardingVariant": variant.rawValue])
        } catch {
            print("Failed to fetch/activate remote config: \(error.localizedDescription)")
        }
    }
}
