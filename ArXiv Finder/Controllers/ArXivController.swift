//
//  ArXivController.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import Foundation
import SwiftUI
import SwiftData
import UserNotifications

/// Controller that handles the business logic of the ArXiv Finder application
/// Acts as intermediary between models (data) and views (UI)
@MainActor
final class ArXivController: ObservableObject {
    
    // MARK: - Properties
    /// Model context for SwiftData
    var modelContext: ModelContext?
    
    // MARK: - Published Properties
    /// Papers from the "Latest" category
    @Published var latestPapers: [ArXivPaper] = []
    
    /// Computer Science papers
    @Published var csPapers: [ArXivPaper] = []
    
    /// Mathematics papers
    @Published var mathPapers: [ArXivPaper] = []
    
    /// Physics papers
    @Published var physicsPapers: [ArXivPaper] = []
    
    /// Quantitative Biology papers
    @Published var quantitativeBiologyPapers: [ArXivPaper] = []
    
    /// Quantitative Finance papers
    @Published var quantitativeFinancePapers: [ArXivPaper] = []
    
    /// Statistics papers
    @Published var statisticsPapers: [ArXivPaper] = []
    
    /// Electrical Engineering and Systems Science papers
    @Published var electricalEngineeringPapers: [ArXivPaper] = []
    
    /// Economics papers
    @Published var economicsPapers: [ArXivPaper] = []
    
    /// User's favorite papers
    @Published var favoritePapers: [ArXivPaper] = []
    
    /// Loading state
    @Published var isLoading = false
    
    /// Error message
    @Published var errorMessage: String?
    
    /// Currently selected category
    @Published var currentCategory: String = "latest"
    
    // MARK: - Search Properties
    /// Search results
    @Published var searchResults: [ArXivPaper] = []
    
    /// Current search query
    @Published var searchQuery: String = ""
    
    /// Search category filter
    @Published var searchCategory: String = ""
    
    /// Whether search is active
    @Published var isSearchActive: Bool = false
    
    /// Search loading state
    @Published var isSearching: Bool = false
    
    // MARK: - Private Properties
    /// Service for obtaining ArXiv data
    private let arxivService = ArXivService()
    
    /// Timer for automatic refresh
    private var autoRefreshTimer: Timer?
    
    // MARK: - Settings Properties
    /// Maximum number of papers to fetch (configured in Settings)
    private var maxPapers: Int {
        UserDefaults.standard.integer(forKey: "maxPapers") == 0 ? 10 : UserDefaults.standard.integer(forKey: "maxPapers")
    }
    
    /// Automatic refresh interval in minutes
    private var refreshInterval: Int {
        UserDefaults.standard.integer(forKey: "refreshInterval") == 0 ? 30 : UserDefaults.standard.integer(forKey: "refreshInterval")
    }
    
    /// If automatic refresh is enabled
    private var autoRefresh: Bool {
        UserDefaults.standard.bool(forKey: "autoRefresh")
    }
    
    /// Default category
    private var defaultCategory: String {
        UserDefaults.standard.string(forKey: "defaultCategory") ?? "latest"
    }
    
    // MARK: - Computed Properties
    /// Papers filtered by current category
    var filteredPapers: [ArXivPaper] {
        switch currentCategory {
        case "search":
            return searchResults
        case "cs":
            return csPapers
        case "math":
            return mathPapers
        case "physics":
            return physicsPapers
        case "q-bio":
            return quantitativeBiologyPapers
        case "q-fin":
            return quantitativeFinancePapers
        case "stat":
            return statisticsPapers
        case "eess":
            return electricalEngineeringPapers
        case "econ":
            return economicsPapers
        case "favorites":
            return favoritePapers
        default:
            return latestPapers
        }
    }
    
    // MARK: - Public Methods
    
    /// Loads the latest papers published on ArXiv
    /// Updates the `latestPapers` property with the results
    func loadLatestPapers() async {
        print("🚀 Controller: Starting to load latest papers...")
        print("🔧 Controller: MaxPapers setting: \(maxPapers)")
        await loadPapers(category: "latest")
        print("🔧 Controller: Latest papers loaded: \(latestPapers.count) papers")
    }
    
    /// Loads papers from the Computer Science category
    /// Updates the `csPapers` property with the results
    func loadComputerSciencePapers() async {
        print("🚀 Controller: Starting to load Computer Science papers...")
        await loadPapers(category: "cs")
    }
    
    /// Loads papers from the Mathematics category
    /// Updates the `mathPapers` property with the results
    func loadMathematicsPapers() async {
        print("🚀 Controller: Starting to load Mathematics papers...")
        await loadPapers(category: "math")
    }
    
    /// Loads papers from the Physics category
    /// Updates the `physicsPapers` property with the results
    func loadPhysicsPapers() async {
        print("🚀 Controller: Starting to load Physics papers...")
        await loadPapers(category: "physics")
    }
    
    /// Loads papers from the Quantitative Biology category
    /// Updates the `quantitativeBiologyPapers` property with the results
    func loadQuantitativeBiologyPapers() async {
        print("🚀 Controller: Starting to load Quantitative Biology papers...")
        await loadPapers(category: "q-bio")
    }
    
    /// Loads papers from the Quantitative Finance category
    /// Updates the `quantitativeFinancePapers` property with the results
    func loadQuantitativeFinancePapers() async {
        print("🚀 Controller: Starting to load Quantitative Finance papers...")
        await loadPapers(category: "q-fin")
    }
    
    /// Loads papers from the Statistics category
    /// Updates the `statisticsPapers` property with the results
    func loadStatisticsPapers() async {
        print("🚀 Controller: Starting to load Statistics papers...")
        await loadPapers(category: "stat")
    }
    
    /// Loads papers from the Electrical Engineering and Systems Science category
    /// Updates the `electricalEngineeringPapers` property with the results
    func loadElectricalEngineeringPapers() async {
        print("🚀 Controller: Starting to load Electrical Engineering papers...")
        await loadPapers(category: "eess")
    }
    
    /// Loads papers from the Economics category
    /// Updates the `economicsPapers` property with the results
    func loadEconomicsPapers() async {
        print("🚀 Controller: Starting to load Economics papers...")
        await loadPapers(category: "econ")
    }
    
    // MARK: - Search Methods
    
    /// Performs a search for papers on ArXiv
    /// - Parameters:
    ///   - query: Search terms
    ///   - category: Optional category to filter
    func searchPapers(query: String, category: String = "") async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Controller: Empty search query, ignoring search request")
            return
        }
        
        print("🔍 Controller: Starting search for query: '\(query)' in category: '\(category)'")
        
        isSearching = true
        errorMessage = nil
        searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchCategory = category
        isSearchActive = true
        currentCategory = "search"
        
        // Registra el tiempo de inicio para garantizar una duración mínima de carga
        let startTime = Date()
        
        do {
            let results = try await arxivService.searchPapers(
                query: searchQuery,
                count: maxPapers,
                category: category.isEmpty ? nil : category
            )
            
            // Synchronize favorite state for search results
            var synchronizedResults = results
            synchronizeFavoriteState(for: &synchronizedResults)
            searchResults = synchronizedResults
            
            // Asegura que la animación de carga dure al menos 1 segundo
            await ensureMinimumLoadingTime(startTime: startTime)
            
            isSearching = false
            print("✅ Controller: Search completed successfully with \(results.count) results")
            
        } catch {
            print("❌ Controller: Search error: \(error.localizedDescription)")
            errorMessage = "Error en la búsqueda: \(error.localizedDescription)"
            
            // Asegura que la animación de carga dure al menos 1 segundo incluso en caso de error
            await ensureMinimumLoadingTime(startTime: startTime)
            isSearching = false
        }
    }
    
    /// Enhanced search function that uses multiple strategies
    func enhancedSearch(query: String, category: String = "") async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Controller: Empty search query, ignoring search request")
            return
        }
        
        print("🔍 Controller: Starting enhanced search for query: '\(query)'")
        
        isSearching = true
        errorMessage = nil
        searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchCategory = category
        isSearchActive = true
        currentCategory = "search"
        
        let startTime = Date()
        
        do {
            let results = try await arxivService.enhancedSearch(query: searchQuery, count: maxPapers)
            
            // Synchronize favorite state for enhanced search results
            var synchronizedResults = results
            synchronizeFavoriteState(for: &synchronizedResults)
            searchResults = synchronizedResults
            
            await ensureMinimumLoadingTime(startTime: startTime)
            
            isSearching = false
            print("✅ Controller: Enhanced search completed successfully with \(results.count) results")
            
        } catch {
            print("❌ Controller: Enhanced search error: \(error.localizedDescription)")
            errorMessage = "Error en búsqueda mejorada: \(error.localizedDescription)"
            
            await ensureMinimumLoadingTime(startTime: startTime)
            isSearching = false
        }
    }
    
    /// Clears the current search and returns to the normal view
    func clearSearch() {
        print("🧹 Controller: Clearing search")
        searchQuery = ""
        searchCategory = ""
        searchResults = []
        isSearchActive = false
        isSearching = false
        errorMessage = nil
        
        // Volver a la categoría por defecto
        currentCategory = defaultCategory
    }
    
    /// Changes the current category and updates the UI
    /// - Parameter category: New category to select ("latest", "cs", "math", "physics", "q-bio", "q-fin", "stat", "eess", "econ", "favorites")
    func changeCategory(to category: String) {
        currentCategory = category
    }
    
    // MARK: - Private Methods
    
    /// Generic method to load papers according to the specified category
    /// Manages the loading state, errors and updates the corresponding properties
    /// - Parameter category: Category of papers to load ("latest", "cs", "math", "physics", "q-bio", "q-fin", "stat", "eess", "econ")
    private func loadPapers(category: String) async {
        isLoading = true
        errorMessage = nil
        currentCategory = category
        
        // Register the start time to ensure a minimum loading duration
        let startTime = Date()
        
        do {
            var fetchedPapers: [ArXivPaper] = []
            
            // Get papers according to the category
            if category == "favorites" {
                // For favorites, we don't need to fetch, just load from memory
                await loadFavoritePapers()
                return
            } else {
                fetchedPapers = try await fetchPapersForCategory(category)
            }
            
            // Update the papers according to the category
            updatePapers(fetchedPapers, for: category)
            
            // Ensure that the loading animation lasts at least 1 second
            await ensureMinimumLoadingTime(startTime: startTime)
            
            isLoading = false
            print("✅ Controller: Successfully loaded \(fetchedPapers.count) papers for category: \(category)")
            
        } catch {
            print("❌ Controller: Error loading papers: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            
            // Ensure that the loading animation lasts at least 1 second even in case of error
            await ensureMinimumLoadingTime(startTime: startTime)
            isLoading = false
        }
    }
    
    /// Gets papers from the specified category using ArxivKit
    /// - Parameter category: Category to fetch papers from
    /// - Returns: Array of papers from the category
    private func fetchPapersForCategory(_ category: String) async throws -> [ArXivPaper] {
        guard let arxivCategory = ArXivCategory.allCases.first(where: { $0.identifier == category }) else {
            return try await arxivService.fetchLatestPapers(count: maxPapers)
        }
        return try await arxivService.fetchPapers(for: arxivCategory, count: maxPapers)
    }
    
    /// Updates the papers according to the category
    private func updatePapers(_ papers: [ArXivPaper], for category: String) {
        var papersToUpdate = papers
        
        // Synchronize favorite state before updating
        synchronizeFavoriteState(for: &papersToUpdate)
        
        switch category {
        case "cs":
            csPapers = papersToUpdate
        case "math":
            mathPapers = papersToUpdate
        case "physics":
            physicsPapers = papersToUpdate
        case "q-bio":
            quantitativeBiologyPapers = papersToUpdate
        case "q-fin":
            quantitativeFinancePapers = papersToUpdate
        case "stat":
            statisticsPapers = papersToUpdate
        case "eess":
            electricalEngineeringPapers = papersToUpdate
        case "econ":
            economicsPapers = papersToUpdate
        default: // "latest"
            latestPapers = papersToUpdate
        }
    }
    
    /// Ensures that the loading lasts at least 1 second for a better UX
    private func ensureMinimumLoadingTime(startTime: Date) async {
        let elapsedTime = Date().timeIntervalSince(startTime)
        let minimumLoadingTime: TimeInterval = 1.0
        
        if elapsedTime < minimumLoadingTime {
            let remainingTime = minimumLoadingTime - elapsedTime
            try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
        }
    }
    
    // MARK: - Initialization
    
    /// Initializer for the controller that sets the initial state
    /// Sets the default category, configures automatic updates
    /// and registers observers for user configuration changes
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        
        // Set the initial category based on user settings
        currentCategory = defaultCategory
        
        // Configure automatic updates if enabled in settings
        setupAutoRefresh()
        
        // Listen for configuration changes to react dynamically
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsChanged(_:)),
            name: .settingsChanged,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(interfaceSettingsChanged(_:)),
            name: .interfaceSettingsChanged,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsReset),
            name: .settingsReset,
            object: nil
        )
    }
    
    deinit {
        autoRefreshTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Auto Refresh
    
    /// Configures the automatic refresh timer
    private func setupAutoRefresh() {
        autoRefreshTimer?.invalidate() // Invalidate the previous timer if it exists
        
        guard autoRefresh else {
            print("🚫 Controller: Auto-refresh is disabled in settings.")
            return
        }
        
        // Configure a new timer for automatic updates
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshInterval * 60), repeats: true) { [weak self] _ in
            Task {
                await self?.performAutoRefresh()
            }
        }
        
        print("🕒 Controller: Auto-refresh timer set up to refresh every \(refreshInterval) minutes.")
    }
    
    /// Performs an automatic update
    private func performAutoRefresh() async {
        guard !isLoading else { return }
        
        print("🔄 Performing automatic update...")
        
        // Update the current category
        switch currentCategory {
        case "cs":
            await loadComputerSciencePapers()
        case "math":
            await loadMathematicsPapers()
        default:
            await loadLatestPapers()
        }
        
        // Show notification if enabled
        if UserDefaults.standard.bool(forKey: "showNotifications") {
            showAutoRefreshNotification()
        }
    }
    
    /// Shows an automatic update notification
    private func showAutoRefreshNotification() {
        let content = UNMutableNotificationContent()
                        content.title = "ArXiv Finder"
        content.body = "Papers actualizados automáticamente"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "autoRefresh",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error showing notification: \(error)")
            }
        }
    }
    
    /// Handles configuration changes
    @objc private func settingsChanged(_ notification: Notification) {
        print("⚙️ Configuration changed, updating...")
        
        if let userInfo = notification.userInfo,
           let setting = userInfo["setting"] as? String {
            
            switch setting {
            case "autoRefresh", "refreshInterval":
                setupAutoRefresh()
            case "maxPapers":
                print("📄 Maximum papers configuration updated")
            case "defaultCategory":
                if let newCategory = userInfo["value"] as? String {
                    currentCategory = newCategory
                }
            default:
                break
            }
        } else {
            // Fallback for UserDefaults.didChangeNotification
            setupAutoRefresh()
        }
    }
    
    /// Handles interface configuration changes
    @objc private func interfaceSettingsChanged(_ notification: Notification) {
        print("🖼️ Interface configuration changed")
        // Here you could update the UI if needed
    }
    
    /// Handles the reset of configuration
    @objc private func settingsReset() {
        print("🔄 Configuration reset, restarting controller...")
        
        // Reset the controller values
        currentCategory = "latest"
        setupAutoRefresh()
        
        // Reload data with default configuration
        Task {
            await loadPapersWithSettings()
        }
    }
    
    // MARK: - Settings Integration Methods
    
    /// Loads papers using the current configuration
    func loadPapersWithSettings() async {
        let category = defaultCategory
        currentCategory = category
        
        print("🔧 Controller: Loading papers with settings - Category: \(category), MaxPapers: \(maxPapers)")
        
        switch category {
        case "cs":
            await loadComputerSciencePapers()
        case "math":
            await loadMathematicsPapers()
        case "physics":
            await loadPhysicsPapers()
        case "q-bio":
            await loadQuantitativeBiologyPapers()
        case "q-fin":
            await loadQuantitativeFinancePapers()
        case "stat":
            await loadStatisticsPapers()
        case "eess":
            await loadElectricalEngineeringPapers()
        case "econ":
            await loadEconomicsPapers()
        case "favorites":
            await loadFavoritePapers()
        default:
            await loadLatestPapers()
        }
        
        print("🔧 Controller: Finished loading papers - Current category: \(currentCategory), Papers count: \(filteredPapers.count)")
    }
    
    // MARK: - Favorites Management
    
    /// Loads all favorite papers from the database
    func loadFavoritePapers() async {
        print("🚀 Controller: Starting to load favorite papers...")
        currentCategory = "favorites"
        isLoading = true
        
        // Clean up duplicates before loading
        cleanupDuplicateFavorites()
        
        do {
            if let modelContext = modelContext {
                // Load from SwiftData
                let descriptor = FetchDescriptor<ArXivPaper>(predicate: #Predicate<ArXivPaper> { $0.isFavorite == true })
                let favoriteResults = try modelContext.fetch(descriptor)
                
                // Remove duplicates and sort by favorited date
                var uniqueFavorites: [ArXivPaper] = []
                var seenIDs: Set<String> = []
                
                for paper in favoriteResults {
                    if !seenIDs.contains(paper.id) {
                        uniqueFavorites.append(paper)
                        seenIDs.insert(paper.id)
                    }
                }
                
                favoritePapers = uniqueFavorites.sorted { $0.favoritedDate ?? Date.distantPast > $1.favoritedDate ?? Date.distantPast }
                print("✅ Controller: Loaded \(favoritePapers.count) favorite papers from SwiftData")
                
            } else {
                // Fallback: load from memory
                favoritePapers = getAllPapers().filter { $0.isFavorite }
                    .sorted { $0.favoritedDate ?? Date.distantPast > $1.favoritedDate ?? Date.distantPast }
                print("✅ Controller: Loaded \(favoritePapers.count) favorite papers from memory")
            }
        } catch {
            print("❌ Controller: Error loading favorites: \(error)")
            errorMessage = "Error cargando favoritos: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Toggles the favorite state of a paper
    /// - Parameter paper: The paper to mark/unmark as favorite
    func toggleFavorite(for paper: ArXivPaper) {
        print("🚀 Controller: Toggling favorite for paper: \(paper.title)")
        
        // Update the paper's favorite state
        let newFavoriteState = !paper.isFavorite
        paper.setFavorite(newFavoriteState)
        
        // Save to SwiftData if available
        if let modelContext = modelContext {
            // Ensure paper is in SwiftData
            modelContext.insert(paper)
            
            do {
                try modelContext.save()
                print("✅ Controller: Paper favorite status saved to SwiftData")
            } catch {
                print("❌ Controller: Error saving to SwiftData: \(error)")
            }
        }
        
        // Update the favorite list
        if newFavoriteState {
            if !favoritePapers.contains(where: { $0.id == paper.id }) {
                favoritePapers.append(paper)
                favoritePapers.sort { $0.favoritedDate ?? Date.distantPast > $1.favoritedDate ?? Date.distantPast }
                print("✅ Controller: Added paper to favorites. Total: \(favoritePapers.count)")
            }
        } else {
            favoritePapers.removeAll { $0.id == paper.id }
            print("✅ Controller: Removed paper from favorites. Total: \(favoritePapers.count)")
        }
        
        // Update in all other category lists
        updatePaperInAllCategories(paper)
    }
    

    
    /// Updates a paper in all categories where it appears
    private func updatePaperInAllCategories(_ paper: ArXivPaper) {
        // Update in all category lists
        if let index = latestPapers.firstIndex(where: { $0.id == paper.id }) {
            latestPapers[index] = paper
        }
        if let index = csPapers.firstIndex(where: { $0.id == paper.id }) {
            csPapers[index] = paper
        }
        if let index = mathPapers.firstIndex(where: { $0.id == paper.id }) {
            mathPapers[index] = paper
        }
        if let index = physicsPapers.firstIndex(where: { $0.id == paper.id }) {
            physicsPapers[index] = paper
        }
        if let index = quantitativeBiologyPapers.firstIndex(where: { $0.id == paper.id }) {
            quantitativeBiologyPapers[index] = paper
        }
        if let index = quantitativeFinancePapers.firstIndex(where: { $0.id == paper.id }) {
            quantitativeFinancePapers[index] = paper
        }
        if let index = statisticsPapers.firstIndex(where: { $0.id == paper.id }) {
            statisticsPapers[index] = paper
        }
        if let index = electricalEngineeringPapers.firstIndex(where: { $0.id == paper.id }) {
            electricalEngineeringPapers[index] = paper
        }
        if let index = economicsPapers.firstIndex(where: { $0.id == paper.id }) {
            economicsPapers[index] = paper
        }
    }
    
    /// Synchronizes the favorite state of papers with SwiftData
    /// This ensures that papers loaded from API have the correct favorite state
    private func synchronizeFavoriteState(for papers: inout [ArXivPaper]) {
        guard modelContext != nil else { return }
        
        // Get all favorite papers from SwiftData
        let favoriteIDs = Set(favoritePapers.map { $0.id })
        
        // Update each paper's favorite state
        for i in 0..<papers.count {
            let isFavorite = favoriteIDs.contains(papers[i].id)
            if papers[i].isFavorite != isFavorite {
                papers[i].setFavorite(isFavorite)
                print("🔄 Controller: Synchronized favorite state for paper: \(papers[i].title) - isFavorite: \(isFavorite)")
            }
        }
    }
    
    /// Gets all papers from all categories (helper method)
    private func getAllPapers() -> [ArXivPaper] {
        var allPapers: [ArXivPaper] = []
        allPapers.append(contentsOf: latestPapers)
        allPapers.append(contentsOf: csPapers)
        allPapers.append(contentsOf: mathPapers)
        allPapers.append(contentsOf: physicsPapers)
        allPapers.append(contentsOf: quantitativeBiologyPapers)
        allPapers.append(contentsOf: quantitativeFinancePapers)
        allPapers.append(contentsOf: statisticsPapers)
        allPapers.append(contentsOf: electricalEngineeringPapers)
        allPapers.append(contentsOf: economicsPapers)
        
        // Remove duplicates based on the ID
        var uniquePapers: [ArXivPaper] = []
        var seenIDs: Set<String> = []
        
        for paper in allPapers {
            if !seenIDs.contains(paper.id) {
                uniquePapers.append(paper)
                seenIDs.insert(paper.id)
            }
        }
        
        return uniquePapers
    }
    
    /// Simple cleanup of duplicate favorites
    private func cleanupDuplicateFavorites() {
        guard let modelContext = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<ArXivPaper>(predicate: #Predicate<ArXivPaper> { $0.isFavorite == true })
            let favorites = try modelContext.fetch(descriptor)
            
            var seenIDs: Set<String> = []
            var duplicates: [ArXivPaper] = []
            
            for paper in favorites {
                if seenIDs.contains(paper.id) {
                    duplicates.append(paper)
                } else {
                    seenIDs.insert(paper.id)
                }
            }
            
            if !duplicates.isEmpty {
                for paper in duplicates {
                    modelContext.delete(paper)
                }
                try modelContext.save()
                print("🧹 Controller: Removed \(duplicates.count) duplicate favorites")
            }
        } catch {
            print("❌ Controller: Error cleaning favorites: \(error)")
        }
    }
}

// MARK: - Notification Names Extension
extension Notification.Name {
    static let settingsChanged = Notification.Name("settingsChanged")
    static let interfaceSettingsChanged = Notification.Name("interfaceSettingsChanged")
    static let settingsReset = Notification.Name("settingsReset")
}


