import Foundation

final class CoinListApi {
    static let shared = CoinListApi()
    
    private init() {}
    
    private struct CoinDataListApiResponse: Decodable, Sendable {
        struct ResponseList: Decodable, Sendable {
            let gainerList: [Coin]
            let loserList: [Coin]
            
            private enum CodingKeys: CodingKey {
                case gainerList
                case loserList
            }
            
            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let gainers = try container.decode([Coin?].self, forKey: .gainerList)
                let losers = try container.decode([Coin?].self, forKey: .loserList)
                
                self.gainerList = gainers.compactMap { $0 }
                self.loserList = losers.compactMap { $0 }
            }
        }
        
        let data: ResponseList
    }
    
    private struct SearchApiResponse: Decodable {
        let data: DataResponse

        struct DataResponse: Decodable {
            let tks: [Coin]
        }
    }

    private struct DexCoinListApiResponse: Decodable, Sendable {
        struct ResponseData: Decodable, Sendable {
            let total: Int
            let tks: [Coin]
        }
        let data: ResponseData
    }
    
    private struct RecentlyAddedApiResponse: Decodable, Sendable {
        struct ResponseList: Decodable, Sendable {
            let recentlyAddedList: [Coin]
            
            private enum CodingKeys: CodingKey {
                case recentlyAddedList
            }
            
            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let list = try container.decode([Coin?].self, forKey: .recentlyAddedList)
                
                self.recentlyAddedList = list.compactMap { $0 }
            }
        }
        
        let data: ResponseList
    }
    
    private struct TrendingCoinsApiResponse: Decodable, Sendable {
        struct ResponseList: Decodable, Sendable {
            let cryptoTopSearchRanks: [Coin]
            
            private enum CodingKeys: CodingKey {
                case cryptoTopSearchRanks
            }
            
            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let list = try container.decode([Coin?].self, forKey: .cryptoTopSearchRanks)
                
                self.cryptoTopSearchRanks = list.compactMap { $0 }
            }
        }
        
        let data: ResponseList
    }
    
    private struct MostVisitedApiResponse: Decodable, Sendable {
        struct ResponseList: Decodable, Sendable {
            let mostVisitedList: [Coin]
            
            private enum CodingKeys: CodingKey {
                case mostVisitedList
            }
            
            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let list = try container.decode([Coin?].self, forKey: .mostVisitedList)
                
                self.mostVisitedList = list.compactMap { $0 }
            }
        }
        
        let data: ResponseList
    }
    
    func fetchRecentlyAddedList(timeRange: String) async {
        guard let url = URL(string: "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/spotlight?dataType=8&limit=100&start=1&range=\(timeRange)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Accepts")
        
        do {
            let (data, _) = try await safeSession().data(for: request)
            let decoded = try JSONDecoder().decode(RecentlyAddedApiResponse.self, from: data)
            
            DispatchQueue.main.async {
                AppManager.shared.recentlyAddedCoinsList = decoded.data.recentlyAddedList
            }
        } catch {
            print("There was an error fetching recently added coins: \(error)")
        }
    }
    
    func fetchMostVisitedCoins(timeRange: String) async {
        guard let url = URL(string: "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/spotlight") else { return }
        
        let parameters: [String: Any] = [
            "rankRange": "0",
            "timeframe": timeRange != "1h" ? timeRange : "24h",
            "convert": "USD",
            "limit": 30
        ]
        
        let headers = [
            "Accepts": "application/json",
        ]
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        do {
            let (data, _) = try await safeSession().data(for: request)
            let decoded = try JSONDecoder().decode(MostVisitedApiResponse.self, from: data)
            DispatchQueue.main.async { @MainActor in
                AppManager.shared.mostVisitedCoinsList = decoded.data.mostVisitedList
            }
        } catch {
            print("Caught an error while fetching most visited coins: \(error)")
        }
    }
    
    func fetchTrendingCoins(timeRange: String) async {
        guard let url = URL(string: "https://api.coinmarketcap.com/data-api/v3/topsearch/rank?top=50&timeframe=\(timeRange)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Accepts")
        
        do {
            let (data, _) = try await safeSession().data(for: request)
            let decoded = try JSONDecoder().decode(TrendingCoinsApiResponse.self, from: data)
            DispatchQueue.main.async {
                AppManager.shared.trendingCoinsList = decoded.data.cryptoTopSearchRanks
            }
        } catch {
            print("There was an error fetching trending coins: \(error)")
        }
    }
    
    func searchCoins(query: String) async -> [Coin] {
        guard let url = URL(string: "https://dapi.coinmarketcap.com/dex/v1/search?q=\(query)") else { return [] }
        
        do {
            let (data, _) = try await safeSession().data(from: url)
            
            let decoded = try JSONDecoder().decode(SearchApiResponse.self, from: data)

            var seenIds = Set<Int>()
            let uniqueFilteredList = decoded.data.tks.filter { coin in
                guard !seenIds.contains(coin.id) else { return false }
                seenIds.insert(coin.id)
                return true
            }
            
            return uniqueFilteredList
        } catch {
            print("Caught an error while fetching search api: \(error)")
            return []
        }
    }
    
    func fetchGainerLoserList(timeRange: String) async {
        guard let url = URL(string: "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/spotlight") else { return }
        
        let parameters: [String: Any] = [
            "rankRange": "0",
            "timeframe": timeRange,
            "convert": "USD",
            "limit": 30
        ]
        
        let headers = [
            "Accepts": "application/json",
        ]
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        do {
            let (data, _) = try await safeSession().data(for: request)
            
            let decoded = try JSONDecoder().decode(CoinDataListApiResponse.self, from: data)
            
            DispatchQueue.main.async {
                AppManager.shared.gainersCoinsList = decoded.data.gainerList
                AppManager.shared.losersCoinsList = decoded.data.loserList
            }
        } catch {
            print("Caught an error while fetching trending coins: \(error)")
        }
    }
}
