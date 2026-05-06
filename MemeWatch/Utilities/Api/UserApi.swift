import Foundation
import SwiftUI

final class UserApi {
    private init() {}
    
    static let shared = UserApi()
    
    func registerUser(firebaseId: String) async throws {
        print("Is user registered: \(Consts.shared.isUserRegistered)")
        guard !Consts.shared.isUserRegistered else { return }
        
        guard let url = URL(string: "https://memo-coin-api-production.up.railway.app/api/user/register-user?applicationCode=\(Consts.shared.appCode)") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "appVersion": Consts.shared.appVersion,
            "fireBaseId": firebaseId,
            "userId": Consts.shared.appUserId,
            "customData": ["": ""]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
            
            let (data, response) = try await safeSession().data(for: request)
            
            print("User register data: \(String(decoding: data, as: UTF8.self))")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("Registration response: \(jsonResponse)")
                Consts.shared.setUserRegistered()
            }
        } catch {
            print("Registration error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func loadWatchList() async {
        let watchListArray = Consts.shared.sharedWatchList
        
        var coinArray: [Coin] = []
        for id in watchListArray {
            if let coinDetails = await CoinDataApi.shared.getCoinData(id: id) {
                let coin = Coin(fromCoinDetails: coinDetails)
                coinArray.append(coin)
            }
        }
        
        DispatchQueue.main.async {
            AppManager.shared.watchList = coinArray
        }
    }
}
