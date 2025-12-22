# ArXiv Finder

A modern iOS application for browsing and searching arXiv papers, built with SwiftUI and powered by the ArxivKit library.

## Overview

ArXiv Finder provides a clean, intuitive interface for exploring academic papers from arXiv, the popular repository for electronic preprints. The app leverages ArxivKit, a modern Swift library, to provide type-safe access to the arXiv API with automatic XML parsing and comprehensive error handling.

## Key Features

### 📚 **Paper Browsing**
- Browse papers by category (Computer Science, Mathematics, Physics, etc.)
- View latest papers across multiple disciplines
- Clean, readable paper listings with titles, authors, and abstracts

### 🔍 **Advanced Search**
- Search papers by keywords, titles, or authors
- Filter results by specific arXiv categories
- Real-time search results with comprehensive metadata

### 💾 **Favorites System**
- Save interesting papers to your favorites
- Persistent storage across app sessions
- Quick access to your saved papers

### 📱 **Modern UI**
- Native iOS design with SwiftUI
- Dark mode support
- Responsive layout for different screen sizes
- Intuitive navigation with sidebar

### ⚡ **Performance**
- Async/await for smooth user experience
- Efficient data loading and caching
- Optimized network requests

## Architecture

### **MVVM Pattern**
The app follows the Model-View-ViewModel architecture:

- **Models**: `ArXivPaper` - Represents individual papers
- **Views**: SwiftUI views for the user interface
- **ViewModels**: `ArXivController` - Manages data and business logic

### **Service Layer**
- **ArXivService**: Uses ArxivKit to communicate with the arXiv API
- **Data Persistence**: Local storage for favorites

### **Dependencies**
- **ArxivKit 2.1.0**: Modern Swift library for arXiv API access
- **SwiftUI**: Native iOS UI framework
- **Foundation**: Core Swift functionality

## Core Components

### **ArXivService**
The service layer that handles all arXiv API communication using ArxivKit:

```swift
// Example: Fetching Computer Science papers
let papers = try await arxivService.fetchComputerSciencePapers(count: 20)

// Example: Searching for papers
let results = try await arxivService.searchPapers(
    query: "machine learning", 
    count: 20, 
    category: "cs"
)
```

**Benefits of ArxivKit Integration:**
- Type-safe queries with compile-time checking
- Automatic XML parsing and error handling
- Support for all arXiv subjects and categories
- Modern async/await support
- Regular updates and community maintenance

### **ArXivController**
The main view model that manages the app's state and coordinates between the UI and service layer:

```swift
class ArXivController: ObservableObject {
    @Published var papers: [ArXivPaper] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadLatestPapers() async {
        // Implementation using ArxivService
    }
}
```

### **Views**
- **MainView**: Main app interface with sidebar navigation
- **PapersListView**: Displays lists of papers
- **PaperDetailView**: Shows detailed paper information
- **SearchResultsView**: Displays search results
- **SettingsView**: App configuration and preferences

## Data Model

### **ArXivPaper**
Represents a single arXiv paper with all relevant metadata:

```swift
struct ArXivPaper: Identifiable, Codable {
    let id: String
    let title: String
    let summary: String
    let authors: String
    let publishedDate: Date
    let updatedDate: Date
    let pdfURL: String
    let linkURL: String
    let categories: String
    var isFavorite: Bool
}
```

## Supported Categories

The app supports all major arXiv categories:

- **Computer Science** (`cs.*`)
- **Mathematics** (`math.*`)
- **Physics** (`physics.*`)
- **Quantitative Biology** (`q-bio.*`)
- **Quantitative Finance** (`q-fin.*`)
- **Statistics** (`stat.*`)
- **Electrical Engineering** (`eess.*`)
- **Economics** (`econ.*`)

## Error Handling

The app provides comprehensive error handling:

- **Network Errors**: Connection issues and timeouts
- **API Errors**: Invalid responses from arXiv
- **Parsing Errors**: Data processing issues
- **User-Friendly Messages**: Clear error descriptions for users

## Performance Optimizations

### **Async/Await**
All network operations use modern Swift concurrency:

```swift
func loadPapers() async {
    isLoading = true
    do {
        papers = try await arxivService.fetchLatestPapers()
    } catch {
        errorMessage = error.localizedDescription
    }
    isLoading = false
}
```

### **Efficient Data Loading**
- Lazy loading of paper lists
- Optimized network requests
- Smart caching strategies

## User Experience

### **Intuitive Navigation**
- Sidebar for quick category access
- Search functionality prominently displayed
- Favorites easily accessible

### **Responsive Design**
- Adapts to different screen sizes
- Supports both iPhone and iPad
- Dark mode compatibility

### **Accessibility**
- VoiceOver support
- Dynamic Type compatibility
- High contrast mode support

## Development

### **Requirements**
- iOS 17.6+
- Xcode 15.0+
- Swift 5.9+

### **Setup**
1. Clone the repository
2. Open `ArXiv Finder.xcodeproj` in Xcode
3. Build and run on simulator or device

### **Dependencies**
The project uses Swift Package Manager for dependencies:
- **ArxivKit**: `https://github.com/ivicamil/ArxivKit.git`

## Future Enhancements

### **Planned Features**
- Offline paper caching
- PDF download and viewing
- Citation export
- Paper recommendations
- Social sharing features

### **Technical Improvements**
- Enhanced search filters
- Advanced sorting options
- Performance optimizations
- Additional arXiv categories

## Contributing

The app is designed with extensibility in mind. Key areas for contribution:

- **UI/UX Improvements**: Enhanced user interface and experience
- **Feature Additions**: New functionality and capabilities
- **Performance**: Optimizations and efficiency improvements
- **Testing**: Unit tests and UI tests
- **Documentation**: Code documentation and user guides

## License

This project is open source and available under the MIT License.

## Acknowledgments

- **ArxivKit**: The excellent Swift library that powers the arXiv API integration
- **arXiv**: For providing the comprehensive paper repository
- **SwiftUI**: Apple's modern UI framework
- **Open Source Community**: For inspiration and best practices 