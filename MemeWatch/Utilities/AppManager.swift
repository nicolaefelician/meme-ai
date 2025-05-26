import Combine

final class AppManager: ObservableObject {
    private init() {}
    
    static let shared = AppManager()
    
    @Published var path: [NavigationView] = []
    
    @Published var showOnboarding: Bool = true
    @Published var showSplashView: Bool = true
    
    @Published var gainersCoinsList: [Coin] = []
    @Published var losersCoinsList: [Coin] = []
    @Published var mostVisitedCoinsList: [Coin] = []
    @Published var trendingCoinsList: [Coin] = []
    @Published var recentlyAddedCoinsList: [Coin] = []
    @Published var watchList: [Coin] = []
    
    @Published var fearGreedIndicator: Double = 0.0
    
    @Published var isPremiumUser: Bool = false
    
    @Published var newsPreviews: [NewsPreview] = []
    
    @Published var stringToShare: String? = nil
    @Published var isSharing: Bool = false
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    
    func completedOnboarding() {
        showOnboarding = false
    }
}
