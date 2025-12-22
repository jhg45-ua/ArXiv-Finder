# ArXivPaper

The fundamental data model representing an ArXiv academic paper.

## Overview

``ArXivPaper`` is the main data model class that represents a scientific paper from the ArXiv repository. It uses SwiftData for local persistence and provides a complete structure for storing all relevant metadata of an academic paper.

This class is designed to be:
- **Thread-safe** through `@unchecked Sendable`
- **Persistent** using SwiftData with `@Model`
- **Efficient** with properties optimized for search and display

## Data Structure

### 🔑 Main Properties

The ``ArXivPaper`` model includes the following essential properties:

```swift
/// Unique identifier of the paper in ArXiv (e.g.: "2023.12345v1")
var id: String

/// Complete title of the scientific paper
var title: String

/// Abstract or summary of the paper
var summary: String

/// List of paper authors, comma-separated
var authors: String
```

### 📅 Temporal Metadata

```swift
/// Publication date of the paper
var publishedDate: Date

/// Last update date of the paper (if available)
var updatedDate: Date?
```

### 🏷️ Categorization and Links

```swift
/// Main category of the paper (e.g.: "cs.AI", "math.CO")
var category: String

/// Direct URL to the paper on ArXiv
var link: String
```

## Key Functionalities

### 🔍 Search and Filtering

The model is optimized for efficient searches:

- **Title search**: Using optimized indexes in SwiftData
- **Category filtering**: Automatic grouping by academic disciplines
- **Temporal sorting**: Support for sorting by publication or update date

### 💾 Local Persistence

``ArXivPaper`` uses SwiftData for:

- **Offline storage**: Papers are saved locally for offline access
- **Synchronization**: Automatic updates with the latest ArXiv data
- **Performance optimization**: Lazy loading of papers for large lists

### 🔄 MVVM Integration

The model integrates seamlessly with the MVVM pattern:

- **Model**: ``ArXivPaper`` represents the data and business logic
- **View**: SwiftUI views display the data from the model
- **ViewModel**: ``ArXivController`` handles CRUD operations and state management

## Usage Example

### Creating a Paper

```swift
let paper = ArXivPaper(
    id: "2023.12345v1",
    title: "Advances in Machine Learning",
    summary: "This paper presents new approaches to ML...",
    authors: "John Doe, Jane Smith",
    publishedDate: Date(),
    updatedDate: nil,
    category: "cs.AI",
    link: "https://arxiv.org/abs/2023.12345"
)
```

### Search and Filtering

```swift
// Filter papers by category
let aiPapers = papers.filter { $0.category.hasPrefix("cs.AI") }

// Search by title
let searchResults = papers.filter { 
    $0.title.localizedCaseInsensitiveContains("machine learning") 
}

// Sort by publication date
let sortedPapers = papers.sorted { $0.publishedDate > $1.publishedDate }
```

## Best Practices

### 🛡️ Data Validation

```swift
// Validate ArXiv ID
func isValidArXivID(_ id: String) -> Bool {
    let pattern = #"^\d{4}\.\d{4,5}v\d+$"#
    return id.range(of: pattern, options: .regularExpression) != nil
}
```

### 🎯 Performance Optimization

- **Lazy Loading**: Only loads data necessary for the current view
- **Indexes**: Uses SwiftData indexes for fast searches
- **Cache**: Implements in-memory cache for frequently accessed papers

## Relationship with Other Components

### 🔗 Interaction with ArXivService

``ArXivService`` creates ``ArXivPaper`` instances from XML data:

```swift
// Service parses XML and creates ArXivPaper objects
let papers = try await ArXivService().fetchLatestPapers(count: 20)
```

### 🎛️ Management by ArXivController

``ArXivController`` (ViewModel) handles ``ArXivPaper`` collections:

```swift
// ViewModel organizes papers by categories
@Published var latestPapers: [ArXivPaper] = []
@Published var searchResults: [ArXivPaper] = []
```

### 🖥️ Visualization in Views

SwiftUI views use ``ArXivPaper`` to display information:

```swift
// List view displaying papers
ForEach(papers) { paper in
    ArXivPaperRow(paper: paper)
}
```

## Design Considerations

### 🏗️ Thread-Safe Architecture

The class uses `@unchecked Sendable` to allow usage in concurrent contexts, ensuring that network and UI operations do not block the main thread.

### 📱 Multiplatform Compatibility

The model is designed to work on both iOS and macOS, automatically adapting to the specific capabilities of each platform.

### 🔄 Extensibility

The structure allows for easily adding new properties without breaking existing compatibility:

```swift
// Future extensions could include:
var citations: Int?
var downloadCount: Int?
var tags: [String]?
```

## Related Resources

- ``ArXivController`` - Controller handling business logic
- ``ArXivService`` - Service for API communication
- ``ArXivPaperRow`` - View to display an individual paper
- ``PaperDetailView`` - Detailed view of a paper 