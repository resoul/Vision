import Foundation

@MainActor
protocol ContentListViewModelProtocol: AnyObject {
    var onLoadingChanged: ((Bool) -> Void)? { get set }
    var onMoviesChanged: (([ContentItem]) -> Void)? { get set }
    var onMoviesAppended: (([ContentItem]) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onPlayRequested: (([ContentItem], Int) -> Void)? { get set }
    var onDetailRequested: ((ContentItem) -> Void)? { get set }

    func onViewDidLoad()
    func loadNextPageIfNeeded(currentIndex: Int)
    func didSelectItem(at index: Int)
}
