import XCTest

@MainActor final class TestRetroUIDisplay: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testRetroUIRenderingIsNotBlank() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-ForceTheme")
        app.launchArguments.append("Retro (Pixel LCD)")
        app.launch()
        
        let hexBuffer = app.staticTexts["lcd_buffer_hex"]
        XCTAssertTrue(hexBuffer.waitForExistence(timeout: 5), "Retro LCD Buffer must exist in Retro mode")
        
        var label = ""
        var isAllZero = true
        for _ in 0..<10 {
            label = hexBuffer.label
            if !label.isEmpty && !label.allSatisfy({ $0 == "0" }) {
                isAllZero = false
                break
            }
            Thread.sleep(forTimeInterval: 0.5)
        }
        
        XCTAssertFalse(label.isEmpty, "Buffer hex string is empty!")
        XCTAssertFalse(isAllZero, "The RetroLCD is completely blank! Buffer is all zeros.")
    }
}
