//
//  NewsFeedDataSource.swift
//  AutodocTest
//
//  Created by sergey on 01.02.2025.
//

import UIKit

final class NewsFeedDataSource: UICollectionViewDiffableDataSource<NewsFeedSection, NewsModel> {
    
    init(collectionView: UICollectionView, imageProvider: some ImageProviderProtocol) {
        super.init(collectionView: collectionView)
        { [unowned imageProvider] collectionView, indexPath, newsModel in
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewsFeedCollectionViewCell.reuseId,
                for: indexPath
            ) as! NewsFeedCollectionViewCell
            
            cell.configure(newsModel, imageProvider: imageProvider)
            
            return cell
        }
    }
    
    func applySnapshot(withItems items: [NewsModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<NewsFeedSection, NewsModel>()
        snapshot.appendSections([.news])
        snapshot.appendItems(items)
        self.apply(snapshot, animatingDifferences: true)
    }
    
    deinit {
        print("Deinited \(String(describing: self))")
    }
}
