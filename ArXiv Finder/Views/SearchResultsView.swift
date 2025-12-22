//
//  SearchResultsView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 3/7/25.
//

import SwiftUI

/// Clean and modern search interface for ArXiv papers
/// Provides a streamlined search experience with improved UX
///
/// Features:
/// - Clean, minimal search interface
/// - Real-time search results
/// - Search history with quick access
/// - Category filtering
/// - Proper paper selection handling
/// - Responsive design for both platforms
struct SearchResultsView: View {
    /// Controller to handle search logic
    @ObservedObject var controller: ArXivController
    
    /// Selected paper for navigation (passed from parent)
    @Binding var selectedPaper: ArXivPaper?
    
    /// Search query text
    @State private var searchText: String = ""
    
    /// Selected category for filtering
    @State private var selectedCategory: String = ""
    
    /// Whether to show search interface
    @State private var showSearchInterface: Bool = true
    
    /// Search history
    @State private var searchHistory: [String] = []
    
    /// Maximum search history items
    private let maxHistoryItems = 8
    
    var body: some View {
        VStack(spacing: 0) {
            // Search interface
            if showSearchInterface {
                searchInterfaceView
            }
            
            // Results view or no results message
            if !showSearchInterface {
                if controller.isSearching {
                    loadingView
                } else if controller.errorMessage != nil {
                    errorView
                } else if controller.searchResults.isEmpty && controller.isSearchActive {
                    noResultsView
                } else if !controller.searchResults.isEmpty {
                    resultsView
                }
            }
        }
        .onAppear {
            loadSearchHistory()
            
            // Pre-fill search text if there's an active search
            if controller.isSearchActive {
                searchText = controller.searchQuery
                selectedCategory = controller.searchCategory
                showSearchInterface = false
            }
        }
        #if os(macOS)
        .frame(minWidth: 350)
        #endif
    }
    
    /// Clean search interface view
    private var searchInterfaceView: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    Text("Search Papers")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                Text("Find papers by title, author, or keywords")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Search input
            VStack(spacing: 16) {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16, weight: .medium))
                    
                    TextField("Search papers...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16))
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Category filter
                HStack {
                    Text("Category:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Category", selection: $selectedCategory) {
                        Text("All Categories").tag("")
                        Text("Computer Science").tag("cs")
                        Text("Mathematics").tag("math")
                        Text("Physics").tag("physics")
                        Text("Quantitative Biology").tag("q-bio")
                        Text("Quantitative Finance").tag("q-fin")
                        Text("Statistics").tag("stat")
                        Text("Electrical Engineering").tag("eess")
                        Text("Economics").tag("econ")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: 200)
                    
                    Spacer()
                    
                    Button("Search") {
                        performSearch()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(searchText.isEmpty || controller.isSearching)
                }
                .padding(.horizontal)
            }
            
            // Search history
            if !searchHistory.isEmpty && searchText.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Searches")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Button("Clear All") {
                            clearSearchHistory()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(searchHistory.prefix(6), id: \.self) { query in
                            Button(action: {
                                searchText = query
                                performSearch()
                            }) {
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(query)
                                        .font(.caption)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top)
    }
    
    /// Loading view
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.regular)
                .scaleEffect(1.2)
            
            Text("Searching papers...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Error view
    private var errorView: some View {
        VStack(spacing: 16) {
            ContentUnavailableView(
                "Search Error",
                systemImage: "exclamationmark.triangle",
                description: Text(controller.errorMessage ?? "Unknown error")
            )
            
            VStack(spacing: 12) {
                Button("Retry") {
                    performSearch()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Clear Error") {
                    controller.errorMessage = nil
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
    
    /// No results view
    private var noResultsView: some View {
        VStack(spacing: 16) {
            ContentUnavailableView(
                "No Results Found",
                systemImage: "magnifyingglass",
                description: Text("No papers found for '\(controller.searchQuery)'. Try different keywords or check your spelling.")
            )
            
            VStack(spacing: 12) {
                Button("Try Different Search") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSearchInterface = true
                        selectedPaper = nil
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Clear Search") {
                    controller.clearSearch()
                    selectedPaper = nil
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
    
    /// Clean results view
    private var resultsView: some View {
        VStack(spacing: 0) {
            // Results header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Search Results")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(controller.searchResults.count) papers found")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("New Search") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSearchInterface = true
                        selectedPaper = nil
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button("Clear") {
                    controller.clearSearch()
                    selectedPaper = nil
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // Results list with proper selection handling
            #if os(macOS)
            List(controller.searchResults, id: \.id, selection: $selectedPaper) { paper in
                ArXivPaperRow(paper: paper, controller: controller)
                    .tag(paper)
            }
            .listStyle(PlainListStyle())
            #else
            List(controller.searchResults, id: \.id) { paper in
                NavigationLink(destination: PaperDetailView(paper: paper, controller: controller, onBackToList: nil)) {
                    ArXivPaperRow(paper: paper, controller: controller)
                }
            }
            .listStyle(DefaultListStyle())
            #endif
        }
    }
    
    /// Perform the search operation
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Add to search history
        addToSearchHistory(query)
        
        // Hide search interface and clear selection
        withAnimation(.easeInOut(duration: 0.3)) {
            showSearchInterface = false
            selectedPaper = nil
        }
        
        // Perform search
        Task {
            await controller.searchPapers(query: query, category: selectedCategory)
        }
    }
    
    /// Add query to search history
    private func addToSearchHistory(_ query: String) {
        searchHistory.removeAll { $0 == query }
        searchHistory.insert(query, at: 0)
        
        if searchHistory.count > maxHistoryItems {
            searchHistory = Array(searchHistory.prefix(maxHistoryItems))
        }
        
        saveSearchHistory()
    }
    
    /// Load search history from UserDefaults
    private func loadSearchHistory() {
        if let data = UserDefaults.standard.data(forKey: "searchHistory"),
           let history = try? JSONDecoder().decode([String].self, from: data) {
            searchHistory = history
        }
    }
    
    /// Save search history to UserDefaults
    private func saveSearchHistory() {
        if let data = try? JSONEncoder().encode(searchHistory) {
            UserDefaults.standard.set(data, forKey: "searchHistory")
        }
    }
    
    /// Clear search history
    private func clearSearchHistory() {
        searchHistory.removeAll()
        UserDefaults.standard.removeObject(forKey: "searchHistory")
    }
}

#Preview {
    SearchResultsView(
        controller: ArXivController(),
        selectedPaper: .constant(nil)
    )
    .frame(width: 400, height: 600)
} 
