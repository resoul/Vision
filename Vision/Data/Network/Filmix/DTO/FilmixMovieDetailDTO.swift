import Foundation

struct FilmixMovieDetailDTO {
    let id: Int
    let movieURL: String
    let posterThumb: String
    let posterFull: String
    let title: String
    let originalTitle: String
    let quality: String
    let date: String
    let dateISO: String
    let year: String
    let durationMinutes: Int?
    let mpaa: String
    let slogan: String
    let statusOnAir: String?
    let statusHint: String?
    let lastAdded: String?
    let directors: [String]
    let actors: [String]
    let writers: [String]
    let producers: [String]
    let genres: [String]
    let countries: [String]
    let translate: String
    let description: String
    let isAdIn: Bool
    let isNotMovie: Bool
    let frames: [FilmixMovieFrameDTO]
    let kinopoiskRating: String
    let kinopoiskVotes: String
    let imdbRating: String
    let imdbVotes: String
    let userPositivePercent: Int
    let userLikes: Int
    let userDislikes: Int
    
    init(
        id: Int, movieURL: String,
        posterThumb: String, posterFull: String,
        title: String, originalTitle: String,
        quality: String, date: String, dateISO: String,
        year: String, durationMinutes: Int?,
        mpaa: String, slogan: String,
        statusOnAir: String?, statusHint: String?, lastAdded: String?,
        directors: [String], actors: [String],
        writers: [String], producers: [String],
        genres: [String], countries: [String],
        translate: String, description: String,
        isAdIn: Bool, isNotMovie: Bool, frames: [FilmixMovieFrameDTO],
        kinopoiskRating: String, kinopoiskVotes: String,
        imdbRating: String, imdbVotes: String,
        userPositivePercent: Int, userLikes: Int, userDislikes: Int
    ) {
        self.id = id; self.movieURL = movieURL
        self.posterThumb = posterThumb; self.posterFull = posterFull
        self.title = title; self.originalTitle = originalTitle
        self.quality = quality; self.date = date; self.dateISO = dateISO
        self.year = year; self.durationMinutes = durationMinutes
        self.mpaa = mpaa; self.slogan = slogan
        self.statusOnAir = statusOnAir; self.statusHint = statusHint; self.lastAdded = lastAdded
        self.directors = directors; self.actors = actors
        self.writers = writers; self.producers = producers
        self.genres = genres; self.countries = countries
        self.translate = translate; self.description = description
        self.isAdIn = isAdIn; self.isNotMovie = isNotMovie; self.frames = frames
        self.kinopoiskRating = kinopoiskRating; self.kinopoiskVotes = kinopoiskVotes
        self.imdbRating = imdbRating; self.imdbVotes = imdbVotes
        self.userPositivePercent = userPositivePercent
        self.userLikes = userLikes; self.userDislikes = userDislikes
    }
    
    var isSeries: Bool {
        statusOnAir != nil || lastAdded != nil || year.contains("Сезон")
    }
    
    var durationFormatted: String {
        guard let m = durationMinutes, m > 0 else { return quality }
        let h = m / 60, min = m % 60
        let base = h > 0 ? "\(h)ч \(min)м" : "\(min)м"
        return isSeries ? "\(base)/серия" : base
    }
    
    var userRating: String {
        let total = userLikes + userDislikes
        guard total > 0 else { return "—" }
        return String(format: "%.1f", Double(userLikes) / Double(total) * 10)
    }
}
