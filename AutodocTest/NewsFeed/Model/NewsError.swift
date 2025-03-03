//
//  NewsError.swift
//  AutodocTest
//
//  Created by sergey on 22.02.2025.
//

import Foundation

enum NewsError: Error {
    case networkError(error: URLError)
    case wrongDataFormat(error: Error)
    case missingData
    case batchInsertError
    case persistentHistoryChangeError
    case unexpectedError(error: Error)
}

extension NewsError: LocalizedError {
    var title: String {
        switch self {
        case .networkError:
            return String(localized: "Network error")
        case .wrongDataFormat:
            return String(localized: "Decoding error")
        case .batchInsertError, .persistentHistoryChangeError:
            return String(localized: "CoreData error")
        case .unexpectedError:
            return String(localized: "Unexpected error")
        default:
            return String(localized: "Error")
        }
    }
    
    var errorDescription: String? {
        switch self {
        case let .networkError(error as Error), let .wrongDataFormat(error), let .unexpectedError(error):
            return error.localizedDescription
        case .missingData:
            return String(localized: "Could not fetch news.")
        case .batchInsertError:
            return String(localized: "Failed to execute a batch insert request.")
        case .persistentHistoryChangeError:
            return String(localized: "Failed to execute a persistent history change request.")
        }
    }
}
