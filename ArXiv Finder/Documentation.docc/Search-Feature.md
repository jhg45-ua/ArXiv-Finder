# Search Feature

Comprehensive search functionality for finding papers in ArXiv with advanced filtering and history.

## Overview

The search feature provides users with a powerful interface to find specific papers in ArXiv using various search criteria including title, author, keywords, and category filtering.

## 🔍 Search Capabilities

### Basic Search
- **Text Search**: Search by title, author, or abstract content
- **Category Filtering**: Filter results by scientific category
- **Real-time Results**: Instant display of search results
- **Search History**: Remember and reuse previous searches

### Advanced Search
- **Exact Phrases**: Use quotes for exact phrase matching
- **Author Search**: Search by specific author names
- **Title Search**: Search within paper titles only
- **Combined Queries**: Combine multiple search criteria

## 🏗️ Architecture

### Search Flow
```mermaid
graph LR
    A[User Input] --> B[Search Interface]
    B --> C[ArXivController]
    C --> D[ArXivService]
    D --> E[ArXiv API]
    E --> F[XML Parser]
    F --> G[Search Results]
    G --> H[Results Display]
```

### Components

#### ArXivService
```swift
/// Search papers in ArXiv using query terms
func searchPapers(query: String, count: Int = 20, category: String? = nil) async throws -> [ArXivPaper]
```

**Features:**
- Query encoding for URL safety
- Category filtering support
- Error handling and logging
- Fallback mechanisms

#### ArXivController
```swift
/// Search-related properties
@Published var searchResults: [ArXivPaper] = []
@Published var searchQuery: String = ""
@Published var searchCategory: String = ""
@Published var isSearchActive: Bool = false
@Published var isSearching: Bool = false
```

**Methods:**
- `searchPapers(query:category:)` - Perform search
- `clearSearch()` - Reset search state

#### SearchResultsView
```swift
/// Comprehensive search interface with results
struct SearchResultsView: View {
    @ObservedObject var controller: ArXivController
    @State private var searchText: String = ""
    @State private var selectedCategory: String = ""
    @State private var showAdvancedOptions: Bool = false
}
```

## 🎯 User Interface

### Search Interface
- **Input Field**: Text input with clear button
- **Category Picker**: Dropdown for category filtering
- **Advanced Options**: Expandable section with search tips
- **Search Button**: Perform search with loading state
- **Search History**: Grid of recent searches

### Results Display
- **Results Header**: Shows count and query
- **Paper List**: Standard paper rows with navigation
- **Loading State**: Progress indicator during search
- **Error Handling**: User-friendly error messages
- **Empty State**: Helpful message when no results found

## 📱 Multiplatform Support

### macOS
- **Sidebar Integration**: Search accessible from sidebar
- **Split View**: Search interface in content area
- **Keyboard Shortcuts**: Cmd+F for quick search access
- **Native Controls**: macOS-style pickers and buttons

### iOS
- **Navigation Integration**: Search within navigation stack
- **Touch Optimized**: Larger touch targets
- **Adaptive Layout**: Responsive design for different screen sizes
- **Haptic Feedback**: Tactile response for interactions

## 🔧 Implementation Details

### Search Query Construction
```swift
// Basic search
let query = "all:machine learning"

// Category filtered search
let query = "all:quantum computing+AND+cat:cs*"

// Author search
let query = "au:Smith+AND+all:neural networks"
```

### Search History Management
```swift
@AppStorage("searchHistory") private var searchHistory: [String] = []

private func addToSearchHistory(_ query: String) {
    // Remove duplicates
    searchHistory.removeAll { $0 == query }
    
    // Add to beginning
    searchHistory.insert(query, at: 0)
    
    // Limit history size
    if searchHistory.count > maxHistoryItems {
        searchHistory = Array(searchHistory.prefix(maxHistoryItems))
    }
}
```

### Error Handling
```swift
enum ArXivError: Error, LocalizedError {
    case invalidURL
    case networkError(String)
    case parsingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid ArXiv URL"
        case .networkError(let message):
            return "Connection error: \(message)"
        case .parsingError(let message):
            return "Data processing error: \(message)"
        }
    }
}
```

## 🎨 User Experience Features

### Search Tips
- **Exact Phrases**: Use quotes for precise matching
- **Author Search**: `au:Smith` for author-specific search
- **Title Search**: `ti:quantum` for title-only search
- **Category Combination**: `cs.AI AND "deep learning"`

### Visual Feedback
- **Loading States**: Progress indicators during search
- **Result Counts**: Clear indication of found papers
- **Error Messages**: Helpful error descriptions
- **Empty States**: Guidance when no results found

### Accessibility
- **VoiceOver Support**: Full screen reader compatibility
- **Keyboard Navigation**: Complete keyboard accessibility
- **High Contrast**: Support for accessibility settings
- **Dynamic Type**: Scalable text sizes

## 🚀 Performance Optimizations

### Search Efficiency
- **Debounced Input**: Prevent excessive API calls
- **Cached Results**: Store recent search results
- **Lazy Loading**: Load results incrementally
- **Background Processing**: Non-blocking search operations

### Memory Management
- **Result Limiting**: Configurable result count
- **History Cleanup**: Automatic history size management
- **Image Caching**: Efficient image loading
- **Memory Monitoring**: Track memory usage

## 📊 Search Analytics

### Usage Tracking
- **Search Frequency**: Track how often search is used
- **Popular Queries**: Identify common search terms
- **Category Preferences**: Monitor category filter usage
- **Success Rates**: Measure search result relevance

### Performance Metrics
- **Search Speed**: Response time measurements
- **Result Quality**: User satisfaction metrics
- **Error Rates**: Track and analyze search failures
- **User Behavior**: Search pattern analysis

## 🔮 Future Enhancements

### Planned Features
- **Advanced Filters**: Date range, citation count
- **Saved Searches**: Persistent search configurations
- **Search Suggestions**: AI-powered query suggestions
- **Export Results**: Save search results to files

### Technical Improvements
- **Search Indexing**: Local search index for offline use
- **Fuzzy Matching**: Handle typos and variations
- **Semantic Search**: Understand search intent
- **Personalization**: Learn from user search patterns

## 📚 Related Documentation

### Components
- ``ArXivService`` - API communication service
- ``ArXivController`` - Search state management
- ``SearchResultsView`` - Search interface implementation
- ``ArXivPaper`` - Paper data model

### Guides
- <doc:API-Guide> - ArXiv API integration
- <doc:Architecture> - MVVM architecture overview
- <doc:ArXivController> - ViewModel documentation

---

*The search feature provides a comprehensive and user-friendly way to discover relevant papers in ArXiv, with advanced filtering capabilities and a smooth user experience across all platforms.* 