import Foundation

extension FilmixMovieDTO {
    func toEntity() -> ContentItem {
        ContentItem(
            id: id,
            title: title,
            year: year,
            description: description,
            genre: genre,
            rating: rating,
            duration: duration,
            type: type.toEntity(),
            translate: translate,
            isAdIn: isAdIn,
            movieURL: movieURL,
            posterURL: posterURL,
            actors: actors,
            directors: directors,
            genreList: genreList,
            lastAdded: lastAdded
        )
    }
}

extension FilmixMovieDTO.ContentType {
    func toEntity() -> ContentItem.ContentType {
        switch self {
        case .movie:
            return .movie
        case .series(let seasons):
            return .series(seasons: seasons.map { $0.toEntity() })
        }
    }
}

extension FilmixSeasonDTO {
    func toEntity() -> Season {
        Season(
            title: title,
            episodes: episodes.map { $0.toEntity() }
        )
    }
}

extension FilmixEpisodeDTO {
    func toEntity() -> Episode {
        Episode(
            title: title,
            id: id,
            streams: streams
        )
    }
}

extension FilmixMoviePageDTO {
    func toEntity() -> ContentPage {
        ContentPage(
            items: movies.map { $0.toEntity() },
            nextPageURL: nextPageURL
        )
    }
}

extension FilmixTranslationDTO {
    func toEntity() -> Translation {
        Translation(
            studio: studio,
            streams: streams,
            seasons: seasons.map { $0.toEntity() }
        )
    }
}

extension FilmixMovieDetailDTO {
    func toEntity() -> ContentItem {
        ContentItem(
            id: id,
            title: title,
            year: year,
            description: description,
            genre: genres.first ?? "",
            rating: userRating,
            duration: durationFormatted,
            type: isSeries ? .series(seasons: []) : .movie,
            translate: translate,
            isAdIn: isAdIn,
            movieURL: movieURL,
            posterURL: posterFull,
            actors: actors,
            directors: directors,
            genreList: genres,
            lastAdded: lastAdded
        )
    }

    func toDetailEntity() -> ContentDetail {
        ContentDetail(
            id: id,
            title: title,
            originalTitle: originalTitle,
            year: year,
            description: description,
            posterFullURL: posterFull,
            backdropURL: frames.first?.fullURL ?? posterFull,
            countries: countries,
            genres: genres,
            directors: directors,
            actors: actors,
            writers: writers,
            producers: producers,
            slogan: slogan,
            mpaa: mpaa,
            duration: durationFormatted,
            quality: quality,
            date: date,
            kinopoiskRating: kinopoiskRating,
            kinopoiskVotes: kinopoiskVotes,
            imdbRating: imdbRating,
            imdbVotes: imdbVotes,
            userRating: userRating,
            userLikes: userLikes,
            userDislikes: userDislikes,
            isSeries: isSeries,
            isNotMovie: isNotMovie,
            lastAdded: lastAdded,
            statusOnAir: statusOnAir
        )
    }
}
