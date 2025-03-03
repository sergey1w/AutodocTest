//
//  NewsFeedRepository.swift
//  AutodocNews
//
//  Created by sergey on 17.01.2025.
//

import Foundation

final class NewsFeedRepository: NewsFeedRepositoryProtocol {
    
    private let dataTransferService: NetworkingServiceProtocol
    private let newsFeedStorage: NewsFeedStorageProtocol
    
    init(dataTransferService: some NetworkingServiceProtocol,
         newsFeedStorage: some NewsFeedStorageProtocol) {
        self.dataTransferService = dataTransferService
        self.newsFeedStorage = newsFeedStorage
    }
    
    func getNews(page: Int, count: Int) async throws -> NewsResult {
        do {
            return try await fetchFromNetwork(page: page, count: count)
        } catch let error as URLError where error.code == .notConnectedToInternet {
            return try await fetchFromCache(page: page, count: count)
        }
    }
    
    private func fetchFromNetwork(page: Int, count: Int) async throws -> NewsResult {
        let newsEndpoint = NewsEndpoint(page: page, limit: count)
        let newsDTO = try await dataTransferService.request(withEndpoint: newsEndpoint)
        
        try? await saveNews(news: newsDTO.news)
        
        return .network(newsDTO)
    }
    
    private func fetchFromCache(page: Int, count: Int) async throws -> NewsResult {
        let cachedNews = try await newsFeedStorage.getNews(page: page, count: count)
        let newsDTO = await NewsModel.DTO(news: cachedNews, totalCount: newsFeedStorage.totalCount)
        
        return .cached(newsDTO)
    }
    
    private func saveNews(news: [NewsModel]) async throws {
        try await newsFeedStorage.saveNews(news: news)
    }
    
    deinit {
        print("Deinited \(String(describing: self))")
    }
}
