//
//  NewsFeedViewModel.swift
//  AutodocTest
//
//  Created by sergey on 01.02.2025.
//

import Foundation
import Combine

struct NewsFeedViewModelActions {
    let selectItem: (NewsModel) -> Void
}

protocol NewsFeedViewModelOutput {
    var newsPublisher: Published<[NewsModel]>.Publisher { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<NewsError?>.Publisher { get }
    var lastResultPublisher: Published<NewsResult?>.Publisher { get }
}

protocol NewsFeedViewModelInput {
    func didScrollToBottom()
    func viewDidLoad()
    func refresh()
    func didSelect(newsItem item: NewsModel)
}

typealias NewsFeedViewModelProtocol = NewsFeedViewModelInput & NewsFeedViewModelOutput & AnyObject

final class NewsFeedViewModel {
    
    private let newsFeedRepository: NewsFeedRepositoryProtocol
    private let actions: NewsFeedViewModelActions
    
    @Published private var news: [NewsModel] = []
    @Published private var isLoading = false
    @Published private var error: NewsError?
    @Published private var lastResult: NewsResult?
    
    private var currentPage: Int = 1
    private var totalCount: Int? = nil
    
    init(newsFeedRepository: some NewsFeedRepositoryProtocol,
         actions: NewsFeedViewModelActions) {
        self.newsFeedRepository = newsFeedRepository
        self.actions = actions
    }
    
    private var hasMorePages: Bool {
        if let totalCount {
            return news.count < totalCount
        } else {
            return true
        }
    }
    
    private var nextPage: Int {
        hasMorePages ? currentPage + 1 : currentPage
    }
    
    private func fetchNews(reset: Bool = false) async {
        
        if isLoading {
            return
        }
        
        defer { isLoading = false }
        
        isLoading = true
        
        do {
            
            if reset {
                resetPagination()
            }
            
            guard hasMorePages else {
                return
            }
            
            var newsResult = try await newsFeedRepository.getNews(
                page: currentPage,
                count: SharedConstants.newsPerPage
            )
            
            // if DataSource changed – reset items to prevent duplicate entries
            if let lastResult, lastResult.dataSource != newsResult.dataSource {
                resetPagination()
                
                newsResult = try await newsFeedRepository.getNews(
                    page: currentPage,
                    count: SharedConstants.newsPerPage
                )
            }
             
            self.news += newsResult.news
            self.currentPage = nextPage
            self.totalCount = newsResult.totalCount
            self.lastResult = newsResult
        } catch let error as NewsError {
            self.error = error
        } catch let error as URLError {
            self.error = .networkError(error: error)
        } catch let error as DecodingError {
            self.error = .wrongDataFormat(error: error)
        } catch {
            self.error = .unexpectedError(error: error)
        }
    }
    
    private func resetPagination() {
        currentPage = 1
        totalCount = nil
        news = []
    }
    
    deinit {
        print("Deinited \(String(describing: self))")
    }
    
}

// MARK: Output
extension NewsFeedViewModel: NewsFeedViewModelOutput {
    var newsPublisher: Published<[NewsModel]>.Publisher { $news }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<(NewsError)?>.Publisher { $error }
    var lastResultPublisher: Published<NewsResult?>.Publisher { $lastResult }
}

// MARK: Input
extension NewsFeedViewModel: NewsFeedViewModelInput {
    
    func didScrollToBottom() {
        Task(priority: .userInitiated) { [unowned self] in
            await fetchNews()
        }
    }
    
    func viewDidLoad() {
        Task(priority: .userInitiated) { [unowned self] in
            await fetchNews()
        }
    }
    
    func refresh() {
        Task(priority: .userInitiated) { [unowned self] in
            await fetchNews(reset: true)
        }
    }
    
    func didSelect(newsItem item: NewsModel) {
        actions.selectItem(item)
    }
}
