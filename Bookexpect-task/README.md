# News App - Bookexpect Task

A modern iOS news application built with UIKit following MVVM architecture and Clean Architecture principles. The app fetches articles from a REST API, provides offline caching, search functionality, and bookmark features.

## 📱 Features

### Core Features
- ✅ **Fetch Articles**: Retrieve news articles from REST API using URLSession
- ✅ **Offline Caching**: Store articles locally using Core Data for offline access
- ✅ **Pull-to-Refresh**: Refresh article list with UIRefreshControl
- ✅ **Search Articles**: Filter articles by title, author, or description
- ✅ **Bookmark Articles**: Save articles to bookmarks and view in dedicated tab

### Additional Features
- ✅ **Image Caching**: Async image loading with memory and disk caching
- ✅ **Network Monitoring**: Real-time network connectivity detection
- ✅ **Dark Mode Support**: Automatic light/dark mode support
- ✅ **Error Handling**: Graceful error handling with user-friendly messages
- ✅ **Unit Tests**: Comprehensive test coverage for ViewModels and Repository layer

## 🏗️ Architecture

The app follows **MVVM (Model-View-ViewModel)** pattern with **Clean Architecture** principles:

```
├── Models/                 # Data models and entities
├── ViewModels/            # Business logic and presentation logic
├── Views/                 # UI components
│   ├── Controllers/       # View controllers
│   └── Cells/            # Custom table view cells
├── Repository/           # Data access layer
├── Network/              # Networking layer
├── Utils/                # Utilities and helpers
├── Extensions/           # Swift extensions
└── Tests/                # Unit tests
```

### Architecture Components

#### 1. **Model Layer**
- `Article`: Main data model for news articles
- `NewsResponse`: API response wrapper
- `ArticleEntity`: Core Data entity for offline storage

#### 2. **Repository Layer**
- `ArticleRepository`: Implements data access logic
- `CoreDataManager`: Manages Core Data operations
- Abstracts data sources from ViewModels

#### 3. **Network Layer**
- `NetworkManager`: Handles API calls with URLSession
- `NetworkReachability`: Monitors network connectivity
- Implements retry mechanisms and error handling

#### 4. **ViewModel Layer**
- `ArticleListViewModel`: Manages article list state and operations
- `BookmarkViewModel`: Handles bookmark-related operations
- Uses Combine for reactive programming

#### 5. **View Layer**
- `ArticleListViewController`: Main articles screen
- `BookmarksViewController`: Bookmarks screen
- `ArticleTableViewCell`: Custom cell for article display
- `MainTabBarController`: Tab-based navigation

## 🛠️ Technical Implementation

### Networking
- **URLSession** for HTTP requests
- Async/await for modern concurrency
- Automatic retry on failure
- Network reachability monitoring

### Data Persistence
- **Core Data** for offline caching
- Bookmark storage and management
- Automatic cache cleanup

### Image Loading
- Custom image cache implementation
- Memory and disk caching
- Async loading with placeholders
- Cache size limits (50MB, 100 images)

### UI Implementation
- **UIKit** with programmatic Auto Layout
- Pull-to-refresh functionality
- Search with debounced text input
- Empty state handling
- Loading indicators

### Testing
- Unit tests for ViewModels and Repository
- Mock objects for dependencies
- XCTest framework with async testing
- Test coverage for core functionality

## 📋 Requirements Met

### ✅ Core Requirements
1. **Fetch Articles** - ✅ URLSession implementation with NewsAPI
2. **Offline Caching** - ✅ Core Data with graceful offline handling
3. **Pull-to-Refresh** - ✅ UIRefreshControl implementation
4. **Search Articles** - ✅ Real-time search with debouncing
5. **Bookmark Articles** - ✅ Separate bookmarks tab with Core Data

### ✅ Architecture Requirements
1. **MVVM Architecture** - ✅ Clear separation of concerns
2. **Repository Pattern** - ✅ Abstracted data access layer
3. **SOLID Principles** - ✅ Dependency injection and protocols
4. **Unit Tests** - ✅ ViewModel and Repository test coverage

### ✅ UI Requirements
1. **UIKit Only** - ✅ No SwiftUI dependencies
2. **Auto Layout** - ✅ Programmatic constraints for all devices
3. **Light/Dark Mode** - ✅ Automatic system appearance support
4. **Smooth Performance** - ✅ Optimized image loading and caching

## 🚀 Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 15.0 or later
- Swift 5.9 or later

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/bookexpect-task.git
   cd bookexpect-task
   ```

2. Open the project:
   ```bash
   open Bookexpect-task.xcodeproj
   ```

3. **Configure API Key** (Important):
   - Open `Network/NetworkManager.swift`
   - Replace `your_api_key_here` with your NewsAPI key:
     ```swift
     private let apiKey = "YOUR_ACTUAL_API_KEY"
     ```
   - Get your free API key from [NewsAPI.org](https://newsapi.org/register)

4. Build and run the project (⌘+R)

### Core Data Model
The app includes a pre-configured Core Data model (`Bookexpect_task.xcdatamodeld`) with the ArticleEntity. Make sure to add the entity with these attributes in Xcode's Core Data editor:

- `title` (String)
- `author` (String, Optional)
- `articleDescription` (String, Optional)
- `url` (String)
- `urlToImage` (String, Optional)
- `publishedAt` (String)
- `content` (String, Optional)
- `sourceName` (String, Optional)
- `sourceId` (String, Optional)
- `bookmarked` (Boolean)
- `cachedAt` (Date, Optional)

## 🧪 Testing

Run the unit tests:
```bash
# In Xcode
⌘+U

# Or via command line
xcodebuild test -project Bookexpect-task.xcodeproj -scheme Bookexpect-task -destination 'platform=iOS Simulator,name=iPhone 15'
```

Test coverage includes:
- `ArticleListViewModelTests`: ViewModel logic testing
- `ArticleRepositoryTests`: Data layer testing
- Mock implementations for network and persistence layers

## 📚 Dependencies

### System Frameworks
- **UIKit**: UI components and navigation
- **Foundation**: Core Swift functionality
- **Core Data**: Local data persistence
- **Network**: Network connectivity monitoring
- **SafariServices**: In-app web browsing
- **Combine**: Reactive programming

### No Third-Party Libraries
The app is built entirely with system frameworks to demonstrate native iOS development skills. However, the architecture is designed to easily accommodate libraries like:
- **Alamofire**: For enhanced networking (if needed)
- **Kingfisher**: For more advanced image caching (if needed)

## 🎯 Architecture Benefits

### Separation of Concerns
- **Models**: Pure data structures
- **ViewModels**: Business logic and state management
- **Views**: UI presentation and user interaction
- **Repository**: Data access abstraction

### Testability
- Protocol-based dependencies
- Dependency injection
- Mock implementations for testing
- Isolated business logic

### Maintainability
- Clear code organization
- Single responsibility principle
- Loosely coupled components
- Easy to extend and modify

### Scalability
- Modular architecture
- Protocol-oriented design
- Async/await for performance
- Memory-efficient image caching

## 🔧 Performance Optimizations

### Image Loading
- Memory and disk caching
- Background queue processing
- Automatic cache cleanup
- Placeholder images

### Network Efficiency
- Request debouncing for search
- Offline-first approach
- Automatic retry mechanisms
- Connection monitoring

### UI Performance
- Cell reuse in table views
- Lazy loading of images
- Efficient Core Data queries
- Main thread UI updates

## 📱 Supported Features

- **iOS 15.0+** compatibility
- **iPhone and iPad** support
- **Portrait and landscape** orientations
- **Dynamic Type** support
- **Accessibility** considerations
- **Voice Over** support

## 🔮 Future Enhancements

Potential improvements that could be added:

1. **Pagination**: Load more articles on scroll
2. **Categories**: Filter articles by category
3. **Push Notifications**: Breaking news alerts
4. **Social Sharing**: Share articles to social media
5. **Reading List**: Offline reading functionality
6. **Analytics**: User interaction tracking
7. **Localization**: Multi-language support

## 📄 License

This project is created as part of a technical assessment and is for demonstration purposes.

## 👨‍💻 Author

**Gowtham**
- Email: [your-email@domain.com]
- LinkedIn: [Your LinkedIn Profile]

## 📞 Support

If you have any questions or need clarification about the implementation, please feel free to reach out.

---

*This README provides a comprehensive overview of the News App implementation, demonstrating modern iOS development practices with MVVM architecture, Clean Architecture principles, and thorough testing.*