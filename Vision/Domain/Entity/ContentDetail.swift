import Foundation

struct ContentDetail: Hashable {
    let id: Int
    let title: String
    let originalTitle: String
    let year: String
    let description: String
    let posterFullURL: String
    let backdropURL: String
    let countries: [String]
    let genres: [String]
    let directors: [String]
    let actors: [String]
    let writers: [String]
    let producers: [String]
    let slogan: String
    let mpaa: String
    let duration: String
    let quality: String
    let date: String
    let kinopoiskRating: String
    let kinopoiskVotes: String
    let imdbRating: String
    let imdbVotes: String
    let userRating: String
    let userLikes: Int
    let userDislikes: Int
    let isSeries: Bool
    let isNotMovie: Bool
    let lastAdded: String?
    let statusOnAir: String?
}
