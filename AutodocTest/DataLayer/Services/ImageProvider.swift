//
//  ImageProviderProtocol.swift
//  AutodocTest
//
//  Created by sergey on 02.02.2025.
//

import UIKit.UIImage

final class NewsFeedImageProvider: ImageProviderProtocol {
    
    let imageStorage: ImageStorageProtocol
    
    private var imageCache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 50
        return cache
    }()
    
    init(imageStorage: ImageStorageProtocol) {
        self.imageStorage = imageStorage
    }
    
    func getImage(url: URL) async -> UIImage? {
        
        if let cachedImage = await cachedImage(for: url) {
            return cachedImage
        }
        
        guard let image = await fetchImage(url: url) else {
            return nil
        }
        
        guard let thumbnail = await image.thumbnail(withResizeDimension: .height(100)) else {
            return nil
        }
        
        saveImage(thumbnail, for: url)
        
        return thumbnail
    }
    
    private func fetchImage(url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    private func saveImage(_ image: UIImage, for url: URL) {
        saveToCache(image, for: url)
        Task.detached { [unowned self] in
            await saveToDisk(image, for: url)
        }
    }
    
    private func cachedImage(for url: URL) async -> UIImage? {
        if let nsCacheIMage = imageCache.object(forKey: url as NSURL) {
            return nsCacheIMage
        } else if let diskImage = try? await imageStorage.getImage(name: url.lastPathComponent) {
            saveToCache(diskImage, for: url)
            return diskImage
        }
        
        return nil
    }
    
    private func saveToCache(_ image: UIImage, for url: URL) {
        imageCache.setObject(image, forKey: url as NSURL)
    }
    
    private func saveToDisk(_ image: UIImage, for url: URL) async {
        try? await imageStorage.saveImage(image: image, withName: url.lastPathComponent)
    }
    
    deinit {
        print("Deinited \(String(describing: self))")
    }
}
