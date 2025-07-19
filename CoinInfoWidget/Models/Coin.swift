import Foundation

struct Coin: Identifiable, Decodable, CoinInfoEntity {
    let id: Int
    let name: String
    let symbol: String
    let price: Double
    let selfReportedMarketCap: Double
    let marketCap: Double
    let priceChange1h: Double?
    let priceChange24h: Double
    let priceChange7d: Double?
    let priceChange30d: Double?
    let volume24h: Double
    
    var image: String {
        let imageUrl = "https://s2.coinmarketcap.com/static/img/coins/128x128/\(id).png"
        print("🔗 WIDGET: Generated image URL for \(symbol) (ID: \(id)): \(imageUrl)")
        return imageUrl
    }
    
    private enum CodingKeys: CodingKey {
        case id
        case name
        case symbol
        case selfReportedMarketCap
        case marketCap
        case priceChange
    }
    
    private enum PriceChangeKeys: CodingKey {
        case price
        case priceChange1h
        case priceChange24h
        case priceChange7d
        case priceChange30d
        case volume24h
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let symbol = try container.decode(String.self, forKey: .symbol)
        let priceContainer = try container.nestedContainer(keyedBy: PriceChangeKeys.self, forKey: .priceChange)
        let price = try priceContainer.decode(Double.self, forKey: .price)
        let priceChange1h = try? priceContainer.decodeIfPresent(Double.self, forKey: .priceChange1h)
        let priceChange24h = try? priceContainer.decode(Double.self, forKey: .priceChange24h)
        let priceChange7d = try? priceContainer.decode(Double.self, forKey: .priceChange7d)
        let priceChange30d = try? priceContainer.decode(Double.self, forKey: .priceChange30d)
        let volume24h = try? priceContainer.decode(Double.self, forKey: .volume24h)
        let marketCap = try? container.decodeIfPresent(Double.self, forKey: .marketCap)
        let selfReportedMarketCap = try? container.decodeIfPresent(Double.self, forKey: .selfReportedMarketCap)
        
        self.id = id
        self.name = name
        self.symbol = symbol
        self.price = price
        self.priceChange1h = priceChange1h
        self.priceChange24h = priceChange24h ?? 0
        self.priceChange7d = priceChange7d
        self.priceChange30d = priceChange30d
        self.volume24h = volume24h ?? 0.0
        self.marketCap = marketCap ?? 0.0
        self.selfReportedMarketCap = selfReportedMarketCap ?? 0.0
    }
    
    init(fromCoinDetails details: CoinData) {
        self.id = details.id
        self.name = details.name
        self.selfReportedMarketCap = details.statistics.fullyDilutedMarketCap
        self.symbol = details.symbol
        self.price = details.statistics.price
        self.volume24h = details.volume
        self.priceChange24h = details.statistics.priceChangePercentage24h
        self.marketCap = details.statistics.fullyDilutedMarketCap
        self.priceChange1h = nil
        self.priceChange7d = nil
        self.priceChange30d = nil
    }
}
