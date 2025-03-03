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
    
    var rootViewController: UISplitViewController
    
    init() {
        let splitController = UISplitViewController(style: .doubleColumn)
        self.rootViewController = splitController
        splitController.displayModeButtonVisibility = .never
    }

    func start() {
        let newsFeedController = makeNewsFeedController()
        rootViewController.setViewController(newsFeedController, for: .primary)
    }
    
    private func showNewsDetail(newsModel: NewsModel) {
        let safariVC = SplitSFViewController(url: newsModel.fullUrl)
        safariVC.preferredControlTintColor = .accent
        let navigationController = UINavigationController(rootViewController: safariVC)
        rootViewController.showDetailViewController(navigationController, sender: rootViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
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
