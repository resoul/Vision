import Foundation
import UIKit
import AVFoundation
import CryptoKit

/// A cache manager for video thumbnails with in-memory and disk caching.
/// Generates thumbnails asynchronously and coalesces concurrent requests.
final class VideoThumbnailCache {
    
    /// Shared singleton instance.
    static let shared = VideoThumbnailCache()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCacheURL: URL
    private let ioQueue = DispatchQueue(label: "com.yourapp.VideoThumbnailCache.ioQueue")
    private let pendingCompletionsQueue = DispatchQueue(label: "com.yourapp.VideoThumbnailCache.pendingCompletionsQueue")
    
    /// Maps cacheKey (String) to array of completion handlers awaiting thumbnail generation.
    private var pendingCompletions: [String: [(UIImage?) -> Void]] = [:]
    
    private init() {
        memoryCache.countLimit = 200
        // Approximate cost: pixels (width * height) * bytes per pixel (4)
        // For ~800x800 image = 640000px * 4 = ~2.56MB per image
        // 50MB / 2.56MB ≈ 19 images, but we set countLimit to 200 to keep memory control flexible.
        memoryCache.totalCostLimit = 50 * 1024 * 1024
        
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cachesDirectory.appendingPathComponent("com.yourapp.VideoThumbnailCache", isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            // Directory creation failure will cause disk caching to be skipped silently.
        }
    }
    
    /// Returns a thumbnail image for the given video URL string.
    ///
    /// - Parameters:
    ///   - videoURLString: The string representation of the video URL (can be remote or local file URL).
    ///   - completion: Closure called on main thread with the resulting UIImage or nil if failed.
    func thumbnail(for videoURLString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: videoURLString),
              url.isFileURL || url.scheme == "http" || url.scheme == "https"
        else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        
        let cacheKey = self.cacheKey(for: videoURLString)
        
        // Check in-memory cache
        if let cachedImage = memoryCache.object(forKey: cacheKey as NSString) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }
        
        // Synchronize access to pending completions
        pendingCompletionsQueue.sync {
            if var completions = pendingCompletions[cacheKey] {
                // Another request is in progress for this key, append the completion and return
                completions.append(completion)
                pendingCompletions[cacheKey] = completions
                return
            } else {
                // No request in progress, start with current completion
                pendingCompletions[cacheKey] = [completion]
            }
        }
        
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Check disk cache
            if let diskImage = self.loadFromDisk(forKey: cacheKey) {
                self.memoryCache.setObject(diskImage, forKey: cacheKey as NSString, cost: self.cost(for: diskImage))
                self.completeAll(forKey: cacheKey, with: diskImage)
                return
            }
            
            // Generate thumbnail asynchronously
            self.generateThumbnail(for: url) { image in
                if let image = image {
                    self.memoryCache.setObject(image, forKey: cacheKey as NSString, cost: self.cost(for: image))
                    self.saveToDisk(image, forKey: cacheKey)
                }
                self.completeAll(forKey: cacheKey, with: image)
            }
        }
    }
    
    // MARK: - Private helpers
    
    private func cost(for image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
    
    private func completeAll(forKey key: String, with image: UIImage?) {
        var completions: [(UIImage?) -> Void] = []
        pendingCompletionsQueue.sync {
            completions = pendingCompletions[key] ?? []
            pendingCompletions[key] = nil
        }
        DispatchQueue.main.async {
            for completion in completions {
                completion(image)
            }
        }
    }
    
    private func generateThumbnail(for url: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVURLAsset(url: url)
        
        asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak asset] in
            guard let asset = asset else {
                completion(nil)
                return
            }
            var durationSeconds: Float64 = 0
            var durationStatus = asset.statusOfValue(forKey: "duration", error: nil)
            if durationStatus == .loaded {
                durationSeconds = CMTimeGetSeconds(asset.duration)
            }
            
            if durationSeconds.isNaN || durationSeconds <= 0 {
                // fallback duration
                durationSeconds = 10
            }
            
            // Choose random time between 5% and 15% of duration
            let minTime = durationSeconds * 0.05
            let maxTime = durationSeconds * 0.15
            let chosenTimeSeconds: Float64
            if minTime >= maxTime {
                chosenTimeSeconds = minTime
            } else {
                chosenTimeSeconds = Double.random(in: minTime...maxTime)
            }
            
            let requestedTime = CMTimeMakeWithSeconds(chosenTimeSeconds, preferredTimescale: 600)
            
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.maximumSize = CGSize(width: 800, height: 800)
            imageGenerator.requestedTimeToleranceBefore = .zero
            imageGenerator.requestedTimeToleranceAfter = .zero
            
            var actualTime = CMTime.zero
            
            do {
                let cgImage = try imageGenerator.copyCGImage(at: requestedTime, actualTime: &actualTime)
                let image = UIImage(cgImage: cgImage)
                completion(image)
            } catch {
                completion(nil)
            }
        }
    }
    
    private func cacheURL(forKey key: String) -> URL {
        return diskCacheURL.appendingPathComponent(key).appendingPathExtension("png")
    }
    
    private func cacheKey(for urlString: String) -> String {
        let data = Data(urlString.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func saveToDisk(_ image: UIImage, forKey key: String) {
        let fileURL = cacheURL(forKey: key)
        
        guard let data = image.pngData() else { return }
        
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // ignore disk write errors
        }
    }
    
    private func loadFromDisk(forKey key: String) -> UIImage? {
        let fileURL = cacheURL(forKey: key)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data)
        else {
            return nil
        }
        return image
    }
}
