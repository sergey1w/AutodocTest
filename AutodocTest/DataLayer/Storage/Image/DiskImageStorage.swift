//
//  DiskImageStorage.swift
//  AutodocTest
//
//  Created by sergey on 03.02.2025.
//

import UIKit.UIImage

final class DiskImageStorage: ImageStorageProtocol {
    
    private let fileManager = FileManager.default
    
    func getImage(name: String) async throws -> UIImage? {
        guard let cachesDirectoryUrl = fileManager.urls(for: .cachesDirectory,
                                                        in: .userDomainMask).first else {
            return nil
        }
        
        let imageUrl = cachesDirectoryUrl.appendingPathComponent(name, conformingTo: .jpeg)
        
        let (imageData, _) = try await URLSession.shared.data(from: imageUrl)
        
        return UIImage(data: imageData)
    }
    
    func saveImage(image: UIImage, withName name: String) async throws {
        guard let cachesDirectoryUrl = fileManager.urls(for: .cachesDirectory,
                                                        in: .userDomainMask).first else {
            return
        }
        
        let imageUrl = cachesDirectoryUrl.appendingPathComponent(name, conformingTo: .jpeg)
        
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            return
        }
     
        try imageData.write(to: imageUrl)
    }
    
    deinit {
        print("Deinited \(String(describing: self))")
    }
}
