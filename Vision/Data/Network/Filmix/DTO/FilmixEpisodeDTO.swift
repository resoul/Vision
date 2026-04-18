import Foundation

struct FilmixEpisodeDTO {
    let title: String
    let id: String
    let streams: [String: String]
    
    nonisolated init(title: String, id: String, streams: [String: String]) {
        self.title = title
        self.id = id
        self.streams = streams
    }
}
