# ArXiv Finder

A multiplatform application (iOS and macOS) for exploring and managing scientific papers from ArXiv.

## 📋 Description

ArXiv Finder allows users to search, explore, and save scientific papers from ArXiv with a modern and native interface. The application offers advanced search functionality, category-based browsing, favorites management, and local storage for offline access.

## ✨ Features

- **Multiplatform**: Native iOS and macOS apps with adaptive UI
- **Advanced Search**: Search papers by title, author, keywords, or ArXiv ID with real-time results
- **Search History**: Remember and reuse previous searches for quick access
- **Category Browsing**: Explore papers by Computer Science, Mathematics, Physics, and more
- **Favorites System**: Mark important papers for later reading with persistent storage
- **Local Storage**: Automatic paper caching for offline access using SwiftData
- **Native Interface**: Platform-optimized design (NavigationSplitView for macOS, NavigationStack for iOS)
- **Modern UI**: Clean, responsive interface with proper dark mode support

## 🛠 Technologies Used

- **SwiftUI**: Modern and declarative UI framework
- **SwiftData**: Advanced data persistence and modeling
- **ArXivKit**: Third-party library for robust ArXiv API integration
- **URLSession**: Networking with comprehensive error handling
- **Async/Await**: Modern Swift concurrency with @MainActor
- **Swift Package Manager**: Dependency management

## 📱 Architecture

The project follows the **Model-View-ViewModel (MVVM)** pattern with modern Swift best practices:

### Models
- `ArXivPaper`: SwiftData model for scientific papers with favorites support

### Views
- `MainView`: Main coordinator view with platform-specific navigation
- `SidebarView`: Sidebar navigation for macOS
- `PapersListView`: Adaptive paper list with category filtering
- `SearchResultsView`: Advanced search interface with history
- `PaperDetailView`: Detailed paper view with sharing capabilities
- `ArXivPaperRow`: Reusable paper row component
- `SettingsView`: Application configuration

### ViewModels
- `ArXivController`: Centralized business logic and state management (ViewModel)

### Services
- `ArXivService`: ArXiv API communication using ArXivKit with category support

## 📚 Documentation

For detailed information, consult the integrated Xcode documentation:

- **MVVM Architecture**: Comprehensive DocC documentation for design patterns and implementation details
- **ArXiv API Integration**: Complete ArXivKit usage documentation available in DocC
- **Search Functionality**: Advanced search capabilities including history and category filtering
- **Favorites System**: Complete favorites management documentation
- **Components**: Detailed documentation of each component available in Xcode Quick Help

To access documentation:
1. Open the project in Xcode
2. Go to `Product > Build Documentation` or press `Cmd + Shift + Control + D`
3. Explore the automatically generated documentation

## 🚀 Installation

### Requirements

- macOS 14.0+ or iOS 17.6+
- Xcode 15.0+
- Swift 5.9+

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/jhg45-ua/Arxiv-Finder.git
   cd "ArXiv Finder"
   ```

2. **Open the project**:
   ```bash
   open "ArXiv Finder.xcodeproj"
   ```

3. **Configure the project**:
   - Select your development team in project settings
   - Adjust Bundle Identifier if necessary

4. **Run the application**:
   - Select the desired simulator or device
   - Press `Cmd + R` to build and run

## 📖 Usage

### Navigation

- **iOS**: NavigationStack with bottom tab navigation for optimal mobile experience
- **macOS**: NavigationSplitView with sidebar for comprehensive desktop experience

### Paper Search

1. **Search Interface**: Use the advanced search interface to find papers by:
   - Title keywords
   - Author names
   - Abstract content
   - ArXiv ID

2. **Category Filtering**: Browse papers by scientific categories:
   - Computer Science (cs)
   - Mathematics (math)
   - Physics (physics)
   - Quantitative Biology (q-bio)
   - Quantitative Finance (q-fin)
   - Statistics (stat)
   - Electrical Engineering (eess)
   - Economics (econ)

3. **Search History**: Quickly access previous searches with the built-in history feature

### Paper Management

- **Automatic Saving**: Papers are automatically cached for offline access using SwiftData
- **Favorites**: Mark important papers with the heart icon for quick access later
- **Paper Details**: View complete abstracts, author information, and access PDF links
- **Sharing**: Share papers with other users using the system share sheet

## 🔧 Configuration

### Application Settings

- **Default Categories**: Configure your preferred scientific categories for browsing
- **Search Preferences**: Customize search behavior and result display
- **Data Management**: Configure automatic caching and storage preferences
- **Interface**: Toggle between light and dark modes (follows system preference)

## 📁 Project Structure

```
ArXiv Finder/
├── ArXiv_Finder.swift          # Main application entry point
├── Models/
│   └── ArXivPaper.swift         # SwiftData model with favorites support
├── Views/
│   ├── MainView.swift           # Main coordinator view
│   ├── SidebarView.swift        # Sidebar navigation (macOS)
│   ├── PapersListView.swift     # Adaptive paper list
│   ├── SearchResultsView.swift  # Advanced search interface
│   ├── PaperDetailView.swift    # Detailed paper view
│   ├── ArXivPaperRow.swift      # Reusable paper row component
│   └── SettingsView.swift       # Application settings
├── Controllers/
│   └── ArXivController.swift    # Business logic and state management (ViewModel)
├── Services/
│   └── ArXivService.swift       # ArXiv API service using ArXivKit
├── Assets.xcassets/             # App icons and visual resources
└── Documentation.docc/          # DocC documentation
    ├── Architecture.md
    ├── Search-Feature.md
    ├── Favourites-Feature.md
    └── API-Guide.md
```

## 🧪 Testing

The project includes comprehensive unit and UI tests:

```bash
# Run all tests
Cmd + U

# Run specific tests
Cmd + Control + U
```

### Test Structure
- **Unit Tests**: ArXiv_FinderTests.swift - Core functionality testing
- **UI Tests**: ArXiv_FinderUITests.swift - Interface and user interaction testing
- **Launch Tests**: Performance and startup testing

## 📝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow SwiftUI and Swift best practices
- Write comprehensive documentation
- Include unit tests for new features
- Ensure compatibility with both iOS and macOS

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

## 👨‍💻 Author

**Julián Hinojosa Gil**

## 🔗 Useful Links

- [ArXiv API Documentation](https://arxiv.org/help/api)
- [ArXivKit Library](https://github.com/ivicamil/ArxivKit)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)

## 📊 App Information

- **Current Version**: 1.1.0
- **Build**: 32
- **Minimum iOS**: 17.6+
- **Minimum macOS**: 14.0+
- **Bundle ID**: com.jhg.ArXiv-Finder
