import XCTest

class CrossSurfaceFuzzTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }

    func clearApp() {
        app.buttons["btn_yellow_shift"].tap()
        app.buttons["func_←"].tap()
        if app.buttons["Clear ALL"].exists {
            app.buttons["Clear ALL"].firstMatch.tap()
        } else if app.buttons["ALL"].exists {
            app.buttons["ALL"].firstMatch.tap()
        }
    }

    func testFuzzSequence_0() throws {
        clearApp()
        app.buttons["btn_1"].tap()
        app.buttons["func_ENTER"].tap()
        app.buttons["btn_0"].tap()
        app.buttons["func_÷"].tap()

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("DIVIDE BY 0"), "Expected DIVIDE BY 0, got \(lcd)")
    }

    func testFuzzSequence_1() throws {
        clearApp()
        app.buttons["func_-"].tap()
        app.buttons["btn_1"].tap()
        app.buttons["func_√𝑥"].tap()

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("1"), "Expected 1, got \(lcd)")
    }

    func testFuzzSequence_2() throws {
        clearApp()
        app.buttons["btn_0"].tap()
        app.buttons["func_LN"].tap()

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("DIVIDE BY 0"), "Expected DIVIDE BY 0, got \(lcd)")
    }

    func testFuzzSequence_3() throws {
        clearApp()
        app.buttons["func_ENTER"].tap()
        app.buttons["func_ENTER"].tap()
        app.buttons["func_+"].tap()
        app.buttons["func_+"].tap()

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("0"), "Expected 0, got \(lcd)")
    }

    func testFuzzSequence_4() throws {
        clearApp()
        app.buttons["btn_3"].tap()
        app.buttons["btn_0"].tap()
        app.buttons["btn_8"].tap()
        app.buttons["btn_7"].tap()
        app.buttons["btn_7"].tap()
        app.buttons["btn_4"].tap()
        app.buttons["btn_3"].tap()
        app.buttons["func_LN"].tap()
        app.buttons["func_÷"].tap()
        app.buttons["btn_2"].tap()
        app.buttons["func_𝑦ˣ"].tap()
        app.buttons["func_ENTER"].tap()
        app.buttons["btn_1"].tap()
        app.buttons["btn_0"].tap()
        app.buttons["btn_2"].tap()

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("102"), "Expected 102, got \(lcd)")
    }

    func testFuzzSequence_5() throws {
        clearApp()
        app.buttons["btn_7"].tap()
        app.buttons["func_×"].tap()
        app.buttons["func_√𝑥"].tap()
        app.buttons["btn_0"].tap()
        app.buttons["func_÷"].tap()
        app.buttons["btn_6"].tap()
        app.buttons["func_1/𝑥"].tap()
        app.buttons["func_÷"].tap()

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("DIVIDE BY 0"), "Expected DIVIDE BY 0, got \(lcd)")
    }

    func testFuzzSequence_6() throws {
        clearApp()
        app.buttons["btn_7"].tap()
        app.buttons["func_+"].tap()
        app.buttons["func_𝑦ˣ"].tap()
        app.buttons["btn_8"].tap()
        app.buttons["btn_0"].tap()
        app.buttons["btn_5"].tap()
        app.buttons["func_ENTER"].tap()
        app.buttons["btn_dot"].tap()
        app.buttons["btn_8"].tap()
        app.buttons["btn_4"].tap()
        app.buttons["btn_6"].tap()

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("0.846"), "Expected 0.846, got \(lcd)")
    }

    func testFuzzSequence_7() throws {
        clearApp()
        app.buttons["btn_3"].tap()
        app.buttons["btn_2"].tap()
        app.buttons["func_E"].tap()
        app.buttons["btn_3"].tap()
        app.buttons["func_+/-"].tap()
        app.buttons["func_+/-"].tap()
        app.buttons["func_√𝑥"].tap()
        app.buttons["btn_8"].tap()
        app.buttons["btn_1"].tap()
        app.buttons["func_+"].tap()

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("32,081"), "Expected 32,081, got \(lcd)")
    }

    func testFuzzSequence_8() throws {
        clearApp()
        app.buttons["btn_3"].tap()
        app.buttons["func_E"].tap()
        app.buttons["btn_2"].tap()
        app.buttons["func_÷"].tap()
        app.buttons["btn_9"].tap()
        app.buttons["func_1/𝑥"].tap()
        app.buttons["func_√𝑥"].tap()
        app.buttons["func_+/-"].tap()
        app.buttons["func_𝑦ˣ"].tap()
        app.buttons["btn_6"].tap()
        app.buttons["btn_2"].tap()
        app.buttons["btn_1"].tap()
        app.buttons["func_LN"].tap()

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("6.4313310819"), "Expected 6.4313310819, got \(lcd)")
    }

    func testFuzzSequence_9() throws {
        clearApp()
        app.buttons["btn_9"].tap()
        app.buttons["btn_2"].tap()
        app.buttons["btn_7"].tap()
        app.buttons["btn_3"].tap()
        app.buttons["func_E"].tap()
        app.buttons["btn_8"].tap()
        app.buttons["func_+"].tap()
        app.buttons["func_1/𝑥"].tap()

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("9.273E11"), "Expected 9.273E11, got \(lcd)")
    }

    func testFuzzSequence_10() throws {
        clearApp()
        app.buttons["btn_5"].tap()
        app.buttons["func_+/-"].tap()
        app.buttons["func_+/-"].tap()
        app.buttons["btn_6"].tap()
        app.buttons["func_LN"].tap()
        app.buttons["btn_8"].tap()
        app.buttons["func_LN"].tap()
        app.buttons["func_1/𝑥"].tap()
        app.buttons["btn_2"].tap()
        app.buttons["func_√𝑥"].tap()

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("2"), "Expected 2, got \(lcd)")
    }

    func testFuzzSequence_11() throws {
        clearApp()
        app.buttons["btn_5"].tap()
        app.buttons["func_÷"].tap()
        app.buttons["btn_7"].tap()
        app.buttons["btn_5"].tap()
        app.buttons["func_+"].tap()
        app.buttons["func_E"].tap()
        app.buttons["btn_8"].tap()
        app.buttons["func_1/𝑥"].tap()
        app.buttons["func_÷"].tap()
        app.buttons["btn_7"].tap()
        app.buttons["func_LN"].tap()
        app.buttons["btn_dot"].tap()
        app.buttons["btn_1"].tap()
        app.buttons["btn_7"].tap()
        app.buttons["btn_1"].tap()

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("0.171"), "Expected 0.171, got \(lcd)")
    }

    func testFuzzSequence_12() throws {
        clearApp()
        app.buttons["func_E"].tap()
        app.buttons["btn_8"].tap()
        app.buttons["btn_2"].tap()
        app.buttons["btn_6"].tap()
        app.buttons["func_𝑦ˣ"].tap()
        app.buttons["btn_dot"].tap()
        app.buttons["btn_6"].tap()
        app.buttons["func_1/𝑥"].tap()
        app.buttons["func_-"].tap()
        app.buttons["func_E"].tap()

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("0.6"), "Expected 0.6, got \(lcd)")
    }

    func testFuzzSequence_13() throws {
        clearApp()
        app.buttons["func_+"].tap()
        app.buttons["btn_4"].tap()
        app.buttons["btn_8"].tap()
        app.buttons["btn_4"].tap()
        app.buttons["btn_7"].tap()
        app.buttons["func_÷"].tap()
        app.buttons["func_÷"].tap()
        app.buttons["btn_8"].tap()
        app.buttons["func_𝑦ˣ"].tap()
        app.buttons["func_ENTER"].tap()
        app.buttons["func_𝑦ˣ"].tap()
        app.buttons["func_E"].tap()
        app.buttons["func_+/-"].tap()
        app.buttons["btn_7"].tap()
        app.buttons["btn_4"].tap()

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("1E-74"), "Expected 1E-74, got \(lcd)")
    }
}
