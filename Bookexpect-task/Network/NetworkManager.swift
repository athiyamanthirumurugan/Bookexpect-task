//
//  NetworkManager.swift
//  Bookexpect-task
//
//  Created by Gowtham on 16/09/25.
//

import Foundation
import Network
import Combine

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkUnavailable
    case serverError(Int)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkUnavailable:
            return "Network is unavailable"
        case .serverError(let code):
            return "Server error with code: \(code)"
        }
    }
}

protocol NetworkManagerProtocol {
    func fetchArticles(page: Int, pageSize: Int) async throws -> NewsResponse
    func isNetworkAvailable() -> Bool
}

class NetworkManager: NetworkManagerProtocol, ObservableObject {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    @Published private(set) var isConnected = true
    
    // NewsAPI
    private let apiKey = "df86f76de349436189b9233bf24ba5c1"
    private let baseURL = "https://newsapi.org/v2"
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
        
        startNetworkMonitoring()
    }
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    func fetchArticles(page: Int = 1, pageSize: Int = 20) async throws -> NewsResponse {
        guard isConnected else {
            throw NetworkError.networkUnavailable
        }
        
       
        let endpoint = "\(baseURL)/top-headlines?country=us&page=\(page)&pageSize=\(pageSize)&apiKey=\(apiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    throw NetworkError.serverError(httpResponse.statusCode)
                }
            }
            
            let decoder = JSONDecoder()
            let newsResponse = try decoder.decode(NewsResponse.self, from: data)
            return newsResponse
            
        } catch is DecodingError {
            throw NetworkError.decodingError
        } catch {
            throw error
        }
    }
    
    func isNetworkAvailable() -> Bool {
        return isConnected
    }
    
    deinit {
        monitor.cancel()
    }
}

// MARK: - Mock Network Manager for Testing
class MockNetworkManager: NetworkManagerProtocol {
    var shouldFail = false
    var mockResponse: NewsResponse?
    
    func fetchArticles(page: Int, pageSize: Int) async throws -> NewsResponse {
        if shouldFail {
            throw NetworkError.networkUnavailable
        }
        
        return mockResponse ?? NewsResponse(
            status: "ok",
            totalResults: 2,
            articles: [
                Article(
                    source: Source(id: "test", name: "Test Source"),
                    author: "Test Author",
                    title: "Test Article 1",
                    description: "This is a test article",
                    url: "https://test.com/1",
                    urlToImage: "https://test.com/image1.jpg",
                    publishedAt: "2024-01-01T00:00:00Z",
                    content: "Test content 1"
                ),
                Article(
                    source: Source(id: "test2", name: "Test Source 2"),
                    author: "Test Author 2",
                    title: "Test Article 2",
                    description: "This is another test article",
                    url: "https://test.com/2",
                    urlToImage: "https://test.com/image2.jpg",
                    publishedAt: "2024-01-02T00:00:00Z",
                    content: "Test content 2"
                )
            ]
        )
    }
    
    func isNetworkAvailable() -> Bool {
        return !shouldFail
    }
}
