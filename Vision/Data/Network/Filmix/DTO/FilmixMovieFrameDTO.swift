import Foundation

struct FilmixMovieFrameDTO {
    let thumbURL: String
    let fullURL: String
    
    init(thumbURL: String, fullURL: String) {
        self.thumbURL = thumbURL
        self.fullURL = fullURL
    }
}
