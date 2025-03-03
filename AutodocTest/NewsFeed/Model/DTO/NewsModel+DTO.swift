//
//  NewsModel+DTO.swift
//  AutodocTest
//
//  Created by sergey on 01.02.2025.
//

import Foundation

extension NewsModel {
    struct DTO {
        let news: [NewsModel]
        let totalCount: Int
    }
}

extension NewsModel.DTO: Decodable {}
