import Foundation

struct FilmixMoviePageDTO {
    let movies: [FilmixMovieDTO]
    let nextPageURL: URL?
    
    init(movies: [FilmixMovieDTO], nextPageURL: URL?) {
        self.movies = movies
        self.nextPageURL = nextPageURL
    }
}
