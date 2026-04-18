import UIKit
import Combine

public protocol FontSettingsManagerProtocol {
    var currentFamily: AnyPublisher<FontFamily, Never> { get }
    var family: FontFamily { get }
    func apply(_ family: FontFamily)
}

final class FontSettingsManager: FontSettingsManagerProtocol {
    @Published private(set) var family: FontFamily

    var currentFamily: AnyPublisher<FontFamily, Never> {
        $family.eraseToAnyPublisher()
    }

    private let storage: UserDefaults

    init(storage: UserDefaults = .standard) {
        self.storage = storage
        let saved = storage.string(forKey: "app.font_family").flatMap { FontFamily(rawValue: $0) }
        self.family = saved ?? .amazon
    }

    func apply(_ family: FontFamily) {
        self.family = family
        storage.set(family.rawValue, forKey: "app.font_family")
        
        // Note: Global font update usually requires a deeper integration 
        // depending on how UI components are built. For now, we publish the change.
        NotificationCenter.default.post(name: Notification.Name("AppFontChanged"), object: family)
    }
}
