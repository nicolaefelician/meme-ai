import Foundation
import SwiftUI

final class CoinData: Codable, Identifiable, CoinInfoEntity {
    struct Urls: Codable {
        let website: [String]
        let twitter: [String]
    }
    
    struct ContractInfo: Codable {
        let contractId: Int
        let contractAddress: String
        let contractPlatform: String
        let contractExplorerUrl: String
        
        var imageUrl: String {
            return "https://s2.coinmarketcap.com/static/img/coins/128x128/\(contractId).png"
        }
    }
    
    struct Holders: Codable {
        struct HolderInfo: Codable {
            let address: String
            let balance: Double
            let share: Double
        }
        
        let holderList: [HolderInfo]
        let topTenHolderRatio: Double
        let topTwentyHolderRatio: Double
        let topFiftyHolderRatio: Double
        let topHundredHolderRatio: Double
    }
    
    struct Statistics: Codable {
        let price: Double
        let fullyDilutedMarketCap: Double
        let totalSupply: Double
        let rank: Int
        let priceChangePercentage1h: Double
        let priceChangePercentage24h: Double
        let priceChangePercentage7d: Double
        let priceChangePercentage30d: Double
        let priceChangePercentage1y: Double
        let lowAllTime: Double
        let highAllTime: Double
        let volumeRank: Int
    }
    
    let id: Int
    let name: String
    let symbol: String
    let description: String
    let dateAdded: String
    let urls: Urls
    let volume: Double
    let statistics: Statistics
    let platforms: [ContractInfo]?
    let holders: Holders?
    let watchCount: String
    
    var image: String {
        return "https://s2.coinmarketcap.com/static/img/coins/128x128/\(id).png"
    }
    
    func getPriceChange(_ timeRange: CoinPriceChartTimeRange) -> Double {
        switch timeRange {
        case .oneHour:
            return statistics.priceChangePercentage1h
        case .oneDay:
            return statistics.priceChangePercentage24h
        case .sevenDays:
            return statistics.priceChangePercentage7d
        case .oneMonth:
            return statistics.priceChangePercentage30d
        case .oneYear:
            return statistics.priceChangePercentage1y
        }
    }
    
    func buildPriceChangeText(_ timeRange: CoinPriceChartTimeRange) -> AnyView {
        let priceChangePercentage: Double = getPriceChange(timeRange)
        
        if priceChangePercentage < 0 {
            return AnyView(
                HStack(alignment: .center, spacing: 1) {
                    Text("▴")
                        .font(.custom(TextFonts.interMedium.rawValue, size: 17))
                        .foregroundStyle(.red)
                        .rotation3DEffect(
                            .degrees(180),
                            axis: (x: 1, y: 0, z: 0)
                        )
                        .padding(.bottom, 0)
                    Text("\(String(format: "%.2f", priceChangePercentage))%")
                        .font(.custom(TextFonts.interMedium.rawValue, size: 17))
                        .foregroundStyle(.red)
                }
            )
        } else {
            return AnyView(
                HStack(alignment: .center, spacing: 1) {
                    Text("▴")
                        .font(.custom(TextFonts.interMedium.rawValue, size: 17))
                        .foregroundStyle(.green)
                        .rotation3DEffect(
                            .degrees(0),
                            axis: (x: 1, y: 0, z: 0)
                        )
                        .padding(.top, 2)
                    Text("\(String(format: "%.2f", priceChangePercentage))%")
                        .font(.custom(TextFonts.interMedium.rawValue, size: 17))
                        .foregroundStyle(.green)
                }
            )
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.symbol = try container.decode(String.self, forKey: .symbol)
        self.description = try container.decode(String.self, forKey: .description)
        
        let stringDate = try container.decode(String.self, forKey: .dateAdded)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: stringDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd MMM. yyyy"
            self.dateAdded = outputFormatter.string(from: date)
        } else {
            self.dateAdded = ""
        }
        
        self.urls = try container.decode(Urls.self, forKey: .urls)
        self.volume = try container.decode(Double.self, forKey: .volume)
        self.statistics = try container.decode(Statistics.self, forKey: .statistics)
        self.platforms = try? container.decode([ContractInfo].self, forKey: .platforms)
        self.holders = try? container.decode(Holders.self, forKey: .holders)
        self.watchCount = try container.decode(String.self, forKey: .watchCount)
    }
}
