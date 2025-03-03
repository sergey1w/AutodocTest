//
//  NewsFeedCoordinator.swift
//  AutodocTest
//
//  Created by sergey on 26.02.2025.
//

import UIKit
import SafariServices

@MainActor
final class NewsFeedCoordinator: Coordinator {
    
    var rootViewController: UINavigationController
    
    init() {
        self.rootViewController = UINavigationController()
        self.rootViewController.navigationBar.prefersLargeTitles = false
    }

    func start() {
        let newsFeedController = makeNewsFeedController()
        rootViewController.setViewControllers([newsFeedController], animated: false)
    }
    
    private func showNewsDetail(newsModel: NewsModel) {
        let safariVC = SFSafariViewController(url: newsModel.fullUrl)
        safariVC.preferredControlTintColor = .accent
        rootViewController.present(safariVC, animated: true)
    }
    
    private func makeNewsFeedController() -> NewsFeedViewController {
        let newsFeedRepository = NewsFeedRepository(
            dataTransferService: NetworkingService(),
            newsFeedStorage: CoreDataNewsStorage()
        )
        let newsFeedActions = NewsFeedViewModelActions { [unowned self] in
            self.showNewsDetail(newsModel: $0)
        }
        let newsFeedViewModel = NewsFeedViewModel(
            newsFeedRepository: newsFeedRepository,
            actions: newsFeedActions
        )
        let imageProvider = NewsFeedImageProvider(imageStorage: DiskImageStorage())
        let newsFeedController = NewsFeedViewController(
            viewModel: newsFeedViewModel,
            imageProvider: imageProvider
        )
        return newsFeedController
    }
}
