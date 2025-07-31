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

/// Controller that handles the business logic of the ArXiv application
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
        await loadPapers(category: "latest")
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
            
            searchResults = results
            
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
            switch category {
            case "cs":
                fetchedPapers = try await fetchComputerSciencePapersWithFallback()
            case "math":
                fetchedPapers = try await fetchMathematicsPapersWithFallback()
            case "physics":
                fetchedPapers = try await fetchPhysicsPapersWithFallback()
            case "q-bio":
                fetchedPapers = try await fetchQuantitativeBiologyPapersWithFallback()
            case "q-fin":
                fetchedPapers = try await fetchQuantitativeFinancePapersWithFallback()
            case "stat":
                fetchedPapers = try await fetchStatisticsPapersWithFallback()
            case "eess":
                fetchedPapers = try await fetchElectricalEngineeringPapersWithFallback()
            case "econ":
                fetchedPapers = try await fetchEconomicsPapersWithFallback()
            case "favorites":
                // For favorites, we don't need to fetch, just load from memory
                await loadFavoritePapers()
                return
            default: // "latest"
                fetchedPapers = try await fetchLatestPapersWithFallback()
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
    
    /// Gets the latest papers with fallback
    private func fetchLatestPapersWithFallback() async throws -> [ArXivPaper] {
        // Use the maxPapers configuration
        let count = maxPapers
        
        // Try first with the specific query
        var papers = try await arxivService.fetchLatestPapers(count: count)
        
        // If no results, try with the simple query
        if papers.isEmpty {
            print("⚠️ Controller: No papers found with specific query, trying simple query...")
            papers = try await arxivService.fetchRecentPapers(count: count)
        }
        
        // If still no results, try with the final fallback query
        if papers.isEmpty {
            print("⚠️ Controller: No papers found with simple query, trying fallback query...")
            papers = try await arxivService.fetchFallbackPapers(count: count)
        }
        
        return papers
    }
    
    /// Gets papers from Computer Science with fallback
    private func fetchComputerSciencePapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchComputerSciencePapers(count: maxPapers)
        return papers
    }
    
    /// Gets papers from Mathematics with fallback
    private func fetchMathematicsPapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchMathematicsPapers(count: maxPapers)
        return papers
    }
    
    /// Gets papers from Physics with fallback
    private func fetchPhysicsPapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchPhysicsPapers(count: maxPapers)
        return papers
    }
    
    /// Gets papers from Quantitative Biology with fallback
    private func fetchQuantitativeBiologyPapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchQuantitativeBiologyPapers(count: maxPapers)
        return papers
    }
    
    /// Gets papers from Quantitative Finance with fallback
    private func fetchQuantitativeFinancePapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchQuantitativeFinancePapers(count: maxPapers)
        return papers
    }
    
    /// Gets papers from Statistics with fallback
    private func fetchStatisticsPapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchStatisticsPapers(count: maxPapers)
        return papers
    }
    
    /// Gets papers from Electrical Engineering and Systems Science with fallback
    private func fetchElectricalEngineeringPapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchElectricalEngineeringPapers(count: maxPapers)
        return papers
    }
    
    /// Gets papers from Economics with fallback
    private func fetchEconomicsPapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchEconomicsPapers(count: maxPapers)
        return papers
    }
    
    /// Updates the papers according to the category
    private func updatePapers(_ papers: [ArXivPaper], for category: String) {
        switch category {
        case "cs":
            csPapers = papers
        case "math":
            mathPapers = papers
        case "physics":
            physicsPapers = papers
        case "q-bio":
            quantitativeBiologyPapers = papers
        case "q-fin":
            quantitativeFinancePapers = papers
        case "stat":
            statisticsPapers = papers
        case "eess":
            electricalEngineeringPapers = papers
        case "econ":
            economicsPapers = papers
        default: // "latest"
            latestPapers = papers
        }
        
        // Save papers to SwiftData if available
        if let modelContext = modelContext {
            for paper in papers {
                modelContext.insert(paper)
            }
            
            do {
                try modelContext.save()
                print("✅ Controller: Saved \(papers.count) papers to SwiftData for category: \(category)")
            } catch {
                print("❌ Controller: Error saving papers to SwiftData: \(error)")
            }
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
        content.title = "ArXiv App"
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
    }
    
    // MARK: - Favorites Management
    
    /// Loads all favorite papers from the database
    func loadFavoritePapers() async {
        print("🚀 Controller: Starting to load favorite papers...")
        currentCategory = "favorites"
        isLoading = true
        
        do {
            if let modelContext = modelContext {
                // Load from SwiftData
                let descriptor = FetchDescriptor<ArXivPaper>(predicate: #Predicate<ArXivPaper> { $0.isFavorite == true })
                let favoriteResults = try modelContext.fetch(descriptor)
                favoritePapers = favoriteResults.sorted { $0.favoritedDate ?? Date.distantPast > $1.favoritedDate ?? Date.distantPast }
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
            do {
                try modelContext.save()
                print("✅ Controller: Paper favorite status saved to SwiftData")
            } catch {
                print("❌ Controller: Error saving to SwiftData: \(error)")
            }
        }
        
        // Update the favorite list
        if newFavoriteState {
            // Add to favorites if not already in the list
            if !favoritePapers.contains(where: { $0.id == paper.id }) {
                favoritePapers.append(paper)
                favoritePapers.sort { $0.favoritedDate ?? Date.distantPast > $1.favoritedDate ?? Date.distantPast }
            }
        } else {
            // Remove from favorites
            favoritePapers.removeAll { $0.id == paper.id }
        }
        
        // Update in all other category lists
        updatePaperInAllCategories(paper)
        
        print("✅ Controller: Paper favorite status updated to: \(newFavoriteState)")
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
}

// MARK: - Notification Names Extension
extension Notification.Name {
    static let settingsChanged = Notification.Name("settingsChanged")
    static let interfaceSettingsChanged = Notification.Name("interfaceSettingsChanged")
    static let settingsReset = Notification.Name("settingsReset")
}
