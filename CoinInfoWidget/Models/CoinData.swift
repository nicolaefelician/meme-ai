import Foundation

struct CoinData: Codable {
    struct Statistics: Codable {
        let price: Double
        let fullyDilutedMarketCap: Double
        let priceChangePercentage1h: Double
        let priceChangePercentage24h: Double
        let priceChangePercentage7d: Double
        let priceChangePercentage30d: Double
    }
    
    let id: Int
    let name: String
    let symbol: String
    let volume: Double
    let statistics: Statistics
}