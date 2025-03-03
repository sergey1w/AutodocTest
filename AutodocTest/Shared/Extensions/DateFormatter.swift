//
//  DateFormatter.swift
//  AutodocNews
//
//  Created by sergey on 17.01.2025.
//

import Foundation

extension DateFormatter {
    static let newsFeed: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
}
