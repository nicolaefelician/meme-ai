import SwiftUI
import SuperwallKit

final class HomeViewModel: ObservableObject {
    @Published var selectedTimeRange: TimeRange = .oneHour
    @Published var selctedCoinCategory: CoinCategory = .gainers
    @Published var hasFetchedData: Bool = false
    @Published var isLoading: Bool = true
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    func refreshData() async {
        await CoinListApi.shared.fetchGainerLoserList(timeRange: selectedTimeRange.rawValue)
        await CoinListApi.shared.fetchTrendingCoins(timeRange: selectedTimeRange.rawValue)
        await CoinListApi.shared.fetchRecentlyAddedList(timeRange: selectedTimeRange.rawValue)
        await CoinListApi.shared.fetchMostVisitedCoins(timeRange: selectedTimeRange.rawValue)
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    @State private var hasFetchedApi = false
    
    @ObservedObject var appManager = AppManager.shared
    
    private func getCoinList() -> [Coin] {
        switch viewModel.selctedCoinCategory {
        case .gainers: return appManager.gainersCoinsList
        case .losers: return appManager.losersCoinsList
        case .mostVisited: return appManager.mostVisitedCoinsList
        case .recentlyAdded: return appManager.recentlyAddedCoinsList
        case .watchList: return appManager.watchList
        }
    }
    
    private func buildCoinHorizontalCard(coin: Coin) -> some View {
        return HStack(alignment: .center, spacing: 10) {
            AsyncImage(url: URL(string: coin.image)) { phase in
                if phase.error != nil {
                    Rectangle()
                        .foregroundStyle(.gray)
                        .frame(width: 42, height: 42)
                        .cornerRadius(21)
                } else if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 42, height: 42)
                        .cornerRadius(21)
                } else {
                    ProgressView()
                        .frame(width: 42, height: 42)
                }
            }
            .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(coin.symbol)
                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 18))
                    .foregroundStyle(.black)
                    .padding(.bottom, -10)
                
                coin.buildPriceChangeText(viewModel.selectedTimeRange)
                    .padding(.top, 3)
            }
        }
    }
    
    private func getCategoryIcon(coinCategory: CoinCategory) -> some View {
        switch coinCategory {
        case .gainers: return Image(systemName: "chart.line.uptrend.xyaxis").foregroundStyle(.green)
        case .losers: return Image(systemName: "chart.line.downtrend.xyaxis").foregroundStyle(.red)
        case .watchList: return Image(systemName: "star").foregroundStyle(.yellow)
        case .mostVisited: return Image(systemName: "flame").foregroundStyle(.orange)
        case .recentlyAdded: return Image(systemName: "clock").foregroundStyle(.blue)
        }
    }
    
    private func buildCoinCategoryCard(category: CoinCategory) -> some View {
        return HStack(alignment: .center, spacing: 7) {
            getCategoryIcon(coinCategory: category)
                .font(.title3)
            
            Text(category.rawValue)
                .font(.custom(TextFonts.interRegular.rawValue, size: 12))
                .foregroundStyle(.black)
                .fontWeight(.regular)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .stroke(viewModel.selctedCoinCategory == category ? .gray : .clear, lineWidth: 1)
        )
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .center) {
                    FearGreedIndicator(index: appManager.fearGreedIndicator)
                    
                    Image("home-image")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220)
                }
                .padding(.leading, 18)
                
                Text("Trending now 🔥")
                    .padding(.top, 5)
                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 23))
                    .foregroundStyle(.black)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                
                if viewModel.isLoading {
                    HStack {
                        ProgressView()
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .frame(height: 30)
                    .padding(.top)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 18)
                            
                            LazyHStack(spacing: 20) {
                                ForEach(appManager.losersCoinsList, id: \.self) { coin in
                                    Button(action: {
                                        if appManager.isPremiumUser {
                                            viewModel.impactFeedback.impactOccurred()
                                            appManager.path.append(.coinDataView(coinId: coin.id))
                                        } else {
                                            Superwall.shared.register(placement: "campaign_trigger")
                                        }
                                    }) {
                                        buildCoinHorizontalCard(coin: coin)
                                    }
                                }
                            }
                            
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 18)
                        }
                    }
                    .frame(height: 60)
                    .padding(.top, 5)
                }
                
                HStack {
                    Text("Time range: \(viewModel.selectedTimeRange.rawValue)")
                        .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                        .foregroundStyle(Color(hex: "#000000"))
                    
                    Spacer()
                    
                    Menu {
                        ForEach(TimeRange.allCases, id: \.self) { item in
                            Button(action: {
                                viewModel.selectedTimeRange = item
                                Task {
                                    await viewModel.refreshData()
                                }
                            }) {
                                HStack {
                                    Text(item.rawValue)
                                    if item == viewModel.selectedTimeRange {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image("filter")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 5)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 17) {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(width: 1)
                        ForEach(CoinCategory.allCases, id: \.self) { category in
                            Button(action: {
                                viewModel.impactFeedback.impactOccurred()
                                viewModel.selctedCoinCategory = category
                            }) {
                                buildCoinCategoryCard(category: category)
                                    .padding(.vertical, 1)
                            }
                        }
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(width: 1)
                    }
                }
                .frame(height: 22)
                .padding(.vertical, 15)
                .padding(.bottom, 7)
                
                HStack {
                    Text("Market Cap")
                        .font(.custom(TextFonts.interMedium.rawValue, size: 16))
                        .foregroundStyle(.gray)
                    
                    Spacer()
                    
                    Text("Price")
                        .font(.custom(TextFonts.interMedium.rawValue, size: 16))
                        .foregroundStyle(.gray)
                    
                    Spacer()
                    
                    Text("\(viewModel.selectedTimeRange.rawValue) %")
                        .font(.custom(TextFonts.interMedium.rawValue, size: 16))
                        .foregroundStyle(.gray)
                        .padding(.leading, 17)
                }
                .padding(.horizontal, 18)
                
                LazyVStack(spacing: 13) {
                    if viewModel.selctedCoinCategory == .watchList && getCoinList().isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "star.slash.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("Your Watchlist is Empty")
                                .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 18))
                                .foregroundColor(.black)
                            
                            Text("Save your favorite coins to track them here.")
                                .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                                .foregroundColor(.gray.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 24)
                    } else {
                        if viewModel.isLoading {
                            VStack {
                                Text("Loading...")
                                    .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                                    .foregroundStyle(.black)
                                
                                ProgressView()
                                    .foregroundStyle(.black)
                            }
                            .padding(.top, 65)
                        } else {
                            ForEach(getCoinList(), id: \.id) { coin in
                                Divider()
                                    .foregroundStyle(.gray)
                                    .padding(.leading, 40)
                                Button(action: {
                                    if appManager.isPremiumUser {
                                        viewModel.impactFeedback.impactOccurred()
                                        appManager.path.append(.coinDataView(coinId: coin.id))
                                    } else {
                                        Superwall.shared.register(placement: "campaign_trigger")
                                    }
                                }) {
                                    CoinCard(coin: coin, selectedTimeRange: viewModel.selectedTimeRange, selectedCategory: viewModel.selctedCoinCategory)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 5)
                .padding(.horizontal, 18)
                .padding(.bottom, 20)
            }
        }
        .refreshable {
            Task {
                await viewModel.refreshData()
            }
        }
        .task {
            if !hasFetchedApi {
                viewModel.impactFeedback.prepare()
                await viewModel.refreshData()
                try? await CoinDataApi.shared.fetchFearAndGreedIndicator()
                hasFetchedApi = true
            }
        }
    }
}
