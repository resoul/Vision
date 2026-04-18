import Foundation

protocol FilmixMovieRepositoryProtocol {
    func search(query: String) async throws -> ContentPage
    func fetchTranslations(postId: Int, isSeries: Bool) async throws -> [Translation]
    func fetchDetail(path: String) async throws -> ContentDetail
    func fetchPage(url: URL?) async throws -> ContentPage
}
