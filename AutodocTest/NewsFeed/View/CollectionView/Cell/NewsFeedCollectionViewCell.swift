//
//  NewsFeedCollectionViewCell.swift
//  AutodocNews
//
//  Created by sergey on 18.01.2025.
//

import UIKit

final class NewsFeedCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = String(describing: NewsFeedCollectionViewCell.self)
    
    // MARK: - Properties
    private let imageView: GradientImageView = {
        let imageView = GradientImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Sp.small
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private var currentTask: Task<Void, Never>? {
        willSet {
            currentTask?.cancel()
        }
    }
    
    private var currentImageID: NewsModel.ID?
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch traitCollection.horizontalSizeClass {
        case .compact:
            compactLayout()
        default:
            regularLayout()
        }
        
        setShadowPath()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        let horizontalSizeClass = traitCollection.horizontalSizeClass
        
        guard horizontalSizeClass == .compact else {
            return super.systemLayoutSizeFitting(targetSize,
                                                 withHorizontalFittingPriority: horizontalFittingPriority,
                                                 verticalFittingPriority: horizontalFittingPriority)
        }
        
        let labelSpacing = Sp.small
        let verticalMargins = layoutMargins.top + layoutMargins.bottom
        let verticalSpacing = labelSpacing + verticalMargins
        
        let titleSize = getLabelSize(titleLabel, targetSize: targetSize)
        
        let subtitleSize = getLabelSize(subtitleLabel, targetSize: targetSize)
        
        let height: CGFloat
        
        if horizontalSizeClass == .compact {
            height = titleSize.height + subtitleSize.height + verticalSpacing
        } else {
            height = titleSize.height + subtitleSize.height + verticalSpacing + SharedConstants.minImageSize
        }
        
        if height < SharedConstants.minImageSize + verticalSpacing, imageView.isHidden == false {
            return CGSize(width: targetSize.width, height: SharedConstants.minImageSize + verticalMargins)
        }
        
        return CGSize(width: targetSize.width, height: height)
    }
    
    private func getLabelSize(_ label: UILabel, targetSize: CGSize) -> CGSize {
        let horizontalMargins = layoutMargins.left + layoutMargins.right
        let imageSpacing = Sp.small
        let horizontalSpacing = horizontalMargins + SharedConstants.minImageSize + imageSpacing
        
        let adjustedTargetSize = CGSize(width: targetSize.width - horizontalSpacing,
                                        height: targetSize.height)
        
        let labelSize = label.sizeThatFits(adjustedTargetSize)
        return labelSize
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    // MARK: - Methods
    func configure(_ model: NewsModel, imageProvider: ImageProviderProtocol) {
        titleLabel.text = model.title
        subtitleLabel.text = model.description
        currentImageID = model.id
        
        guard let titleImageUrl = model.titleImageUrl else {
            imageView.isHidden = true
            return
        }
        
        self.currentTask = Task(priority: .userInitiated) { [weak self, unowned imageProvider] in
            let image = await imageProvider.getImage(url: titleImageUrl)
            if Task.isCancelled { return }
            guard self?.currentImageID == model.id else { return }
            self?.imageView.image = image
        }
    }
    
    private func reset() {
        titleLabel.text = nil
        subtitleLabel.text = nil
        imageView.image = nil
        imageView.isHidden = false
        currentTask = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI
private extension NewsFeedCollectionViewCell {
    
    private func setup() {
        self.backgroundColor = .systemBackground
        self.layer.cornerRadius = Sp.small
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        setupShadow()
    }
    
    private func setupShadow() {
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 1
    }
    
    private func setShadowPath() {
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: Sp.small).cgPath
    }
    
}

// MARK: Compact Layout
private extension NewsFeedCollectionViewCell {
    private func compactLayout() {
        
        let layoutFrame = contentView.layoutMarginsGuide.layoutFrame
        let minImageWidth = imageView.isHidden ? .zero : SharedConstants.minImageSize
        let labelWidth = layoutFrame.width - minImageWidth - Sp.small
        
        // Calculate sizes
        imageView.bounds.size = .init(width: minImageWidth, height: minImageWidth)
        
        titleLabel.bounds.size = titleLabel.systemLayoutSizeFitting(
            CGSize(width: labelWidth, height: layoutFrame.height)
        )
        
        let subtitleSize = subtitleLabel.systemLayoutSizeFitting(
            CGSize(
                width: labelWidth,
                height: layoutFrame.height - titleLabel.bounds.height - Sp.small
            )
        )
        
        subtitleLabel.bounds.size = CGSize(
            width: labelWidth,
            height: min(
                layoutFrame.height - titleLabel.bounds.height - Sp.small,
                subtitleSize.height
            )
        )
        
        // Position views
        titleLabel.frame.origin = layoutFrame.origin
        
        subtitleLabel.frame.origin = .init(
            x: layoutFrame.origin.x,
            y: titleLabel.frame.maxY + Sp.small
        )
        
        imageView.center = .init(
            x: layoutFrame.maxX - imageView.bounds.width / 2,
            y: layoutFrame.midY
        )
    }
}

// MARK: Regular Layout
private extension NewsFeedCollectionViewCell {
    private func regularLayout() {
        let layoutFrame = contentView.layoutMarginsGuide.layoutFrame
        let minImageHeight = imageView.isHidden ? 0.0 : 100.0
        let labelWidth = layoutFrame.width
        
        // Calculate sizes
        
        titleLabel.bounds.size = titleLabel.systemLayoutSizeFitting(
            CGSize(width: labelWidth, height: layoutFrame.height)
        )
        
        let subtitleSize = subtitleLabel.systemLayoutSizeFitting(
            CGSize(
                width: labelWidth,
                height: layoutFrame.height - titleLabel.bounds.height - minImageHeight - Sp.small * 2
            )
        )
        
        subtitleLabel.bounds.size = CGSize(
            width: labelWidth,
            height: min(
                layoutFrame.height - titleLabel.bounds.height - minImageHeight - Sp.small * 2,
                subtitleSize.height
            )
        )
        
        imageView.bounds.size = .init(
            width: layoutFrame.width,
            height: max(
                layoutFrame.height - titleLabel.bounds.height - subtitleLabel.bounds.height - Sp.small * 2,
                minImageHeight
            )
        )
        
        // Position views
        titleLabel.frame.origin = layoutFrame.origin
        
        subtitleLabel.frame.origin = .init(
            x: layoutFrame.origin.x,
            y: titleLabel.frame.maxY + Sp.small
        )
        
        imageView.frame.origin = .init(x: layoutFrame.origin.x, y: subtitleLabel.frame.maxY + Sp.small)
    }
}
