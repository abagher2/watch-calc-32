import XCTest

final class TestBasicEnter: XCTestCase {
    func testEnterShows1() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()
        
        let display = app.staticTexts["lcd_display"]
        XCTAssertTrue(display.waitForExistence(timeout: 5))
        
        app.buttons["btn_1"].tap()
        app.otherElements["invisible_ENTER"].tap()
        
        XCTAssertEqual(display.label, "1")
    }
}
