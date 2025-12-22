//
//  ArXiv_FinderUITestsLaunchTests.swift
//  ArXiv FinderUITests
//
//  Created by Julián Hinojosa Gil on 5/8/25.
//

import XCTest

final class ArXiv_FinderUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Wait for app to be ready
        XCTAssertTrue(app.waitForExistence(timeout: 5), "App should launch successfully")

        // Take screenshot of launch screen
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    @MainActor
    func testLaunchWithDarkMode() throws {
        // Test app launch in dark mode
        let app = XCUIApplication()
        app.launchArguments = ["-UIUserInterfaceStyle", "Dark"]
        app.launch()
        
        // Wait for app to fully load
        XCTAssertTrue(app.waitForExistence(timeout: 5), "App should launch in dark mode")
        
        // Take screenshot of dark mode launch
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen - Dark Mode"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    @MainActor
    func testLaunchWithLightMode() throws {
        // Test app launch in light mode
        let app = XCUIApplication()
        app.launchArguments = ["-UIUserInterfaceStyle", "Light"]
        app.launch()
        
        // Wait for app to fully load
        XCTAssertTrue(app.waitForExistence(timeout: 5), "App should launch in light mode")
        
        // Take screenshot of light mode launch
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen - Light Mode"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    @MainActor
    func testLaunchWithLargeText() throws {
        // Test app launch with accessibility large text
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge"]
        app.launch()
        
        // Wait for app to fully load
        XCTAssertTrue(app.waitForExistence(timeout: 5), "App should launch with large text")
        
        // Take screenshot of large text launch
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen - Large Text"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        // Measure launch performance
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launch()
            
            // Wait for app to be ready
            XCTAssertTrue(app.waitForExistence(timeout: 10), "App should launch within performance threshold")
        }
    }
}
