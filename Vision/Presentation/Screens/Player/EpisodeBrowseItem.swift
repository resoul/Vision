import Foundation

struct EpisodeBrowseItem {
    let season: Int
    let episode: Int
    let title: String
    let posterURL: String
    let progress: Double?
    let isWatched: Bool
    let isCurrent: Bool
}
