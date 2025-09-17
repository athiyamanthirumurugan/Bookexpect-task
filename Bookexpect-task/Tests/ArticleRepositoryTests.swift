//
//  ArticleRepositoryTests.swift
//  Bookexpect-task
//
//  Created by Gowtham on 16/09/25.
//

import XCTest
@testable import Bookexpect_task

class ArticleRepositoryTests: XCTestCase {
    var repository: ArticleRepository!
    var mockNetworkManager: MockNetworkManager!
    var mockCoreDataManager: MockCoreDataManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        mockCoreDataManager = MockCoreDataManager()
        repository = ArticleRepository(
            networkManager: mockNetworkManager,
            coreDataManager: mockCoreDataManager
        )
    }
    
    override func tearDown() {
        repository = nil
        mockNetworkManager = nil
        mockCoreDataManager = nil
        super.tearDown()
    }
    
    func testFetchArticles_Success() async throws {
        // Given
        let expectedArticles = MockData.sampleArticles
        mockNetworkManager.mockResponse = NewsResponse(
            status: "ok",
            totalResults: expectedArticles.count,
            articles: expectedArticles
        )
        
        // When
        let articles = try await repository.fetchArticles(page: 1, pageSize: 20)
        
        // Then
        XCTAssertEqual(articles.count, expectedArticles.count)
        XCTAssertEqual(articles.first?.title, expectedArticles.first?.title)
        XCTAssertTrue(mockCoreDataManager.saveArticlesCalled)
    }
    
    func testFetchArticles_NetworkFailure_ReturnsCachedArticles() async throws {
        // Given
        let cachedArticles = MockData.sampleArticles
        mockNetworkManager.shouldFail = true
        mockCoreDataManager.mockCachedArticles = cachedArticles
        
        // When
        let articles = try await repository.fetchArticles(page: 1, pageSize: 20)
        
        // Then
        XCTAssertEqual(articles.count, cachedArticles.count)
        XCTAssertEqual(articles.first?.title, cachedArticles.first?.title)
    }
    
    func testSearchArticles_FiltersCorrectly() {
        // Given
        let articles = MockData.sampleArticles
        
        // When
        let filteredArticles = repository.searchArticles(query: "Test", from: articles)
        
        // Then
        XCTAssertTrue(filteredArticles.allSatisfy { article in
            article.title.lowercased().contains("test") ||
            article.displayAuthor.lowercased().contains("test") ||
            article.displayDescription.lowercased().contains("test")
        })
    }
    
    func testSearchArticles_EmptyQuery_ReturnsAllArticles() {
        // Given
        let articles = MockData.sampleArticles
        
        // When
        let filteredArticles = repository.searchArticles(query: "", from: articles)
        
        // Then
        XCTAssertEqual(filteredArticles.count, articles.count)
    }
    
    func testBookmarkArticle() {
        // Given
        let article = MockData.sampleArticles.first!
        
        // When
        repository.bookmarkArticle(article)
        
        // Then
        XCTAssertTrue(mockCoreDataManager.bookmarkCalled)
        XCTAssertEqual(mockCoreDataManager.bookmarkedArticle?.url, article.url)
    }
    
    func testRemoveBookmark() {
        // Given
        let article = MockData.sampleArticles.first!
        
        // When
        repository.removeBookmark(for: article)
        
        // Then
        XCTAssertTrue(mockCoreDataManager.removeBookmarkCalled)
        XCTAssertEqual(mockCoreDataManager.removedBookmarkArticle?.url, article.url)
    }
}

// MARK: - Mock Core Data Manager
class MockCoreDataManager: CoreDataManager {
    var mockCachedArticles: [Article] = []
    var mockBookmarkedArticles: [Article] = []
    var saveArticlesCalled = false
    var bookmarkCalled = false
    var removeBookmarkCalled = false
    var bookmarkedArticle: Article?
    var removedBookmarkArticle: Article?
    
    override func saveArticles(_ articles: [Article]) {
        saveArticlesCalled = true
        mockCachedArticles = articles
    }
    
    override func fetchCachedArticles() -> [Article] {
        return mockCachedArticles
    }
    
    override func bookmarkArticle(_ article: Article) {
        bookmarkCalled = true
        bookmarkedArticle = article
        mockBookmarkedArticles.append(article)
    }
    
    override func removeBookmark(for article: Article) {
        removeBookmarkCalled = true
        removedBookmarkArticle = article
        mockBookmarkedArticles.removeAll { $0.url == article.url }
    }
    
    override func fetchBookmarkedArticles() -> [Article] {
        return mockBookmarkedArticles
    }
    
    override func isArticleBookmarked(_ article: Article) -> Bool {
        return mockBookmarkedArticles.contains { $0.url == article.url }
    }
}