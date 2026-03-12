struct SettingsData {
    var isAutoplayEnabled: Bool
    var preferredQuality: VideoQuality
}

enum VideoQuality: String, CaseIterable {
    case auto   = "Авто"
    case hd     = "HD"
    case fullHD = "Full HD"
    case uhd    = "4K"
}
