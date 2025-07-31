import Foundation

func safeSession() -> URLSession {
    if #available(iOS 18.4, *) {
        let config = URLSessionConfiguration.ephemeral
        return URLSession(configuration: config)
    } else {
        return URLSession.shared
    }
}