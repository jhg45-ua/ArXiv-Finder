//
//  ArXiv_FinderTests.swift
//  ArXiv FinderTests
//
//  Created by Julián Hinojosa Gil on 5/8/25.
//

import Testing
import Foundation
@testable import ArXiv_Finder

struct ArXiv_FinderTests {
    
    // MARK: - ArXivPaper Model Tests
    
    @Test("ArXivPaper initialization with all required parameters")
    func testArXivPaperInitialization() throws {
        let testDate = Date()
        let paper = ArXivPaper(
            id: "2023.12345v1",
            title: "Test Paper Title",
            summary: "This is a test paper summary",
            authors: "John Doe, Jane Smith",
            publishedDate: testDate,
            updatedDate: testDate,
            pdfURL: "https://arxiv.org/pdf/2023.12345v1.pdf",
            linkURL: "https://arxiv.org/abs/2023.12345v1",
            categories: "cs.AI, cs.LG",
            isFavorite: false
        )
        
        #expect(paper.id == "2023.12345v1")
        #expect(paper.title == "Test Paper Title")
        #expect(paper.summary == "This is a test paper summary")
        #expect(paper.authors == "John Doe, Jane Smith")
        #expect(paper.publishedDate == testDate)
        #expect(paper.updatedDate == testDate)
        #expect(paper.pdfURL == "https://arxiv.org/pdf/2023.12345v1.pdf")
        #expect(paper.linkURL == "https://arxiv.org/abs/2023.12345v1")
        #expect(paper.categories == "cs.AI, cs.LG")
        #expect(paper.isFavorite == false)
        #expect(paper.favoritedDate == nil)
    }
    
    @Test("ArXivPaper initialization with favorite set to true")
    func testArXivPaperInitializationWithFavorite() throws {
        let paper = ArXivPaper(
            id: "2023.12345v1",
            title: "Test Paper Title",
            summary: "This is a test paper summary",
            authors: "John Doe",
            publishedDate: Date(),
            pdfURL: "https://arxiv.org/pdf/2023.12345v1.pdf",
            linkURL: "https://arxiv.org/abs/2023.12345v1",
            categories: "cs.AI",
            isFavorite: true
        )
        
        #expect(paper.isFavorite == true)
        #expect(paper.favoritedDate != nil)
    }
    
    @Test("ArXivPaper setFavorite method functionality")
    func testArXivPaperSetFavorite() throws {
        let paper = ArXivPaper(
            id: "2023.12345v1",
            title: "Test Paper Title",
            summary: "This is a test paper summary",
            authors: "John Doe",
            publishedDate: Date(),
            pdfURL: "https://arxiv.org/pdf/2023.12345v1.pdf",
            linkURL: "https://arxiv.org/abs/2023.12345v1",
            categories: "cs.AI",
            isFavorite: false
        )
        
        // Initially not favorite
        #expect(paper.isFavorite == false)
        #expect(paper.favoritedDate == nil)
        
        // Set as favorite
        paper.setFavorite(true)
        #expect(paper.isFavorite == true)
        #expect(paper.favoritedDate != nil)
        
        // Unset favorite
        paper.setFavorite(false)
        #expect(paper.isFavorite == false)
        #expect(paper.favoritedDate == nil)
    }
    
    // MARK: - ArXivCategory Tests
    
    @Test("ArXivCategory name property returns correct values")
    func testArXivCategoryNames() throws {
        #expect(ArXivCategory.latest.name == "Latest")
        #expect(ArXivCategory.computerScience.name == "Computer Science")
        #expect(ArXivCategory.mathematics.name == "Mathematics")
        #expect(ArXivCategory.physics.name == "Physics")
        #expect(ArXivCategory.statistics.name == "Statistics")
        #expect(ArXivCategory.economics.name == "Economics")
    }
    
    @Test("ArXivCategory identifier property returns correct values")
    func testArXivCategoryIdentifiers() throws {
        #expect(ArXivCategory.latest.identifier == "latest")
        #expect(ArXivCategory.computerScience.identifier == "cs")
        #expect(ArXivCategory.mathematics.identifier == "math")
        #expect(ArXivCategory.physics.identifier == "physics")
        #expect(ArXivCategory.statistics.identifier == "stat")
        #expect(ArXivCategory.economics.identifier == "econ")
    }
    
    @Test("ArXivCategory allCases contains all categories")
    func testArXivCategoryAllCases() throws {
        let allCategories = ArXivCategory.allCases
        #expect(allCategories.count >= 6) // At least the main categories
        
        let expectedCategories: [ArXivCategory] = [
            .latest, .computerScience, .mathematics, .physics, .statistics, .economics
        ]
        
        for expectedCategory in expectedCategories {
            #expect(allCategories.contains(expectedCategory))
        }
    }
    
    // MARK: - ArXivService Tests
    
    @Test("ArXivService initialization")
    func testArXivServiceInitialization() throws {
        let service = ArXivService()
        #expect(type(of: service) == ArXivService.self)
    }
    
    @Test("ArXivError error descriptions")
    func testArXivErrorDescriptions() throws {
        let invalidURLError = ArXivError.invalidURL
        let networkError = ArXivError.networkError("Connection failed")
        let parsingError = ArXivError.parsingError("Invalid XML")
        
        #expect(invalidURLError.errorDescription == "Invalid ArXiv URL")
        #expect(networkError.errorDescription == "Connection error: Connection failed")
        #expect(parsingError.errorDescription == "Error processing data: Invalid XML")
    }
    
    // MARK: - Utility Tests
    
    @Test("Date handling in ArXivPaper")
    func testArXivPaperDateHandling() throws {
        let now = Date()
        let paper = ArXivPaper(
            id: "2023.12345v1",
            title: "Test Paper",
            summary: "Test Summary",
            authors: "Test Author",
            publishedDate: now,
            updatedDate: now,
            pdfURL: "https://arxiv.org/pdf/test.pdf",
            linkURL: "https://arxiv.org/abs/test",
            categories: "cs.AI"
        )
        
        #expect(paper.publishedDate == now)
        #expect(paper.updatedDate == now)
        
        // Test with nil updatedDate
        let paperWithoutUpdate = ArXivPaper(
            id: "2023.12346v1",
            title: "Test Paper 2",
            summary: "Test Summary 2",
            authors: "Test Author 2",
            publishedDate: now,
            updatedDate: nil,
            pdfURL: "https://arxiv.org/pdf/test2.pdf",
            linkURL: "https://arxiv.org/abs/test2",
            categories: "cs.LG"
        )
        
        #expect(paperWithoutUpdate.publishedDate == now)
        #expect(paperWithoutUpdate.updatedDate == nil)
    }
    
    @Test("ArXivPaper favorite functionality with date tracking")
    func testArXivPaperFavoriteDateTracking() throws {
        let paper = ArXivPaper(
            id: "2023.12345v1",
            title: "Test Paper",
            summary: "Test Summary",
            authors: "Test Author",
            publishedDate: Date(),
            pdfURL: "https://arxiv.org/pdf/test.pdf",
            linkURL: "https://arxiv.org/abs/test",
            categories: "cs.AI",
            isFavorite: false
        )
        
        let beforeFavorite = Date()
        paper.setFavorite(true)
        let afterFavorite = Date()
        
        #expect(paper.isFavorite == true)
        #expect(paper.favoritedDate != nil)
        
        if let favoritedDate = paper.favoritedDate {
            #expect(favoritedDate >= beforeFavorite)
            #expect(favoritedDate <= afterFavorite)
        }
        
        // Test unmarking favorite
        paper.setFavorite(false)
        #expect(paper.isFavorite == false)
        #expect(paper.favoritedDate == nil)
    }
    
    @Test("ArXivPaper URL validation")
    func testArXivPaperURLValidation() throws {
        let paper = ArXivPaper(
            id: "2023.12345v1",
            title: "Test Paper",
            summary: "Test Summary",
            authors: "Test Author",
            publishedDate: Date(),
            pdfURL: "https://arxiv.org/pdf/2023.12345v1.pdf",
            linkURL: "https://arxiv.org/abs/2023.12345v1",
            categories: "cs.AI"
        )
        
        // Verify URLs are valid
        #expect(paper.pdfURL.hasPrefix("https://arxiv.org/pdf/"))
        #expect(paper.linkURL.hasPrefix("https://arxiv.org/abs/"))
        #expect(paper.pdfURL.contains(paper.id))
        #expect(paper.linkURL.contains(paper.id))
    }
    
    @Test("ArXivPaper ID uniqueness")
    func testArXivPaperIDUniqueness() throws {
        let paper1 = ArXivPaper(
            id: "2023.12345v1",
            title: "Test Paper 1",
            summary: "Test Summary 1",
            authors: "Test Author 1",
            publishedDate: Date(),
            pdfURL: "https://arxiv.org/pdf/2023.12345v1.pdf",
            linkURL: "https://arxiv.org/abs/2023.12345v1",
            categories: "cs.AI"
        )
        
        let paper2 = ArXivPaper(
            id: "2023.12346v1",
            title: "Test Paper 2",
            summary: "Test Summary 2",
            authors: "Test Author 2",
            publishedDate: Date(),
            pdfURL: "https://arxiv.org/pdf/2023.12346v1.pdf",
            linkURL: "https://arxiv.org/abs/2023.12346v1",
            categories: "cs.LG"
        )
        
        #expect(paper1.id != paper2.id)
        #expect(paper1.title != paper2.title)
    }
}
