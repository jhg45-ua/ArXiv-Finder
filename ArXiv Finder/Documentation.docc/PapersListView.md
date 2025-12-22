# PapersListView

Specialized view for displaying ArXiv paper lists with search and filtering functionalities.

## Overview

``PapersListView`` is a specialized SwiftUI view that displays ArXiv paper lists with advanced search, filtering, and navigation functionalities. It forms part of the MVVM pattern as a view that communicates exclusively with ``ArXivController`` (ViewModel) to obtain data and notify user actions.

This view is designed following principles of:
- **Reusability** in multiple application contexts
- **Optimized performance** for large lists
- **Intuitive and responsive** user experience
- **Complete accessibility** for all users

## View Architecture

### 🏗️ Modular Structure

The view is composed of multiple specialized components:

```swift
/// MVVM architecture:
/// - The view only handles presentation
/// - All business logic is delegated to the ArXivController (ViewModel)
struct PapersListView: View {
    /// ViewModel that provides the data
    @ObservedObject var controller: ArXivController
    
    /// Selected paper for navigation
    @Binding var selectedPaper: ArXivPaper?
    
    /// Search text
    @State private var searchText = ""
    
    /// Active filters
    @State private var activeFilters: Set<String> = []
}
```

### 🎯 Main Responsibilities

1. **List visualization**: Displays papers in optimized list format
2. **Real-time search**: Instant filtering while user types
3. **Paper selection**: Manages selection for navigation
4. **Dynamic loading**: Implements infinite scroll for large lists
5. **UI states**: Handles loading, error and empty states

## Search Functionalities

### 🔍 Real-time Search

```swift
/// Computed property for filtered papers
private var filteredPapers: [ArXivPaper] {
    guard !searchText.isEmpty else { 
        return controller.currentPapers 
    }
    
    return controller.currentPapers.filter { paper in
        paper.title.localizedCaseInsensitiveContains(searchText) ||
        paper.authors.localizedCaseInsensitiveContains(searchText) ||
        paper.summary.localizedCaseInsensitiveContains(searchText)
    }
}

/// Integrated search bar
private var searchBar: some View {
    HStack {
        Image(systemName: "magnifyingglass")
            .foregroundColor(.secondary)
        
        TextField("Search papers, authors or keywords...", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .onSubmit {
                performSearch()
            }
        
        if !searchText.isEmpty {
            Button("Clear") {
                searchText = ""
            }
        }
    }
    .padding(.horizontal)
}
```

### 🏷️ Category Filters

```swift
/// Available category filters
private let availableCategories = [
    // Computer Science
    "cs.AI": "Artificial Intelligence",
    "cs.LG": "Machine Learning",
    "cs.CV": "Computer Vision",
    "cs.DS": "Data Structures",
    
    // Mathematics
    "math.CO": "Combinatorics",
    "math.NT": "Number Theory",
    "math.ST": "Statistics",
    
    // Physics
    "physics.gen-ph": "General Physics",
    "physics.comp-ph": "Computational Physics",
    
    // Quantitative Biology
    "q-bio.BM": "Biomolecules",
    "q-bio.NC": "Computational Neuroscience",
    
    // Quantitative Finance
    "q-fin.CP": "Computational Pricing",
    "q-fin.MF": "Mathematical Finance",
    
    // Statistics
    "stat.ML": "Machine Learning",
    "stat.AP": "Applications",
    
    // Electrical Engineering
    "eess.SP": "Signal Processing",
    "eess.IV": "Image Processing",
    
    // Economics
    "econ.EM": "Econometrics",
    "econ.TH": "Economic Theory"
]

/// Filters view
private var filtersView: some View {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack {
            ForEach(availableCategories.sorted(by: { $0.key < $1.key }), id: \.key) { category, name in
                FilterChip(
                    title: name,
                    isSelected: activeFilters.contains(category),
                    action: { toggleFilter(category) }
                )
            }
        }
        .padding(.horizontal)
    }
}

/// Toggle category filter
private func toggleFilter(_ category: String) {
    if activeFilters.contains(category) {
        activeFilters.remove(category)
    } else {
        activeFilters.insert(category)
    }
}
```

## List Structure

### 📝 Main List

```swift
/// Main article list
private var papersList: some View {
    List(filteredPapers) { paper in
        ArXivPaperRow(paper: paper)
            .onTapGesture {
                selectedPaper = paper
            }
            .contextMenu {
                contextMenuItems(for: paper)
            }
            .swipeActions(edge: .trailing) {
                swipeActions(for: paper)
            }
            .onAppear {
                loadMoreIfNeeded(paper)
            }
    }
    .listStyle(PlainListStyle())
    .refreshable {
        await refreshData()
    }
}
```

### 📱 Context Actions

```swift
/// Context menu for each article
@ViewBuilder
private func contextMenuItems(for paper: ArXivPaper) -> some View {
    Button(action: { sharePaper(paper) }) {
        Label("Share", systemImage: "square.and.arrow.up")
    }
    
    Button(action: { copyLink(paper) }) {
        Label("Copy Link", systemImage: "link")
    }
    
    Button(action: { savePaper(paper) }) {
        Label("Save", systemImage: "bookmark")
    }
    
    Divider()
    
    Button(action: { reportPaper(paper) }) {
        Label("Report", systemImage: "exclamationmark.triangle")
    }
}

/// Swipe actions
@ViewBuilder
private func swipeActions(for paper: ArXivPaper) -> some View {
    Button(action: { savePaper(paper) }) {
        Label("Save", systemImage: "bookmark")
    }
    .tint(.blue)
    
    Button(action: { sharePaper(paper) }) {
        Label("Share", systemImage: "square.and.arrow.up")
    }
    .tint(.green)
}
```

## View States

### 🔄 Loading State

```swift
/// Loading view
private var loadingView: some View {
    VStack(spacing: 20) {
        ProgressView()
            .scaleEffect(1.5)
        
        Text("Loading articles...")
            .font(.headline)
            .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemBackground))
}
```

### 📭 Empty State

```swift
/// Empty state view
private var emptyStateView: some View {
    VStack(spacing: 24) {
        Image(systemName: "doc.text.magnifyingglass")
            .font(.system(size: 64))
            .foregroundColor(.secondary)
        
        VStack(spacing: 12) {
            Text("No articles found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try adjusting your search filters or explore different categories")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        
        Button("Explore Categories") {
            showCategoryBrowser()
        }
        .buttonStyle(.borderedProminent)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
```

### ❌ Error State

```swift
/// Error view
private var errorView: some View {
    VStack(spacing: 24) {
        Image(systemName: "wifi.slash")
            .font(.system(size: 64))
            .foregroundColor(.red)
        
        VStack(spacing: 12) {
            Text("Connection Error")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Could not load articles. Check your internet connection.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        
        Button("Retry") {
            Task {
                await controller.loadLatestPapers()
            }
        }
        .buttonStyle(.borderedProminent)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
```

## Performance Optimizations

### 🚀 Lazy Loading

```swift
/// Loads more data when nearing the end of the list
private func loadMoreIfNeeded(_ paper: ArXivPaper) {
    guard let lastPaper = filteredPapers.last else { return }
    
    if paper.id == lastPaper.id {
        Task {
            await controller.loadMorePapers()
        }
    }
}

/// Infinite scroll implementation
@State private var isLoadingMore = false

private var loadMoreIndicator: some View {
    HStack {
        if isLoadingMore {
            ProgressView()
                .scaleEffect(0.8)
        }
        Text("Loading more articles...")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
}
```

### 💾 Memory Management

```swift
/// Cleans up resources when the view disappears
.onDisappear {
    searchText = ""
    activeFilters.removeAll()
}

/// Memory limits configuration
private let maxVisibleItems = 100

private var limitedPapers: [ArXivPaper] {
    Array(filteredPapers.prefix(maxVisibleItems))
}
```

## Accessibility Features

### ♿ VoiceOver Support

```swift
/// Accessibility configuration
.accessibilityElement(children: .combine)
.accessibilityLabel("ArXiv articles list")
.accessibilityHint("Tap an article to see more details")
.accessibilityAction(.escape) {
    // Escape action for navigation
}
```

### ⌨️ Keyboard Navigation

```swift
/// Keyboard navigation support
.focusable(true)
.onMoveCommand { direction in
    handleKeyboardNavigation(direction)
}

private func handleKeyboardNavigation(_ direction: MoveCommandDirection) {
    switch direction {
    case .up:
        selectPreviousPaper()
    case .down:
        selectNextPaper()
    default:
        break
    }
}
```

## Visual Customization

### 🎨 Theming

```swift
/// Theme configuration
@Environment(\.colorScheme) var colorScheme

private var listBackgroundColor: Color {
    colorScheme == .dark ? .black : .white
}

private var separatorColor: Color {
    Color(.separator)
}
```

### 📐 Adaptive Layout

```swift
/// Layout configuration for different screen sizes
@Environment(\.horizontalSizeClass) var horizontalSizeClass

private var columns: [GridItem] {
    switch horizontalSizeClass {
    case .compact:
        return [GridItem(.flexible())]
    case .regular:
        return [GridItem(.flexible()), GridItem(.flexible())]
    default:
        return [GridItem(.flexible())]
    }
}
```

## Integration with Other Views

### 🔗 Communication with MainView

```swift
/// Binding for communication with parent view
@Binding var selectedPaper: ArXivPaper?

/// Notifies selection to parent view
private func selectPaper(_ paper: ArXivPaper) {
    selectedPaper = paper
    
    // Optional: Analytics
    trackPaperSelection(paper)
}
```

### 📊 Usage Metrics

```swift
/// Usage metrics tracking
private func trackPaperSelection(_ paper: ArXivPaper) {
    // Implement analytics
    Analytics.track("paper_selected", properties: [
        "paper_id": paper.id,
        "category": paper.category,
        "search_query": searchText
    ])
}
```

## Full Usage Example

```swift
/// Full integration example
struct ExampleListView: View {
    @StateObject private var controller = ArXivController()
    @State private var selectedPaper: ArXivPaper?
    
    var body: some View {
        NavigationView {
            PapersListView(
                controller: controller,
                selectedPaper: $selectedPaper
            )
            .navigationTitle("ArXiv Articles")
            .onAppear {
                Task {
                    await controller.loadLatestPapers()
                }
            }
        }
    }
}
```

## Best Practices

### ✅ Implemented Principles

1. **Single Responsibility**: Only handles list visualization
2. **Reactivity**: Responds to data changes automatically
3. **Performance**: Optimized for large lists
4. **Accessibility**: Full support for all users

### 🔧 Advanced Configuration

```swift
/// Customizable configuration
struct PapersListConfig {
    let enableSearch: Bool = true
    let enableFilters: Bool = true
    let enableInfiniteScroll: Bool = true
    let pageSize: Int = 20
    let cacheSize: Int = 100
}
```

## Related Resources

- ``ArXivController`` - ViewModel that provides the data
- ``ArXivPaperRow`` - Individual article component
- ``MainView`` - Main view containing the list
- ``PaperDetailView`` - Detail view for selected articles
- ``SidebarView`` - Side view for category navigation 