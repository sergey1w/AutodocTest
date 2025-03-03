//
//  LoadingFooterView.swift
//  AutodocNews
//
//  Created by sergey on 23.01.2025.
//

import UIKit
import Lottie

final class LoadingFooterView: UICollectionReusableView {
    
    static let identifier = String(describing: LoadingFooterView.self)
    
    private let animationView: LottieAnimationView = {
        let animationView = LottieAnimationView(animation: .gears)
        return animationView
    }()
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animationView.frame = self.bounds
    }
    
    private func startAnimating() {
        animationView.isHidden = false
        animationView.play()
    }

    private func stopAnimating() {
        animationView.stop()
        animationView.isHidden = true
    }
    
    private func setupView() {
        addSubview(animationView)
        animationView.loopMode = .loop
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deinited \(String(describing: self))")
    }

}
