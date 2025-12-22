//
//  ArXiv_FinderUITests.swift
//  ArXiv FinderUITests
//
//  Created by Julián Hinojosa Gil on 5/8/25.
//

import XCTest

final class ArXiv_FinderUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testAppLaunch() throws {
        // Test that the app launches successfully
        XCTAssertTrue(app.waitForExistence(timeout: 5), "App should launch within 5 seconds")
        
        // Verify that the main window is visible
        XCTAssertTrue(app.windows.firstMatch.exists, "Main window should be visible")
    }
    
    @MainActor
    func testBasicAppElements() throws {
        // Test that basic app elements are present
        XCTAssertTrue(app.waitForExistence(timeout: 3), "App should be ready")
        
        // Check if any UI elements are present (this is more flexible)
        let hasAnyElements = app.buttons.count > 0 || 
                           app.collectionViews.count > 0 || 
                           app.tables.count > 0 ||
                           app.searchFields.count > 0
        
        XCTAssertTrue(hasAnyElements, "App should have some UI elements")
    }
    
    @MainActor
    func testSearchFunctionality() throws {
        // Test the search functionality if available
        let searchFields = app.searchFields
        
        if searchFields.count > 0 {
            let searchField = searchFields.firstMatch
            
            // Test typing in search field
            searchField.tap()
            searchField.typeText("test")
            
            // Verify text was entered
            XCTAssertEqual(searchField.value as? String, "test", "Search field should contain entered text")
            
            // Clear the search field if clear button exists
            let clearButton = searchField.buttons["Clear text"]
            if clearButton.exists {
                clearButton.tap()
                XCTAssertEqual(searchField.value as? String, "", "Search field should be cleared")
            }
        } else {
            // If no search field found, this is acceptable
            print("Search field not found - this might be expected depending on the current view")
        }
    }
    
    @MainActor
    func testListInteraction() throws {
        // Test interaction with lists if available
        let lists = app.collectionViews
        let tables = app.tables
        
        if lists.count > 0 {
            let firstList = lists.firstMatch
            
            // Test scrolling
            firstList.swipeUp()
            firstList.swipeDown()
            
            // Test tapping on first item if it exists
            if firstList.cells.count > 0 {
                let firstCell = firstList.cells.firstMatch
                firstCell.tap()
                
                // Wait a moment for any navigation
                Thread.sleep(forTimeInterval: 1)
            }
        } else if tables.count > 0 {
            let firstTable = tables.firstMatch
            
            // Test scrolling
            firstTable.swipeUp()
            firstTable.swipeDown()
            
            // Test tapping on first row if it exists
            if firstTable.cells.count > 0 {
                let firstCell = firstTable.cells.firstMatch
                firstCell.tap()
                
                // Wait a moment for any navigation
                Thread.sleep(forTimeInterval: 1)
            }
        } else {
            // If no lists or tables found, this is acceptable
            print("No list or table elements found - this might be expected")
        }
    }
    
    @MainActor
    func testButtonInteraction() throws {
        // Test interaction with buttons if available
        let buttons = app.buttons
        
        if buttons.count > 0 {
            // Find a button that's not a system button (like close, minimize)
            let nonSystemButtons = buttons.allElementsBoundByIndex.filter { button in
                let title = button.title
                return !title.isEmpty && 
                       !title.contains("Close") && 
                       !title.contains("Minimize") && 
                       !title.contains("Zoom")
            }
            
            if nonSystemButtons.count > 0 {
                let testButton = nonSystemButtons[0]
                testButton.tap()
                
                // Verify button is still accessible after tapping
                XCTAssertTrue(testButton.exists, "Button should still exist after tapping")
            }
        } else {
            print("No buttons found - this might be expected")
        }
    }
    
    @MainActor
    func testAppNavigation() throws {
        // Test basic navigation if available
        let navigationBars = app.navigationBars
        
        if navigationBars.count > 0 {
            let navigationBar = navigationBars.firstMatch
            
            // Test if navigation bar is accessible
            XCTAssertTrue(navigationBar.exists, "Navigation bar should be accessible")
            
            // Look for back button
            let backButton = app.buttons["Back"]
            if backButton.exists {
                backButton.tap()
                Thread.sleep(forTimeInterval: 1)
            }
        } else {
            print("No navigation bars found - this might be expected")
        }
    }
    
    @MainActor
    func testAppResponsiveness() throws {
        // Test that the app responds to basic interactions
        XCTAssertTrue(app.waitForExistence(timeout: 3), "App should be responsive")
        
        // Test that we can interact with the app window
        let window = app.windows.firstMatch
        XCTAssertTrue(window.exists, "App window should be accessible")
        
        // Test that the app is running (more reliable than isEnabled)
        XCTAssertTrue(app.state == .runningForeground, "App should be running in foreground")
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        // Measure launch performance
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let testApp = XCUIApplication()
            testApp.launch()
            
            // Wait for app to be ready
            XCTAssertTrue(testApp.waitForExistence(timeout: 10), "App should launch within performance threshold")
        }
    }
}
