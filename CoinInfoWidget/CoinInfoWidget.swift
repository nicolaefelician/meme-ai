import WidgetKit
import SwiftUI

protocol CoinInfoEntity {
    var id: Int { get }
    var name: String { get }
    var symbol: String { get }
    var price: Double { get }
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
                        .font(.system(size: 8))
                        .offset(y: 3)
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

struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), coins: [], gainers: [], losers: [], isWatchlist: false)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            let watchList = await CoinDataApi.shared.loadWatchList()
            
            if watchList.isEmpty {
                if let gainerLoserData = await CoinListApi.shared.fetchGainerLoserList() {
                    
                    completion(SimpleEntry(date: Date(), coins: [],
                                           gainers: gainerLoserData.gainers,
                                           losers: gainerLoserData.losers,
                                           isWatchlist: false))
                    return
                }
            }
            
            completion(SimpleEntry(date: Date(),
                                   coins: watchList,
                                   gainers: [], losers: [],
                                   isWatchlist: true))
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        Task {
            print("📅 WIDGET: Getting timeline...")
            var entries: [SimpleEntry] = []
            
            let coins = await CoinDataApi.shared.loadWatchList()
            let watchList = Array(coins.prefix(3))
            print("📋 WIDGET: Watchlist has \(watchList.count) coins")
            
            var gainers: [Coin] = []
            var losers: [Coin] = []
            let isWatchlist = !watchList.isEmpty
            
            if watchList.isEmpty {
                print("📈 WIDGET: Watchlist empty, fetching gainers/losers")
                if let gainerLoserData = await CoinListApi.shared.fetchGainerLoserList() {
                    gainers = Array(gainerLoserData.gainers)
                    losers = Array(gainerLoserData.losers)
                    print("📈 WIDGET: Got \(gainers.count) gainers and \(losers.count) losers")
                }
            } else {
                print("👀 WIDGET: Showing watchlist with coins: \(watchList.map { $0.symbol })")
            }
            
            let currentDate = Date()
            for minuteOffset in stride(from: 0, to: 75, by: 15) {
                let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
                let entry = SimpleEntry(date: entryDate,
                                        coins: watchList,
                                        gainers: gainers,
                                        losers: losers,
                                        isWatchlist: isWatchlist)
                entries.append(entry)
            }
            
            print("🔄 WIDGET: Created \(entries.count) timeline entries")
            completion(Timeline(entries: entries, policy: .after(Date().addingTimeInterval(15 * 60))))
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let coins: [Coin]
    let gainers: [Coin]
    let losers: [Coin]
    let isWatchlist: Bool
}

struct CoinInfoWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        if entry.isWatchlist {
            VStack(spacing: 4) {
                HStack {
                    Text("Watchlist")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    Text("See All")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 6)
                
                HStack(spacing: 12) {
                    ForEach(entry.coins.prefix(3)) { coin in
                        CoinMediumRowView(coin: coin)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 8)
                
                Spacer()
            }
        } else {
            VStack(spacing: 4) {
                HStack {
                    Text("Gainers & Losers")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    Text("See All")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 6)
                
                HStack(spacing: 15) {
                    if !entry.gainers.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Gainers")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.green)
                            ForEach(entry.gainers.prefix(2)) { coin in
                                CoinMediumCompactView(coin: coin, isGainer: true)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    if !entry.losers.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Losers")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.red)
                            ForEach(entry.losers.prefix(2)) { coin in
                                CoinMediumCompactView(coin: coin, isGainer: false)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct CachedAsyncImage: View {
    let url: String
    let coin: Coin
    @State private var uiImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } else if isLoading {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            } else {
                // Fallback to colored circle with letter
                Circle()
                    .fill(coinColor(for: coin.symbol))
                    .overlay(
                        Text(String(coin.symbol.prefix(1)))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        print("🔄 WIDGET: Starting to load image for \(coin.symbol)")
        print("🔄 WIDGET: URL: \(url)")
        
        if let cachedImage = ImageCache.shared.getImage(for: url) {
            print("✅ WIDGET: Found cached image for \(coin.symbol)")
            self.uiImage = cachedImage
            self.isLoading = false
            return
        }
        
        Task {
            do {
                guard let imageUrl = URL(string: url) else {
                    print("❌ WIDGET: Invalid URL for \(coin.symbol): \(url)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                
                print("🌐 WIDGET: Making network request for \(coin.symbol)")
                let (data, response) = try await URLSession.shared.data(from: imageUrl)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 WIDGET: HTTP Status \(httpResponse.statusCode) for \(coin.symbol)")
                }
                
                print("📊 WIDGET: Downloaded \(data.count) bytes for \(coin.symbol)")
                
                if let downloadedImage = UIImage(data: data) {
                    print("✅ WIDGET: Successfully created UIImage for \(coin.symbol)")
                    ImageCache.shared.setImage(downloadedImage, for: url)
                    
                    DispatchQueue.main.async {
                        self.uiImage = downloadedImage
                        self.isLoading = false
                    }
                } else {
                    print("❌ WIDGET: Failed to create UIImage from data for \(coin.symbol)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            } catch {
                print("❌ WIDGET: Failed to download image for \(coin.symbol): \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func coinColor(for symbol: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .indigo]
        let index = abs(symbol.hashValue) % colors.count
        return colors[index]
    }
}

final class ImageCache {
    static let shared = ImageCache()
    private var cache: [String: UIImage] = [:]
    private let cacheLimit = 50
    
    private init() {}
    
    func getImage(for url: String) -> UIImage? {
        return cache[url]
    }
    
    func setImage(_ image: UIImage, for url: String) {
        if cache.count >= cacheLimit {
            cache.removeAll()
        }
        cache[url] = image
    }
}

struct CoinMediumRowView: View {
    let coin: Coin
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                CachedAsyncImage(url: coin.image, coin: coin)
                .frame(width: 24, height: 24)
                
                Text(coin.symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
            }
            
            coin.buildFormattedPrice(price: coin.price)
                .font(.system(size: 12))
            
            Text("\(coin.priceChange24h > 0 ? "+" : "")\(String(format: "%.2f", coin.priceChange24h))%")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(coin.priceChange24h >= 0 ? .green : .red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func formatPrice(_ price: Double) -> String {
        if price < 0.01 {
            return String(format: "%.6f", price)
        } else if price < 1 {
            return String(format: "%.4f", price)
        } else if price < 100 {
            return String(format: "%.2f", price)
        } else {
            return String(format: "%.0f", price)
        }
    }
    
    func coinColor(for symbol: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .indigo]
        let index = abs(symbol.hashValue) % colors.count
        return colors[index]
    }
}

struct CoinMediumCompactView: View {
    let coin: Coin
    let isGainer: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            CachedAsyncImage(url: coin.image, coin: coin)
            .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(coin.symbol)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                coin.buildFormattedPrice(price: coin.price)
                    .font(.system(size: 9))
                    .lineLimit(1)
            }
            .frame(minWidth: 30, maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 1) {
                Image(systemName: "triangle.fill")
                    .font(.system(size: 6))
                    .rotationEffect(.degrees(isGainer ? 0 : 180))
                    .foregroundColor(isGainer ? .green : .red)
                Text("\(String(format: "%.1f", abs(coin.priceChange24h)))%")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isGainer ? .green : .red)
                    .lineLimit(1)
            }
            .frame(minWidth: 35)
        }
        .padding(.vertical, 4)
    }
    
    func formatPrice(_ price: Double) -> String {
        if price < 0.01 {
            return String(format: "%.4f", price)
        } else if price < 1 {
            return String(format: "%.3f", price)
        } else {
            return String(format: "%.2f", price)
        }
    }
    
    func coinColor(for symbol: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .indigo]
        let index = abs(symbol.hashValue) % colors.count
        return colors[index]
    }
}

struct CoinInfoWidget: Widget {
    let kind: String = "CoinInfoWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CoinInfoWidgetEntryView(entry: entry)
                .containerBackground(Color.white.gradient, for: .widget)
        }
        .configurationDisplayName("MemeWatch")
        .description("Track your favorite cryptocurrency prices.")
        .supportedFamilies([.systemMedium])
    }
}

extension Coin {
    static let previewGainers: [Coin] = [
        Coin(id: 33369, name: "Book of Meme 3.0", symbol: "BOME",
             price: 4.561144092514442e-09, selfReportedMarketCap: 1915680518.8560658,
             marketCap: 0.0, priceChange1h: 62.05144035, priceChange24h: 444.68443304,
             priceChange7d: 280.33054376, priceChange30d: -46.81314308, volume24h: 1365530.84196937),
        Coin(id: 36949, name: "[Fake]Circle", symbol: "CRCL",
             price: 0.0018360510753402638, selfReportedMarketCap: 427799.9005542815,
             marketCap: 0.0, priceChange1h: 154.31658528, priceChange24h: 57.35613548,
             priceChange7d: 134.05345387, priceChange30d: 697.29388025, volume24h: 18739561.77136112),
        Coin(id: 11220, name: "Port Finance", symbol: "PORT",
             price: 0.00045747936881635306, selfReportedMarketCap: 990.4428334874044,
             marketCap: 0.0, priceChange1h: 110.81224284, priceChange24h: 54.56695007,
             priceChange7d: 1.97413425, priceChange30d: -66.49931463, volume24h: 82006.06209987)
    ]
    
    static let previewLosers: [Coin] = [
        Coin(id: 1, name: "Bitcoin", symbol: "BTC",
             price: 45000.0, selfReportedMarketCap: 900000000000.0,
             marketCap: 900000000000.0, priceChange1h: -2.5, priceChange24h: -5.2,
             priceChange7d: -3.1, priceChange30d: -10.5, volume24h: 25000000000.0),
        Coin(id: 2, name: "Ethereum", symbol: "ETH",
             price: 2500.0, selfReportedMarketCap: 300000000000.0,
             marketCap: 300000000000.0, priceChange1h: -1.8, priceChange24h: -4.5,
             priceChange7d: -2.8, priceChange30d: -8.2, volume24h: 15000000000.0),
        Coin(id: 3, name: "Solana", symbol: "SOL",
             price: 95.0, selfReportedMarketCap: 40000000000.0,
             marketCap: 40000000000.0, priceChange1h: -3.2, priceChange24h: -7.8,
             priceChange7d: -5.4, priceChange30d: -15.3, volume24h: 2500000000.0)
    ]
    
    init(id: Int, name: String, symbol: String, price: Double,
         selfReportedMarketCap: Double, marketCap: Double,
         priceChange1h: Double?, priceChange24h: Double,
         priceChange7d: Double?, priceChange30d: Double?,
         volume24h: Double) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.price = price
        self.selfReportedMarketCap = selfReportedMarketCap
        self.marketCap = marketCap
        self.priceChange1h = priceChange1h
        self.priceChange24h = priceChange24h
        self.priceChange7d = priceChange7d
        self.priceChange30d = priceChange30d
        self.volume24h = volume24h
    }
}

#Preview(as: .systemMedium) {
    CoinInfoWidget()
} timeline: {
    SimpleEntry(date: .now, coins: [], gainers: Coin.previewGainers,
                losers: Coin.previewLosers, isWatchlist: false)
    SimpleEntry(date: .now, coins: Coin.previewGainers, gainers: [],
                losers: [], isWatchlist: true)
}
