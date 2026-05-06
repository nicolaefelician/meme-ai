import SwiftUI

struct CoinAnalysisView: View {
    let analysis: CoinAnalysis
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(String(localized: "analysis.general_trend"))
                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 25))
                    .foregroundStyle(.black)
                    .padding(.top, 15)
                
                Text(analysis.general_trend)
                    .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                    .foregroundStyle(.black.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
                
                Text(String(localized: "analysis.chart_pattern"))
                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 25))
                    .foregroundStyle(.black)
                    .padding(.top, 30)
                
                Text(analysis.chart_pattern)
                    .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                    .foregroundStyle(.black.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
                
                Text(String(localized: "analysis.indicator_analysis"))
                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 25))
                    .foregroundStyle(.black)
                    .padding(.top, 30)
                
                Text(analysis.indicator_analysis)
                    .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                    .foregroundStyle(.black.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
                
                Text(String(localized: "analysis.future_prediction"))
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
