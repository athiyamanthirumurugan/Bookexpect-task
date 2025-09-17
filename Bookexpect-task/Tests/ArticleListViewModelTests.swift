//
//  ArticleListViewModelTests.swift
//  Bookexpect-task
//
//  Created by Gowtham on 16/09/25.
//

import XCTest
import Combine
@testable import Bookexpect_task

@MainActor
class ArticleListViewModelTests: XCTestCase {
    var viewModel: ArticleListViewModel!
    var mockRepository: MockArticleRepository!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockArticleRepository()
        viewModel = ArticleListViewModel(repository: mockRepository)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testLoadArticles_Success() async {
        // Given
        let expectedArticles = MockData.sampleArticles
        mockRepository.mockArticles = expectedArticles
        
        let expectation = XCTestExpectation(description: "Articles loaded")
        
        viewModel.$filteredArticles
            .dropFirst()
            .sink { articles in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.loadArticles()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.filteredArticles.count, expectedArticles.count)
        XCTAssertEqual(viewModel.filteredArticles.first?.title, expectedArticles.first?.title)
    }
    
    func testSearchArticles_FiltersCorrectly() async {
        // Given
        let articles = MockData.sampleArticles
        mockRepository.mockArticles = articles
        
        let expectation = XCTestExpectation(description: "Articles filtered")
        
        viewModel.$filteredArticles
            .dropFirst(2) // Skip initial empty and loaded states
            .sink { filteredArticles in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.loadArticles()
        try? await Task.sleep(nanoseconds: 100_000_000) // Wait for initial load
        viewModel.searchText = "Test"
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.filteredArticles.allSatisfy { article in
            article.title.contains("Test") ||
            article.displayAuthor.contains("Test") ||
            article.displayDescription.contains("Test")
        })
    }
    
    func testBookmarkToggle() {
        // Given
        let article = MockData.sampleArticles.first!
        
        // When
        viewModel.toggleBookmark(for: article)
        
        // Then
        XCTAssertTrue(mockRepository.bookmarkCalled)
        XCTAssertEqual(mockRepository.bookmarkedArticle?.url, article.url)
    }
}

// MARK: - Mock Repository
class MockArticleRepository: ArticleRepositoryProtocol {
    var mockArticles: [Article] = []
    var mockError: Error?
    var bookmarkCalled = false
    var removeBookmarkCalled = false
    var bookmarkedArticle: Article?
    var removedBookmarkArticle: Article?
    
    func fetchArticles(page: Int, pageSize: Int) async throws -> [Article] {
        if let error = mockError {
            throw error
        }
        return mockArticles
    }
    
    func getCachedArticles() -> [Article] {
        return mockArticles
    }
    
    func searchArticles(query: String, from articles: [Article]) -> [Article] {
        guard !query.isEmpty else { return articles }
        return articles.filter { article in
            article.title.contains(query) ||
            article.displayAuthor.contains(query) ||
            article.displayDescription.contains(query)
        }
    }
    
    func bookmarkArticle(_ article: Article) {
        bookmarkCalled = true
        bookmarkedArticle = article
    }
    
    func removeBookmark(for article: Article) {
        removeBookmarkCalled = true
        removedBookmarkArticle = article
    }
    
    func getBookmarkedArticles() -> [Article] {
        return []
    }
    
    func isArticleBookmarked(_ article: Article) -> Bool {
        return bookmarkedArticle?.url == article.url
    }
}

// MARK: - Mock Data
struct MockData {
    static let sampleArticles: [Article] = [
        Article(
            source: Source(id: "test1", name: "Test Source 1"),
            author: "Test Author 1",
            title: "Test Article 1",
            description: "This is a test article description",
            url: "https://example.com/1",
            urlToImage: "https://example.com/image1.jpg",
            publishedAt: "2024-01-01T00:00:00Z",
            content: "Test content 1"
        ),
        Article(
            source: Source(id: "test2", name: "Test Source 2"),
            author: "Another Author",
            title: "Different Article",
            description: "This is another article description",
            url: "https://example.com/2",
            urlToImage: "https://example.com/image2.jpg",
            publishedAt: "2024-01-02T00:00:00Z",
            content: "Different content"
        )
    ]
}