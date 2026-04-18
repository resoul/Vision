import Foundation

struct FilmixSeasonDTO {
    let title: String
    let episodes: [FilmixEpisodeDTO]
    
    nonisolated init(title: String, episodes: [FilmixEpisodeDTO]) {
        self.title = title
        self.episodes = episodes
    }
}
