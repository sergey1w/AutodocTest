//
//  ConnectionStatusView.swift
//  AutodocTest
//
//  Created by sergey on 19.02.2025.
//

import UIKit

final class ConnectionStatusView: UIView {
    
    struct Model {
        let title: String
        let backgroundColor: CGColor
        
        static func online() -> Model {
            return .init(title: String(localized: "Switching back online"), backgroundColor: UIColor.systemGreen.cgColor)
        }
        
        static func offline() -> Model {
            return .init(title: String(localized: "Switching to offline mode"), backgroundColor: UIColor.systemRed.cgColor)
        }
    }
    
    private let textLayer: CATextLayer = {
        let textLayer = CATextLayer()
        let uiFont = UIFont.preferredFont(forTextStyle: .caption1)
        textLayer.fontSize = uiFont.pointSize
        textLayer.font = CTFont(uiFont.fontDescriptor, size: uiFont.pointSize)
        textLayer.foregroundColor = .init(gray: 1, alpha: 1)
        textLayer.alignmentMode = .center
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }()
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        if textLayer.superlayer == nil {
            layer.addSublayer(textLayer)
        }
        
        textLayer.position = .init(x: bounds.midX, y: bounds.midY)
        textLayer.bounds.size = layer.bounds.size
    }
    
    var isOnline: Bool = false {
        didSet {
            
            if isOnline {
                configure(model: .online())
            } else {
                configure(model: .offline())
            }
            
            textLayer.opacity = 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [textLayer] in
                textLayer.opacity = 0
            }
        }
    }
    
    private func configure(model: Model) {
        textLayer.string = model.title
        textLayer.backgroundColor = model.backgroundColor
    }
    
    deinit {
        print("Deinited \(String(describing: self))")
    }
}
