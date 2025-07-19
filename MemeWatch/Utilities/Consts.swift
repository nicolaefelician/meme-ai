import SwiftUI
import RevenueCat

final class Consts {
    private init() {}
    
    static let shared = Consts()
    
    let backgroundColor: Color = Color(hex: "#FFFFFF")
    let cardColor: Color = Color(hex: "#e7e7e7")
    
    let revenueCatApiKey: String = "appl_LLBLyrAeBElmNCSAceowEYvAEvB"
    let superwallApiKey: String = "pk_2e4bce9df65c721b1f9630fe0921ad3c1a8b686a1245ea0d"
    
    let appCode = "meme-ai"
    let appVersion = "1.0.0"
    let firebaseTokenId = ""
    
    let appGroupIdentifier = "group.com.pileus.memewatch.shared"
    
    let openAiApiKey = "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"
    
    func loadContent() {
        AppManager.shared.showOnboarding = !UserDefaults.standard.bool(forKey: "hasShownOnboarding")
    }
    
    var storedUserId: String? {
        return UserDefaults.standard.string(forKey: "userId")
    }
    
    var sharedUserId: String? {
        return sharedUserDefaults?.string(forKey: "userId")
    }
    
    var favoriteCoins: [Int] {
        return UserDefaults.standard.array(forKey: "favoriteCoins") as? [Int] ?? []
    }
    
    var sharedUserDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }
    
    var sharedWatchList: [Int] {
        return sharedUserDefaults?.array(forKey: "watchList") as? [Int] ?? []
    }
    
    func saveToSharedDefaults(key: String, value: Any) {
        sharedUserDefaults?.set(value, forKey: key)
    }
    
    func saveSharedWatchList(_ watchList: [Int]) {
        sharedUserDefaults?.set(watchList, forKey: "watchList")
    }
}

enum NavigationView: Hashable {
    case coinDataView(coinId: Int)
    case newsDataView(newsId: String)
    case coinAnalysisView(analysis: CoinAnalysis)
    case postDetailView(post: Post)
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
