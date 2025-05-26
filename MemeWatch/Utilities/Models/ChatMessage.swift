import Foundation
import SwiftUI

final class ChatMessage: Identifiable, Equatable {
    let id = UUID()
    var isInteracting: Bool
    let sendText: String
    let responseImage: String
    var responseText: String?
    var responseError: String?
    let uploadedImages: [UIImage]
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(isInteracting: Bool, sendText: String, responseImage: String, responseText: String? = nil, responseError: String? = nil, uploadedImages: [UIImage]) {
        self.isInteracting = isInteracting
        self.sendText = sendText
        self.responseImage = responseImage
        self.responseText = responseText
        self.responseError = responseError
        self.uploadedImages = uploadedImages
    }
}
