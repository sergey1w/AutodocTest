//
//  NewsModel.swift
//  AutodocTest
//
//  Created by sergey on 01.02.2025.
//

import Foundation

struct NewsModel {
    let id: Int
    let title: String
    let description: String
    let publishedDate: Date
    let url: URL
    let fullUrl: URL
    let titleImageUrl: URL?
    let categoryType: String
}

extension NewsModel: Identifiable {}

extension NewsModel: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension NewsModel: Decodable {}
