import Foundation
import SwiftUI

final class Utilities {
    static let shared = Utilities()
    
    private init() {}
    
    func convertImageToBase64(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        return imageData.base64EncodedString()
    }
    
    func formatNumber(_ number: Double) -> String {
        func formatWithSuffix(_ value: Double, _ suffix: String) -> String {
            return value < 10 ? String(format: "%.2f%@", value, suffix) : String(format: "%.1f%@", value, suffix)
        }
        
        if number >= 1_000_000_000_000_000 {
            return formatWithSuffix(number / 1_000_000_000_000_000, "Q")
        } else if number >= 1_000_000_000_000 {
            return formatWithSuffix(number / 1_000_000_000_000, "T")
        } else if number >= 1_000_000_000 {
            return formatWithSuffix(number / 1_000_000_000, "B")
        } else if number >= 1_000_000 {
            let formatted = number / 1_000_000
            
            if abs(formatted - round(formatted)) < 0.001 {
                return String(format: "%.0fM", round(formatted))
            }
            return String(format: "%.2fM", formatted)
        } else if number >= 1_000 {
            return formatWithSuffix(number / 1_000, "K")
        } else {
            return String(format: "%.0f", number)
        }
    }
    
    func formatDate(_ date: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        
        guard let date = isoFormatter.date(from: date) else {
            return ""
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMM yyyy 'at' HH:mm"
        outputFormatter.locale = Locale(identifier: "en_US")
        outputFormatter.timeZone = TimeZone.current
        
        return outputFormatter.string(from: date)
    }
}

enum ApiError: Error {
    case invalidResponse
    case decodingFailded
    case encodingFailded
}

func safeSession() -> URLSession {
    if #available(iOS 18.4, *) {
        let config = URLSessionConfiguration.ephemeral
        return URLSession(configuration: config)
    } else {
        return URLSession.shared
    }
}

