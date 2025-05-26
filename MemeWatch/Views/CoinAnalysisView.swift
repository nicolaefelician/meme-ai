import SwiftUI

struct CoinAnalysisView: View {
    let analysis: CoinAnalysis
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("General Trend")
                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 25))
                    .foregroundStyle(.black)
                    .padding(.top, 15)
                
                Text(analysis.general_trend)
                    .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                    .foregroundStyle(.black.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
                
                Text("Chart Pattern")
                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 25))
                    .foregroundStyle(.black)
                    .padding(.top, 30)
                
                Text(analysis.chart_pattern)
                    .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                    .foregroundStyle(.black.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
                
                Text("Indicator Analysis")
                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 25))
                    .foregroundStyle(.black)
                    .padding(.top, 30)
                
                Text(analysis.indicator_analysis)
                    .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                    .foregroundStyle(.black.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
                
                Text("Future Market Prediction")
                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 25))
                    .foregroundStyle(.black)
                    .padding(.top, 30)
                
                Text(analysis.future_market_prediction)
                    .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                    .foregroundStyle(.black.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("Analysis")
        .navigationBarTitleDisplayMode(.large)
        .background(Consts.shared.backgroundColor)
    }
}
