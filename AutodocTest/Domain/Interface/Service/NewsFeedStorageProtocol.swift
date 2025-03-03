//
//  NewsFeedStorageProtocol.swift
//  AutodocTest
//
//  Created by sergey on 01.03.2025.
//

import Foundation

protocol NewsFeedStorageProtocol: AnyObject {
    var totalCount: Int { get async }
    func getNews(page: Int, count: Int) async throws -> [NewsModel]
    func saveNews(news: [NewsModel]) async throws
}
