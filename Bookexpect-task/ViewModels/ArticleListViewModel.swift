//
//  ArticleListViewModel.swift
//  Bookexpect-task
//
//  Created by Gowtham on 16/09/25.
//

import Foundation
import Combine

@MainActor
class ArticleListViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var filteredArticles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = "" {
        didSet {
            filterArticles()
        }
    }
    
    private let repository: ArticleRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: ArticleRepositoryProtocol = ArticleRepository()) {
        self.repository = repository
        setupSearchBinding()
    }
    
    private func setupSearchBinding() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterArticles()
            }
            .store(in: &cancellables)
    }
    
    func loadArticles() {
        Task {
            await fetchArticles()
        }
    }
    
    func refreshArticles() {
        Task {
            await fetchArticles()
        }
    }
    
    private func fetchArticles() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedArticles = try await repository.fetchArticles(page: 1, pageSize: 50)
            articles = fetchedArticles
            filterArticles()
        } catch {
            errorMessage = error.localizedDescription
            // Load cached articles as fallback
            let cachedArticles = repository.getCachedArticles()
            articles = cachedArticles
            filterArticles()
        }
        
        isLoading = false
    }
    
    private func filterArticles() {
        if searchText.isEmpty {
            filteredArticles = articles
        } else {
            filteredArticles = repository.searchArticles(query: searchText, from: articles)
        }
    }
    
    func toggleBookmark(for article: Article) {
        if repository.isArticleBookmarked(article) {
            repository.removeBookmark(for: article)
        } else {
            repository.bookmarkArticle(article)
        }
    }
    
    func isBookmarked(_ article: Article) -> Bool {
        return repository.isArticleBookmarked(article)
    }
}