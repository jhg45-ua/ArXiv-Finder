# MVVM Architecture

The Model-View-ViewModel architecture implemented in ArXiv Finder.

## 🏗️ Architecture Overview

ArXiv Finder implements a modern **Model-View-ViewModel (MVVM)** architecture adapted for SwiftUI, combining the benefits of clear separation of concerns with SwiftUI's native reactivity.

This architecture provides:
- **Clear separation of responsibilities**
- **Maintainable and scalable code**
- **Improved testability**
- **Component reusability**
- **Multiplatform adaptation**

## 📐 Architectural Principles

### 1. 🎯 Separation of Responsibilities

Each layer has specific and well-defined responsibilities:

- **📊 Models**: Data management and domain logic
- **🖥️ Views**: Presentation and user interaction
- **🎛️ ViewModels (Controllers)**: Coordination and state management
- **🔌 Services**: External communication and utilities

### 2. 🔄 Reactive Programming

- Use of `@Published` for automatic notifications
- `@ObservedObject` and `@StateObject` for reactive binding
- Unidirectional data flow
- Automatic UI updates

### 3. 💉 Dependency Injection

- Injection through SwiftUI environment
- Shared model containers
- Services as singletons when appropriate

## 📁 Project Structure

```
ArXiv Finder/
├── Models/                    # 📊 Data models
│   └── ArXivPaper.swift      # Main paper model
├── Views/                     # 🖥️ Interface views
│   ├── MainView.swift        # Main application view
│   ├── ArXivPaperRow.swift   # Individual row view
│   ├── SidebarView.swift     # Sidebar view (macOS)
│   ├── PapersListView.swift  # Paper list view
│   ├── PaperDetailView.swift # Detailed paper view
│   └── SettingsView.swift    # Settings view
├── Controllers/               # 🎛️ ViewModels
│   └── ArXivController.swift # Main view model
├── Services/                  # 🔌 Auxiliary services
│   └── ArXivService.swift    # API service
└── ArXiv_AppApp.swift        # Entry point
```

## 🏗️ Architecture Components

### 📊 Model (Models)

**Location:** `Models/`

Models encapsulate data and domain logic:

```swift
/// Main model representing an ArXiv paper
@Model
final class ArXivPaper: @unchecked Sendable {
    var id: String
    var title: String
    var summary: String
    var authors: String
    var publishedDate: Date
    var category: String
    var link: String
    
    // Domain logic
    func isRecentlyPublished() -> Bool {
        Date().timeIntervalSince(publishedDate) < 7 * 24 * 3600
    }
}
```

**Responsibilities:**
- ✅ Data structure
- ✅ Data validation
- ✅ SwiftData persistence
- ✅ Specific domain logic

### 🖥️ View (Views)

**Location:** `Views/`

Views are exclusively responsible for presentation:

```swift
/// Main view that coordinates the interface
struct MainView: View {
    @StateObject private var controller = ArXivController()
    
    var body: some View {
        NavigationSplitView {
            SidebarView(controller: controller)
        } content: {
            PapersListView(controller: controller)
        } detail: {
            PaperDetailView(paper: selectedPaper)
        }
    }
}
```

**Responsibilities:**
- ✅ Data presentation
- ✅ User interaction
- ✅ Multiplatform adaptation
- ✅ Reactive binding with view models

### 🎛️ ViewModel (Controllers)

**Location:** `Controllers/`

ViewModels (implemented as Controllers in this project) coordinate business logic and state:

```swift
/// Main controller managing state and logic
@MainActor
final class ArXivController: ObservableObject {
    @Published var latestPapers: [ArXivPaper] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let arXivService = ArXivService()
    
    func loadLatestPapers() async {
        isLoading = true
        do {
            latestPapers = try await arXivService.fetchLatestPapers()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
```

**Responsibilities:**
- ✅ Application state management
- ✅ Coordination between models and views
- ✅ Business logic
- ✅ Error handling
- ✅ Service communication

### 🔌 Services (Services)

**Location:** `Services/`

Services handle external operations and utilities:

```swift
/// Service for communication with the ArXiv API
final class ArXivService: @unchecked Sendable {
    private let baseURL = "https://export.arxiv.org/api/query"
    
    func fetchLatestPapers() async throws -> [ArXivPaper] {
        // API communication logic using ArxivKit
        let data = try await performRequest()
        return try parse(data)
    }
}
```

**Responsibilities:**
- ✅ Communication with external APIs
- ✅ Data processing
- ✅ Shared utilities
- ✅ Network error handling

## 🔄 Data Flow in MVVM

```mermaid
graph TB
    A[👤 User] -->|Interaction| B[🖥️ View]
    B -->|Notifies action| C[🎛️ ViewModel]
    C -->|Requests data| D[🔌 Service]
    D -->|HTTP Request| E[🌐 ArXiv API]
    E -->|XML Response| F[🔄 ArxivKit]
    F -->|Processed data| G[📊 Model]
    G -->|@Published| H[🎛️ ViewModel]
    H -->|Updated state| I[🖥️ View]
    I -->|UI updated| A
```

### Flow Steps:

1. **👤 User interacts** with the View (tap, search, etc.)
2. **🖥️ View notifies** the ViewModel about the action
3. **🎛️ ViewModel processes** the business logic
4. **🔌 ViewModel uses** Services to obtain data
5. **🌐 Services make** requests to external APIs
6. **📊 Models are updated** with new data
7. **🔄 ViewModel publishes** changes via `@Published`
8. **🖥️ View updates** automatically

## 🎯 Advantages of this Architecture

### ✅ Maintainability

```swift
// Easy to modify each component independently
// Change UI without affecting business logic
struct NewPaperView: View {
    @ObservedObject var controller: ArXivController
    // New interface using the same controller
}
```

### ✅ Testability

```swift
// ViewModels can be tested independently
class ArXivControllerTests: XCTestCase {
    func testLoadLatestPapers() async {
        let mockService = MockArXivService()
        let controller = ArXivController(service: mockService)
        
        await controller.loadLatestPapers()
        
        XCTAssertFalse(controller.isLoading)
        XCTAssertEqual(controller.latestPapers.count, 10)
    }
}
```

### ✅ Scalability

```swift
// Add new functionalities without modifying existing code
extension ArXivController {
    func loadFavoritePapers() async {
        // New functionality
    }
}
```

### ✅ Reusability

```swift
// Reusable components in different contexts
struct SearchView: View {
    @ObservedObject var controller: ArXivController
    
    var body: some View {
        PapersListView(controller: controller) // Reuses existing view
    }
}
```

## 📱 Multiplatform Adaptation

### iOS Design Pattern

```swift
#if os(iOS)
struct iOSMainView: View {
    @StateObject private var controller = ArXivController()
    
    var body: some View {
        NavigationStack {
            PapersListView(controller: controller)
                .navigationTitle("ArXiv Papers")
                .navigationBarTitleDisplayMode(.large)
        }
    }
}
#endif
```

**iOS Features:**
- 📱 NavigationStack for hierarchical navigation
- 📄 Sheet/Modal for detail presentation
- 🔧 Toolbar with contextual actions
- 👆 Touch-optimized elements

### macOS Design Pattern

```swift
#if os(macOS)
struct macOSMainView: View {
    @StateObject private var controller = ArXivController()
    
    var body: some View {
        NavigationSplitView {
            SidebarView(controller: controller)
        } content: {
            PapersListView(controller: controller)
        } detail: {
            PaperDetailView(paper: selectedPaper)
        }
    }
}
#endif
```

**macOS Features:**
- 🖥️ NavigationSplitView for three columns
- 📋 Sidebar for main navigation
- 🪟 Native window management
- ⌨️ Keyboard shortcuts
- 📂 Menu bar integration

## 🚀 Implemented Design Patterns

### 1. 🎯 Observer Pattern

```swift
// The ViewModel automatically notifies changes
@MainActor
class ArXivController: ObservableObject {
    @Published var papers: [ArXivPaper] = [] // Automatic notification
    
    func updatePapers() {
        // Automatic change triggers notification
        papers = newPapers
    }
}
```

### 2. 🏭 Factory Pattern

```swift
// Factory to create services according to context
struct ServiceFactory {
    static func createArXivService() -> ArXivService {
        #if DEBUG
        return MockArXivService()
        #else
        return ArXivService()
        #endif
    }
}
```

### 3. 🔄 Command Pattern

```swift
// Commands for asynchronous operations
enum ArXivCommand {
    case loadLatest
    case search(String)
    case loadCategory(String)
}

extension ArXivController {
    func execute(_ command: ArXivCommand) async {
        switch command {
        case .loadLatest:
            await loadLatestPapers()
        case .search(let query):
            await searchPapers(query: query)
        case .loadCategory(let category):
            await loadPapersByCategory(category)
        }
    }
}
```

## 🔧 Best Practices Implemented

### 1. ✅ Single Responsibility

```swift
// Each class has a specific responsibility
class ArXivService {
    // Only handles API communication
}

class ArXivController {
    // Only coordinates business logic and state
}

struct PapersListView {
    // Only presents data
}
```

### 2. ✅ Dependency Inversion

```swift
// ViewModel depends on abstraction, not implementation
protocol ArXivServiceProtocol {
    func fetchLatestPapers() async throws -> [ArXivPaper]
}

class ArXivController {
    private let service: ArXivServiceProtocol
    
    init(service: ArXivServiceProtocol = ArXivService()) {
        self.service = service
    }
}
```

### 3. ✅ Immutability

```swift
// Immutable structures for models
struct ArXivPaper {
    let id: String
    let title: String
    let summary: String
    // Immutable properties
}
```

## 📊 Quality Metrics

### 🏗️ Low Coupling

- **Views** do not know service implementation
- **ViewModels** do not depend on UI details
- **Services** are independent of business logic

### 🎯 High Cohesion

- Each component has related responsibilities
- Features grouped logically
- Clear and specific interfaces

### 🔄 Flexibility

- Easy to swap implementations
- Localized modifications
- Extensibility without breaking existing code

## 🚀 Next Architectural Steps

### 1. 🧪 Advanced Testing

```swift
// Implement integration tests
class IntegrationTests: XCTestCase {
    func testFullWorkflow() async {
        // Full MVVM flow test
    }
}
```

### 2. 💾 Improved Persistence

```swift
// Implement repository pattern
protocol ArXivRepository {
    func save(_ papers: [ArXivPaper]) async throws
    func fetch() async throws -> [ArXivPaper]
}
```

### 3. 🔄 State Management

```swift
// Consider implementing Redux pattern
struct AppState {
    var papers: [ArXivPaper] = []
    var isLoading: Bool = false
    var currentCategory: String = "all"
}
```

### 4. 🎨 Design System

```swift
// Implement reusable design system
struct ArXivDesignSystem {
    static let colors = ArXivColors()
    static let typography = ArXivTypography()
    static let spacing = ArXivSpacing()
}
```

## 📚 Related Resources

### 🔗 Main Components

- ``ArXivPaper`` - Fundamental data model
- ``ArXivController`` - Main ViewModel
- ``ArXivService`` - Communication service
- ``MainView`` - Main application view

### 📖 Additional Documentation

- <doc:API-Guide> - API integration guide
- <doc:ArXivService> - Service documentation
- <doc:ArXivController> - ViewModel documentation

---

*This MVVM architecture provides a solid foundation for the future growth and maintenance of ArXiv Finder, adapting to changing needs while maintaining code clarity and simplicity.*