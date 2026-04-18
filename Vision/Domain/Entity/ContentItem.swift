import UIKit

struct ContentItem: Identifiable, Hashable {
    let id: Int
    let title: String
    let year: String
    let description: String
    let genre: String
    let rating: String
    let duration: String
    let type: ContentType
    let translate: String
    let isAdIn: Bool
    let movieURL: String
    let posterURL: String
    let actors: [String]
    let directors: [String]
    let genreList: [String]
    let lastAdded: String?

    enum ContentType: Hashable {
        case movie
        case series(seasons: [Season])
    }

    var accentColor: UIColor {
        let palette: [UIColor] = [
            UIColor(red: 0.55, green: 0.27, blue: 0.07, alpha: 1),
            UIColor(red: 0.10, green: 0.28, blue: 0.55, alpha: 1),
            UIColor(red: 0.35, green: 0.12, blue: 0.45, alpha: 1),
            UIColor(red: 0.08, green: 0.35, blue: 0.28, alpha: 1),
            UIColor(red: 0.50, green: 0.10, blue: 0.10, alpha: 1),
        ]
        return palette[abs(id) % palette.count]
    }
}

extension ContentItem.ContentType {
    var isSeries: Bool {
        if case .series = self { return true }
        return false
    }
}

struct Season: Hashable {
    let title: String
    let episodes: [Episode]
}

struct Episode: Hashable {
    let title: String
    let id: String
    let streams: [String: String]
}

struct Translation: Hashable {
    let studio: String
    let streams: [String: String]
    let seasons: [Season]
    
    var isSeries: Bool { !seasons.isEmpty }
    
    var sortedQualities: [String] {
        let order = ["4K UHD", "1080p Ultra+", "1080p", "720p", "480p", "360p"]
        let known   = order.filter { streams[$0] != nil }
        let unknown = streams.keys.filter { !order.contains($0) }.sorted()
        return known + unknown
    }

    var bestQuality: String? { sortedQualities.first }
    var bestURL: String?     { bestQuality.flatMap { streams[$0] } }
}

struct ContentPage: Hashable {
    let items: [ContentItem]
    let nextPageURL: URL?
}
