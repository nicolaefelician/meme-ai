import SwiftUI
import SuperwallKit

struct NewsListView: View {
    @ObservedObject private var appManager = AppManager.shared
    
    private let orangeColor = Color(hex: "#EF8011")
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
    
    private func buildNewsCard(news: NewsPreview) -> some View {
        return Button(action: {
            if appManager.isPremiumUser {
                impactFeedback.impactOccurred()
                appManager.path.append(.newsDataView(newsId: news.id))
            } else {
                Superwall.shared.register(placement: "campaign_trigger")
            }
            
        }) {
            VStack(alignment: .leading, spacing: 13) {
                Divider()
                    .foregroundStyle(.gray)
                
                HStack {
                    Text(news.title)
                        .font(.custom(TextFonts.interSemibold.rawValue, size: 15))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Spacer(minLength: 10)
                    
                    Text("See more")
                        .font(.custom(TextFonts.interSemibold.rawValue, size: 12))
                        .foregroundColor(Color.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange, lineWidth: 1)
                        )
                }
                
                Text(Utilities.shared.formatDate(news.publishedDate))
                    .font(.custom(TextFonts.interRegular.rawValue, size: 13))
                    .foregroundColor(.black)
                
                buildSentimentCard(sentiment: news.sentiment)
                
                Text(news.content)
                    .font(.custom(TextFonts.interRegular.rawValue, size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            if appManager.newsPreviews.isEmpty {
                VStack {
                    Text("Loading...")
                        .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                        .foregroundStyle(.black)
                    
                    ProgressView()
                        .foregroundStyle(.black)
                }
                .padding(.top, 280)
                .onAppear {
                    impactFeedback.prepare()
                }
            } else {
                LazyVStack(spacing: 20) {
                    ForEach(appManager.newsPreviews) { news in
                        buildNewsCard(news: news)
                            .padding(.trailing, 1)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.top, 7)
            }
        }
        .refreshable {
            await NewsApi.shared.fetchNewsPreviews()
        }
        .task {
            if appManager.newsPreviews.isEmpty {
                await NewsApi.shared.fetchNewsPreviews()
            }
        }
    }
}
