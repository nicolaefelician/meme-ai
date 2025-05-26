import Foundation
import SwiftUI

protocol CoinInfoEntity {
    func buildFormattedPrice(price: Double) -> AnyView
}

extension CoinInfoEntity {
    func buildFormattedPrice(price: Double) -> AnyView {
        if price < 1e-5 {
            let formattedPrice = String(format: "%.15f", price)
            let parts = formattedPrice.split(separator: ".")
            
            guard parts.count == 2 else {
                return AnyView(Text("$0.00000").foregroundStyle(.black))
            }
            
            let wholePart = String(parts[0])
            let decimalPart = String(parts[1])
            
            var zeroCount = 0
            var remainingDecimalPart = decimalPart
            
            for char in decimalPart {
                if char == "0" {
                    zeroCount += 1
                    remainingDecimalPart.removeFirst()
                } else {
                    break
                }
            }
            
            let significantPart = remainingDecimalPart.prefix(4)
            
            return AnyView(
                HStack(spacing: 0) {
                    Text("$\(wholePart).0")
                    Text("\(zeroCount)")
                        .padding(.top, 10)
                    Text(significantPart)
                }
                    .foregroundStyle(.black)
            )
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 5
        numberFormatter.maximumFractionDigits = 15
        
        let formattedPrice = numberFormatter.string(from: NSNumber(value: price)) ?? "\(price)"
        
        return AnyView(Text("$\(formattedPrice.prefix(8))").foregroundStyle(.black))
    }
}
