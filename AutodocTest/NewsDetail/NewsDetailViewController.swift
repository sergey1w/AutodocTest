//
//  NewsDetailViewController.swift
//  AutodocNews
//
//  Created by sergey on 21.01.2025.
//

import UIKit
import WebKit
import Combine

final class NewsDetailViewController: UIViewController {
    
    private let webView = WKWebView(frame: .zero)
    
    private let progressView = UIProgressView(progressViewStyle: .bar)

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.safeAreaLayoutGuide.layoutFrame
    }
    
    private func setup() {
        setupUI()
        setupBindings()
    }
    
    func loadUrl(url: URL) {
        webView.load(URLRequest(url: url))
        self.title = url.host()
    }
    
    private func setupBindings() {
        webView.publisher(for: \.estimatedProgress)
            .receive(on: DispatchQueue.main)
            .sink { [unowned progressView] progress in
                progressView.progress = Float(progress)
                progressView.isHidden = progress == 1.0
            }
            .store(in: &cancellables)
    }
    
}

// MARK: - UI Setup
extension NewsDetailViewController {
    private func setupUI() {
        self.navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGray5
        setupWebView()
        setupProgressBar()
    }
    
    private func setupWebView() {
        view.addSubview(webView)
        webView.backgroundColor = view.backgroundColor
    }
    
    private func setupProgressBar() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
