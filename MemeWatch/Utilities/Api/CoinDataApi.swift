import Foundation

class CoinDataApi {
    static let shared = CoinDataApi()
    
    private init() {}
    
    private struct CoinDataApiResponse: Decodable {
        var data: CoinData
    }
    
    private struct FearGreedDataResponse: Decodable {
        struct FearData: Decodable {
            struct HistoricalValue: Decodable {
                struct Now: Decodable {
                    let score: Int
                }
                
                let now: Now
            }
            
            let historicalValues: HistoricalValue
        }
        
        let data: FearData
    }
    
    private struct TrendingPostsApiResponse: Decodable {
        struct DataResponse: Decodable {
            let tweetDTOList: [Post]
        }
        
        let data: DataResponse
    }
    
    private struct CoinPriceListApiResponse: Decodable {
        struct DataWrapper: Decodable {
            let points: [String: PointData]
        }
        
        struct PointData: Decodable {
            let v: [Double]
        }
        
        let data: DataWrapper
    }
    
    func getTrendingPosts(id: Int) async -> [Post] {
        guard let url = URL(string: "https://api.coinmarketcap.com/gravity/v3/gravity/cdp/trending-posts") else { return [] }
        
        struct TrendingPostsRequest: Encodable {
            let cryptoId: Int
            let overView: Bool
            let type: String
            let language: String
            let index: Int
            let languageCode: String
        }
        
        let body = TrendingPostsRequest(
            cryptoId: id,
            overView: false,
            type: "ALL",
            language: "en",
            index: 0,
            languageCode: "en"
        )
        
        let headers = [
            "Content-Type": "application/json",
            "Accept": "*/*",
            "Accept-Encoding": "gzip, deflate, br",
            "Connection": "keep-alive",
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("cound not set the http body")
        }
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let decoded = try JSONDecoder().decode(TrendingPostsApiResponse.self, from: data)
            
            return decoded.data.tweetDTOList
        } catch {
            return []
        }
    }
    
    func fetchFearAndGreedIndicator() async throws {
        let end = Int(Date().timeIntervalSince1970.rounded())
        let start = end - 2672824
        
        guard let url = URL(string: "https://api.coinmarketcap.com/data-api/v3/fear-greed/chart?start=\(start)&end=\(end)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await safeSession().data(for: request)
        let decoded = try JSONDecoder().decode(FearGreedDataResponse.self, from: data)
        
        DispatchQueue.main.async {
            AppManager.shared.fearGreedIndicator = Double(decoded.data.historicalValues.now.score)
        }
    }
    
    func getCoinPriceList(id: Int, timeRange: CoinPriceChartTimeRange) async -> [Double] {
        guard let url = URL(string: "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/detail/chart?id=\(id)&range=\(timeRange.rawValue.uppercased())") else { return [] }
        
        let headers = [
            "Accepts": "application/json",
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        do {
            let (data, _) = try await safeSession().data(for: request)
            
            let decodedData = try JSONDecoder().decode(CoinPriceListApiResponse.self, from: data)
            
            var pricePoints: [Int: Double] = [:]
            
            for (timestamp, pointData) in decodedData.data.points {
                pricePoints[Int(timestamp) ?? 0] = pointData.v.first!
            }
            
            var prices: [Double] = []
            
            for key in pricePoints.keys.sorted() {
                prices.append(pricePoints[key] ?? 0)
            }
            return prices
        } catch {
            print("Caught an error while fetching api data: \(error.localizedDescription)")
        }
        return []
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
            print("Caught an error while retrieving coin details from api: \(error.localizedDescription)")
        }
        return nil
    }
}
