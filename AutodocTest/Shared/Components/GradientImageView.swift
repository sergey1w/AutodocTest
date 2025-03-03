//
//  GradientImageView.swift
//  AutodocNews
//
//  Created by sergey on 24.01.2025.
//

import UIKit

final class GradientImageView: UIImageView {
    
    private static var gradientColor1: CGColor { UIColor.systemGray5.cgColor }
    private static var gradientColor2: CGColor { UIColor.systemBackground.cgColor }
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.backgroundColor = gradientColor1
        layer.colors = [gradientColor1, gradientColor2]
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        return layer
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        return view
    }()
    
    override var image: UIImage? {
        didSet {
            if image != nil {
                gradientLayer.isHidden = true
                activityIndicator.stopAnimating()
            } else {
                gradientLayer.isHidden = false
                activityIndicator.startAnimating()
                activityIndicator.isHidden = false
            }
        }
    }

    init() {
        super.init(frame: .zero)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        gradientLayer.frame = self.bounds

        CATransaction.commit()
        
        activityIndicator.frame = bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColors()
        }
    }
    
    func updateColors() {
        gradientLayer.backgroundColor = Self.gradientColor2
        gradientLayer.colors = [Self.gradientColor1, Self.gradientColor2]
    }
    
    private func setup() {
        self.backgroundColor = UIColor.systemBackground
        layer.addSublayer(gradientLayer)
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

