//
//  NewsRepositoryProtocol.swift
//  AutodocTest
//
//  Created by sergey on 01.03.2025.
//

import Foundation

protocol NewsFeedRepositoryProtocol {
    func getNews(page: Int, count: Int) async throws -> NewsResult
}
