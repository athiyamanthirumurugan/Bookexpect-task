//
//  BookmarkViewModel.swift
//  Bookexpect-task
//
//  Created by Gowtham on 16/09/25.
//

import Foundation
import Combine

@MainActor
class BookmarkViewModel: ObservableObject {
    @Published var bookmarkedArticles: [Article] = []
    @Published var filteredBookmarks: [Article] = []
    @Published var searchText = "" {
        didSet {
            filterBookmarks()
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
                self?.filterBookmarks()
            }
            .store(in: &cancellables)
    }
    
    func loadBookmarks() {
        bookmarkedArticles = repository.getBookmarkedArticles()
        filterBookmarks()
    }
    
    func refreshBookmarks() {
        loadBookmarks()
    }
    
    private func filterBookmarks() {
        if searchText.isEmpty {
            filteredBookmarks = bookmarkedArticles
        } else {
            filteredBookmarks = repository.searchArticles(query: searchText, from: bookmarkedArticles)
        }
    }
    
    func removeBookmark(for article: Article) {
        repository.removeBookmark(for: article)
        loadBookmarks()
    }
    
    var isEmpty: Bool {
        return bookmarkedArticles.isEmpty
    }
}