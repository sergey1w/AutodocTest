//
//  SplitSFViewController.swift
//  AutodocTest
//
//  Created by sergey on 03.03.2025.
//

import SafariServices

final class SplitSFViewController: SFSafariViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension SplitSFViewController: SFSafariViewControllerDelegate {
    nonisolated public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        DispatchQueue.main.async {
            self.splitViewController?.show(.primary)
        }
    }
}
