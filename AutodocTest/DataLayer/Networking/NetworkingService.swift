//
//  NetworkingService.swift
//  AutodocNews
//
//  Created by sergey on 17.01.2025.
//

import Foundation

protocol NetworkingServiceProtocol: AnyObject {
    func request<E: Endpoint>(withEndpoint endpoint: E) async throws -> E.Response
}

final class NetworkingService: NetworkingServiceProtocol {
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(DateFormatter.newsFeed)
        return decoder
    }()
    
    func request<T: Endpoint>(withEndpoint endpoint: T) async throws -> T.Response  {
        guard let url = endpoint.url else {
            throw URLError(.badURL)
        }
        
        let session = URLSession.shared
        
        let (data, _) = try await session.data(from: url)
        
        do {
            
            let decoded = try decoder.decode(T.Response.self, from: data)
            return decoded
            
        } catch {
            let response = String(data: data, encoding: .utf8) ?? "No data"
            print(error)
            print(response)
            throw error
        }
    }
    
    deinit {
        print("Deinited \(String(describing: self))")
    }
    
}
