# ArXiv API Guide

Complete documentation of ArXiv API integration using ArxivKit.

## 🌐 API Overview

ArXiv Finder leverages the [ArxivKit](https://github.com/ivicamil/ArxivKit) library to interact with the ArXiv API. This provides a type-safe, Swift-native way to query scientific paper metadata without manual XML parsing or URL construction.

The API uses:
- **Protocol**: HTTPS for security
- **Format**: Atom XML (handled internally by ArxivKit)
- **Concurrency**: Swift Async/Await
- **Rate Limiting**: Handled by ArxivKit/URLSession

## 📡 ArxivKit Integration

### Service Structure

The ``ArXivService`` service encapsulates all API communication using ArxivKit's fluent interface:

```swift
/// Main service for ArXiv communication
final class ArXivService: @unchecked Sendable {
    
    /// Fetches papers by category
    func fetchPapers(for category: ArXivCategory, count: Int = 10) async throws -> [ArXivPaper] {
        let query = category.query
        let request = query
            .itemsPerPage(count)
            .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
            .sorted(by: ArxivRequestSpecification.SortingCriterion.lastUpdateDate)
        
        let response = try await request.fetch(using: URLSession.shared)
        return response.entries.map { convertToArXivPaper(from: $0) }
    }
}
```

### Search Implementation

The service implements an "Enhanced Search" strategy to improve result quality:

```swift
/// Enhanced search function that tries multiple strategies
func enhancedSearch(query: String, count: Int = 20) async throws -> [ArXivPaper] {
    // Strategy 1: Title search
    let titleQuery = term(query, in: .title)
    
    // Strategy 2: Abstract search
    let abstractQuery = term(query, in: .abstract)
    
    // Strategy 3: Author search
    let authorQuery = term(query, in: .authors)
    
    // Combine and fetch results...
}
```

## 📊 ArXiv Categories

The application maps ArXiv categories to a strongly typed enum `ArXivCategory`:

### Main Categories

- **Computer Science** (`cs.*`)
- **Mathematics** (`math.*`)
- **Physics** (`physics.*`)
- **Quantitative Biology** (`q-bio.*`)
- **Quantitative Finance** (`q-fin.*`)
- **Statistics** (`stat.*`)
- **Electrical Engineering** (`eess.*`)
- **Economics** (`econ.*`)

### Category Implementation

```swift
enum ArXivCategory: CaseIterable {
    case computerScience
    case mathematics
    // ... other cases
    
    var query: ArxivQuery {
        switch self {
        case .computerScience:
            return subject(ComputerScience.all)
        case .mathematics:
            return subject(Mathematics.all)
        // ... mapped to ArxivKit subjects
        }
    }
}
```

## 🔄 Response Processing

ArxivKit handles the XML parsing automatically, returning `ArxivEntry` objects which are then mapped to the application's domain model `ArXivPaper`.

### Model Mapping

```swift
private func convertToArXivPaper(from entry: ArxivKit.ArxivEntry) -> ArXivPaper {
    return ArXivPaper(
        id: entry.id,
        title: entry.title,
        summary: entry.summary,
        authors: entry.authors.map { $0.name }.joined(separator: ", "),
        publishedDate: entry.submissionDate,
        updatedDate: entry.lastUpdateDate,
        pdfURL: entry.pdfURL.absoluteString,
        linkURL: entry.abstractURL.absoluteString,
        categories: entry.categories.joined(separator: ", ")
    )
}
```

## 🚨 Error Handling

The application wraps network and parsing errors into a localized `ArXivError` enum:

```swift
enum ArXivError: Error, LocalizedError {
    case invalidURL
    case networkError(String)
    case parsingError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Connection error: \(message)"
        // ...
        }
    }
}
```

## 🔗 Integration with MVVM Pattern

### Data Flow

1. **View** requests data from the **ViewModel** (`ArXivController`)
2. **ViewModel** calls methods on **ArXivService**
3. **ArXivService** constructs an **ArxivKit** query
4. **ArxivKit** performs the request and parses XML
5. **ArXivService** maps results to `ArXivPaper`
6. **ViewModel** updates `@Published` properties
7. **View** updates automatically

### Integration Example

```swift
/// Full integration in the ViewModel
@MainActor
class ArXivController: ObservableObject {
    @Published var latestPapers: [ArXivPaper] = []
    
    private let service = ArXivService()
    
    func loadLatestPapers() async {
        do {
            latestPapers = try await service.fetchLatestPapers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

## 📚 Additional Resources

### Useful Links

- [Official ArXiv API Documentation](https://arxiv.org/help/api)
- [ArxivKit Repository](https://github.com/ivicamil/ArxivKit)

### Related Components

- ``ArXivService`` - Service implementation
- ``ArXivController`` - ViewModel using the API
- ``ArXivPaper`` - Domain model

---

*This documentation reflects the current implementation using ArxivKit and MVVM.*