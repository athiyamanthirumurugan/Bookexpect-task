import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get App Delegate")
        }
        return appDelegate.persistentContainer
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        let context = viewContext
        
        // Ensure we're on the main queue for UI context operations
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nsError = error as NSError
                    print("Save error: \(nsError), \(nsError.userInfo)")
                    // Consider using proper error handling instead of fatalError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
    
    // MARK: - Article Operations
    
    func saveArticles(_ articles: [Article]) {
        let context = viewContext
        
        context.performAndWait {
            // Create a copy of the articles array to avoid mutation during enumeration
            let articlesCopy = Array(articles)
            
            for article in articlesCopy {
                let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
                request.predicate = NSPredicate(format: "url == %@", article.url)
                request.fetchLimit = 1 // Optimize by limiting to 1 result
                
                do {
                    let existingArticles = try context.fetch(request)
                    
                    if let existingArticle = existingArticles.first {
                        existingArticle.title = article.title
                        existingArticle.author = article.author
                        existingArticle.articleDescription = article.description
                        existingArticle.cachedAt = Date()
                    } else {
                        let articleEntity = ArticleEntity(context: context)
                        articleEntity.populate(from: article, context: context)
                    }
                } catch {
                    print("Error processing article: \(error)")
                }
            }
            
            // Save within the same performAndWait block
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Error saving articles: \(error)")
                }
            }
        }
    }
    
    func fetchCachedArticles() -> [Article] {
        let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "cachedAt", ascending: false)]
        
        var articles: [Article] = []
        
        viewContext.performAndWait {
            do {
                let articleEntities = try viewContext.fetch(request)
                // Convert to array to avoid mutation issues
                articles = articleEntities.map { $0.toArticle() }
            } catch {
                print("Error fetching cached articles: \(error)")
            }
        }
        
        return articles
    }
    
    // MARK: - Bookmark Operations
    
    func bookmarkArticle(_ article: Article) {
        let context = viewContext
        
        context.performAndWait {
            let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
            request.predicate = NSPredicate(format: "url == %@", article.url)
            request.fetchLimit = 1
            
            do {
                let existingArticles = try context.fetch(request)
                
                if let existingArticle = existingArticles.first {
                    existingArticle.bookmarked = true
                } else {
                    let articleEntity = ArticleEntity(context: context)
                    articleEntity.populate(from: article, context: context)
                    articleEntity.bookmarked = true
                }
                
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                print("Error bookmarking article: \(error)")
            }
        }
    }
    
    func removeBookmark(for article: Article) {
        let context = viewContext
        
        context.performAndWait {
            let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
            request.predicate = NSPredicate(format: "url == %@", article.url)
            request.fetchLimit = 1
            
            do {
                let existingArticles = try context.fetch(request)
                
                if let existingArticle = existingArticles.first {
                    existingArticle.bookmarked = false
                    if context.hasChanges {
                        try context.save()
                    }
                }
            } catch {
                print("Error removing bookmark: \(error)")
            }
        }
    }
    
    func fetchBookmarkedArticles() -> [Article] {
        let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "bookmarked == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "cachedAt", ascending: false)]
        
        var articles: [Article] = []
        
        viewContext.performAndWait {
            do {
                let articleEntities = try viewContext.fetch(request)
                articles = articleEntities.map { $0.toArticle() }
            } catch {
                print("Error fetching bookmarked articles: \(error)")
            }
        }
        
        return articles
    }
    
    func isArticleBookmarked(_ article: Article) -> Bool {
        let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "url == %@ AND bookmarked == YES", article.url)
        request.fetchLimit = 1
        
        var isBookmarked = false
        
        viewContext.performAndWait {
            do {
                let count = try viewContext.count(for: request)
                isBookmarked = count > 0
            } catch {
                print("Error checking bookmark status: \(error)")
            }
        }
        
        return isBookmarked
    }
}
