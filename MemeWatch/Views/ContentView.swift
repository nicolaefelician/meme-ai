import SwiftUI
import Combine
import SuperwallKit

final class ContentViewModel: ObservableObject {
    @Published var selectedTabIndex: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(.black)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(.white)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(.white)]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        let style = UINavigationBarAppearance()
        
        style.titleTextAttributes = [
            .foregroundColor: UIColor(.black),
            .font: UIFont(name: TextFonts.instrumentSansSemiBold.rawValue, size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        
        style.largeTitleTextAttributes = [
            .foregroundColor: UIColor(.black),
            .font: UIFont(name: TextFonts.instrumentSansSemiBold.rawValue, size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .semibold)
        ]
        
        style.backgroundColor = UIColor(Consts.shared.backgroundColor)
        style.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = style
        UINavigationBar.appearance().scrollEdgeAppearance = style
        
        self.impactFeedback.prepare()
        
        $selectedTabIndex
            .sink { newTab in
                self.impactFeedback.impactOccurred()
            }
            .store(in: &cancellables)
    }
}

struct ContentView: View {
    @ObservedObject private var appManager = AppManager.shared
    
    @StateObject private var viewModel: ContentViewModel = ContentViewModel()
    
    private func getViewTitle(for index: Int) -> String {
        switch index {
        case 0: return "Meme AI"
        case 1: return "News"
        case 2: return "AI Chart Analysis"
        case 3: return "Search"
        default: return "Settings"
        }
    }
    
    var body: some View {
        ZStack {
            NavigationStack(path: $appManager.path) {
                TabView(selection: $viewModel.selectedTabIndex) {
                    HomeView()
                        .tabItem {
                            Label("Discover", systemImage: "waveform")
                        }
                        .tag(0)
                    
                    NewsListView()
                        .tabItem {
                            Label("News", systemImage: "doc.text")
                        }
                        .tag(1)
                    
                    AiChatView()
                        .tabItem {
                            Label("AI chat", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                        .tag(2)
                    
                    SearchCoinView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .tag(3)
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }
                        .tag(4)
                }
                .navigationDestination(for: NavigationView.self) { destination in
                    switch destination {
                    case .coinDataView(let id): CoinDataView(coinId: id)
                    case .newsDataView(let id): NewsDataView(id: id)
                    case .coinAnalysisView(let analysis) : CoinAnalysisView(analysis: analysis)
                    case .postDetailView(let post): PostDetailView(post: post)
                    }
                }
                .navigationTitle(getViewTitle(for: viewModel.selectedTabIndex))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if !appManager.isPremiumUser {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                Superwall.shared.register(placement: "campaign_trigger")
                            }) {
                                Image(systemName: "crown.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.yellow)
                            }
                        }
                    }
                    
                    if viewModel.selectedTabIndex != 3 {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: {
                                viewModel.selectedTabIndex = 3
                            }) {
                                Image("search")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $appManager.isSharing) {
                ShareView(activityItems: [appManager.stringToShare ?? ""])
            }
            .alert("Error", isPresented: $appManager.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("There was an error analyzing your coin. Please try again later.")
            }
            
            if appManager.isLoading {
                Consts.shared.backgroundColor
                    .opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Analyzing...")
                        .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                        .foregroundStyle(.black)
                    
                    ProgressView()
                        .foregroundStyle(.black)
                }
            }
        }
    }
}
