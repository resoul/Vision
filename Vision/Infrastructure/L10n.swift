import Foundation

enum L10n {

    static var bundle: Bundle = .main

    static func string(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: bundle)
    }

    // MARK: - Keys

    enum Home {
        static var title:        String { L10n.string("home.title") }
        static var errorLoading: String { L10n.string("home.error.loading") }
    }

    enum Tab {
        static var home:        String { L10n.string("tab.home") }
        static var movies:      String { L10n.string("tab.movies") }
        static var series:      String { L10n.string("tab.series") }
        static var cartoons:    String { L10n.string("tab.cartoons") }
        static var favorites:   String { L10n.string("tab.favorites") }
        static var watchHistory: String { L10n.string("tab.watch_history") }
        static var search:      String { L10n.string("tab.search") }
    }

    enum Genre {
        enum Movies {
            static var action:       String { L10n.string("genre.movies.action") }
            static var comedy:       String { L10n.string("genre.movies.comedy") }
            static var drama:        String { L10n.string("genre.movies.drama") }
            static var thriller:     String { L10n.string("genre.movies.thriller") }
            static var horror:       String { L10n.string("genre.movies.horror") }
            static var scifi:        String { L10n.string("genre.movies.scifi") }
            static var fantasy:      String { L10n.string("genre.movies.fantasy") }
            static var adventure:    String { L10n.string("genre.movies.adventure") }
            static var animation:    String { L10n.string("genre.movies.animation") }
            static var documentary:  String { L10n.string("genre.movies.documentary") }
            static var crime:        String { L10n.string("genre.movies.crime") }
            static var romance:      String { L10n.string("genre.movies.romance") }
            static var biography:    String { L10n.string("genre.movies.biography") }
            static var history:      String { L10n.string("genre.movies.history") }
            static var sport:        String { L10n.string("genre.movies.sport") }
        }
        enum Series {
            static var action:       String { L10n.string("genre.series.action") }
            static var comedy:       String { L10n.string("genre.series.comedy") }
            static var drama:        String { L10n.string("genre.series.drama") }
            static var thriller:     String { L10n.string("genre.series.thriller") }
            static var horror:       String { L10n.string("genre.series.horror") }
            static var scifi:        String { L10n.string("genre.series.scifi") }
            static var fantasy:      String { L10n.string("genre.series.fantasy") }
            static var crime:        String { L10n.string("genre.series.crime") }
            static var romance:      String { L10n.string("genre.series.romance") }
            static var anime:        String { L10n.string("genre.series.anime") }
            static var documentary:  String { L10n.string("genre.series.documentary") }
            static var reality:      String { L10n.string("genre.series.reality") }
        }
        enum Cartoons {
            static var kids:         String { L10n.string("genre.cartoons.kids") }
            static var anime:        String { L10n.string("genre.cartoons.anime") }
            static var adventure:    String { L10n.string("genre.cartoons.adventure") }
            static var comedy:       String { L10n.string("genre.cartoons.comedy") }
            static var scifi:        String { L10n.string("genre.cartoons.scifi") }
            static var fantasy:      String { L10n.string("genre.cartoons.fantasy") }
            static var family:       String { L10n.string("genre.cartoons.family") }
            static var series:       String { L10n.string("genre.cartoons.series") }
        }
    }

    enum Settings {
        static var title:         String { L10n.string("settings.title") }
        enum Autoplay {
            static var title:     String { L10n.string("settings.autoplay.title") }
        }
        enum Quality {
            static var title:     String { L10n.string("settings.quality.title") }
        }
        enum Theme {
            static var title:     String { L10n.string("settings.theme.title") }
            static var dark:      String { L10n.string("settings.theme.dark") }
            static var light:     String { L10n.string("settings.theme.light") }
            static var midnight:  String { L10n.string("settings.theme.midnight") }
        }
        enum Language {
            static var title:     String { L10n.string("settings.language.title") }
        }
    }
}
