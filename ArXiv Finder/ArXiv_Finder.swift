//
//  ArXiv_Finder.swift
//  ArXiv Finder
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI
import SwiftData

/**
 * ARXIV FINDER APPLICATION ARCHITECTURE
 * =====================================
 * 
 * This application follows the Model-View-ViewModel (MVVM) pattern:
 * 
 * MODELS (Models):
 * - ArXivPaper: Data model for scientific papers with SwiftData
 * 
 * VIEWS (Views):
 * - MainView: Main view that coordinates navigation
 * - SidebarView: Sidebar for macOS
 * - PapersListView: Paper list with multiplatform adaptations
 * - ArXivPaperRow: Individual paper row
 * - PaperDetailView: Complete detail of a paper
 * 
 * VIEWMODELS (Controllers):
 * - ArXivController: Business logic and state management
 * 
 * SERVICES (Services):
 * - ArXivService: Communication with the ArXiv API
 * 
 * TECHNICAL FEATURES:
 * - Multiplatform: iOS and macOS with adaptive UI
 * - Persistence: SwiftData for local storage
 * - Networking: URLSession with robust error handling
 * - UI: SwiftUI with NavigationStack (iOS) and NavigationSplitView (macOS)
 * - Concurrency: async/await with @MainActor for UI updates
 */

/// Main entry point of the ArXiv Finder application
/// Configures the application, data persistence and platform-specific UI
/// 
/// Responsibilities:
/// - SwiftData container configuration for persistence
/// - Platform-specific window structure definition
/// - Data model injection into SwiftUI environment
/// - Specific window configuration (macOS: size, style; iOS: basic group)
@main
struct ArXiv_Finder: App {
    /// Shared model container that manages application persistence
    /// Configured with SwiftData to handle local storage of ArXiv papers
    var sharedModelContainer: ModelContainer = {
        // Define the data schema that includes all application models
        let schema = Schema([
            ArXivPaper.self, // Model for ArXiv papers
        ])
        
        // Configure the model to use persistent storage (not in memory)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            // Try to create the model container with the specified configuration
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("❌ SwiftData Error: \(error)")
            
            // If the error is related to migration issues, try to delete the store and recreate
            if error.localizedDescription.contains("migration") || 
               error.localizedDescription.contains("constraint violation") ||
               error.localizedDescription.contains("loadIssueModelContainer") {
                
                print("🔄 Attempting to recover from SwiftData migration error...")
                
                // Try to delete the existing store files
                let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
                try? FileManager.default.removeItem(at: storeURL)
                try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("shm"))
                try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("wal"))
                
                print("🗑️ Deleted existing store files")
                
                // Try to create a new container
                do {
                    let newContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
                    print("✅ Successfully created new ModelContainer after recovery")
                    return newContainer
                } catch {
                    print("❌ Failed to create new container after recovery: \(error)")
                    fatalError("Could not create ModelContainer even after recovery attempt: \(error)")
                }
            }
            
            // For other errors, terminate the application
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    /// Defines the main structure of the application user interface
    /// Uses platform-specific configurations for each platform (iOS/macOS)
    var body: some Scene {
        #if os(macOS)
        // macOS-specific configuration with resizable window
        WindowGroup {
            MainView()
                .frame(minWidth: 1500, minHeight: 700)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 1500, height: 700)
        // Inject the shared model container into the SwiftUI environment
        // This allows all views to access persistent data
        .modelContainer(sharedModelContainer)
        
        // Additional configuration for macOS
        Settings {
            SettingsView()
        }
        #else
        // iOS-specific configuration
        WindowGroup {
            MainView()
        }
        // Inject the shared model container into the SwiftUI environment
        // This allows all views to access persistent data
        .modelContainer(sharedModelContainer)
        #endif
    }
} 