import Foundation

struct SettingsStorageData {
    var postersDiskBytes: Int64
    var watchHistoryBytes: Int64
    var favoritesBytes: Int64
    var coreDataFileBytes: Int64
    var userDefaultsBytes: Int64
    var watchHistoryCount: Int
    var favoritesCount: Int
    
    var totalBytes: Int64 {
        postersDiskBytes + watchHistoryBytes + favoritesBytes + coreDataFileBytes + userDefaultsBytes
    }
    
    func fraction(of bytes: Int64) -> Double {
        guard totalBytes > 0 else { return 0 }
        return Double(bytes) / Double(totalBytes)
    }
    
    static let empty = SettingsStorageData(
        postersDiskBytes: 0,
        watchHistoryBytes: 0,
        favoritesBytes: 0,
        coreDataFileBytes: 0,
        userDefaultsBytes: 0,
        watchHistoryCount: 0,
        favoritesCount: 0
    )
}
