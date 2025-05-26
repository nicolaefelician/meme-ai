import SwiftUI
import Combine

final class SearchCoinViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var coinList: [Coin] = []
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $inputText.sink { newValue in
            if newValue.isEmpty { return }
            
            Task { @MainActor in
                self.coinList = await CoinListApi.shared.searchCoins(query: newValue)
            }
        }
        .store(in: &cancellables)
    }
}

struct SearchCoinView: View {
    @FocusState private var isTextFieldFocused: Bool
    @StateObject private var viewModel = SearchCoinViewModel()
    
    @ObservedObject private var appManager = AppManager.shared
    
    var body: some View {
        ZStack {
            ScrollView {
                if viewModel.coinList.isEmpty {
                    VStack {
                        Text("Loading...")
                            .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                            .foregroundStyle(.black)
                        
                        ProgressView()
                            .foregroundStyle(.black)
                    }
                    .padding(.top, 10)
                } else {
                    VStack(spacing: 13) {
                        ForEach(viewModel.coinList, id: \.self) { coin in
                            Divider()
                                .foregroundStyle(.gray)
                                .padding(.leading, 40)
                            
                            Button(action: {
                                viewModel.impactFeedback.impactOccurred()
                                appManager.path.append(.coinDataView(coinId: coin.id))
                            }) {
                                CoinCard(coin: coin, selectedTimeRange: .oneHour, selectedCategory: .gainers)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .padding(.top, 60)
            .onAppear {
                viewModel.impactFeedback.prepare()
                viewModel.coinList = appManager.gainersCoinsList
            }
            
            VStack {
                HStack(spacing: 5) {
                    Image("search")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                    
                    TextField("Search Meme Coin", text: $viewModel.inputText)
                        .padding(.horizontal, 5)
                        .padding(.leading, 2)
                        .background(.clear)
                        .cornerRadius(22)
                        .foregroundColor(.black)
                        .focused($isTextFieldFocused)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Consts.shared.cardColor)
                .cornerRadius(20)
                .padding(.horizontal, 17)
                
                Spacer()
            }
        }
    }
}
