import Foundation

final class NewsApi {
    static let shared = NewsApi()
    
    private init() {}
    
    func fetchNewsPreviews() async {
        guard let url = URL(string: "https://center.tocaas.com/api/news/list") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await safeSession().data(for: request)
            
            let news = try JSONDecoder().decode([NewsPreview].self, from: data)
            
            DispatchQueue.main.async { @MainActor in
                AppManager.shared.newsPreviews = news
            }
        } catch {
            print("There was an error fetching news: \(error)")
        }
    }
    
    func getNewsData(id: String) async -> NewsData? {
        guard let url = URL(string: "https://center.tocaas.com/api/news/\(id)") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await safeSession().data(for: request)
            
            let news = try JSONDecoder().decode(NewsData.self, from: data)
            
            return news
        } catch {
            print("There was an error fetching news data: \(error)")
            return nil
        }
    }
}
