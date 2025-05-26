import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    @State private var logoScale: CGFloat = 0.5
    
    @ObservedObject private var appManager = AppManager.shared
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1A1A1A"),
                    Color(hex: "2D2D2D")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)
                    .offset(x: -100, y: -100)
                
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)
                    .offset(x: 100, y: 100)
            }
            
            VStack(spacing: 25) {
                Image("icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(color: .orange.opacity(0.3), radius: 20, x: 0, y: 10)
                    .scaleEffect(logoScale)
                
                Text("Meme AI")
                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 36))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                    .scaleEffect(1)
                    .opacity(opacity)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .transition(.opacity.combined(with: .scale))
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
                logoScale = 1.0
            }
            
            Task {
                await refreshData()
            }
        }
    }
    
    func refreshData() async {
        try? await CoinDataApi.shared.fetchFearAndGreedIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.5)) {
                appManager.showSplashView = false
            }
        }
    }
}
