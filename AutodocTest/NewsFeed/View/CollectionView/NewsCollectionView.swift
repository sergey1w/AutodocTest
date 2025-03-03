//
//  NewsCollectionView.swift
//  AutodocNews
//
//  Created by sergey on 17.01.2025.
//

import UIKit

final class NewsCollectionView: UICollectionView {
    
    private let compositionalLayout = makeCompositionalLayout()
    
    private func setup() {
        self.backgroundColor = .systemGray5
        self.register(NewsFeedCollectionViewCell.self,
                      forCellWithReuseIdentifier: NewsFeedCollectionViewCell.reuseId)
        self.register(LoadingFooterView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                      withReuseIdentifier: LoadingFooterView.identifier)
        self.register(SectionHeaderView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: SectionHeaderView.identifier)
    }
    
    init() {
        super.init(frame: .zero, collectionViewLayout: compositionalLayout)
        setup()
    }
    
    func scrollToTop() {
        self.scrollRectToVisible(
            CGRect(x: 0, y: 0, width: self.bounds.width, height: 100),
            animated: true
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deinited \(String(describing: self))")
    }
}

extension NewsCollectionView {
    static func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            let horizontailSizeClass = layoutEnvironment.traitCollection.horizontalSizeClass
            
            let itemWidth: NSCollectionLayoutDimension
            let groupHeight: NSCollectionLayoutDimension
            
            switch horizontailSizeClass {
            case .compact:
                itemWidth = .fractionalWidth(1.0)
                groupHeight = .estimated(124.0)
            default:
                itemWidth = .fractionalWidth(1.0 / 3)
                groupHeight = .estimated(248.0)
            }
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: itemWidth,
                heightDimension: .estimated(groupHeight.dimension)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: groupHeight
            )
            
            let group: NSCollectionLayoutGroup
            switch horizontailSizeClass {
            case .compact:
                group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            default:
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            }
            
            group.interItemSpacing = .fixed(Sp.small)
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.interGroupSpacing = Sp.small
            section.contentInsetsReference = .readableContent
            section.contentInsets.top = Sp.small
            
            let footerHeaderSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(50.0)
            )
            
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerHeaderSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerHeaderSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            header.contentInsets.leading = Sp.small
            
            section.boundarySupplementaryItems = [header, footer]
            
            return section
        }
    }
}
