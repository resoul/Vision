import Foundation
import Combine

protocol FavoritesManagerProtocol {
    var favorites: CurrentValueSubject<Set<Int>, Never> { get }
    func isFavorite(id: Int) -> Bool
    func toggle(_ item: ContentItem)
    func add(_ item: ContentItem)
    func remove(id: Int)
}

final class FavoritesManager: FavoritesManagerProtocol {
    static let shared = FavoritesManager()
    
    private let userDefaults = UserDefaults.standard
    private let key = "v_favorites_ids"
    
    let favorites = CurrentValueSubject<Set<Int>, Never>([])
    
    init() {
        load()
    }
    
    func isFavorite(id: Int) -> Bool {
        favorites.value.contains(id)
    }
    
    func toggle(_ item: ContentItem) {
        if isFavorite(id: item.id) {
            remove(id: item.id)
        } else {
            add(item)
        }
    }
    
    func add(_ item: ContentItem) {
        var set = favorites.value
        set.insert(item.id)
        favorites.send(set)
        save()
    }
    
    func remove(id: Int) {
        var set = favorites.value
        set.remove(id)
        favorites.send(set)
        save()
    }
    
    private func load() {
        let array = userDefaults.array(forKey: key) as? [Int] ?? []
        favorites.send(Set(array))
    }
    
    private func save() {
        userDefaults.set(Array(favorites.value), forKey: key)
    }
}
