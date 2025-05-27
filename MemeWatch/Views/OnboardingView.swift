import SwiftUI
import SuperwallKit

struct OnboardingView: View {
    private struct OnboardingInfo {
        let title: String
        let description: String
        let image: String
        let buttonText: String
    }
    
    private let onboardingInfos: [OnboardingInfo] = [OnboardingInfo(title: "Welcome to MemeAI!", description: "Discover the world of meme coins with MemeAI ! Whether you’re a crypto enthusiast or a new to the market, MemeAI helps you identify meme coins and understand their behavior in the market.", image: "onboarding1", buttonText: "Continue"),
                                                     OnboardingInfo(title: "Analyze Meme Coins with Ease", description: "With MemeAI analyzing meme coins is simple and effective. Just upload an image of the chart, of snap a picture of it using your phone. It’s that easy!", image: "onboarding2", buttonText: "Continue"), OnboardingInfo(title: "Get Informed at any Moment", description: "Our real-time analysis keeps you uptaded with market movements, helping you make informed decisions.", image: "onboarding3", buttonText: "Get Started")]
    @State private var currentOnboardingIndex = 0
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    @Environment(\.requestReview) var requestReview
    
    @ObservedObject private var appManager = AppManager.shared
    
    var body: some View {
        VStack {
            Image(onboardingInfos[currentOnboardingIndex].image)
                .resizable()
                .scaledToFit()
                .frame(width: 350)
                .padding(.top, 90)
            
            VStack(alignment: .leading) {
                Text(onboardingInfos[currentOnboardingIndex].title)
                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 28))
                    .foregroundStyle(.black)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 7)
                    .padding(.top, 45)
                
                Text(onboardingInfos[currentOnboardingIndex].description)
                    .font(.custom(TextFonts.interRegular.rawValue, size: 17))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 28)
            
            Spacer()
            
            Button(action: {
                impactFeedback.impactOccurred()
                if currentOnboardingIndex == onboardingInfos.count - 1 {
                    withAnimation {
                        requestReview()
                        appManager.completedOnboarding()
                        Superwall.shared.register(placement: "campaign_trigger")
                    }
                } else {
                    withAnimation {
                        currentOnboardingIndex += 1
                    }
                }
            }) {
                Text(onboardingInfos[currentOnboardingIndex].buttonText)
                    .font(.custom(TextFonts.interMedium.rawValue, size: 22))
                    .foregroundColor(.white)
                    .padding(.vertical, 17)
                    .frame(width: 340)
                    .background(.black)
                    .cornerRadius(13)
                    .padding(.bottom, 20)
            }
        }
        .background(Consts.shared.backgroundColor)
        .onAppear {
            impactFeedback.prepare()
        }
    }
}
