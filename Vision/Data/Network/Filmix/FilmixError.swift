import Foundation

enum FilmixError: LocalizedError {
    case articleNotFound
    case invalidURL(String)
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case .articleNotFound:
            return "Cannot find article. Try reloading the page or a different search query."
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .decodingFailed:
            return "Failed to decode server response."
        }
    }
}
