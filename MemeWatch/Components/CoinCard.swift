import SwiftUI

struct CoinCard: View {
    let coin: Coin
    let selectedTimeRange: TimeRange
    let selectedCategory: CoinCategory
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: coin.image)) { phase in
                if phase.error != nil {
                    Rectangle()
                        .foregroundStyle(.gray)
                        .frame(width: 33, height: 33)
                        .cornerRadius(16.5)
                } else if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 33, height: 33)
                        .cornerRadius(16.5)
                } else {
                    ProgressView()
                        .frame(width: 33, height: 33)
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(coin.symbol)
                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 18))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                
                let marketCap = coin.marketCap != 0.0 ? coin.marketCap : coin.selfReportedMarketCap
                
                Text("$\(Utilities.shared.formatNumber(marketCap))")
                    .foregroundStyle(.gray)
                    .font(.custom(TextFonts.interMedium.rawValue, size: 14))
            }
            
            Spacer()
            
            coin.buildFormattedPrice(price: coin.price)
            
            Spacer()
            
            coin.buildPriceChangeText(selectedCategory == CoinCategory.mostVisited && selectedTimeRange == TimeRange.oneHour ? TimeRange.twentyFourHours : selectedTimeRange)
        }
    }
}
