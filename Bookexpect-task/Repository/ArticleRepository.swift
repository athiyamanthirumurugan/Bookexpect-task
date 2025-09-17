//
//  ArticleRepository.swift
//  Bookexpect-task
//
//  Created by Gowtham on 16/09/25.
//

import Foundation
import Combine

protocol ArticleRepositoryProtocol {
    func fetchArticles(page: Int, pageSize: Int) async throws -> [Article]
    func getCachedArticles() -> [Article]
    func searchArticles(query: String, from articles: [Article]) -> [Article]
    func bookmarkArticle(_ article: Article)
    func removeBookmark(for article: Article)
    func getBookmarkedArticles() -> [Article]
    func isArticleBookmarked(_ article: Article) -> Bool
}

class ArticleRepository: ArticleRepositoryProtocol {
    private let networkManager: NetworkManagerProtocol
    private let coreDataManager: CoreDataManager
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared,
         coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.networkManager = networkManager
        self.coreDataManager = coreDataManager
    }
    
    func fetchArticles(page: Int = 1, pageSize: Int = 20) async throws -> [Article] {
        do {
            
            let newsResponse = try await networkManager.fetchArticles(page: page, pageSize: pageSize)
            let articles = newsResponse.articles
            
            
            coreDataManager.saveArticles(articles)
            
            return articles
        } catch {
            
            print("Network request failed, returning cached articles: \(error)")
            return getCachedArticles()
        }
    }
    
    func getCachedArticles() -> [Article] {
        return coreDataManager.fetchCachedArticles()
    }
    
    func searchArticles(query: String, from articles: [Article]) -> [Article] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return articles
        }
        
        let lowercaseQuery = query.lowercased()
        return articles.filter { article in
            article.title.lowercased().contains(lowercaseQuery) ||
            article.displayAuthor.lowercased().contains(lowercaseQuery) ||
            article.displayDescription.lowercased().contains(lowercaseQuery)
        }
    }
    
    func bookmarkArticle(_ article: Article) {
        coreDataManager.bookmarkArticle(article)
    }
    
    func removeBookmark(for article: Article) {
        coreDataManager.removeBookmark(for: article)
    }
    
    func getBookmarkedArticles() -> [Article] {
        return coreDataManager.fetchBookmarkedArticles()
    }
    
    func isArticleBookmarked(_ article: Article) -> Bool {
        return coreDataManager.isArticleBookmarked(article)
    }
}
