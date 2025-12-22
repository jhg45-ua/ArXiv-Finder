# Favorites Functionality

Complete documentation of the favorites functionality in ArXiv Finder.

## 🌟 Overview

The favorites functionality allows users to mark papers of interest for later reading. This feature provides:

- **Persistent Storage**: Favorites are saved using SwiftData and persist between app sessions
- **Quick Access**: Dedicated "Favorites" section in navigation
- **Simple Management**: Toggle favorites with a tap from list and detail views
- **Visual Feedback**: Heart icons indicate favorite status

## 📱 User Interface

### Navigation

#### macOS
- **Sidebar**: "Favorites" button in the left sidebar
- **Paper List**: Heart icon in each paper row
- **Detail View**: Heart icon in the toolbar

#### iOS
- **Tab Navigation**: "Favorites" in the bottom navigation menu
- **Paper List**: Heart icon in each paper row
- **Detail View**: Heart icon in the navigation bar

### Visual States

#### Favorites Button States
- **Empty Heart (♡)**: The paper is not marked as favorite
- **Filled Heart (♥)**: The paper is marked as favorite
- **Color**: System accent color when marked as favorite

## 🏗️ Architecture

### Model Layer

#### ArXivPaper Properties
```swift
/// Indicates if the paper is marked as favorite
var isFavorite: Bool = false

/// Date when marked as favorite (only relevant if isFavorite is true)
var favoritedDate: Date?

/// Marks or unmarks the paper as favorite
func setFavorite(_ favorite: Bool) {
    self.isFavorite = favorite
    self.favoritedDate = favorite ? Date() : nil
}
```

### Controller Layer

#### ArXivController Methods
```swift
/// Loads all favorite papers from the database
func loadFavoritePapers() async

/// Toggles the favorite status of a paper
func toggleFavorite(for paper: ArXivPaper)

/// Updates a paper in all category lists
func updatePaperInAllCategories(_ paper: ArXivPaper)
```

### View Layer

#### PaperDetailView
- Shows the favorites button in the toolbar/navigation
- Calls `controller.toggleFavorite(for: paper)` when tapped

#### PapersListView
- Shows the favorites button in each paper row
- Includes "Favorites" in the navigation menu (iOS)

#### ArXivPaperRow
- Shows heart icon reflecting favorite status
- Handles quick favorite changes

#### SidebarView (macOS)
- Shows the "Favorites" button in the sidebar
- Calls `onFavoritesSelected` when tapped

## 💾 Data Persistence

### SwiftData Integration

The favorites functionality uses SwiftData for persistent storage:

```swift
/// ArXivPaper model with SwiftData annotation
@Model
final class ArXivPaper: @unchecked Sendable {
    // ... other properties
    
    /// Indicates if the paper is marked as favorite
    var isFavorite: Bool = false
    
    /// Date when marked as favorite
    var favoritedDate: Date?
}
```

### Storage Implementation

#### Load Favorites
```swift
func loadFavoritePapers() async {
    if let modelContext = modelContext {
        // Load from SwiftData
        let descriptor = FetchDescriptor<ArXivPaper>(
            predicate: #Predicate<ArXivPaper> { $0.isFavorite == true }
        )
        let favoriteResults = try modelContext.fetch(descriptor)
        favoritePapers = favoriteResults.sorted { 
            $0.favoritedDate ?? Date.distantPast > $1.favoritedDate ?? Date.distantPast 
        }
    }
}
```

#### Save Favorites
```swift
func toggleFavorite(for paper: ArXivPaper) {
    // Update article state
    paper.setFavorite(!paper.isFavorite)
    
    // Save in SwiftData
    if let modelContext = modelContext {
        try modelContext.save()
    }
    
    // Update local lists
    updateFavoritesList()
}
```

## 🔄 Data Flow

### Add to Favorites
1. The user taps the heart icon
2. `toggleFavorite(for:)` is called
3. The article's `isFavorite` property is updated
4. Changes are saved in SwiftData
5. The local favorites list is updated
6. The UI reflects the change

### Remove from Favorites
1. The user taps the filled heart icon
2. `toggleFavorite(for:)` is called
3. The article's `isFavorite` property is set to false
4. Changes are saved in SwiftData
5. The article is removed from the favorites list
6. The UI reflects the change

### Load Favorites
1. The user navigates to the "Favorites" section
2. `loadFavoritePapers()` is called
3. The SwiftData fetch descriptor retrieves favorite articles
4. Articles are sorted by `favoritedDate` (most recent first)
5. The UI displays the favorite articles

## 🎨 UI Components

### Favorites Button

#### Implementation
```swift
Button(action: {
    controller.toggleFavorite(for: paper)
}) {
    Image(systemName: paper.isFavorite ? "heart.fill" : "heart")
        .foregroundColor(paper.isFavorite ? .red : .primary)
}
```

#### Visual States
- **Not Favorite**: `heart` icon in primary color
- **Favorite**: `heart.fill` icon in red
- **Animation**: Smooth transition between states

### Integration in Article Row

Each article row includes:
- Article title and metadata
- Favorites button (heart icon)
- Proper spacing and alignment

### Integration in Navigation

#### macOS Sidebar
- "Favorites" button in the category list
- Consistent with other category buttons
- Shows selected state when active

#### iOS Tab Navigation
- "Favorites" in the bottom navigation menu
- Proper integration with the tab bar
- Badge support (future improvement)

## 📊 Performance Considerations

### Memory Management
- Favorites are loaded on demand
- SwiftData handles efficient queries
- No unnecessary data retention

### Database Optimization
- Indexed queries for the `isFavorite` property
- Efficient fetch descriptors
- Proper use of predicates

### UI Responsiveness
- Immediate feedback in the UI
- Asynchronous data operations
- Smooth animations

## 🧪 Testing

### Unit Tests (Future)
- Test favorite state changes
- Test SwiftData persistence
- Test UI state updates

### Integration Tests (Future)
- Test full favorites flow
- Test data persistence across app sessions
- Test UI integration

## 🔮 Future Improvements

### Potential Features
- **Favorite Collections**: Organize favorites into custom collections
- **Export Favorites**: Export favorite articles as bibliography
- **Favorites Sync**: Sync favorites across devices
- **Favorite Notes**: Add personal notes to favorite articles
- **Favorites Search**: Search within favorite articles
- **Favorites Statistics**: Show favorite counts and trends

### Technical Improvements
- **Batch Operations**: Bulk favorite/unfavorite operations
- **Offline Support**: Better offline favorites management
- **Performance**: Optimize for large favorites lists
- **Accessibility**: Enhanced accessibility features

## 🔗 Related Documentation

- [ArXivController](ArXivController.md) - Controller implementation details
- [ArXivPaper](ArXivPaper.md) - Data model documentation
- [Architecture](Architecture.md) - General app architecture
- [MainView](MainView.md) - Main view implementation
- [PapersListView](PapersListView.md) - List view implementation 