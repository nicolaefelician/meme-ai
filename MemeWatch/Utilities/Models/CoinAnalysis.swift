import Foundation

final class CoinAnalysis: Decodable, Hashable {
    let general_trend: String
    let indicator_analysis: String
    let chart_pattern: String
    let future_market_prediction: String
    
    static func == (lhs: CoinAnalysis, rhs: CoinAnalysis) -> Bool {
        return lhs.general_trend == rhs.general_trend
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(general_trend)
    }
}
