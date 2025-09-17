//
//  ImageCache.swift
//  Bookexpect-task
//
//  Created by Gowtham on 16/09/25.
//

import UIKit
import Foundation

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private lazy var cacheDirectory: URL = {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheURL = urls[0].appendingPathComponent("ImageCache")
        try? fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true)
        return cacheURL
    }()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func image(for urlString: String) -> UIImage? {
        let key = NSString(string: urlString)
        
        // Check memory cache first
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        // Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent(key.hash.description)
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            cache.setObject(image, forKey: key)
            return image
        }
        
        return nil
    }
    
    func setImage(_ image: UIImage, for urlString: String) {
        let key = NSString(string: urlString)
        
        // Store in memory cache
        cache.setObject(image, forKey: key)
        
        // Store in disk cache
        let fileURL = cacheDirectory.appendingPathComponent(key.hash.description)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

extension UIImageView {
    func loadImage(from urlString: String?, placeholder: UIImage? = nil) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            self.image = placeholder
            return
        }
        
        // Set placeholder immediately
        self.image = placeholder
        
        // Check cache first
        if let cachedImage = ImageCache.shared.image(for: urlString) {
            self.image = cachedImage
            return
        }
        
        // Download image
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    // Cache the image
                    ImageCache.shared.setImage(image, for: urlString)
                    
                    // Update UI on main thread
                    await MainActor.run {
                        self.image = image
                    }
                }
            } catch {
                await MainActor.run {
                    self.image = placeholder
                }
            }
        }
    }
}