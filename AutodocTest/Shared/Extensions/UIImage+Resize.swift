//
//  UIImage+Resize.swift
//  AutodocNews
//
//  Created by sergey on 23.01.2025.
//

import UIKit.UIImage

extension UIImage {
    
    enum ResizeDimension {
        case width(CGFloat)
        case height(CGFloat)
    }
    
    var aspectRatio: CGFloat {
        return size.width / size.height
    }
    
    func thumbnail(withResizeDimension dimension: ResizeDimension) async -> UIImage? {
        
        let thumbnailSize: CGSize
        
        switch dimension {
        case .width(let width):
            thumbnailSize = CGSize(
                width: width.rounded(.towardZero),
                height: width / aspectRatio
            )
        case .height(let height):
            thumbnailSize = CGSize(
                width: (height * aspectRatio).rounded(.towardZero),
                height: height
            )
        }
        
        let scale = await UIScreen.main.scale
        let scaleTransform = CGAffineTransformMakeScale(scale, scale)
        let scaledSize = CGSizeApplyAffineTransform(thumbnailSize, scaleTransform)
                                                          
        guard let thumbnail = await self.byPreparingThumbnail(ofSize: scaledSize) else {
            return nil
        }
        
        return thumbnail
    }
}
