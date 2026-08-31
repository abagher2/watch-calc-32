import XCTest

class CrossSurfaceFuzzTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }


    func tapButton(_ id: String) {
        if app.buttons[id].exists {
            app.buttons[id].firstMatch.tap()
        } else {
            app.swipeLeft()
            if app.buttons[id].exists { app.buttons[id].firstMatch.tap(); return }
            app.swipeRight(); app.swipeRight()
            if app.buttons[id].exists { app.buttons[id].firstMatch.tap(); return }
            app.swipeLeft()
            app.swipeDown()
            if app.buttons[id].exists { app.buttons[id].firstMatch.tap(); return }
            app.swipeUp()
            app.buttons[id].firstMatch.tap()
        }
    }

    func clearApp() {
        tapButton("op_shiftYellow")
        tapButton("op_backspace")
        if app.buttons["Clear ALL"].exists {
            app.buttons["Clear ALL"].firstMatch.tap()
        } else if app.buttons["ALL"].exists {
            app.buttons["ALL"].firstMatch.tap()
        }
    }

    func testFuzzSequence_0() throws {
        clearApp()
        tapButton("op_digit1")
        tapButton("op_enter")
        tapButton("op_digit0")
        tapButton("op_divide")

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("DIVIDE BY 0"), "Expected DIVIDE BY 0, got \(lcd)")
    }

    func testFuzzSequence_1() throws {
        clearApp()
        tapButton("op_subtract")
        tapButton("op_digit1")
        tapButton("op_sqrt")

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("1"), "Expected 1, got \(lcd)")
    }

    func testFuzzSequence_2() throws {
        clearApp()
        tapButton("op_digit0")
        tapButton("op_ln")

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("DIVIDE BY 0"), "Expected DIVIDE BY 0, got \(lcd)")
    }

    func testFuzzSequence_3() throws {
        clearApp()
        tapButton("op_enter")
        tapButton("op_enter")
        tapButton("op_add")
        tapButton("op_add")

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("0"), "Expected 0, got \(lcd)")
    }

    func testFuzzSequence_4() throws {
        clearApp()
        tapButton("op_digit3")
        tapButton("op_digit0")
        tapButton("op_digit8")
        tapButton("op_digit7")
        tapButton("op_digit7")
        tapButton("op_digit4")
        tapButton("op_digit3")
        tapButton("op_ln")
        tapButton("op_divide")
        tapButton("op_digit2")
        tapButton("op_power")
        tapButton("op_enter")
        tapButton("op_digit1")
        tapButton("op_digit0")
        tapButton("op_digit2")

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("102"), "Expected 102, got \(lcd)")
    }

    func testFuzzSequence_5() throws {
        clearApp()
        tapButton("op_digit7")
        tapButton("op_multiply")
        tapButton("op_sqrt")
        tapButton("op_digit0")
        tapButton("op_divide")
        tapButton("op_digit6")
        tapButton("op_reciprocal")
        tapButton("op_divide")

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("0"), "Expected 0, got \(lcd)")
    }

    func testFuzzSequence_6() throws {
        clearApp()
        tapButton("op_digit7")
        tapButton("op_add")
        tapButton("op_power")
        tapButton("op_digit8")
        tapButton("op_digit0")
        tapButton("op_digit5")
        tapButton("op_enter")
        tapButton("op_decimal")
        tapButton("op_digit8")
        tapButton("op_digit4")
        tapButton("op_digit6")

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("0.846"), "Expected 0.846, got \(lcd)")
    }

    func testFuzzSequence_7() throws {
        clearApp()
        tapButton("op_digit3")
        tapButton("op_digit2")
        tapButton("op_e")
        tapButton("op_digit3")
        tapButton("op_toggleSign")
        tapButton("op_toggleSign")
        tapButton("op_sqrt")
        tapButton("op_digit8")
        tapButton("op_digit1")
        tapButton("op_add")

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("32,081"), "Expected 32,081, got \(lcd)")
    }

    func testFuzzSequence_8() throws {
        clearApp()
        tapButton("op_digit3")
        tapButton("op_e")
        tapButton("op_digit2")
        tapButton("op_divide")
        tapButton("op_digit9")
        tapButton("op_reciprocal")
        tapButton("op_sqrt")
        tapButton("op_toggleSign")
        tapButton("op_power")
        tapButton("op_digit6")
        tapButton("op_digit2")
        tapButton("op_digit1")
        tapButton("op_ln")

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("3.0445224377"), "Expected 3.0445224377, got \(lcd)")
    }

    func testFuzzSequence_9() throws {
        clearApp()
        tapButton("op_digit9")
        tapButton("op_digit2")
        tapButton("op_digit7")
        tapButton("op_digit3")
        tapButton("op_e")
        tapButton("op_digit8")
        tapButton("op_add")
        tapButton("op_reciprocal")

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("1.0784E-12"), "Expected 1.0784E-12, got \(lcd)")
    }

    func testFuzzSequence_10() throws {
        clearApp()
        tapButton("op_digit5")
        tapButton("op_toggleSign")
        tapButton("op_toggleSign")
        tapButton("op_digit6")
        tapButton("op_ln")
        tapButton("op_digit8")
        tapButton("op_ln")
        tapButton("op_reciprocal")
        tapButton("op_digit2")
        tapButton("op_sqrt")

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("2"), "Expected 2, got \(lcd)")
    }

    func testFuzzSequence_11() throws {
        clearApp()
        tapButton("op_digit5")
        tapButton("op_divide")
        tapButton("op_digit7")
        tapButton("op_digit5")
        tapButton("op_add")
        tapButton("op_e")
        tapButton("op_digit8")
        tapButton("op_reciprocal")
        tapButton("op_divide")
        tapButton("op_digit7")
        tapButton("op_ln")
        tapButton("op_decimal")
        tapButton("op_digit1")
        tapButton("op_digit7")
        tapButton("op_digit1")

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("0.171"), "Expected 0.171, got \(lcd)")
    }

    func testFuzzSequence_12() throws {
        clearApp()
        tapButton("op_e")
        tapButton("op_digit8")
        tapButton("op_digit2")
        tapButton("op_digit6")
        tapButton("op_power")
        tapButton("op_decimal")
        tapButton("op_digit6")
        tapButton("op_reciprocal")
        tapButton("op_subtract")
        tapButton("op_e")

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("1E0"), "Expected 1E0, got \(lcd)")
    }

    func testFuzzSequence_13() throws {
        clearApp()
        tapButton("op_add")
        tapButton("op_digit4")
        tapButton("op_digit8")
        tapButton("op_digit4")
        tapButton("op_digit7")
        tapButton("op_divide")
        tapButton("op_divide")
        tapButton("op_digit8")
        tapButton("op_power")
        tapButton("op_enter")
        tapButton("op_power")
        tapButton("op_e")
        tapButton("op_toggleSign")
        tapButton("op_digit7")
        tapButton("op_digit4")

        let lcd = app.staticTexts["LCD"].label
        XCTAssertTrue(lcd.contains("1E-74"), "Expected 1E-74, got \(lcd)")
    }
}
