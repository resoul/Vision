import UIKit

protocol ImageRepositoryProtocol {
    /// Loads an image from the given URL.
    /// - Parameters:
    ///   - url: Image URL string.
    ///   - completion: Callback with the loaded image.
    /// - Returns: The cached image if available immediately, nil otherwise.
    func loadImage(from url: String, completion: @escaping (UIImage) -> Void) -> UIImage?
    
    /// Pre-fetches an image to the cache.
    func prefetchImage(from url: String)
    
    /// Cancels a pending image load task.
    func cancelLoading(for url: String)
    
    /// Applies memory limit for the image cache.
    func applyCacheLimit(bytes: Int)
    
    /// Returns disk cache size in bytes.
    func diskCacheSizeBytes() -> Int64
    
    /// Clears both memory and disk image cache.
    func clearDiskCache() throws
}
