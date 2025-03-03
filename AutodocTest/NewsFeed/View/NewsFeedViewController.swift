//
//  NewsFeedViewController.swift
//  AutodocTest
//
//  Created by sergey on 01.02.2025.
//

import UIKit
import Combine

final class NewsFeedViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: NewsFeedViewModelProtocol
    
    private let imageProvider: ImageProviderProtocol
    
    private let newsDataSource: NewsFeedDataSource
    
    private let newsCollectionView = NewsCollectionView()
    
    private let connectionStatusView = ConnectionStatusView(frame: .zero)
    
    private let refreshControl = UIRefreshControl()
    
    private var sectionFooter: LoadingFooterView?
    
    private var sectionHeader: SectionHeaderView?
    
    private var scrollBottomReached = false

    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: Init
    init(viewModel: some NewsFeedViewModelProtocol, imageProvider: some ImageProviderProtocol) {
        self.viewModel = viewModel
        self.imageProvider = imageProvider
        self.newsDataSource = NewsFeedDataSource(collectionView: self.newsCollectionView,
                                                 imageProvider: imageProvider)
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        newsCollectionView.frame = view.safeAreaLayoutGuide.layoutFrame
        layoutConnectionStatusView()
    }
    
    // MARK: Methods
    private func setup() {
        setupUI()
        bindFetchedNews()
        bindLoadingStatus()
        bindDataSourceChage()
        bindError()
        viewModel.viewDidLoad()
    }
    
    private func handleDataSourceChange(currentSource: NewsResult.DataSource) {
        switch currentSource {
        case .cache:
            connectionStatusView.isOnline = false
        case .network:
            connectionStatusView.isOnline = true
        }
        
        newsCollectionView.scrollToTop()
    }
    
    private func handleLoadingStatus(isLoading: Bool) {
        sectionFooter?.isLoading = isLoading && !refreshControl.isRefreshing
        
        if isLoading, newsCollectionView.numberOfSections < 1 {
            refreshControl.beginRefreshing()
            newsCollectionView.setContentOffset(CGPoint(x: 0, y: -refreshControl.bounds.height),
                                                animated: true)
        } else if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deinited \(String(describing: self))")
    }
}

// MARK: - ViewModel bindings
extension NewsFeedViewController {
    
    private func bindFetchedNews() {
        viewModel.newsPublisher
            .receive(on: DispatchQueue.main)
            .filter { !$0.isEmpty }
            .sink { [unowned newsDataSource] items in
                newsDataSource.applySnapshot(withItems: items)
            }
            .store(in: &cancellables)
    }
    
    private func bindLoadingStatus() {
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isLoading in
                handleLoadingStatus(isLoading: isLoading)
            }
            .store(in: &cancellables)
    }
    
    private func bindError() {
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] error in
                if let error = error {
                    self.showAlert(title: error.title, message: error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindDataSourceChage() {
        viewModel.lastResultPublisher
            .receive(on: DispatchQueue.main)
            .scan((NewsResult?.none, NewsResult?.none)) { ($0.1, $1) }
            .compactMap { (oldValue, newValue) -> (NewsResult.DataSource, NewsResult.DataSource)? in
                guard let oldValue, let newValue else {
                    return nil
                }
                return (oldValue.dataSource, newValue.dataSource)
            }
            .filter(!=)
            .sink { [unowned self] (_, newDataSource) in
                self.handleDataSourceChange(currentSource: newDataSource)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UI Setup
extension NewsFeedViewController {
    
    private func setupUI() {
        self.title = String(localized: "News")
        navigationItem.title = nil
        view.backgroundColor = .systemGray5
        view.addSubview(newsCollectionView)
        view.addSubview(connectionStatusView)
        setupRefreshControl()
        configureSupplementaryViewProvider()
        setupCollectionView()
    }
    
    private func setupRefreshControl() {
        let refreshAction = UIAction { [unowned viewModel] _ in
            viewModel.refresh()
        }
        refreshControl.addAction(refreshAction, for: .valueChanged)
    }
    
    private func configureSupplementaryViewProvider() {
        let supplementaryViewProvider: NewsFeedDataSource.SupplementaryViewProvider = {
            
            [unowned self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
            
            switch kind {
            case UICollectionView.elementKindSectionFooter:
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: LoadingFooterView.identifier,
                    for: indexPath
                ) as? LoadingFooterView
                
                self.sectionFooter = footer
                
                return footer
            case UICollectionView.elementKindSectionHeader:
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SectionHeaderView.identifier,
                    for: indexPath
                ) as? SectionHeaderView
                
                self.sectionHeader = header
                
                return header
            default:
                return nil
            }
        }
        
        newsDataSource.supplementaryViewProvider = supplementaryViewProvider
    }
    
    private func setupCollectionView() {
        newsCollectionView.refreshControl = refreshControl
        newsCollectionView.delegate = self
        newsCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func layoutConnectionStatusView() {
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame
        let statusViewHeight = view.safeAreaInsets.bottom
        
        connectionStatusView.bounds.size.width = view.bounds.width
        connectionStatusView.bounds.size.height = statusViewHeight
        connectionStatusView.center.x = view.center.x
        
        if UIDevice.current.orientation.isLandscape {
            connectionStatusView.center.y = safeAreaFrame.maxY - statusViewHeight / 2
        } else {
            connectionStatusView.center.y = safeAreaFrame.maxY + statusViewHeight / 2
        }
    }
    
}

// MARK: UICollectionViewDelegate
extension NewsFeedViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        guard offsetY > 0 else { return }
        
        if offsetY > scrollView.contentSize.height - scrollView.frame.height {
            if !scrollBottomReached, !refreshControl.isRefreshing {
                viewModel.didScrollToBottom()
            }
            scrollBottomReached = true
        } else {
            scrollBottomReached = false
        }
        
        if let header = sectionHeader, offsetY < header.frame.maxY {
            self.navigationItem.title = nil
        } else {
            self.navigationItem.title = self.title
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = newsDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        viewModel.didSelect(newsItem: item)
    }
}
