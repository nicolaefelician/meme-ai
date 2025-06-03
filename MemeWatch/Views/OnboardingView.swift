import SwiftUI
import SuperwallKit

struct OnboardingView: View {
    private struct OnboardingInfo {
        let title: String
        let description: String
        let image: String
        let buttonText: String
    }
    
    private let onboardingInfos: [OnboardingInfo] = [
        OnboardingInfo(
            title: "Welcome to MemeAI!",
            description: "Spot the next 100x meme coin before everyone else. AI-powered insights that give you the edge.",
            image: "onboarding1",
            buttonText: "Continue"
        ),
        OnboardingInfo(
            title: "Instant Chart Analysis",
            description: "Snap any crypto chart. Get professional analysis in seconds. No more missed opportunities.",
            image: "onboarding2",
            buttonText: "Continue"
        ),
        OnboardingInfo(
            title: "Join Elite Traders",
            description: "Pro members get real-time alerts, exclusive insights, and priority analysis. Start winning today.",
            image: "onboarding3",
            buttonText: "Get Started"
        )
    ]
    
    @State private var currentOnboardingIndex = 0
    @State private var imageOffset: CGFloat = 0
    @State private var showContent = false
    @State private var buttonScale: CGFloat = 1.0
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    @Environment(\.requestReview) var requestReview
    @ObservedObject private var appManager = AppManager.shared
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#FFFFFF"),
                    Color(hex: "#F8F9FA")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                skipButton
                
                imageSection
                
                progressIndicator
                    .padding(.top, 30)
                
                contentSection
                
                Spacer()
                
                actionButton
            }
        }
        .onAppear {
            impactFeedback.prepare()
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
        }
    }
    
    private var skipButton: some View {
        HStack {
            Spacer()
            
            Button(action: {
                impactFeedback.impactOccurred()
                withAnimation {
                    appManager.completedOnboarding()
                    Superwall.shared.register(placement: "test")
                }
            }) {
                Text("Skip")
                    .font(.custom(TextFonts.interMedium.rawValue, size: 16))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
        }
        .padding(.top, 25)
        .padding(.horizontal, 20)
    }
    
    private var imageSection: some View {
        ZStack {
            ForEach(onboardingInfos.indices, id: \.self) { index in
                Image(onboardingInfos[index].image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
                    .frame(height: 300)
                    .opacity(currentOnboardingIndex == index ? 1 : 0)
                    .scaleEffect(currentOnboardingIndex == index ? 1 : 0.8)
                    .offset(x: currentOnboardingIndex == index ? imageOffset : 0)
            }
        }
        .padding(.top, 35)
        .gesture(
            DragGesture()
                .onChanged { value in
                    imageOffset = value.translation.width
                }
                .onEnded { value in
                    withAnimation(.spring()) {
                        imageOffset = 0
                        
                        if value.translation.width < -50 && currentOnboardingIndex < onboardingInfos.count - 1 {
                            currentOnboardingIndex += 1
                        } else if value.translation.width > 50 && currentOnboardingIndex > 0 {
                            currentOnboardingIndex -= 1
                        }
                    }
                }
        )
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(onboardingInfos.indices, id: \.self) { index in
                Capsule()
                    .fill(currentOnboardingIndex == index ? Color.black : Color.gray.opacity(0.3))
                    .frame(width: currentOnboardingIndex == index ? 24 : 8, height: 8)
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(onboardingInfos[currentOnboardingIndex].title)
                .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 32))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            
            Text(onboardingInfos[currentOnboardingIndex].description)
                .font(.custom(TextFonts.interRegular.rawValue, size: 18))
                .foregroundStyle(Color.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .padding(.horizontal, 40)
        }
        .padding(.top, 40)
        .transition(.opacity.combined(with: .slide))
        .id(currentOnboardingIndex)
    }
    
    private var actionButton: some View {
        VStack(spacing: 20) {
            Button(action: {
                impactFeedback.impactOccurred()
                
                withAnimation(.easeInOut(duration: 0.1)) {
                    buttonScale = 0.95
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        buttonScale = 1.0
                    }
                }
                
                if currentOnboardingIndex == onboardingInfos.count - 1 {
                    requestReview()
                    
                    withAnimation {
                        appManager.completedOnboarding()
                    }
                    
                    Superwall.shared.register(placement: "campaign_trigger")
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showContent = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        currentOnboardingIndex += 1
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showContent = true
                        }
                    }
                }
            }) {
                HStack {
                    Text(onboardingInfos[currentOnboardingIndex].buttonText)
                        .font(.custom(TextFonts.interSemibold.rawValue, size: 18))
                        .foregroundColor(.white)
                    
                    if currentOnboardingIndex < onboardingInfos.count - 1 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .scaleEffect(buttonScale)
            }
            .padding(.horizontal, 30)
        }
        .padding(.bottom, 20)
    }
}
