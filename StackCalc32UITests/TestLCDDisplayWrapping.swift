import XCTest

@MainActor final class TestLCDDisplayWrapping: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLCDScrollViewBehavior() throws {
        let app = XCUIApplication()
        // Ensure modern layout to test LCDDisplayView
        app.launchArguments.append("-UITesting")
        app.launchArguments.append("-ForceTheme")
        app.launchArguments.append("Modern")
        app.launch()
        
        // Find the LCD display text
        let lcdText = app.staticTexts["lcd_display"]
        XCTAssertTrue(lcdText.waitForExistence(timeout: 5), "LCD display must exist")
        
        // 1. While NOT typing, there should be NO scroll view wrapping the LCD
        // We will tap CLEAR to ensure we are in a clean evaluated state (0)
        app.navigateAndTap("op_backspace")
        
        // The LCD display is typically inside a ScrollView only if isBuildingNumber is true
        // If it's 0 (evaluated), no ScrollView should be present in that exact hierarchy
        // We can query scrollViews. Wait, the main UI might have scroll views.
        // We can check if the lcd_display's parent is a ScrollView.
        // XCUITest doesn't allow parent traversal easily, but we can check the count of scrollviews.
        let initialScrollViewsCount = app.scrollViews.count
        
        // 2. Start typing a long number
        let keys = ["op_digit1", "op_digit2", "op_digit3", "op_digit4", "op_decimal", "op_digit5", "op_digit6", "op_digit7", "op_digit8"]
        for key in keys {
            app.navigateAndTap(key)
        }
        
        // 3. While typing, a ScrollView should appear for the LCD
        XCTAssertEqual(app.scrollViews.count, initialScrollViewsCount + 1, "A new ScrollView should appear for the LCD while typing")
        
        // 4. Hit ENTER
        if app.buttons["sim_swipe_up"].waitForExistence(timeout: 1.0) {
            app.navigateAndTap("sim_swipe_up")
        } else {
            app.navigateAndTap("op_enter") // Fallback
        }
        
        // 5. After ENTER, it is evaluated. The ScrollView should disappear!
        XCTAssertEqual(app.scrollViews.count, initialScrollViewsCount, "The ScrollView should be removed after evaluation to prevent wrapping/scrolling")
    }
}
