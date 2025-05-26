import SwiftUI

struct FearGreedIndicator: View {
    var index: Double
    
    struct Arc: Shape {
        var startAngle: Angle
        var endAngle: Angle
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY),
                        radius: rect.width / 2,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false)
            return path
        }
    }
    
    var body: some View {
        VStack() {
            HStack {
                Text("Fear & Greed")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .padding(.horizontal)
            
            ZStack(alignment: .bottom) {
                Arc(startAngle: .degrees(180), endAngle: .degrees(0))
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: [
                            .red, .orange, .yellow, .green
                        ]), startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 140, height: 70)
                
                Circle()
                    .fill(.white)
                    .frame(width: 14, height: 14)
                    .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 1)
                        )
                    .offset(arcPosition(for: index))
                
                VStack {
                    Text("\(Int(index))")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    Text(fearGreedText(for: index))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .offset(y: 15)
            }
        }
        .padding(.vertical, 17)
        .padding(.bottom, 20)
        .frame(width: 170)
    }
    
    private func angle(for value: Double) -> Angle {
        let degrees = 180 - (value / 100) * 180
        return .degrees(degrees)
    }
    
    private func arcPosition(for value: Double) -> CGSize {
        let radius: CGFloat = 70.0
        let angle = angle(for: value)
        
        let radians = angle.radians
        
        let x = cos(radians) * radius
        let y = sin(radians) * radius
        
        return CGSize(width: x, height: -y + 7)
    }
    
    private func fearGreedText(for value: Double) -> String {
        switch value {
        case 0..<25: return "Extreme Fear"
        case 25..<50: return "Fear"
        case 50..<75: return "Greed"
        default: return "Extreme Greed"
        }
    }
}
