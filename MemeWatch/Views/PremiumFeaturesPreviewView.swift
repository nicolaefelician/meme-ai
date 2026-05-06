import SwiftUI

struct PremiumFeaturesPreviewView: View {
    @Environment(\.dismiss) var dismiss
    let coin: Coin
    
    private let features = [
        PremiumFeature(
            icon: "brain.head.profile",
            title: "AI Analysis",
            description: "Get detailed AI-powered technical analysis with trend predictions, indicator analysis, and chart patterns for every coin.",
            color: .blue,
            imageName: "premium2"
        ),
        PremiumFeature(
            icon: "newspaper",
            title: "Latest News",
            description: "Stay informed with real-time news, market insights, and updates specifically related to your selected cryptocurrency.",
            color: .orange,
            imageName: "premium3"
        ),
        PremiumFeature(
            icon: "chart.line.uptrend.xyaxis",
            title: "Advanced Charts",
            description: "Access detailed price charts with multiple timeframes, technical indicators, and comprehensive market data.",
            color: .green,
            imageName: "premium1"
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(String(localized: "common.cancel")) {
                    dismiss()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(String(localized: "premium.title"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("for \(coin.symbol)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(String(localized: "common.cancel"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            // Features List
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        PremiumFeatureCard(feature: feature, isLast: index == features.count - 1)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            
            // Get Pro Button
            VStack(spacing: 12) {
                Button(action: {
                    dismiss()
                    // Small delay to ensure dismiss completes before showing paywall
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        SubscriptionManager.shared.showPaywall = true
                    }
                }) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 16, weight: .bold))
                        
                        Text(String(localized: "premium.cta.get_pro"))
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.red.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(27)
                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Text(String(localized: "premium.cta.subtitle"))
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .padding(.top, 20)
        }
        .background(Color.white)
        .preferredColorScheme(.light)
    }
}

struct PremiumFeature {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let imageName: String
}

struct PremiumFeatureCard: View {
    let feature: PremiumFeature
    let isLast: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Feature Header
            HStack(spacing: 15) {
                // Icon
                ZStack {
                    Circle()
                        .fill(feature.color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: feature.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(feature.color)
                }
                
                // Title and Description
                VStack(alignment: .leading, spacing: 4) {
                    Text(feature.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(feature.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            // Feature Preview Image
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.05))
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                
                // Load actual screenshot or fallback
                if let image = UIImage(named: feature.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 190)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: feature.icon)
                            .font(.system(size: 40))
                            .foregroundColor(feature.color.opacity(0.6))
                        
                        Text(String(localized: "premium.preview_coming_soon"))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            if !isLast {
                Divider()
                    .padding(.top, 10)
            }
        }
        .padding(.vertical, 10)
    }
}
