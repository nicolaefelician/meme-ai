final class NewsPreview: Decodable, Identifiable {
    let id: String
    let title: String
    let content: String
    let sentiment: String
    let publishedDate: String
}

final class NewsData: Decodable, Identifiable {
    let id: String
    let title: String
    let url: String
    let coin: String
    let sentiment: String
    let cryptoMarketImpact: String
    let content: String
    let analysisDate: String
}
