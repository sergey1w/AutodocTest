//
//  SectionHeaderView.swift
//  AutodocTest
//
//  Created by sergey on 25.02.2025.
//

import UIKit
import Lottie

final class SectionHeaderView: UICollectionReusableView {
    
    static let identifier = String(describing: SectionHeaderView.self)
    
    private let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "News")
        if #available(iOS 17.0, *) {
            label.font = .preferredFont(forTextStyle: .extraLargeTitle)
        } else {
            label.font = .preferredFont(forTextStyle: .largeTitle)
        }
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return titleLabel.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
    
    private func setupView() {
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deinited \(String(describing: self))")
    }
}
