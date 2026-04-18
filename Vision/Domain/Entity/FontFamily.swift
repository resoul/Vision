import Foundation

public enum FontFamily: String, CaseIterable {
    case amazon
    case montserrat
    case roboto
    case poppins
    case lato

    public var displayName: String {
        switch self {
        case .amazon:     return "Amazon Ember"
        case .montserrat: return "Montserrat"
        case .roboto:     return "Roboto"
        case .poppins:    return "Poppins"
        case .lato:       return "Lato"
        }
    }
}
