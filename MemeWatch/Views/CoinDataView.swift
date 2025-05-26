import SwiftUI

class CoinDataViewModel: ObservableObject {
    @Published var coinData: CoinData?
    
    @Published var priceData: [Double] = []
    @Published var selectedPrice = 0.0
    
    @Published var selectedDateRange = CoinPriceChartTimeRange.oneDay
    
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var isSharing = false
    
    @Published var postsList: [Post] = []
    
    @Published var isCopied = false
    
    @Published var showFullDescription = false
    
    @Published var trimValue: CGFloat = 0
    @Published var memeCoinAnalysis: CoinAnalysis? = nil
    
    let id: Int
    
    init(id: Int) {
        self.id = id
        self.impactFeedback.prepare()
        
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        Task { @MainActor in
            self.postsList = await CoinDataApi.shared.getTrendingPosts(id: self.id)
            self.priceData = await CoinDataApi.shared.getCoinPriceList(id: self.id, timeRange: self.selectedDateRange)
            self.coinData = await CoinDataApi.shared.getCoinData(id: self.id)
        }
    }
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
}

struct CoinDataView: View {
    @StateObject private var viewModel: CoinDataViewModel
    @ObservedObject private var appManager = AppManager.shared
    
    let id: Int
    
    init(coinId: Int) {
        self.id = coinId
        _viewModel = StateObject(wrappedValue: CoinDataViewModel(id: coinId))
    }
    
    private func buildTimeRangeButton(_ timeRange: CoinPriceChartTimeRange) -> some View {
        return Button(action: {
            viewModel.impactFeedback.impactOccurred()
            viewModel.trimValue = 0
            viewModel.selectedDateRange = timeRange
            Task {
                viewModel.priceData = await CoinDataApi.shared.getCoinPriceList(id: id, timeRange: timeRange)
                withAnimation(.linear(duration: 1.5)) {
                    viewModel.trimValue = 1
                }
            }
        }) {
            Text(timeRange.rawValue)
                .font(.custom(TextFonts.interMedium.rawValue, size: 17))
                .foregroundColor(viewModel.selectedDateRange == timeRange ? .black : .gray)
                .frame(maxWidth: .infinity)
        }
    }
    
    var body: some View {
        if let coinData = viewModel.coinData {
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .center, spacing: 15) {
                            AsyncImage(url: URL(string: coinData.image)) { phase in
                                if phase.error != nil {
                                    Rectangle()
                                        .foregroundStyle(.gray)
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(25)
                                } else if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(25)
                                } else {
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(coinData.name)
                                        .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 22))
                                        .foregroundColor(.black)
                                        .frame(height: 25)
                                    
                                    coinData.buildFormattedPrice(price: viewModel.selectedPrice)
                                        .frame(height: 25)
                                }
                                
                                coinData.buildPriceChangeText(viewModel.selectedDateRange)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        
                        CoinPriceChart(priceList: viewModel.priceData, trimValue: $viewModel.trimValue, selectedPrice: $viewModel.selectedPrice, priceChange: coinData.getPriceChange(viewModel.selectedDateRange))
                            .frame(height: 150)
                            .padding(.horizontal, 20)
                        
                        HStack {
                            ForEach(CoinPriceChartTimeRange.allCases, id: \.self) { timeRange in
                                buildTimeRangeButton(timeRange)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        .padding(.bottom, 13)
                        
                        Text("Details")
                            .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 25))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 7)
                        
                        if coinData.description.isEmpty {
                            Text("No description available for this coin.")
                                .multilineTextAlignment(.leading)
                                .font(.custom(TextFonts.interRegular.rawValue, size: 15))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 20)
                        } else {
                            Text(coinData.description)
                                .multilineTextAlignment(.leading)
                                .font(.custom(TextFonts.interRegular.rawValue, size: 15))
                                .foregroundStyle(.gray)
                                .lineLimit(viewModel.showFullDescription ? nil : 5)
                                .padding(.horizontal, 20)
                            
                            Button(action: {
                                withAnimation {
                                    viewModel.showFullDescription.toggle()
                                }
                            }) {
                                Text(viewModel.showFullDescription ? "View Less" : "Read More")
                                    .font(.custom(TextFonts.interSemibold.rawValue, size: 16))
                                    .foregroundStyle(.black.opacity(0.8))
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        HStack(spacing: 13) {
                            Button(action: {
                                viewModel.impactFeedback.impactOccurred()
                                appManager.stringToShare = "Check out \(coinData.name) on Meme.co app!"
                                appManager.isSharing = true
                            }) {
                                HStack(spacing: 7) {
                                    Image("share")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                    
                                    Text("Share")
                                        .font(.custom(TextFonts.interSemibold.rawValue, size: 15))
                                        .foregroundStyle(.black)
                                }
                                .padding(.vertical, 13)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "#d6d6d6"))
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                viewModel.impactFeedback.impactOccurred()
                                Task { @MainActor in
                                    appManager.isLoading = true
                                    let analysis = await CoinAnalysisApi.shared.getCoinAnalysis(coinData: coinData, priceList: viewModel.priceData, timeRange: viewModel.selectedDateRange)
                                    if let analysis = analysis {
                                        appManager.path.append(.coinAnalysisView(analysis: analysis))
                                    } else {
                                        appManager.showError = true
                                    }
                                    appManager.isLoading = false
                                }
                            }) {
                                HStack(spacing: 7) {
                                    Image("atom")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                    
                                    Text("Get Analysis")
                                        .font(.custom(TextFonts.interSemibold.rawValue, size: 15))
                                        .foregroundStyle(.white)
                                }
                                .padding(.vertical, 13)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "#EF8011"))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 13)
                        
                        Text("Statistics")
                            .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 25))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 7)
                            .padding(.top, 9)
                        
                        HStack(spacing: 8) {
                            VStack(spacing: 3) {
                                Text("#\(coinData.statistics.rank)")
                                    .font(.custom(TextFonts.interMedium.rawValue, size: 15))
                                    .foregroundStyle(.black)
                                Text("rank")
                                    .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 75)
                            .background(Consts.shared.cardColor)
                            .cornerRadius(9)
                            
                            VStack(spacing: 3) {
                                HStack(spacing: 5) {
                                    Image(systemName: "dollarsign.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 17, height: 17)
                                        .foregroundStyle(.black)
                                    
                                    Text("$\(Utilities.shared.formatNumber(coinData.statistics.fullyDilutedMarketCap))")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 15))
                                        .foregroundStyle(.black)
                                }
                                Text("market cap")
                                    .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 75)
                            .background(Consts.shared.cardColor)
                            .cornerRadius(9)
                            
                            VStack(spacing: 3) {
                                HStack(spacing: 5) {
                                    Image(systemName: "chart.bar")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 17, height: 17)
                                        .foregroundStyle(.black)
                                    
                                    Text("$\(Utilities.shared.formatNumber(coinData.volume))")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 15))
                                        .foregroundStyle(.black)
                                }
                                Text("volume")
                                    .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 75)
                            .background(Consts.shared.cardColor)
                            .cornerRadius(9)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                        
                        HStack(spacing: 8) {
                            VStack(spacing: 3) {
                                HStack(spacing: 5) {
                                    Image(systemName: "arrow.up.right.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 17, height: 17)
                                        .foregroundStyle(.black)
                                    
                                    Text("\(Utilities.shared.formatNumber(coinData.statistics.totalSupply))")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 15))
                                        .foregroundStyle(.black)
                                }
                                Text("total supply")
                                    .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 75)
                            .background(Consts.shared.cardColor)
                            .cornerRadius(9)
                            
                            VStack(spacing: 3) {
                                HStack(spacing: 5) {
                                    Image(systemName: "calendar.badge.clock")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 17, height: 17)
                                        .foregroundStyle(.black)
                                    
                                    Text("\(coinData.dateAdded)")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 15))
                                        .foregroundStyle(.black)
                                }
                                Text("added date")
                                    .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 75)
                            .background(Consts.shared.cardColor)
                            .cornerRadius(9)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                        
                        HStack(spacing: 8) {
                            if !coinData.urls.website.isEmpty {
                                Link(destination: URL(string: coinData.urls.website.first!)!) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "globe")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 23, height: 23)
                                            .foregroundColor(.blue)
                                        
                                        Text("Website")
                                            .font(.custom(TextFonts.interMedium.rawValue, size: 15))
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 75)
                                    .background(Consts.shared.cardColor)
                                    .cornerRadius(9)
                                }
                            }
                            
                            if !coinData.urls.twitter.isEmpty {
                                Link(destination: URL(string: coinData.urls.website.first!)!) {
                                    HStack(spacing: 5) {
                                        Image("twitter")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(.blue)
                                        
                                        Text("Twitter")
                                            .font(.custom(TextFonts.interMedium.rawValue, size: 15))
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 75)
                                    .background(Consts.shared.cardColor)
                                    .cornerRadius(9)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                        
                        if let holders = coinData.holders {
                            Text("Top 5 holders")
                                .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 25))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 7)
                                .padding(.top, 9)
                            
                            VStack {
                                ForEach(holders.holderList.prefix(5), id: \.address) { info in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Address")
                                                .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                                                .foregroundColor(.gray)
                                            
                                            Button(action: {
                                                let generator = UIImpactFeedbackGenerator(style: .light)
                                                generator.impactOccurred()
                                                UIPasteboard.general.string = info.address
                                            }) {
                                                HStack(spacing: 5) {
                                                    Text(info.address)
                                                        .font(.custom(TextFonts.interMedium.rawValue, size: 16))
                                                        .foregroundColor(.black)
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    Image(systemName: "doc.on.doc")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 22, height: 22)
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                        }
                                        
                                        VStack(alignment: .trailing) {
                                            Text("Balance")
                                                .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                                                .foregroundColor(.gray)
                                            
                                            Text(Utilities.shared.formatNumber(info.balance))
                                                .font(.custom(TextFonts.interMedium.rawValue, size: 16))
                                                .foregroundColor(.black)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 15)
                                    .background(Consts.shared.cardColor)
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            Text("Holders share")
                                .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 25))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 7)
                                .padding(.top, 9)
                            
                            HStack(spacing: 9) {
                                VStack {
                                    Text("Top 10")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 15))
                                        .foregroundStyle(.black)
                                    
                                    Text("\(String(format: "%.2f", holders.topHundredHolderRatio))%")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                                        .foregroundColor(.green)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(Consts.shared.cardColor)
                                .cornerRadius(10)
                                
                                VStack {
                                    Text("Top 50")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 15))
                                        .foregroundStyle(.black)
                                    
                                    Text("\(String(format: "%.2f", holders.topHundredHolderRatio))%")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                                        .foregroundColor(.green)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(Consts.shared.cardColor)
                                .cornerRadius(10)
                                
                                VStack {
                                    Text("Top 100")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 15))
                                        .foregroundStyle(.black)
                                    
                                    Text("\(String(format: "%.2f", holders.topHundredHolderRatio))%")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                                        .foregroundColor(.green)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(Consts.shared.cardColor)
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        if !viewModel.postsList.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Trending Posts")
                                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 25))
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 20)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(viewModel.postsList, id: \.postTime) { post in
                                            PostCard(post: post)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.top, 30)
                            
                        }
                        
                        if let contractInfo = coinData.platforms, !contractInfo.isEmpty {
                            HStack(spacing: 15) {
                                AsyncImage(url: URL(string: contractInfo.first!.imageUrl)) { phase in
                                    if phase.error != nil {
                                        Rectangle()
                                            .foregroundStyle(.gray)
                                            .frame(width: 40, height: 40)
                                            .cornerRadius(20)
                                    } else if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .cornerRadius(20)
                                    } else {
                                        ProgressView()
                                            .frame(width: 40, height: 40)
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(contractInfo.first!.contractPlatform)
                                        .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 18))
                                        .foregroundStyle(.black)
                                    Text("Contract Network")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                                        .foregroundStyle(.gray)
                                }
                            }
                            .padding(.top, 18)
                            .padding(.horizontal, 20)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Address")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 16))
                                        .foregroundStyle(.gray)
                                    Text(contractInfo.first!.contractAddress)
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                                        .foregroundStyle(.black)
                                }
                                
                                Button(action: {
                                    viewModel.impactFeedback.impactOccurred()
                                    UIPasteboard.general.string = contractInfo.first!.contractAddress
                                    withAnimation {
                                        viewModel.isCopied = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            viewModel.isCopied = false
                                        }
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "doc.on.doc")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25, height: 25)
                                            .foregroundStyle(.blue)
                                        Text(viewModel.isCopied ? "copied" : "copy")
                                            .font(.custom(TextFonts.interMedium.rawValue, size: 16))
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                            .padding(.top, 10)
                            .padding(.horizontal, 20)
                            
                            Button(action: {
                                viewModel.impactFeedback.impactOccurred()
                                if let url = URL(string: "https://phantom.app/ul/buy?tokenAddress=\(contractInfo.first!.contractAddress)") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image("phantom")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                    
                                    Text("Trade on Phantom")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 17))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.purple)
                                .cornerRadius(15)
                                .padding(.top, 15)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 20)
                                
                            }
                            
                            Button(action: {
                                viewModel.impactFeedback.impactOccurred()
                                var chain = ""
                                switch contractInfo.first!.contractPlatform {
                                case "Base":
                                    chain = "base"
                                    break
                                case "Ethereum":
                                    chain = "mainnet"
                                    break
                                case "BNB Smart Chain (BEP20)":
                                    chain = "bnb"
                                    break
                                default:
                                    break
                                }
                                
                                var link = "https://app.uniswap.org/swap?chain=\(chain)&outputCurrency=\(contractInfo.first!.contractAddress)"
                                if chain.isEmpty {
                                    link = "https://app.uniswap.org/swap?outputCurrency=\(contractInfo.first!.contractAddress)"
                                }
                                if let url = URL(string: link) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image("uniswap")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                    
                                    Text("Trade on Uniswap")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 17))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(.pink)
                                .cornerRadius(15)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 20)
                            }
                            
                            Button(action: {
                                viewModel.impactFeedback.impactOccurred()
                                if let url = URL(string: "https://raydium.io/swap/?inputMint=sol&outputMint=\(contractInfo.first!.contractAddress)") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image("raydium")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                    
                                    Text("Trade on Raydium")
                                        .font(.custom(TextFonts.interMedium.rawValue, size: 17))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.init(hex: "#6A0DAD"))
                                .cornerRadius(15)
                                .padding(.vertical, 5)
                                .padding(.bottom, 20)
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .navigationTitle(coinData.symbol)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    //                    ToolbarItem(placement: .topBarTrailing) {
                    //                        Button(action: {
                    //
                    //                        }) {
                    //                            Image(systemName: "star.fill")
                    //                                .resizable()
                    //                                .scaledToFit()
                    //                                .frame(width: 25, height: 25)
                    //                                .foregroundStyle(.yellow)
                    //                        }
                    //                    }
                }
            }
            
        } else {
            VStack {
                Text("Loading...")
                    .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                    .foregroundStyle(.black)
                
                ProgressView()
                    .foregroundStyle(.black)
            }
        }
    }
}
