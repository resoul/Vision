enum TabDestination: Equatable {
    case home
    case movies(genreURL: String?)
    case series(genreURL: String?)
    case cartoons(genreURL: String?)
    case favorites
    case watchHistory
}
