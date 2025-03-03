//
//  Endpoint.swift
//  AutodocNews
//
//  Created by sergey on 17.01.2025.
//

import Foundation

protocol Endpoint {
    associatedtype Response: Decodable
    var url: URL? { get }
}

struct NewsEndpoint: Endpoint {
    typealias Response = NewsModel.DTO
    
    let page: Int
    let limit: Int
    
    var url: URL? {
        return URL(string: "https://webapi.autodoc.ru/api/news/\(page)/\(limit)")
    }
}
