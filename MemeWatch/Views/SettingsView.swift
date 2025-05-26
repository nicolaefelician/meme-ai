import SwiftUI
import StoreKit

struct SettingsView: View {
    @State private var isSharing = false
    @Environment(\.requestReview) var requestReview
    @ObservedObject private var appManager = AppManager.shared
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    sectionHeader(title: "General")
                    settingButton(icon: "square.and.arrow.up", title: "Share App") {
                        isSharing = true
                    }
                    settingButton(icon: "envelope", title: "Contact us") {
                        openMail()
                    }
                    settingButton(icon: "hand.thumbsup", title: "Rate us") {
                        requestReview()
                    }
                    
                    Divider().background(Color.gray.opacity(0.4)).padding(.horizontal, 20)
                    
                    sectionHeader(title: "Support")
                    settingButton(icon: "person.2.fill", title: "Follow us") {
                        openURL("https://www.google.com")
                    }
                    settingButton(icon: "info.circle", title: "About us") {
                        openURL("https://www.google.com")
                    }
                    settingButton(icon: "app.badge", title: "Our Apps") {
                        openURL("https://www.google.com")
                    }
                    
                    Divider().background(Color.gray.opacity(0.4)).padding(.horizontal, 20)
                    
                    sectionHeader(title: "Legal")
                    settingButton(icon: "dollarsign.arrow.circlepath", title: "Restore Purchase") {}
                    settingButton(icon: "lock.shield", title: "Privacy Policy") {
                        openURL("https://www.google.com")
                    }
                    settingButton(icon: "doc.text", title: "Terms of Use") {
                        openURL("https://www.google.com")
                    }
                    settingButton(icon: "creditcard.fill", title: "Manage Subscription") {}
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.light)
    }
    
    @ViewBuilder
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 20))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 10)
            .padding(.top, 10)
    }
    
    @ViewBuilder
    private func settingButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                    .font(.title2)
                    .frame(width: 30)
                
                Text(title)
                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 18))
                    .foregroundColor(.black.opacity(0.6))
                    .padding(.leading, 5)
                
                Spacer()
            }
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)]), startPoint: .leading, endPoint: .trailing))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            )
        }
    }
    
    private func openMail() {
        let email = "support@example.com"
        let subject = "Support Request"
        let body = "Hi, I need help with..."
        let mailtoURL = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: mailtoURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
