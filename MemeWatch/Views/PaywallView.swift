import SwiftUI
import RevenueCat

struct PaywallView: View {
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var selectedPackage: Package?
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#1A1A1A"), Color(hex: "#2D2D2D")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Crown icon + title
                        VStack(spacing: 12) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 56))
                                .foregroundColor(.orange)

                            Text(String(localized: "paywall.title"))
                                .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 28))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text(String(localized: "paywall.subtitle"))
                                .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 10)

                        // Feature list
                        VStack(spacing: 14) {
                            featureRow(icon: "brain.head.profile", text: String(localized: "paywall.feature.ai_analysis"))
                            featureRow(icon: "newspaper", text: String(localized: "paywall.feature.news"))
                            featureRow(icon: "chart.line.uptrend.xyaxis", text: String(localized: "paywall.feature.charts"))
                            featureRow(icon: "bell.fill", text: String(localized: "paywall.feature.alerts"))
                        }
                        .padding(.horizontal, 24)

                        // Package selector
                        if subscriptionManager.weeklyPackage != nil || subscriptionManager.monthlyPackage != nil {
                            VStack(spacing: 12) {
                                if let monthly = subscriptionManager.monthlyPackage {
                                    packageCard(
                                        package: monthly,
                                        label: String(localized: "paywall.plan.monthly.label"),
                                        detail: String(format: String(localized: "paywall.plan.monthly.detail"), monthly.storeProduct.localizedPriceString),
                                        badge: String(localized: "paywall.plan.monthly.badge")
                                    )
                                }
                                if let weekly = subscriptionManager.weeklyPackage {
                                    packageCard(
                                        package: weekly,
                                        label: String(localized: "paywall.plan.weekly.label"),
                                        detail: String(format: String(localized: "paywall.plan.weekly.detail"), weekly.storeProduct.localizedPriceString),
                                        badge: nil
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                                .padding(.top, 10)
                                .task {
                                    await subscriptionManager.loadOfferings()
                                }
                        }

                        // Error message
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.custom(TextFonts.interRegular.rawValue, size: 14))
                                .foregroundColor(.red.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }

                        // Subscribe button
                        Button(action: handlePurchase) {
                            ZStack {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(String(localized: "paywall.cta.subscribe"))
                                        .font(.custom(TextFonts.interSemibold.rawValue, size: 18))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.red.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isPurchasing || selectedPackage == nil)
                        .padding(.horizontal, 20)

                        // Restore
                        Button(action: handleRestore) {
                            if isRestoring {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(String(localized: "paywall.cta.restore"))
                                    .font(.custom(TextFonts.interRegular.rawValue, size: 15))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .disabled(isRestoring)

                        Text(String(localized: "paywall.legal.disclaimer"))
                            .font(.custom(TextFonts.interRegular.rawValue, size: 12))
                            .foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 30)
                    }
                }
            }
        }
        .onAppear {
            selectedPackage = subscriptionManager.monthlyPackage ?? subscriptionManager.weeklyPackage
        }
        .onChange(of: subscriptionManager.monthlyPackage) { pkg in
            if selectedPackage == nil { selectedPackage = pkg }
        }
    }

    private func packageCard(package: Package, label: String, detail: String, badge: String?) -> some View {
        let isSelected = selectedPackage?.identifier == package.identifier

        return Button(action: { selectedPackage = package }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(label)
                            .font(.custom(TextFonts.interSemibold.rawValue, size: 16))
                            .foregroundColor(.white)

                        if let badge {
                            Text(badge)
                                .font(.custom(TextFonts.interMedium.rawValue, size: 11))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.orange.opacity(0.15))
                                .cornerRadius(8)
                        }
                    }

                    Text(detail)
                        .font(.custom(TextFonts.interRegular.rawValue, size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .orange : .white.opacity(0.4))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(isSelected ? 0.12 : 0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.orange : Color.white.opacity(0.15), lineWidth: 1.5)
                    )
            )
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.orange)
                .frame(width: 24)

            Text(text)
                .font(.custom(TextFonts.interRegular.rawValue, size: 15))
                .foregroundColor(.white.opacity(0.85))

            Spacer()
        }
    }

    private func handlePurchase() {
        guard let pkg = selectedPackage else { return }
        errorMessage = nil
        isPurchasing = true
        Task {
            let success = await subscriptionManager.purchase(package: pkg)
            await MainActor.run {
                isPurchasing = false
                if success { dismiss() }
            }
        }
    }

    private func handleRestore() {
        errorMessage = nil
        isRestoring = true
        Task {
            let restored = await subscriptionManager.restorePurchases()
            await MainActor.run {
                isRestoring = false
                if restored {
                    dismiss()
                } else {
                    errorMessage = String(localized: "paywall.error.no_subscriptions")
                }
            }
        }
    }
}
