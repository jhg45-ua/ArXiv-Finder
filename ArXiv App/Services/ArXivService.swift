//
//  ArXivService.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import Foundation
import ArxivKit

/// Service responsible for communicating with the ArXiv API using ArxivKit
/// Provides a clean interface for fetching papers from different categories
final class ArXivService: @unchecked Sendable {
    
    /// Gets the latest papers published on ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of ArXiv papers
    /// - Throws: Error if request or parsing fails
    nonisolated func fetchLatestPapers(count: Int = 10) async throws -> [ArXivPaper] {
        print("🌐 Fetching latest papers using ArxivKit...")
        
        do {
            // Search across multiple categories to get the most recent papers
            let query = any {
                subject(ComputerScience.all)
                subject(Statistics.all)
                subject(Mathematics.all)
            }
            
            let request = query
                .itemsPerPage(count)
                .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
                .sorted(by: ArxivRequestSpecification.SortingCriterion.lastUpdateDate)
            
            let response = try await request.fetch(using: URLSession.shared)
            
            let papers = response.entries.map { entry in
                convertToArXivPaper(from: entry)
            }
            
            print("✅ Successfully fetched \(papers.count) latest papers using ArxivKit")
            return papers
            
        } catch {
            print("❌ Error fetching latest papers: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets Computer Science papers from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of Computer Science papers
    /// - Throws: Error if request or parsing fails
    nonisolated func fetchComputerSciencePapers(count: Int = 10) async throws -> [ArXivPaper] {
        print("🌐 Fetching Computer Science papers using ArxivKit...")
        
        do {
            let query = subject(ComputerScience.all)
            let request = query
                .itemsPerPage(count)
                .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
                .sorted(by: ArxivRequestSpecification.SortingCriterion.lastUpdateDate)
            
            let response = try await request.fetch(using: URLSession.shared)
            
            let papers = response.entries.map { entry in
                convertToArXivPaper(from: entry)
            }
            
            print("✅ Successfully fetched \(papers.count) Computer Science papers using ArxivKit")
            return papers
            
        } catch {
            print("❌ Error fetching Computer Science papers: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets papers from Mathematics from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of papers from Mathematics
    /// - Throws: Error if the request or parsing fails
    nonisolated func fetchMathematicsPapers(count: Int = 10) async throws -> [ArXivPaper] {
        print("🌐 Fetching Mathematics papers using ArxivKit...")
        
        do {
            let query = subject(Mathematics.all)
            let request = query
                .itemsPerPage(count)
                .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
                .sorted(by: ArxivRequestSpecification.SortingCriterion.lastUpdateDate)
            
            let response = try await request.fetch(using: URLSession.shared)
            
            let papers = response.entries.map { entry in
                convertToArXivPaper(from: entry)
            }
            
            print("✅ Successfully fetched \(papers.count) Mathematics papers using ArxivKit")
            return papers
            
        } catch {
            print("❌ Error fetching Mathematics papers: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets papers from Physics from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of papers from Physics
    /// - Throws: Error if the request or parsing fails
    nonisolated func fetchPhysicsPapers(count: Int = 10) async throws -> [ArXivPaper] {
        print("🌐 Fetching Physics papers using ArxivKit...")
        
        do {
            let query = subject(Physics.all)
            let request = query
                .itemsPerPage(count)
                .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
                .sorted(by: ArxivRequestSpecification.SortingCriterion.lastUpdateDate)
            
            let response = try await request.fetch(using: URLSession.shared)
            
            let papers = response.entries.map { entry in
                convertToArXivPaper(from: entry)
            }
            
            print("✅ Successfully fetched \(papers.count) Physics papers using ArxivKit")
            return papers
            
        } catch {
            print("❌ Error fetching Physics papers: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets papers from Quantitative Biology from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of papers from Quantitative Biology
    /// - Throws: Error if the request or parsing fails
    nonisolated func fetchQuantitativeBiologyPapers(count: Int = 10) async throws -> [ArXivPaper] {
        print("🌐 Fetching Quantitative Biology papers using ArxivKit...")
        
        do {
            let query = subject(QuantitativeBiology.all)
            let request = query
                .itemsPerPage(count)
                .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
                .sorted(by: ArxivRequestSpecification.SortingCriterion.lastUpdateDate)
            
            let response = try await request.fetch(using: URLSession.shared)
            
            let papers = response.entries.map { entry in
                convertToArXivPaper(from: entry)
            }
            
            print("✅ Successfully fetched \(papers.count) Quantitative Biology papers using ArxivKit")
            return papers
            
        } catch {
            print("❌ Error fetching Quantitative Biology papers: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets papers from Quantitative Finance from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of papers from Quantitative Finance
    /// - Throws: Error if the request or parsing fails
    nonisolated func fetchQuantitativeFinancePapers(count: Int = 10) async throws -> [ArXivPaper] {
        print("🌐 Fetching Quantitative Finance papers using ArxivKit...")
        
        do {
            let query = subject(QuantitativeFinance.all)
            let request = query
                .itemsPerPage(count)
                .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
                .sorted(by: ArxivRequestSpecification.SortingCriterion.lastUpdateDate)
            
            let response = try await request.fetch(using: URLSession.shared)
            
            let papers = response.entries.map { entry in
                convertToArXivPaper(from: entry)
            }
            
            print("✅ Successfully fetched \(papers.count) Quantitative Finance papers using ArxivKit")
            return papers
            
        } catch {
            print("❌ Error fetching Quantitative Finance papers: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets papers from Statistics from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of papers from Statistics
    /// - Throws: Error if the request or parsing fails
    nonisolated func fetchStatisticsPapers(count: Int = 10) async throws -> [ArXivPaper] {
        print("🌐 Fetching Statistics papers using ArxivKit...")
        
        do {
            let query = subject(Statistics.all)
            let request = query
                .itemsPerPage(count)
                .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
                .sorted(by: ArxivRequestSpecification.SortingCriterion.lastUpdateDate)
            
            let response = try await request.fetch(using: URLSession.shared)
            
            let papers = response.entries.map { entry in
                convertToArXivPaper(from: entry)
            }
            
            print("✅ Successfully fetched \(papers.count) Statistics papers using ArxivKit")
            return papers
            
        } catch {
            print("❌ Error fetching Statistics papers: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets papers from Electrical Engineering and Systems Science from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of papers from Electrical Engineering and Systems Science
    /// - Throws: Error if the request or parsing fails
    nonisolated func fetchElectricalEngineeringPapers(count: Int = 10) async throws -> [ArXivPaper] {
        print("🌐 Fetching Electrical Engineering papers using ArxivKit...")
        
        do {
            let query = subject(ElectricalEngineeringAndSystemsScience.all)
            let request = query
                .itemsPerPage(count)
                .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
                .sorted(by: ArxivRequestSpecification.SortingCriterion.lastUpdateDate)
            
            let response = try await request.fetch(using: URLSession.shared)
            
            let papers = response.entries.map { entry in
                convertToArXivPaper(from: entry)
            }
            
            print("✅ Successfully fetched \(papers.count) Electrical Engineering papers using ArxivKit")
            return papers
            
        } catch {
            print("❌ Error fetching Electrical Engineering papers: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets papers from Economics from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of papers from Economics
    /// - Throws: Error if the request or parsing fails
    nonisolated func fetchEconomicsPapers(count: Int = 10) async throws -> [ArXivPaper] {
        print("🌐 Fetching Economics papers using ArxivKit...")
        
        do {
            let query = subject(Economy.all)
            let request = query
                .itemsPerPage(count)
                .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
                .sorted(by: ArxivRequestSpecification.SortingCriterion.lastUpdateDate)
            
            let response = try await request.fetch(using: URLSession.shared)
            
            let papers = response.entries.map { entry in
                convertToArXivPaper(from: entry)
            }
            
            print("✅ Successfully fetched \(papers.count) Economics papers using ArxivKit")
            return papers
            
        } catch {
            print("❌ Error fetching Economics papers: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Search papers in ArXiv using search terms
    /// - Parameters:
    ///   - query: Search terms (title, author, summary)
    ///   - count: Maximum number of results (default 20)
    ///   - category: Optional category to filter (e.g.: "cs", "math", "physics")
    ///   - sortByRelevance: Whether to sort by relevance (true) or date (false)
    /// - Returns: Array of papers that match the search
    /// - Throws: Error if the request or parsing fails
    nonisolated func searchPapers(query: String, count: Int = 20, category: String? = nil, sortByRelevance: Bool = true) async throws -> [ArXivPaper] {
        print("🔍 Searching papers using ArxivKit with query: \(query)")
        
        do {
            // Build the search query - avoid the ArxivKit bug with .any field
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Use title search to avoid the ArxivKit bug with .any field
            var searchQuery = term(trimmedQuery, in: .title)
            
            // If a category is specified, add it to the filter
            if let category = category, !category.isEmpty {
                let categoryQuery = subject(ArxivSubject(symbol: category) ?? ComputerScience.all)
                searchQuery = all {
                    searchQuery
                    categoryQuery
                }
            }
            
            let request = searchQuery
                .itemsPerPage(count)
                .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
                .sorted(by: sortByRelevance ? 
                    ArxivRequestSpecification.SortingCriterion.relevance : 
                    ArxivRequestSpecification.SortingCriterion.lastUpdateDate)
            
            let response = try await request.fetch(using: URLSession.shared)
            
            let papers = response.entries.map { entry in
                convertToArXivPaper(from: entry)
            }
            
            print("✅ Successfully found \(papers.count) papers for query: \(query)")
            return papers
            
        } catch {
            print("❌ Search error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Enhanced search function that tries multiple strategies
    /// This helps overcome ArxivKit limitations
    nonisolated func enhancedSearch(query: String, count: Int = 20) async throws -> [ArXivPaper] {
        print("🔍 Enhanced search for: '\(query)'")
        
        do {
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Try multiple search strategies
            var allResults: [ArxivEntry] = []
            
            // Strategy 1: Title search
            print("📝 Strategy 1: Title search")
            let titleQuery = term(trimmedQuery, in: .title)
            let titleRequest = titleQuery
                .itemsPerPage(count)
                .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
                .sorted(by: ArxivRequestSpecification.SortingCriterion.relevance)
            
            let titleResponse = try await titleRequest.fetch(using: URLSession.shared)
            allResults.append(contentsOf: titleResponse.entries)
            print("✅ Title search found \(titleResponse.entries.count) results")
            
            // Strategy 2: Abstract search
            print("📝 Strategy 2: Abstract search")
            let abstractQuery = term(trimmedQuery, in: .abstract)
            let abstractRequest = abstractQuery
                .itemsPerPage(count)
                .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
                .sorted(by: ArxivRequestSpecification.SortingCriterion.relevance)
            
            let abstractResponse = try await abstractRequest.fetch(using: URLSession.shared)
            
            // Add unique results from abstract search
            for entry in abstractResponse.entries {
                if !allResults.contains(where: { $0.id == entry.id }) {
                    allResults.append(entry)
                }
            }
            print("✅ Abstract search added \(abstractResponse.entries.count) unique results")
            
            // Strategy 3: Authors search (for specific author names)
            if trimmedQuery.contains(" ") {
                print("📝 Strategy 3: Authors search")
                let authorsQuery = term(trimmedQuery, in: .authors)
                let authorsRequest = authorsQuery
                    .itemsPerPage(count)
                    .sortingOrder(ArxivRequestSpecification.SortingOrder.descending)
                    .sorted(by: ArxivRequestSpecification.SortingCriterion.relevance)
                
                let authorsResponse = try await authorsRequest.fetch(using: URLSession.shared)
                
                // Add unique results from authors search
                for entry in authorsResponse.entries {
                    if !allResults.contains(where: { $0.id == entry.id }) {
                        allResults.append(entry)
                    }
                }
                print("✅ Authors search added \(authorsResponse.entries.count) unique results")
            }
            
            // Take the first 'count' results
            let finalResults = Array(allResults.prefix(count))
            
            let papers = finalResults.map { entry in
                convertToArXivPaper(from: entry)
            }
            
            print("✅ Enhanced search found \(papers.count) total papers")
            return papers
            
        } catch {
            print("❌ Enhanced search error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Converts ArxivKit Entry to our ArXivPaper model
    /// - Parameter entry: ArxivKit Entry object
    /// - Returns: Our ArXivPaper model
    private func convertToArXivPaper(from entry: ArxivKit.ArxivEntry) -> ArXivPaper {
        // Extract authors as comma-separated string
        let authorsString = entry.authors.map { $0.name }.joined(separator: ", ")
        
        // Extract categories as comma-separated string
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
}

/// Enumeration of specific errors for the ArXiv service
/// Defines the types of errors that can occur during communication with the API
enum ArXivError: Error, LocalizedError {
    /// Error when the constructed URL is invalid
    case invalidURL
    /// Network error with descriptive message
    case networkError(String)
    /// Error during XML parsing with descriptive message
    case parsingError(String)
    
    /// Localized error description for display to the user
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid ArXiv URL"
        case .networkError(let message):
            return "Connection error: \(message)"
        case .parsingError(let message):
            return "Error processing data: \(message)"
        }
    }
}
