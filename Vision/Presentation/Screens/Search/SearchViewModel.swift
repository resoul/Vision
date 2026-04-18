import Foundation
import Combine

@MainActor
final class SearchViewModel {
    private let searchUseCase: SearchUseCaseProtocol
    
    @Published var results: [ContentItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var query: String = ""
    
    var onDetailRequested: ((ContentItem) -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    
    init(searchUseCase: SearchUseCaseProtocol) {
        self.searchUseCase = searchUseCase
        setupSearch()
    }
    
    private func setupSearch() {
        $query
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.performSearch(query: text)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) {
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            results = []
            isLoading = false
            errorMessage = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        searchTask = Task {
            do {
                let items = try await searchUseCase.search(query: query)
                guard !Task.isCancelled else { return }
                self.results = items
                self.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.results = []
            }
        }
    }
    
    func selectItem(at index: Int) {
        guard index < results.count else { return }
        onDetailRequested?(results[index])
    }
}
