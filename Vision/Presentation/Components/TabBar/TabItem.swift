import Foundation

struct TabItem: Equatable {
    let id: String
    let title: String
    let icon: String
    let genres: [GenreItem]

    init(id: String, title: String, icon: String, genres: [GenreItem] = []) {
        self.id = id
        self.title = title
        self.icon = icon
        self.genres = genres
    }
}
