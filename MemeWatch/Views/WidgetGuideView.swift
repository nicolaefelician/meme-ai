import SwiftUI

struct WidgetGuideView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    
    private let images = ["1", "2", "3", "4"]
    private let titles = [
        String(localized: "widget_guide.step1.title"),
        String(localized: "widget_guide.step2.title"),
        String(localized: "widget_guide.step3.title"),
        String(localized: "widget_guide.step4.title")
    ]
    private let descriptions = [
        String(localized: "widget_guide.step1.description"),
        String(localized: "widget_guide.step2.description"),
        String(localized: "widget_guide.step3.description"),
        String(localized: "widget_guide.step4.description")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(String(localized: "widget_guide.close")) {
                    dismiss()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)

                Spacer()

                Text(String(localized: "widget_guide.nav_title"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Spacer()

                Text(String(localized: "widget_guide.close"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 20)
            
            // Content
            TabView(selection: $currentPage) {
                ForEach(0..<4, id: \.self) { index in
                    VStack(spacing: 30) {
                        Spacer()
                        
                        // Image
                        Image(images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 400)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.horizontal, 20)
                        
                        // Text content
                        VStack(spacing: 15) {
                            Text(titles[index])
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                            
                            Text(descriptions[index])
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        }
                        
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Navigation buttons
            HStack(spacing: 20) {
                Button(action: {
                    if currentPage > 0 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage -= 1
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                        Text(String(localized: "widget_guide.previous"))
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(currentPage > 0 ? .blue : .gray)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                .disabled(currentPage == 0)
                
                Spacer()
                
                Button(action: {
                    if currentPage < 3 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    } else {
                        dismiss()
                    }
                }) {
                    HStack {
                        Text(currentPage < 3 ? String(localized: "widget_guide.next") : String(localized: "widget_guide.done"))
                            .font(.system(size: 16, weight: .medium))
                        if currentPage < 3 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.blue)
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color.white)
        .preferredColorScheme(.light)
    }
}
