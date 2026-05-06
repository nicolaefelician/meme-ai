import SwiftUI

final class NewsDataViewModel: ObservableObject {
    @Published var newsData: NewsData? = nil
}

struct NewsDataView: View {
    let id: String
    
    @StateObject private var viewModel: NewsDataViewModel = NewsDataViewModel()
    @State private var showWebView = false
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    private func buildSentimentCard(sentiment: String) -> some View {
        let sentimentColor: Color
        switch sentiment {
        case "Positive":
            sentimentColor = .green
        case "Negative":
            sentimentColor = .red
        default:
            sentimentColor = .yellow
        }
        
        return Text(sentiment)
            .font(.custom(TextFonts.interMedium.rawValue, size: 12))
            .foregroundColor(sentimentColor)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(sentimentColor.opacity(0.4))
            .cornerRadius(10)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                if let data = viewModel.newsData {
                    VStack(alignment: .leading, spacing: 15) {
                        Divider()
                            .foregroundStyle(.gray)
                        
                        Text(data.title)
                            .font(.custom(TextFonts.interSemibold.rawValue, size: 20))
                            .multilineTextAlignment(.leading)
                        
                        Text(Utilities.shared.formatDate(data.analysisDate))
                            .font(.custom(TextFonts.interRegular.rawValue, size: 14))
                            .foregroundStyle(.black)
                        
                        buildSentimentCard(sentiment: data.sentiment)
                        
                        if data.coin != "" && data.coin.lowercased() != "n/a" {
                            HStack {
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .foregroundColor(.yellow)
                                Text(data.coin.uppercased())
                                    .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                                    .bold()
                                    .foregroundColor(.gray.opacity(0.8))
                            }
                        }
                        
                        Text(data.content)
                            .font(.custom(TextFonts.interRegular.rawValue, size: 15))
                            .multilineTextAlignment(.leading)
                    }
                }
                else {
                    VStack {
                        Text(String(localized: "common.loading"))
                            .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                            .foregroundStyle(.black)
                        
                        ProgressView()
                            .foregroundStyle(.black)
                    }
                    .padding(.top, 300)
                    .task {
                        impactFeedback.prepare()
                        viewModel.newsData = await NewsApi.shared.getNewsData(id: id)
                    }
                }
            }
            .padding(.horizontal, 20)
            .navigationTitle("News")
            .navigationBarTitleDisplayMode(.large)
            
            if let data = viewModel.newsData {
                VStack {
                    Spacer()
                    
                    Button(action: {
                        impactFeedback.impactOccurred()
                        if let url = URL(string: data.url) {
                            showWebView = true
                        }
                    }) {
                        Text(String(localized: "news.read_full_article"))
                            .foregroundStyle(.white)
                            .font(.custom(TextFonts.interSemibold.rawValue, size: 20))
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(
                                Color(hex: "#EF8011")
                                    .cornerRadius(8)
                                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 4)
                                    .padding(.horizontal, 20)
                            )
                            .padding(.bottom, 23)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showWebView) {
            if let data = viewModel.newsData, let url = URL(string: data.url) {
                ArticleWebView(url: url)
            }
        }
    }
}
