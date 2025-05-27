import Foundation
import SwiftUI

final class UserApi {
    private init() {}
    
    static let shared = UserApi()
    
    func registerUser(firebaseId: String) async throws {
        guard let url = URL(string: "https://center.tocaas.com/api/user/register-user?applicationCode=\(Consts.shared.appCode)") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "appVersion": Consts.shared.appVersion,
            "fireBaseId": firebaseId,
            "customData": ["": ""]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("Registration response: \(jsonResponse)")
            }
        } catch {
            print("Registration error: \(error.localizedDescription)")
            throw error
        }
    }
}
