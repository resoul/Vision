import Foundation

struct Category {
    let id: String
    let title: String
    let url: String
    let icon: String
    var kind: Kind
    var genres: [Genre] = []

    enum Kind {
        case regular
        case favorites
        case watchHistory
    }

    static var all: [Category] {[
        Category(id: "home",
                 title: L10n.Tab.home,
                 url: "https://filmix.my/",
                 icon: "house.fill",
                 kind: .regular),

        Category(id: "movies",
                 title: L10n.Tab.movies,
                 url: "https://filmix.my/film/",
                 icon: "film.fill",
                 kind: .regular,
                 genres: Genre.movies),

        Category(id: "series",
                 title: L10n.Tab.series,
                 url: "https://filmix.my/seria/",
                 icon: "tv.fill",
                 kind: .regular,
                 genres: Genre.series),

        Category(id: "cartoons",
                 title: L10n.Tab.cartoons,
                 url: "https://filmix.my/mults/",
                 icon: "sparkles.tv.fill",
                 kind: .regular,
                 genres: Genre.cartoons),

        Category(id: "favorites",
                 title: L10n.Tab.favorites,
                 url: "favorites://",
                 icon: "star.fill",
                 kind: .favorites),

        Category(id: "history",
                 title: L10n.Tab.watchHistory,
                 url: "history://",
                 icon: "play.circle.fill",
                 kind: .watchHistory),
    ]}
}
