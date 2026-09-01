import XCTest

final class TestBasicEnter: XCTestCase {
    func testEnterShows1() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()
        
        let display = app.descendants(matching: .any)["lcd_display"]
        XCTAssertTrue(display.waitForExistence(timeout: 5))
        
        app.navigateAndTap("op_digit1")
        app.tapEnter()
        
        XCTAssertEqual(display.label, "1")
    }
}
