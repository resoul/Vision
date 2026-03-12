import Foundation

struct ContentItemViewModel {
    let id: Int
    let posterURL: String
    let isAdIn: Bool
    let isSeries: Bool
    let title: String

    let watchProgress: Double?
    let isSeriesInProgress: Bool

    init(item: ContentItem, watchProgress: Double?, isSeriesInProgress: Bool) {
        self.id               = item.id
        self.posterURL        = item.posterURL
        self.isAdIn           = item.isAdIn
        self.isSeries         = item.type.isSeries
        self.title            = item.title
        self.watchProgress    = watchProgress
        self.isSeriesInProgress = isSeriesInProgress
    }
}
