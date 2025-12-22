# ArXivService

The `ArXivService` class provides a clean interface for communicating with the arXiv API using the ArxivKit library. This service encapsulates all the complexity of making HTTP requests, parsing XML responses, and handling errors.

## Overview

The service uses ArxivKit, a modern Swift library that provides:
- Type-safe arXiv API queries
- Automatic XML parsing
- Built-in error handling
- Support for all arXiv subjects and categories
- Async/await support

## Key Features

- **Multiple Category Support**: Fetch papers from different arXiv categories
- **Search Functionality**: Search papers by keywords with optional category filtering
- **Error Handling**: Comprehensive error handling with descriptive messages
- **Async/Await**: Modern Swift concurrency support
- **Type Safety**: Strongly typed responses and queries

## Methods

### Fetching Papers by Category

#### `fetchLatestPapers(count:)`
Fetches the most recent papers across multiple categories (Computer Science, Statistics, Mathematics).

```swift
let papers = try await arxivService.fetchLatestPapers(count: 10)
```

#### `fetchComputerSciencePapers(count:)`
Fetches papers from the Computer Science category.

```swift
let papers = try await arxivService.fetchComputerSciencePapers(count: 10)
```

#### `fetchMathematicsPapers(count:)`
Fetches papers from the Mathematics category.

```swift
let papers = try await arxivService.fetchMathematicsPapers(count: 10)
```

#### `fetchPhysicsPapers(count:)`
Fetches papers from the Physics category.

```swift
let papers = try await arxivService.fetchPhysicsPapers(count: 10)
```

#### `fetchQuantitativeBiologyPapers(count:)`
Fetches papers from the Quantitative Biology category.

```swift
let papers = try await arxivService.fetchQuantitativeBiologyPapers(count: 10)
```

#### `fetchQuantitativeFinancePapers(count:)`
Fetches papers from the Quantitative Finance category.

```swift
let papers = try await arxivService.fetchQuantitativeFinancePapers(count: 10)
```

#### `fetchStatisticsPapers(count:)`
Fetches papers from the Statistics category.

```swift
let papers = try await arxivService.fetchStatisticsPapers(count: 10)
```

#### `fetchElectricalEngineeringPapers(count:)`
Fetches papers from the Electrical Engineering and Systems Science category.

```swift
let papers = try await arxivService.fetchElectricalEngineeringPapers(count: 10)
```

#### `fetchEconomicsPapers(count:)`
Fetches papers from the Economics category.

```swift
let papers = try await arxivService.fetchEconomicsPapers(count: 10)
```

### Search Functionality

#### `searchPapers(query:count:category:)`
Searches for papers using keywords with optional category filtering.

```swift
// Search for papers about "machine learning"
let papers = try await arxivService.searchPapers(
    query: "machine learning", 
    count: 20
)

// Search for papers about "neural networks" in Computer Science
let papers = try await arxivService.searchPapers(
    query: "neural networks", 
    count: 20, 
    category: "cs"
)
```

### Fallback Methods

#### `fetchRecentPapers(count:)`
Alternative method for fetching recent papers when the main query doesn't work.

#### `fetchFallbackPapers(count:)`
Final backup method using a simple and reliable query.

## Error Handling

The service defines custom error types in the `ArXivError` enum:

- `invalidURL`: When the constructed URL is invalid
- `networkError(String)`: Network-related errors with descriptive messages
- `parsingError(String)`: Errors during data parsing

All errors provide localized descriptions for user-friendly error messages.

## Implementation Details

### ArxivKit Integration

The service leverages ArxivKit's powerful query system:

```swift
// Example: Creating a query for Computer Science papers
let query = subject(ComputerScience.all)
let request = query
    .itemsPerPage(count)
    .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
    .sorted(by: ArxivRequestSpecification.SortingCriterion.lastUpdateDate)

let response = try await request.fetch(using: URLSession.shared)
```

### Data Conversion

The service converts ArxivKit's `ArxivEntry` objects to the app's `ArXivPaper` model:

```swift
private func convertToArXivPaper(from entry: ArxivKit.ArxivEntry) -> ArXivPaper {
    let authorsString = entry.authors.map { $0.name }.joined(separator: ", ")
    let categoriesString = entry.categories.joined(separator: ", ")
    
    return ArXivPaper(
        id: entry.id,
        title: entry.title,
        summary: entry.summary,
        authors: authorsString,
        publishedDate: entry.submissionDate,
        updatedDate: entry.lastUpdateDate,
        pdfURL: entry.pdfURL.absoluteString,
        linkURL: entry.abstractURL.absoluteString,
        categories: categoriesString,
        isFavorite: false
    )
}
```

## Usage Example

```swift
class ArXivController: ObservableObject {
    private let arxivService = ArXivService()
    
    @Published var papers: [ArXivPaper] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadLatestPapers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            papers = try await arxivService.fetchLatestPapers(count: 20)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func searchPapers(query: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            papers = try await arxivService.searchPapers(query: query, count: 20)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
```

## Benefits of Using ArxivKit

1. **Simplified Code**: No need to manually construct URLs or parse XML
2. **Type Safety**: Compile-time checking for query parameters
3. **Better Error Handling**: Specific error types for different failure scenarios
4. **Maintained Library**: Regular updates and bug fixes from the community
5. **Performance**: Optimized XML parsing and network handling
6. **Extensibility**: Easy to add new query types and features

## Dependencies

- **ArxivKit**: Version 2.1.0 - Provides the core arXiv API functionality
- **Foundation**: For basic Swift functionality
- **SwiftUI**: For integration with the UI layer (via the controller) 