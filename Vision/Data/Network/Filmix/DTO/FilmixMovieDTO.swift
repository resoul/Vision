import Foundation

struct FilmixMovieDTO: Identifiable, Hashable {
    let id: Int
    let title: String
    let originalTitle: String
    let year: String
    let description: String
    let genre: String
    let genreList: [String]
    let rating: String
    let duration: String
    let type: ContentType
    let translate: String
    let isAdIn: Bool
    let movieURL: String
    let posterURL: String
    let actors: [String]
    let directors: [String]
    let lastAdded: String?
    
    init(
        id: Int, title: String, originalTitle: String,
        year: String, description: String,
        genre: String, genreList: [String],
        rating: String, duration: String,
        type: ContentType, translate: String, isAdIn: Bool,
        movieURL: String, posterURL: String,
        actors: [String], directors: [String], lastAdded: String?
    ) {
        self.id = id; self.title = title; self.originalTitle = originalTitle
        self.year = year; self.description = description
        self.genre = genre; self.genreList = genreList
        self.rating = rating; self.duration = duration
        self.type = type; self.translate = translate; self.isAdIn = isAdIn
        self.movieURL = movieURL; self.posterURL = posterURL
        self.actors = actors; self.directors = directors; self.lastAdded = lastAdded
    }
    
    enum ContentType: Hashable {
        case movie
        case series(seasons: [FilmixSeasonDTO])

        public var isSeries: Bool {
            if case .series = self { return true }
            return false
        }

        public static func == (lhs: ContentType, rhs: ContentType) -> Bool {
            switch (lhs, rhs) {
            case (.movie, .movie): return true
            case (.series, .series): return true
            default: return false
            }
        }

        public func hash(into hasher: inout Hasher) {
            switch self {
            case .movie:   hasher.combine(0)
            case .series:  hasher.combine(1)
            }
        }
    }
}
