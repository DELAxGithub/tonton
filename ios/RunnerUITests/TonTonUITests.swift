//
//  TonTonUITests.swift
//  RunnerUITests
//
//  UI Tests for automated screenshot generation
//

import XCTest

class TonTonUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        // Enable continued execution after failure
        continueAfterFailure = false
        
        // Initialize app
        app = XCUIApplication()
        
        // Setup snapshot
        setupSnapshot(app)
        
        // Add UI test launch arguments
        app.launchArguments.append("--UITest")
        app.launchArguments.append("--DisableAnimations")
        app.launchArguments.append("--ResetData") // Clear data for consistent screenshots
        
        // Launch the app
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCaptureScreenshots() {
        // Wait for app to load
        sleep(2)
        
        // 1. Capture Home Screen with savings balance
        captureHomeScreen()
        
        // 2. Capture Meal Records List
        captureMealRecordsList()
        
        // 3. Capture AI Meal Analysis
        captureAIMealAnalysis()
        
        // 4. Capture Monthly Progress Graph
        captureMonthlyProgress()
        
        // 5. Capture Empty States
        captureEmptyStates()
        
        // 6. Capture Profile/Settings
        captureProfileScreen()
    }
    
    func captureHomeScreen() {
        // Wait for home screen to load
        let homeTitle = app.staticTexts["home_greeting"] // Accessibility ID needed
        _ = homeTitle.waitForExistence(timeout: 5)
        
        // Take screenshot
        snapshot("01_home_screen")
        
        // Wait a moment for animations
        sleep(1)
    }
    
    func captureMealRecordsList() {
        // Navigate to meals if not already there
        if app.tabBars.buttons["meals_tab"].exists {
            app.tabBars.buttons["meals_tab"].tap()
        }
        
        // Wait for meal list to load
        let mealList = app.tables["meal_records_table"] // Accessibility ID needed
        _ = mealList.waitForExistence(timeout: 5)
        
        // Scroll to show variety
        if mealList.cells.count > 3 {
            mealList.swipeUp()
        }
        
        snapshot("02_meal_records")
        
        sleep(1)
    }
    
    func captureAIMealAnalysis() {
        // Navigate to meal logging
        if app.buttons["add_meal_button"].exists {
            app.buttons["add_meal_button"].tap()
        }
        
        // Wait for camera/AI screen
        sleep(2)
        
        // For demo purposes, we'll capture the meal entry screen
        // In real implementation, we'd have a pre-analyzed meal to show
        snapshot("03_ai_meal_analysis")
        
        // Go back
        if app.navigationBars.buttons.element(boundBy: 0).exists {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        
        sleep(1)
    }
    
    func captureMonthlyProgress() {
        // Navigate to progress/insights tab
        if app.tabBars.buttons["insights_tab"].exists {
            app.tabBars.buttons["insights_tab"].tap()
        }
        
        // Wait for graphs to load
        let progressChart = app.otherElements["progress_chart"] // Accessibility ID needed
        _ = progressChart.waitForExistence(timeout: 5)
        
        snapshot("04_monthly_progress")
        
        sleep(1)
    }
    
    func captureEmptyStates() {
        // This would require a fresh install or data reset
        // For now, we'll capture whatever empty state we can find
        
        // Try to find an empty state in savings
        if app.tabBars.buttons["savings_tab"].exists {
            app.tabBars.buttons["savings_tab"].tap()
            sleep(2)
            snapshot("05_empty_state")
        }
        
        sleep(1)
    }
    
    func captureProfileScreen() {
        // Navigate to profile/settings
        if app.tabBars.buttons["profile_tab"].exists {
            app.tabBars.buttons["profile_tab"].tap()
        } else if app.navigationBars.buttons["settings_button"].exists {
            app.navigationBars.buttons["settings_button"].tap()
        }
        
        // Wait for profile to load
        let profileView = app.scrollViews["profile_scroll"] // Accessibility ID needed
        _ = profileView.waitForExistence(timeout: 5)
        
        snapshot("06_profile_settings")
        
        sleep(1)
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    func scrollToElement(element: XCUIElement) {
        while !element.visible() {
            swipeUp()
        }
    }
    
    func visible() -> Bool {
        guard self.exists && !self.frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }
}