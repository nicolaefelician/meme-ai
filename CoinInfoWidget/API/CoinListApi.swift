import Foundation

class CoinListApi {
    static let shared = CoinListApi()
    
    private init() {}
    
    struct GainerLoserResponse {
        let gainers: [Coin]
        let losers: [Coin]
    }
    
    private struct CoinDataListApiResponse: Decodable {
        struct ResponseList: Decodable {
            let gainerList: [Coin]
            let loserList: [Coin]
        }
        
        let data: ResponseList
    }
    
    func fetchGainerLoserList(timeRange: String = "24h") async -> GainerLoserResponse? {
        guard let url = URL(string: "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/spotlight") else { 
            return nil 
        }
        
        let params = [
            "rankRange": "0",
            "timeframe": timeRange,
            "convert": "USD"
        ]
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let finalUrl = components?.url else { return nil }
        
        var request = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accepts")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(CoinDataListApiResponse.self, from: data)
            
            return GainerLoserResponse(
                gainers: Array(decoded.data.gainerList.prefix(3)),
                losers: Array(decoded.data.loserList.prefix(3))
            )
        } catch {
            print("Error fetching gainer/loser list: \(error.localizedDescription)")
            return nil
        }
    }
}
