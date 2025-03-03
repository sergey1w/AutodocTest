//
//  AppCoordinator.swift
//  AutodocTest
//
//  Created by sergey on 01.02.2025.
//

import UIKit

@MainActor
protocol Coordinator {
    func start()
}

@MainActor
final class AppCoordinator: Coordinator {
    
    let window: UIWindow
    
    var childCoordinators: [Coordinator] = []
    
    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let newsFeedCoordinator = NewsFeedCoordinator()
        newsFeedCoordinator.start()
        self.childCoordinators = [newsFeedCoordinator]
        window.rootViewController = newsFeedCoordinator.rootViewController
        
//        Task { [unowned self] in
//            try await Task.sleep(for: .seconds(3))
//            childCoordinators = []
//            window.rootViewController = nil
//        }
    }
    
}
