import Foundation
import SwiftUI

final class Coin: Decodable, Identifiable, Hashable, Sendable, Equatable, CoinInfoEntity {
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
        return "https://s2.coinmarketcap.com/static/img/coins/128x128/\(id).png"
    }
    
    static func == (lhs: Coin, rhs: Coin) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
    
    private enum PairKeys: String, CodingKey {
        case baseToken
        case name = "baseTokenName"
        case symbol = "baseTokenSymbol"
        case price = "priceUsd"
        case priceChange24h
        case volume24h
        case selfReportedMarketCap
        case marketCap
    }
    
    private enum BaseTokenKeys: String, CodingKey {
        case id
    }
    
    func buildPriceChangeText(_ timeRange: TimeRange) -> AnyView {
        var priceChangePercentage: Double = 0.0
        
        switch timeRange {
        case .oneHour:
            priceChangePercentage = priceChange1h ?? 0.0
        case .twentyFourHours:
            priceChangePercentage = priceChange24h
        case .sevenDays:
            priceChangePercentage = priceChange7d ?? 0.0
        case .thirtyDays:
            priceChangePercentage = priceChange30d ?? 0.0
        }
        
        if priceChangePercentage < 0 {
            return AnyView(
                HStack(alignment: .center, spacing: 1) {
                    Text("▴")
                        .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                        .foregroundStyle(.red)
                        .rotation3DEffect(
                            .degrees(180),
                            axis: (x: 1, y: 0, z: 0)
                        )
                        .padding(.bottom, 0)
                    Text("\(String(format: "%.2f", priceChangePercentage))%")
                        .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                        .foregroundStyle(.red)
                }
            )
        } else {
            return AnyView(
                HStack(alignment: .center, spacing: 1) {
                    Text("▴")
                        .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                        .foregroundStyle(.green)
                        .rotation3DEffect(
                            .degrees(0),
                            axis: (x: 1, y: 0, z: 0)
                        )
                        .padding(.top, 2)
                    Text("\(String(format: "%.2f", priceChangePercentage))%")
                        .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                        .foregroundStyle(.green)
                }
            )
        }
    }
    
    init(from decoder: any Decoder) throws {
        do {
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
        } catch {
            let container = try decoder.container(keyedBy: PairKeys.self)
            let baseTokenContainer = try container.nestedContainer(keyedBy: BaseTokenKeys.self, forKey: .baseToken)
            
            let baseTokenId = try? baseTokenContainer.decodeIfPresent(String.self, forKey: .id)
            let intBaseTokenId = Int(baseTokenId ?? "0") ?? 0
            
            let name = try container.decode(String.self, forKey: .name)
            let symbol = try container.decode(String.self, forKey: .symbol)
            let price = try Double(container.decode(String.self, forKey: .price)) ?? 0.0
            let priceChange24h = try Double(container.decode(String.self, forKey: .priceChange24h)) ?? 0.0
            let volume24h = try Double(container.decode(String.self, forKey: .volume24h)) ?? 0.0
            let selfReportedMarketCap = try? container.decode(Double.self, forKey: .selfReportedMarketCap)
            let marketcap = try? container.decode(String.self, forKey: .marketCap)
            
            self.id = intBaseTokenId
            self.name = name
            self.symbol = symbol
            self.price = price
            self.priceChange1h = nil
            self.priceChange24h = priceChange24h
            self.priceChange7d = nil
            self.priceChange30d = nil
            self.volume24h = volume24h
            self.selfReportedMarketCap = selfReportedMarketCap ?? 0.0
            self.marketCap = Double(marketcap ?? "0.0") ?? 0.0
        }
    }
    
    init (fromNotificationData data: [AnyHashable : Any]) {
        self.id = Int(data["id"] as! String) ?? 1
        self.symbol = data["symbol"] as! String
        self.name = data["name"] as! String
        self.price = Double(data["price"] as! String) ?? 0
        self.marketCap = Double(data["marketCap"] as! String) ?? 0
        self.priceChange1h = nil
        self.volume24h = Double(data["volume24h"] as! String) ?? 0
        self.priceChange24h = Double(data["priceChange24h"] as! String) ?? 0
        self.priceChange7d = nil
        self.priceChange30d = nil
        self.selfReportedMarketCap = Double(data["marketCap"] as! String) ?? 0
    }
}
