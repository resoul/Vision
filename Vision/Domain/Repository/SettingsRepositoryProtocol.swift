protocol SettingsRepositoryProtocol {
    func fetchSettings(completion: @escaping (Result<SettingsData, Error>) -> Void)
    func saveAutoplay(_ isEnabled: Bool)
    func savePreferredQuality(_ quality: VideoQuality)
    func saveCacheSizeStep(_ step: Int)
}

