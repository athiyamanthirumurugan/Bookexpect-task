//
//  ArticleEntity+CoreDataClass.swift
//  Bookexpect-task
//
//  Created by Gowtham on 16/09/25.
//

import Foundation
import CoreData

@objc(ArticleEntity)
public class ArticleEntity: NSManagedObject {
    
    // Convert ArticleEntity to Article model
    func toArticle() -> Article {
        return Article(
            source: sourceName != nil ? Source(id: sourceId, name: sourceName!) : nil,
            author: author,
            title: title ?? "",
            description: articleDescription,
            url: url ?? "",
            urlToImage: urlToImage,
            publishedAt: publishedAt ?? "",
            content: content
        )
    }
    
    // Populate ArticleEntity from Article model
    func populate(from article: Article, context: NSManagedObjectContext) {
        self.title = article.title
        self.author = article.author
        self.articleDescription = article.description
        self.url = article.url
        self.urlToImage = article.urlToImage
        self.publishedAt = article.publishedAt
        self.content = article.content
        self.sourceName = article.source?.name
        self.sourceId = article.source?.id
        self.cachedAt = Date()
    }
    
    // Check if article is bookmarked
    var isBookmarked: Bool {
        return bookmarked
    }
}