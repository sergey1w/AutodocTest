//
//  NewsResult.swift
//  AutodocTest
//
//  Created by sergey on 15.02.2025.
//

import Foundation

struct NewsResult {
    
    enum DataSource {
        case cache
        case network
    }
    
    let news: [NewsModel]
    let totalCount: Int
    let dataSource: DataSource
}

extension NewsResult {
    static func network(_ newsDTO: NewsModel.DTO) -> Self {
        return Self.init(news: newsDTO.news, totalCount: newsDTO.totalCount, dataSource: .network)
    }
    
    static func cached(_ newsDTO: NewsModel.DTO) -> Self {
        return Self.init(news: newsDTO.news, totalCount: newsDTO.totalCount, dataSource: .cache)
    }
}
