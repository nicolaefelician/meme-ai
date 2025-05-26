import SwiftUI

final class Consts {
    private init() {}
    
    static let shared = Consts()
    
    let backgroundColor: Color = Color(hex: "#FFFFFF")
    let cardColor: Color = Color(hex: "#e7e7e7")
    
    let revenueCatApiKey: String = ""
    let superwallApiKey: String = ""
    let openAiApiKey: String = "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"
}

enum NavigationView: Hashable {
    case coinDataView(coinId: Int)
    case newsDataView(newsId: String)
    case coinAnalysisView(analysis: CoinAnalysis)
}

enum TimeRange: String, CaseIterable {
    case oneHour = "1h"
    case twentyFourHours = "24h"
    case sevenDays = "7d"
    case thirtyDays = "30d"
}

enum CoinPriceChartTimeRange: String, CaseIterable {
    case oneHour = "1h"
    case oneDay = "1d"
    case sevenDays = "7d"
    case oneMonth = "1m"
    case oneYear = "1y"
}

enum TextFonts: String, CaseIterable {
    case instrumentSansSemiBold = "InstrumentSans-SemiBold"
    case interRegular = "Inter_24pt-Regular"
    case interMedium = "Inter_24pt-Medium"
    case interSemibold = "Inter_24pt-SemiBold"
}

enum CoinCategory: String, CaseIterable {
    case gainers = "Gainers"
    case watchList = "Watch List"
    case losers = "Losers"
    case mostVisited = "Most Visited"
    case recentlyAdded = "Recently Added"
}

enum ChatMessageError: Error {
    case invalidJson
    case invalidHttpResponse(statusCode: Int?)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
