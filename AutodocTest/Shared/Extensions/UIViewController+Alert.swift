//
//  UIViewController+Alert.swift
//  AutodocNews
//
//  Created by sergey on 20.01.2025.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        guard presentedViewController == nil else {
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
}
