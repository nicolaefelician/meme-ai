import SwiftUI
import RevenueCat
import UserNotifications

struct OnboardingVBView: View {
    @ObservedObject private var appManager = AppManager.shared
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared

    @State private var screen: V2Screen = .welcome
    @State private var selectedExperience: String? = nil
    @State private var selectedChains: Set<String> = []
    @State private var selectedGoals: Set<String> = []
    
    @Environment(\.requestReview) private var requestReview

    private let accent = Color(hex: "#f97316")

    var body: some View {
        ZStack {
            Color(hex: "#0a0a0b").ignoresSafeArea()

            switch screen {
            case .welcome:
                V2WelcomeScreen(accent: accent) { advance() }
            case .social:
                V2SocialProofScreen(accent: accent) { advance() }
            case .alerts:
                V2AlertsScreen(accent: accent) { advance() }
            case .feed:
                V2FeedScreen(accent: accent) { advance() }
            case .experience:
                V2ExperienceScreen(
                    accent: accent,
                    selected: $selectedExperience
                ) { advance() }
            case .chains:
                V2ChainsScreen(
                    accent: accent,
                    selected: $selectedChains
                ) { advance() }
            case .goals:
                V2GoalsScreen(
                    accent: accent,
                    selected: $selectedGoals
                ) { advance() }
            case .notify:
                V2NotifyScreen(accent: accent) { advance() }
            case .analyzing:
                V2AnalyzingScreen(accent: accent) { advance() }
            case .reviews:
                V2ReviewsScreen(accent: accent) {
                    requestReview()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: advance)
                }
            case .paywall:
                V2PaywallScreen(
                    accent: accent,
                    onSkip: { finishOnboarding() },
                    onDone: { advance() }
                )
            case .done:
                V2DoneScreen(accent: accent) { finishOnboarding() }
            }
        }
        .transition(.opacity)
    }

    private func advance() {
        withAnimation(.easeInOut(duration: 0.35)) {
            screen = screen.next
        }
    }

    private func finishOnboarding() {
        withAnimation {
            appManager.completedOnboarding()
        }
    }
}

// MARK: - Screen enum
private enum V2Screen: CaseIterable {
    case welcome, social, alerts, feed, experience, chains, goals, notify, analyzing, reviews, paywall, done

    var next: V2Screen {
        let all = V2Screen.allCases
        guard let idx = all.firstIndex(of: self), idx + 1 < all.count else { return .done }
        return all[idx + 1]
    }
}

// MARK: - Welcome Screen
private struct V2WelcomeScreen: View {
    let accent: Color
    let onContinue: () -> Void

    private let coins: [(sym: String, pct: String, up: Bool)] = [
        ("PEPE", "+247%", true), ("WIF", "+89%", true), ("BONK", "+412%", true),
        ("POPCAT", "+33%", true), ("MOG", "−12%", false), ("BRETT", "+76%", true),
        ("TURBO", "+158%", true), ("MEW", "+44%", true), ("SHIB", "+19%", true),
        ("FLOKI", "−5%", false),
    ]

    @State private var showContent = false
    @State private var pulseDot = false

    var body: some View {
        ZStack {
            // Radial glow
            RadialGradient(
                colors: [accent.opacity(0.2), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 380
            )
            .ignoresSafeArea()
            .offset(y: -160)

            VStack(spacing: 0) {
                Spacer().frame(height: 100)

                // Ticker rows
                VStack(spacing: 8) {
                    TickerRow(coins: coins, accent: accent, reverse: false, duration: 50)
                    TickerRow(coins: coins, accent: Color(hex: "#a855f7"), reverse: true, duration: 40)
                    TickerRow(coins: coins, accent: accent, reverse: false, duration: 60)
                }

                Spacer()

                // Hero copy
                VStack(alignment: .leading, spacing: 0) {
                    // Live badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(accent)
                            .frame(width: 6, height: 6)
                            .scaleEffect(pulseDot ? 1.05 : 0.8)
                            .opacity(pulseDot ? 1 : 0.8)
                            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: pulseDot)

                        Text(String(localized: "onboarding_v2.welcome.live_badge"))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(accent)
                            .kerning(0.4)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(accent.opacity(0.12))
                    .overlay(Capsule().stroke(accent.opacity(0.25), lineWidth: 1))
                    .clipShape(Capsule())
                    .padding(.bottom, 16)

                    // Headline
                    VStack(alignment: .leading, spacing: 0) {
                        Text(String(localized: "onboarding_v2.welcome.headline1"))
                            .font(.system(size: 44, weight: .heavy))
                            .foregroundColor(.white)
                            .tracking(-1.5)

                        Text(String(localized: "onboarding_v2.welcome.headline2"))
                            .font(.system(size: 44, weight: .heavy))
                            .tracking(-1.5)
                            .overlay(
                                LinearGradient(
                                    colors: [accent, Color(hex: "#a855f7")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .mask(
                                    Text(String(localized: "onboarding_v2.welcome.headline2"))
                                        .font(.system(size: 44, weight: .heavy))
                                        .tracking(-1.5)
                                )
                            )
                            .foregroundColor(.clear)
                    }

                    Text(String(localized: "onboarding_v2.welcome.subtitle"))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .lineSpacing(4)
                        .padding(.top, 14)
                        .frame(maxWidth: 320, alignment: .leading)
                }
                .padding(.horizontal, 28)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 8)

                // CTA
                VStack(spacing: 14) {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onContinue()
                    } label: {
                        Text(String(localized: "onboarding_v2.welcome.cta"))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: "#0a0a0b"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(.white)
                            .cornerRadius(18)
                            .shadow(color: accent.opacity(0.25), radius: 14, x: 0, y: 6)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            pulseDot = true
            withAnimation(.easeOut(duration: 0.6)) { showContent = true }
        }
    }
}

// MARK: - Ticker
private struct TickerRow: View {
    let coins: [(sym: String, pct: String, up: Bool)]
    let accent: Color
    let reverse: Bool
    let duration: Double

    @State private var offset: CGFloat = 0

    var body: some View {
        let items = coins + coins
        GeometryReader { geo in
            HStack(spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, coin in
                    CoinChip(coin: coin, accent: accent)
                }
            }
            .offset(x: offset)
            .onAppear {
                let chipWidth: CGFloat = 100
                let totalWidth = CGFloat(coins.count) * (chipWidth + 8)
                offset = reverse ? -totalWidth : 0
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: false)
                ) {
                    offset = reverse ? 0 : -totalWidth
                }
            }
        }
        .frame(height: 46)
        .mask(
            LinearGradient(
                colors: [.clear, .black, .black, .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipped()
    }
}

private struct CoinChip: View {
    let coin: (sym: String, pct: String, up: Bool)
    let accent: Color

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                LinearGradient(colors: [accent, .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .clipShape(Circle())
                Text(String(coin.sym.prefix(2)))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text(coin.sym)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .kerning(0.2)
                Text(coin.pct)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(coin.up ? Color(hex: "#22c55e") : Color(hex: "#ef4444"))
            }
        }
        .padding(.leading, 8)
        .padding(.trailing, 14)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.04))
        .overlay(Capsule().stroke(Color.white.opacity(0.07), lineWidth: 1))
        .clipShape(Capsule())
        .fixedSize()
    }
}

// MARK: - Social Proof Screen
private struct V2SocialProofScreen: View {
    let accent: Color
    let onContinue: () -> Void

    private let traderImages = ["trader-1", "trader-2", "trader-3", "trader-4"]

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Progress bar
            ProgressBar(filled: 1, total: 6, accent: accent)
                .padding(.bottom, 40)

            // Avatars
            HStack(spacing: 0) {
                ForEach(traderImages.indices, id: \.self) { i in
                    Image(traderImages[i])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 38, height: 38)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(hex: "#0a0a0b"), lineWidth: 2))
                        .offset(x: CGFloat(i) * -10)
                        .zIndex(Double(traderImages.count - i))
                }
                Text("+247K")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 38)
                    .background(Color.white.opacity(0.08))
                    .overlay(Capsule().stroke(Color(hex: "#0a0a0b"), lineWidth: 2))
                    .clipShape(Capsule())
                    .offset(x: CGFloat(traderImages.count) * -10)
            }
            .padding(.bottom, 22)

            Text(String(localized: "onboarding_v2.social.headline"))
                .font(.system(size: 36, weight: .heavy))
                .foregroundColor(.white)
                .tracking(-1.2)
                .lineSpacing(2)

            Text(String(localized: "onboarding_v2.social.subtitle"))
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.55))
                .lineSpacing(4)
                .frame(maxWidth: 320, alignment: .leading)
                .padding(.top, 12)
                .padding(.bottom, 28)

            // Stats grid
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    StatBlock(value: String(localized: "onboarding_v2.social.stat1.value"), label: String(localized: "onboarding_v2.social.stat1.label"), sub: String(localized: "onboarding_v2.social.stat1.sub"), accent: accent)
                    StatBlock(value: String(localized: "onboarding_v2.social.stat2.value"), label: String(localized: "onboarding_v2.social.stat2.label"), sub: String(localized: "onboarding_v2.social.stat2.sub"), accent: Color(hex: "#a855f7"))
                }
                HStack(spacing: 10) {
                    StatBlock(value: String(localized: "onboarding_v2.social.stat3.value"), label: String(localized: "onboarding_v2.social.stat3.label"), sub: String(localized: "onboarding_v2.social.stat3.sub"), accent: Color(hex: "#fbbf24"))
                    StatBlock(value: String(localized: "onboarding_v2.social.stat4.value"), label: String(localized: "onboarding_v2.social.stat4.label"), sub: String(localized: "onboarding_v2.social.stat4.sub"), accent: accent)
                }
            }

            Spacer()

            ContinueButton(action: onContinue)
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .padding(.bottom, 30)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) { appeared = true }
        }
    }
}

private struct StatBlock: View {
    let value: String
    let label: String
    let sub: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value)
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(accent)
                .tracking(-1)
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .padding(.top, 8)
            Text(sub)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .padding(.top, 2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.04))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.07), lineWidth: 1))
        .cornerRadius(20)
    }
}

// MARK: - Alerts Screen
private struct V2AlertsScreen: View {
    let accent: Color
    let onContinue: () -> Void

    private var alerts: [(image: String, title: String, body: String, time: String, color: Color)] {[
        ("pepe",   String(localized: "onboarding_v2.alerts.alert1.title"),   String(localized: "onboarding_v2.alerts.alert1.body"), String(localized: "onboarding_v2.alerts.alert1.time"), Color(hex: "#22c55e")),
        ("wif",    String(localized: "onboarding_v2.alerts.alert2.title"),   String(localized: "onboarding_v2.alerts.alert2.body"), String(localized: "onboarding_v2.alerts.alert2.time"), Color(hex: "#a855f7")),
        ("banana", String(localized: "onboarding_v2.alerts.alert3.title"),   String(localized: "onboarding_v2.alerts.alert3.body"), String(localized: "onboarding_v2.alerts.alert3.time"), Color(hex: "#fbbf24")),
    ]}

    @State private var visibleCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProgressBar(filled: 2, total: 6, accent: accent)
                .padding(.bottom, 30)

            Text(String(localized: "onboarding_v2.alerts.headline1"))
                .font(.system(size: 36, weight: .heavy))
                .foregroundColor(.white)
                .tracking(-1.2)
            +
            Text(String(localized: "onboarding_v2.alerts.headline_accent"))
                .font(.system(size: 36, weight: .heavy))
                .foregroundColor(accent)
                .tracking(-1.2)
            +
            Text(String(localized: "onboarding_v2.alerts.headline2"))
                .font(.system(size: 36, weight: .heavy))
                .foregroundColor(.white)
                .tracking(-1.2)

            Text(String(localized: "onboarding_v2.alerts.subtitle"))
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.55))
                .lineSpacing(4)
                .frame(maxWidth: 320, alignment: .leading)
                .padding(.top, 12)
                .padding(.bottom, 24)

            VStack(spacing: 10) {
                ForEach(alerts.indices, id: \.self) { i in
                    AlertCard(alert: alerts[i])
                        .opacity(visibleCount > i ? 1 : 0)
                        .offset(y: visibleCount > i ? 0 : 12)
                        .animation(.easeOut(duration: 0.4).delay(Double(i) * 0.15), value: visibleCount)
                }
            }

            Spacer()

            ContinueButton(action: onContinue)
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .padding(.bottom, 30)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { visibleCount = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { visibleCount = 2 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { visibleCount = 3 }
        }
    }
}

private struct AlertCard: View {
    let alert: (image: String, title: String, body: String, time: String, color: Color)

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(alert.image)
                .resizable()
                .scaledToFill()
                .frame(width: 38, height: 38)
                .clipShape(Circle())
                .overlay(Circle().stroke(alert.color.opacity(0.4), lineWidth: 1.5))

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(String(localized: "onboarding_v2.alerts.app_name"))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text(alert.time)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.45))
                }
                Text(alert.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(alert.body)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .lineSpacing(2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .background(.ultraThinMaterial.opacity(0.3))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.1), lineWidth: 1))
        )
        .cornerRadius(18)
    }
}

// MARK: - Feed Screen
private struct V2FeedScreen: View {
    let accent: Color
    let onContinue: () -> Void

    private let coins: [FeedCoinEntry] = [
        FeedCoinEntry(rank: "01", sym: "PEPE",  name: "Pepe",      price: "$0.0000142", pct: "+247%", color: Color(hex: "#22c55e"), imageName: "pepe"),
        FeedCoinEntry(rank: "02", sym: "WIF",   name: "dogwifhat", price: "$3.42",      pct: "+89%",  color: Color(hex: "#a855f7"), imageName: "wif"),
        FeedCoinEntry(rank: "03", sym: "BONK",  name: "Bonk",      price: "$0.0000341", pct: "+412%", color: Color(hex: "#f97316"), imageName: "bonk"),
        FeedCoinEntry(rank: "04", sym: "MOG",   name: "Mog Coin",  price: "$0.00184",   pct: "−12%",  color: Color(hex: "#ef4444"), imageName: "mog"),
        FeedCoinEntry(rank: "05", sym: "BRETT", name: "Brett",     price: "$0.176",     pct: "+76%",  color: Color(hex: "#06b6d4"), imageName: "brett"),
    ]

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProgressBar(filled: 3, total: 6, accent: accent)
                .padding(.bottom, 30)

            // Headline — "updated live." uses the accent color
            VStack(alignment: .leading, spacing: 0) {
                Text(String(localized: "onboarding_v2.feed.headline1"))
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(.white)
                    .tracking(-1.2)

                HStack(spacing: 0) {
                    Text(String(localized: "onboarding_v2.feed.headline2"))
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(.white)
                        .tracking(-1.2)
                    Text(String(localized: "onboarding_v2.feed.headline_accent"))
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(accent)
                        .tracking(-1.2)
                }
            }

            Text(String(localized: "onboarding_v2.feed.subtitle"))
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.55))
                .lineSpacing(4)
                .frame(maxWidth: 320, alignment: .leading)
                .padding(.top, 12)
                .padding(.bottom, 22)

            // Coin rows
            VStack(spacing: 8) {
                ForEach(coins.indices, id: \.self) { i in
                    FeedCoinRow(entry: coins[i])
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(.easeOut(duration: 0.4).delay(Double(i) * 0.07), value: appeared)
                }
            }

            Spacer()

            ContinueButton(action: onContinue)
                .padding(.top, 16)
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .padding(.bottom, 30)
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}

private struct FeedCoinEntry {
    let rank: String
    let sym: String
    let name: String
    let price: String
    let pct: String
    let color: Color
    let imageName: String
    var up: Bool { !pct.hasPrefix("−") }
}

private struct FeedCoinRow: View {
    let entry: FeedCoinEntry

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text(entry.rank)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 16)

            // Avatar
            Image(entry.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                .overlay(Circle().stroke(entry.color.opacity(0.35), lineWidth: 1.5))

            // Name
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.sym)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(entry.name)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.45))
            }

            Spacer()

            // Sparkline
            SparklineView(up: entry.up, color: entry.up ? Color(hex: "#22c55e") : Color(hex: "#ef4444"))
                .frame(width: 64, height: 36)

            // Price + pct
            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.price)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text(entry.pct)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(entry.up ? Color(hex: "#22c55e") : Color(hex: "#ef4444"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.04))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
        .cornerRadius(14)
    }
}

private struct SparklineView: View {
    let up: Bool
    let color: Color

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // Point sets matching the JSX paths
            let upPoints: [CGPoint] = [
                CGPoint(x: 0,  y: 30), CGPoint(x: 8,  y: 28), CGPoint(x: 16, y: 32),
                CGPoint(x: 24, y: 22), CGPoint(x: 32, y: 24), CGPoint(x: 40, y: 16),
                CGPoint(x: 48, y: 18), CGPoint(x: 56, y: 8),  CGPoint(x: 64, y: 4),
            ]
            let downPoints: [CGPoint] = [
                CGPoint(x: 0,  y: 8),  CGPoint(x: 8,  y: 12), CGPoint(x: 16, y: 10),
                CGPoint(x: 24, y: 18), CGPoint(x: 32, y: 16), CGPoint(x: 40, y: 22),
                CGPoint(x: 48, y: 20), CGPoint(x: 56, y: 28), CGPoint(x: 64, y: 30),
            ]

            let srcPoints = up ? upPoints : downPoints
            let srcW: CGFloat = 64
            let srcH: CGFloat = 36

            // Scale to canvas size
            let pts = srcPoints.map { CGPoint(x: $0.x / srcW * w, y: $0.y / srcH * h) }

            // Stroke path
            var linePath = Path()
            linePath.move(to: pts[0])
            for pt in pts.dropFirst() { linePath.addLine(to: pt) }
            context.stroke(linePath, with: .color(color), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))

            // Fill area
            var fillPath = Path()
            fillPath.move(to: pts[0])
            for pt in pts.dropFirst() { fillPath.addLine(to: pt) }
            fillPath.addLine(to: CGPoint(x: w, y: h))
            fillPath.addLine(to: CGPoint(x: 0, y: h))
            fillPath.closeSubpath()
            context.fill(fillPath, with: .linearGradient(
                Gradient(stops: [
                    .init(color: color.opacity(0.3), location: 0),
                    .init(color: color.opacity(0),   location: 1),
                ]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: h)
            ))
        }
    }
}

// MARK: - Experience Screen
private struct V2ExperienceScreen: View {
    let accent: Color
    @Binding var selected: String?
    let onContinue: () -> Void

    private struct Option {
        let id: String
        let icon: String
        let title: String
        let sub: String
    }

    private var options: [Option] {[
        Option(id: "newbie", icon: "🌱", title: String(localized: "onboarding_v2.experience.option1.title"), sub: String(localized: "onboarding_v2.experience.option1.sub")),
        Option(id: "casual", icon: "🎯", title: String(localized: "onboarding_v2.experience.option2.title"), sub: String(localized: "onboarding_v2.experience.option2.sub")),
        Option(id: "degen",  icon: "🔥", title: String(localized: "onboarding_v2.experience.option3.title"), sub: String(localized: "onboarding_v2.experience.option3.sub")),
        Option(id: "whale",  icon: "🐋", title: String(localized: "onboarding_v2.experience.option4.title"), sub: String(localized: "onboarding_v2.experience.option4.sub")),
    ]}

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProgressBar(filled: 4, total: 6, accent: accent)
                .padding(.bottom, 30)

            Text(String(localized: "onboarding_v2.experience.headline"))
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.white)
                .tracking(-1)
                .lineSpacing(2)

            Text(String(localized: "onboarding_v2.experience.subtitle"))
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.55))
                .lineSpacing(4)
                .padding(.top, 10)
                .padding(.bottom, 26)

            VStack(spacing: 10) {
                ForEach(options.indices, id: \.self) { i in
                    let opt = options[i]
                    OptionCard(
                        icon: opt.icon,
                        title: opt.title,
                        sub: opt.sub,
                        isSelected: selected == opt.id,
                        accent: accent
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selected = opt.id
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.4).delay(Double(i) * 0.07), value: appeared)
                }
            }

            Spacer()

            // Continue — disabled until a selection is made
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onContinue()
            } label: {
                Text(String(localized: "onboarding_v2.cta.continue"))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(selected != nil ? Color(hex: "#0a0a0b") : .white.opacity(0.3))
                    .tracking(-0.3)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(selected != nil ? Color.white : Color.white.opacity(0.1))
                    .cornerRadius(18)
            }
            .disabled(selected == nil)
            .padding(.top, 16)
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .padding(.bottom, 30)
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}

// Shared option card used by experience (and future personalize screens)
private struct OptionCard: View {
    let icon: String
    let title: String
    let sub: String
    let isSelected: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            HStack(spacing: 14) {
                // Icon box
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? accent : Color.white.opacity(0.06))
                    Text(icon)
                        .font(.system(size: 22))
                }
                .frame(width: 44, height: 44)

                // Labels
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(sub)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.55))
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // Radio circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? accent : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 22, height: 22)

                    if isSelected {
                        Circle()
                            .fill(accent)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "#0a0a0b"))
                    }
                }
            }
            .padding(16)
            .background(isSelected ? accent.opacity(0.08) : Color.white.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? accent : Color.white.opacity(0.08), lineWidth: 1.5)
            )
            .cornerRadius(18)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
    }
}

// MARK: - Chains Screen
private struct V2ChainsScreen: View {
    let accent: Color
    @Binding var selected: Set<String>
    let onContinue: () -> Void

    private struct Chain {
        let id: String
        let imageName: String?  // nil = "Track all chains" uses glyph fallback
        let accentColor: Color
        let title: String
        let sub: String
    }

    private var chains: [Chain] {[
        Chain(id: "sol",  imageName: "solana",   accentColor: Color(hex: "#9945ff"), title: "Solana",           sub: String(localized: "onboarding_v2.chains.sol.sub")),
        Chain(id: "base", imageName: "base",     accentColor: Color(hex: "#0052ff"), title: "Base",             sub: String(localized: "onboarding_v2.chains.base.sub")),
        Chain(id: "eth",  imageName: "ethereum", accentColor: Color(hex: "#627eea"), title: "Ethereum",         sub: String(localized: "onboarding_v2.chains.eth.sub")),
        Chain(id: "bsc",  imageName: "bnb",      accentColor: Color(hex: "#f3ba2f"), title: "BNB Chain",        sub: String(localized: "onboarding_v2.chains.bsc.sub")),
        Chain(id: "tron", imageName: "tron",     accentColor: Color(hex: "#ef4444"), title: "Tron",             sub: String(localized: "onboarding_v2.chains.tron.sub")),
        Chain(id: "all",  imageName: nil,        accentColor: Color(hex: "#22c55e"), title: String(localized: "onboarding_v2.chains.all.title"), sub: String(localized: "onboarding_v2.chains.all.sub")),
    ]}

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProgressBar(filled: 5, total: 6, accent: accent)
                .padding(.bottom, 30)

            Text(String(localized: "onboarding_v2.chains.headline"))
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.white)
                .tracking(-1)
                .lineSpacing(2)

            Text(String(localized: "onboarding_v2.chains.subtitle"))
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.55))
                .lineSpacing(4)
                .padding(.top, 10)
                .padding(.bottom, 26)

            VStack(spacing: 10) {
                ForEach(chains.indices, id: \.self) { i in
                    let chain = chains[i]
                    let isSelected = selected.contains(chain.id)

                    ChainOptionCard(
                        imageName: chain.imageName,
                        accentColor: chain.accentColor,
                        title: chain.title,
                        sub: chain.sub,
                        isSelected: isSelected,
                        accent: accent
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if isSelected {
                                selected.remove(chain.id)
                            } else {
                                selected.insert(chain.id)
                            }
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.4).delay(Double(i) * 0.06), value: appeared)
                }
            }

            Spacer()

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onContinue()
            } label: {
                Text(String(localized: "onboarding_v2.cta.continue"))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(selected.isEmpty ? .white.opacity(0.3) : Color(hex: "#0a0a0b"))
                    .tracking(-0.3)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(selected.isEmpty ? Color.white.opacity(0.1) : Color.white)
                    .cornerRadius(18)
                    .animation(.easeInOut(duration: 0.15), value: selected.isEmpty)
            }
            .disabled(selected.isEmpty)
            .padding(.top, 16)
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .padding(.bottom, 30)
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}

// Chain card — uses real chain image asset, with ✦ glyph fallback for "all"
private struct ChainOptionCard: View {
    let imageName: String?
    let accentColor: Color
    let title: String
    let sub: String
    let isSelected: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            HStack(spacing: 14) {
                // Icon box
                ZStack {
                    if let name = imageName {
                        Image(name)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        // "Track all chains" fallback — keep dark bg + glyph
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? accent.opacity(0.15) : Color.white.opacity(0.06))
                        Text("✦")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(isSelected ? accent : accentColor)
                    }
                }
                .frame(width: 44, height: 44)
                .animation(.easeInOut(duration: 0.15), value: isSelected)

                // Labels
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(sub)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.55))
                }

                Spacer()

                // Radio circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? accent : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 22, height: 22)

                    if isSelected {
                        Circle()
                            .fill(accent)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "#0a0a0b"))
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: isSelected)
            }
            .padding(16)
            .background(isSelected ? accent.opacity(0.08) : Color.white.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? accent : Color.white.opacity(0.08), lineWidth: 1.5)
            )
            .cornerRadius(18)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
    }
}

// MARK: - Goals Screen
private struct V2GoalsScreen: View {
    let accent: Color
    @Binding var selected: Set<String>
    let onContinue: () -> Void

    private struct Goal {
        let id: String
        let icon: String
        let title: String
        let sub: String
    }

    private var goals: [Goal] {[
        Goal(id: "pumps",   icon: "🚀", title: String(localized: "onboarding_v2.goals.goal1.title"), sub: String(localized: "onboarding_v2.goals.goal1.sub")),
        Goal(id: "whales",  icon: "🐋", title: String(localized: "onboarding_v2.goals.goal2.title"), sub: String(localized: "onboarding_v2.goals.goal2.sub")),
        Goal(id: "new",     icon: "✨", title: String(localized: "onboarding_v2.goals.goal3.title"), sub: String(localized: "onboarding_v2.goals.goal3.sub")),
        Goal(id: "social",  icon: "📈", title: String(localized: "onboarding_v2.goals.goal4.title"), sub: String(localized: "onboarding_v2.goals.goal4.sub")),
        Goal(id: "pnl",     icon: "💼", title: String(localized: "onboarding_v2.goals.goal5.title"), sub: String(localized: "onboarding_v2.goals.goal5.sub")),
    ]}

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProgressBar(filled: 6, total: 6, accent: accent)
                .padding(.bottom, 30)

            Text(String(localized: "onboarding_v2.goals.headline"))
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.white)
                .tracking(-1)
                .lineSpacing(2)

            Text(String(localized: "onboarding_v2.goals.subtitle"))
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.55))
                .lineSpacing(4)
                .padding(.top, 10)
                .padding(.bottom, 26)

            VStack(spacing: 10) {
                ForEach(goals.indices, id: \.self) { i in
                    let goal = goals[i]
                    let isSelected = selected.contains(goal.id)

                    OptionCard(
                        icon: goal.icon,
                        title: goal.title,
                        sub: goal.sub,
                        isSelected: isSelected,
                        accent: accent
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if isSelected {
                                selected.remove(goal.id)
                            } else {
                                selected.insert(goal.id)
                            }
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.4).delay(Double(i) * 0.07), value: appeared)
                }
            }

            Spacer()

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onContinue()
            } label: {
                Text(String(localized: "onboarding_v2.goals.cta"))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(selected.isEmpty ? .white.opacity(0.3) : Color(hex: "#0a0a0b"))
                    .tracking(-0.3)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(selected.isEmpty ? Color.white.opacity(0.1) : Color.white)
                    .cornerRadius(18)
                    .animation(.easeInOut(duration: 0.15), value: selected.isEmpty)
            }
            .disabled(selected.isEmpty)
            .padding(.top, 16)
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .padding(.bottom, 30)
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}

// MARK: - Notify Screen
private struct V2NotifyScreen: View {
    let accent: Color
    let onContinue: () -> Void

    @State private var notifOffset: CGFloat = -20
    @State private var notifOpacity: Double = 0
    @State private var contentAppeared = false
    @State private var pulseDot = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()

                // Mock notification card
                HStack(alignment: .top, spacing: 12) {
                    // Pepe coin image as app icon
                    Image("pepe")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 38, height: 38)
                        .clipShape(RoundedRectangle(cornerRadius: 9))

                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("MemeAI")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text(String(localized: "onboarding_v2.notify.notif_time"))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.45))
                        }
                        Text(String(localized: "onboarding_v2.notify.notif_title"))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text(String(localized: "onboarding_v2.notify.notif_body"))
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.65))
                            .lineSpacing(2)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(hex: "#28282a").opacity(0.92))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .rotationEffect(.degrees(-2))
                .shadow(color: accent.opacity(0.35), radius: 28, x: 0, y: 12)
                .padding(.horizontal, 24)
                .offset(y: notifOffset)
                .opacity(notifOpacity)
                .rotation3DEffect(.degrees(notifOpacity < 1 ? -4 : 0), axis: (1, 0, 0))

                Spacer().frame(height: 66)

                // Headline + body
                VStack(spacing: 14) {
                    Text(String(localized: "onboarding_v2.notify.headline"))
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundColor(.white)
                        .tracking(-1.1)
                        .multilineTextAlignment(.center)

                    Text(String(localized: "onboarding_v2.notify.subtitle"))
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .frame(maxWidth: 300)
                }
                .opacity(contentAppeared ? 1 : 0)
                .offset(y: contentAppeared ? 0 : 10)

                Spacer()

                // Buttons
                VStack(spacing: 14) {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onContinue()
                    } label: {
                        Text(String(localized: "onboarding_v2.notify.cta.skip"))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.4))
                    }

                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        requestAndContinue()
                    } label: {
                        Text(String(localized: "onboarding_v2.notify.cta.enable"))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: "#0a0a0b"))
                            .tracking(-0.3)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(accent)
                            .cornerRadius(18)
                            .shadow(color: accent.opacity(0.4), radius: 14, x: 0, y: 6)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .opacity(contentAppeared ? 1 : 0)
            }
        }
        .onAppear {
            // Notification card slides in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.15)) {
                notifOffset = 0
                notifOpacity = 1
            }
            // Copy + buttons fade in after card settles
            withAnimation(.easeOut(duration: 0.45).delay(0.5)) {
                contentAppeared = true
            }
        }
    }

    private func requestAndContinue() {
        Task {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            do {
                let granted = try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: authOptions)
                print("Notification authorization granted: \(granted)")
            } catch {
                print("Notification authorization error: \(error.localizedDescription)")
            }
            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
                onContinue()
            }
        }
    }
}

// MARK: - Analyzing Screen
private struct V2AnalyzingScreen: View {
    let accent: Color
    let onComplete: () -> Void

    private let floatingEmojis = ["🐸", "🚀", "💎", "🔥", "🐋", "✨"]
    private var steps: [String] {[
        String(localized: "onboarding_v2.analyzing.step1"),
        String(localized: "onboarding_v2.analyzing.step2"),
        String(localized: "onboarding_v2.analyzing.step3"),
        String(localized: "onboarding_v2.analyzing.step4"),
    ]}

    @State private var progress: CGFloat = 0
    @State private var stepIndex = 0
    @State private var floatPhase: [Bool] = Array(repeating: false, count: 6)

    private let circleRadius: CGFloat = 80
    private var circumference: CGFloat { 2 * .pi * circleRadius }

    var body: some View {
        ZStack {
            // Floating emojis
            ForEach(floatingEmojis.indices, id: \.self) { i in
                Text(floatingEmojis[i])
                    .font(.system(size: 28))
                    .opacity(0.5)
                    .offset(
                        x: CGFloat([-80, 60, -100, 90, -70, 100][i]),
                        y: floatPhase[i]
                            ? CGFloat([-60, -40, 20, -80, 60, 30][i]) - 20
                            : CGFloat([-60, -40, 20, -80, 60, 30][i])
                    )
                    .rotationEffect(.degrees(floatPhase[i] ? 8 : 0))
                    .opacity(floatPhase[i] ? 0.9 : 0.4)
                    .animation(
                        .easeInOut(duration: 3 + Double(i) * 0.4)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.3),
                        value: floatPhase[i]
                    )
            }

            VStack(spacing: 32) {
                // Circular progress ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 6)
                        .frame(width: circleRadius * 2, height: circleRadius * 2)

                    Circle()
                        .trim(from: 0, to: progress / 100)
                        .stroke(accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: circleRadius * 2, height: circleRadius * 2)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: progress)

                    Text("\(Int(progress))%")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(.white)
                        .tracking(-1)
                }

                VStack(spacing: 8) {
                    Text(String(localized: "onboarding_v2.analyzing.headline"))
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(.white)
                        .tracking(-0.6)

                    Text(steps[stepIndex])
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.55))
                        .animation(.easeInOut(duration: 0.3), value: stepIndex)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Start float animations
            for i in floatingEmojis.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                    floatPhase[i] = true
                }
            }
            // Progress timer
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                let next = min(progress + 1.4, 100)
                progress = next
                stepIndex = min(steps.count - 1, Int(next / 25))
                if next >= 100 {
                    timer.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        onComplete()
                    }
                }
            }
        }
    }
}

// MARK: - Reviews Screen
private struct V2ReviewsScreen: View {
    let accent: Color
    let onContinue: () -> Void

    private var reviews: [(name: String, handle: String, title: String, body: String)] {[
        ("Marcus T.", "@degenmarc",
         String(localized: "onboarding_v2.reviews.review1.title"),
         String(localized: "onboarding_v2.reviews.review1.body")),
        ("Lina K.", "@linatrades",
         String(localized: "onboarding_v2.reviews.review2.title"),
         String(localized: "onboarding_v2.reviews.review2.body")),
        ("Jay R.", "@jaybonks",
         String(localized: "onboarding_v2.reviews.review3.title"),
         String(localized: "onboarding_v2.reviews.review3.body")),
    ]}

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Rating headline
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text("4.8")
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundColor(.white)
                    .tracking(-1.5)
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "#fbbf24"))
                    }
                }
            }

            Text(String(localized: "onboarding_v2.reviews.rating_sub"))
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
                .padding(.bottom, 24)

            Text(String(localized: "onboarding_v2.reviews.headline"))
                .font(.system(size: 30, weight: .heavy))
                .foregroundColor(.white)
                .tracking(-1)
                .lineSpacing(2)

            VStack(spacing: 12) {
                ForEach(reviews.indices, id: \.self) { i in
                    ReviewCard(review: reviews[i])
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.easeOut(duration: 0.45).delay(Double(i) * 0.1), value: appeared)
                }
            }
            .padding(.top, 20)

            Spacer()

            ContinueButton(action: onContinue)
                .padding(.top, 20)
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .padding(.bottom, 30)
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}

private struct ReviewCard: View {
    let review: (name: String, handle: String, title: String, body: String)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(review.name) · \(review.handle)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.45))
                }
                Spacer()
                HStack(spacing: 1) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#fbbf24"))
                    }
                }
            }
            Text("\u{201C}\(review.body)\u{201D}")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .lineSpacing(3)
                .padding(.top, 8)
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.07), lineWidth: 1))
        .cornerRadius(18)
    }
}

// MARK: - Paywall Screen
private struct V2PaywallScreen: View {
    let accent: Color
    let onSkip: () -> Void
    let onDone: () -> Void

    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedPackage: Package?
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var errorMessage: String?
    @State private var appeared = false

    private var features: [String] {[
        String(localized: "onboarding_v2.paywall.feature1"),
        String(localized: "onboarding_v2.paywall.feature2"),
        String(localized: "onboarding_v2.paywall.feature3"),
        String(localized: "onboarding_v2.paywall.feature4"),
        String(localized: "onboarding_v2.paywall.feature5"),
    ]}

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Radial glow
            RadialGradient(
                colors: [accent.opacity(0.2), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 380
            )
            .ignoresSafeArea()
            .offset(y: -100)

            // Scrollable content — badge, headline, features
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Badge
                    Text(String(localized: "onboarding_v2.paywall.badge"))
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(Color(hex: "#0a0a0b"))
                        .kerning(0.6)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(colors: [accent, Color(hex: "#a855f7")], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .padding(.bottom, 16)

                    Text(String(localized: "onboarding_v2.paywall.headline"))
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(.white)
                        .tracking(-1.3)
                        .lineSpacing(2)

                    Text(String(localized: "onboarding_v2.paywall.subtitle"))
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.55))
                        .lineSpacing(4)
                        .padding(.top, 10)
                        .padding(.bottom, 20)

                    // Feature checklist
                    VStack(spacing: 2) {
                        ForEach(features.indices, id: \.self) { i in
                            FeatureCheckRow(text: features[i], accent: accent)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 10)
                                .animation(.easeOut(duration: 0.4).delay(Double(i) * 0.08), value: appeared)
                        }
                    }

                    // Spacer so content isn't hidden behind the fixed footer
                    Spacer().frame(height: 260)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
            }

            // Fixed footer — plans + CTA + legal
            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(spacing: 15) {
                    // Plan selector
                    if subscriptionManager.weeklyPackage != nil || subscriptionManager.monthlyPackage != nil {
                        if let weekly = subscriptionManager.weeklyPackage {
                            PlanCard(
                                title: String(localized: "onboarding_v2.paywall.plan.weekly.title"),
                                detail: String(format: String(localized: "onboarding_v2.paywall.plan.weekly.detail"), weekly.storeProduct.localizedPriceString),
                                price: weekly.storeProduct.localizedPriceString,
                                period: String(localized: "onboarding_v2.paywall.plan.weekly.period"),
                                badge: String(localized: "onboarding_v2.paywall.plan.weekly.badge"),
                                isSelected: selectedPackage?.identifier == weekly.identifier,
                                accent: accent
                            ) { selectedPackage = weekly }
                        }
                        if let monthly = subscriptionManager.monthlyPackage {
                            PlanCard(
                                title: String(localized: "onboarding_v2.paywall.plan.monthly.title"),
                                detail: String(format: String(localized: "onboarding_v2.paywall.plan.monthly.detail"), monthly.storeProduct.localizedPriceString),
                                price: monthly.storeProduct.localizedPriceString,
                                period: String(localized: "onboarding_v2.paywall.plan.monthly.period"),
                                badge: nil,
                                isSelected: selectedPackage?.identifier == monthly.identifier,
                                accent: accent
                            ) { selectedPackage = monthly }
                        }
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: accent))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .task { await subscriptionManager.loadOfferings() }
                    }

                    // CTA button
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        handlePurchase()
                    } label: {
                        ZStack {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#0a0a0b")))
                            } else {
                                Text(String(localized: "onboarding_v2.paywall.cta.subscribe"))
                                    .font(.system(size: 17, weight: .heavy))
                                    .foregroundColor(Color(hex: "#0a0a0b"))
                                    .tracking(-0.3)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(accent)
                        .cornerRadius(18)
                        .shadow(color: accent.opacity(0.4), radius: 14, x: 0, y: 6)
                    }
                    .disabled(isPurchasing || selectedPackage == nil)

                    // Restore + legal
                    HStack(spacing: 16) {
                        Link(String(localized: "onboarding_v2.paywall.legal.terms"), destination: URL(string: "https://apps.tocaas.com/meme-ai/terms-of-use")!)
                        Text("·")
                        Button(action: handleRestore) {
                            if isRestoring {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(String(localized: "onboarding_v2.paywall.cta.restore"))
                            }
                        }
                        Text("·")
                        Link(String(localized: "onboarding_v2.paywall.legal.privacy"), destination: URL(string: "https://apps.tocaas.com/meme-ai/privacy-policy")!)
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 26)
                .padding(.bottom, 10)
                .background(
                    // Fade-up blur so content beneath doesn't hard-cut
                    LinearGradient(
                        colors: [Color(hex: "#0a0a0b").opacity(0), Color(hex: "#0a0a0b")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    .padding(.top, -40)
                )
            }
        }
        .onAppear {
            selectedPackage = subscriptionManager.weeklyPackage ?? subscriptionManager.monthlyPackage
            withAnimation { appeared = true }
        }
        .onChange(of: subscriptionManager.weeklyPackage) { pkg in
            if selectedPackage == nil { selectedPackage = pkg }
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
                if success { onDone() }
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
                    onDone()
                } else {
                    errorMessage = String(localized: "paywall.error.no_subscriptions")
                }
            }
        }
    }
}

private struct FeatureCheckRow: View {
    let text: String
    let accent: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(accent).frame(width: 22, height: 22)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "#0a0a0b"))
            }
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

private struct PlanCard: View {
    let title: String
    let detail: String
    let price: String
    let period: String
    let badge: String?
    let isSelected: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text(detail)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.55))
                }
                Spacer()
                HStack(alignment: .lastTextBaseline, spacing: 1) {
                    Text(price)
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(.white)
                        .tracking(-0.6)
                    Text(period)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.55))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(isSelected ? accent.opacity(0.15) : Color.white.opacity(0.04))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? accent : Color.white.opacity(0.08), lineWidth: 2)
        )
        .cornerRadius(18)
        .overlay(alignment: .topTrailing) {
            if let badge {
                Text(badge)
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(Color(hex: "#0a0a0b"))
                    .kerning(0.5)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(accent)
                    .clipShape(Capsule())
                    .offset(x: -12, y: -10)
                    .allowsHitTesting(false)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Done Screen
private struct V2DoneScreen: View {
    let accent: Color
    let onContinue: () -> Void

    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [accent, Color(hex: "#a855f7")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: accent.opacity(0.55), radius: 30, x: 0, y: 10)

                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color(hex: "#0a0a0b"))
            }
            .scaleEffect(iconScale)
            .opacity(iconOpacity)
            .padding(.bottom, 28)

            Text(String(localized: "onboarding_v2.done.headline"))
                .font(.system(size: 36, weight: .heavy))
                .foregroundColor(.white)
                .tracking(-1.2)

            Text(String(localized: "onboarding_v2.done.subtitle"))
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: 280)
                .padding(.top, 12)

            Spacer()

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onContinue()
            } label: {
                Text(String(localized: "onboarding_v2.done.cta"))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(hex: "#0a0a0b"))
                    .tracking(-0.3)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.white)
                    .cornerRadius(18)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .onAppear {
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 15).delay(0.1)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
        }
    }
}

// MARK: - Shared Components

private struct ProgressBar: View {
    let filled: Int
    let total: Int
    let accent: Color

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                RoundedRectangle(cornerRadius: 99)
                    .fill(i < filled ? accent : Color.white.opacity(0.08))
                    .frame(maxWidth: .infinity)
                    .frame(height: 4)
            }
        }
    }
}

private struct ContinueButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        } label: {
            Text(String(localized: "onboarding_v2.cta.continue"))
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(hex: "#0a0a0b"))
                .tracking(-0.3)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(.white)
                .cornerRadius(18)
        }
    }
}
