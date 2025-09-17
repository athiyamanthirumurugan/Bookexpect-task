//
//  Article.swift
//  Bookexpect-task
//
//  Created by Gowtham on 16/09/25.
//

import Foundation

// MARK: - NewsResponse
struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

// MARK: - Article
struct Article: Codable, Equatable {
    let source: Source?
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
    
    // Computed property for display
    var displayAuthor: String {
        return author ?? "Unknown Author"
    }
    
    var displayDescription: String {
        return description ?? "No description available"
    }
    
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: publishedAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return publishedAt
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.url == rhs.url
    }
}

// MARK: - Source
struct Source: Codable {
    let id: String?
    let name: String
}