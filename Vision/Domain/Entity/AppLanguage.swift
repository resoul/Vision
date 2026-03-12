import Foundation

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case russian = "ru"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        }
    }

    var bundle: Bundle {
        guard
            let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else { return .main }
        return bundle
    }
}
