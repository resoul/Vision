import Foundation

enum PlaybackContext: Equatable {
    case movie(id: Int, studio: String, quality: String, url: String, title: String)
    case episode(id: Int, season: Int, episode: Int, studio: String, quality: String, url: String, title: String)
    
    var movieId: Int {
        switch self {
        case .movie(let id, _, _, _, _): return id
        case .episode(let id, _, _, _, _, _, _): return id
        }
    }
    
    var streamURL: String {
        switch self {
        case .movie(_, _, _, let url, _): return url
        case .episode(_, _, _, _, _, let url, _): return url
        }
    }
}

struct PlaybackState: Equatable {
    let movieId: Int
    let season: Int
    let episode: Int
    let studio: String
    let quality: String
    let updatedAt: Date
}
