import Foundation

class CoinDataApi {
    static let shared = CoinDataApi()
    
    private init() {}
    
    private struct CoinDataApiResponse: Decodable {
        var data: CoinData
    }
    
    func getCoinData(id: Int) async -> CoinData? {
        guard let url = URL(string: "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/detail/?id=\(id)") else { return nil }
        
        let headers = [
            "Accepts": "application/json",
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        do {
            let (data, _) = try await safeSession().data(for: request)
            let response = try JSONDecoder().decode(CoinDataApiResponse.self, from: data)
            return response.data
        } catch {
            print("Error fetching coin data: \(error.localizedDescription)")
        }
        return nil
    }
    
    func loadWatchList() async -> [Coin] {
        print("🏠 WIDGET: Loading watchlist from UserDefaults")
        let sharedDefaults = UserDefaults(suiteName: "group.com.pileus.memewatch.shared")
        let watchListArray = sharedDefaults?.array(forKey: "watchList") as? [Int] ?? []
        print("🏠 WIDGET: Found \(watchListArray.count) coins in watchlist: \(watchListArray)")
        
        var coinArray: [Coin] = []
        for id in watchListArray {
            print("🔄 WIDGET: Fetching coin data for ID: \(id)")
            if let coinDetails = await getCoinData(id: id) {
                let coin = Coin(fromCoinDetails: coinDetails)
                print("✅ WIDGET: Successfully created coin: \(coin.symbol) - \(coin.name)")
                coinArray.append(coin)
            } else {
                print("❌ WIDGET: Failed to fetch coin data for ID: \(id)")
            }
        }
        
        print("🏁 WIDGET: Loaded \(coinArray.count) coins for watchlist")
        return coinArray
    }
}