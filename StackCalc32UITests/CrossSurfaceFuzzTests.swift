import XCTest

class CrossSurfaceFuzzTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }


    func deletedTapButton(_ id: String) {
        if id == "op_enter" { app.tapEnter(); return }
        if app.buttons[id].exists {
            app.navigateAndTap(id)
        } else {
            app.swipeLeft()
            if app.buttons[id].exists { app.navigateAndTap(id); return }
            app.swipeRight(); app.swipeRight()
            if app.buttons[id].exists { app.navigateAndTap(id); return }
            app.swipeLeft()
            app.swipeDown()
            if app.buttons[id].exists { app.navigateAndTap(id); return }
            app.tapEnter()
            app.navigateAndTap(id)
        }
    }

    func clearApp() {
        app.navigateAndTap("op_shiftYellow")
        app.navigateAndTap("op_backspace")
        if app.buttons["Clear ALL"].exists {
            app.navigateAndTap("Clear ALL")
        } else if app.buttons["ALL"].exists {
            app.navigateAndTap("ALL")
        }
    }

    func testFuzzSequence_0() throws {
        clearApp()
        app.navigateAndTap("op_digit1")
        app.navigateAndTap("op_enter")
        app.navigateAndTap("op_digit0")
        app.navigateAndTap("op_divide")

        let lcd = app.staticTexts["lcd_display"].label
        XCTAssertTrue(lcd.contains("DIVIDE BY 0"), "Expected DIVIDE BY 0, got \(lcd)")
    }

    func testFuzzSequence_1() throws {
        clearApp()
        app.navigateAndTap("op_subtract")
        app.navigateAndTap("op_digit1")
        app.navigateAndTap("op_sqrt")

        let lcd = app.staticTexts["lcd_display"].label
        XCTAssertTrue(lcd.contains("1"), "Expected 1, got \(lcd)")
    }

    func testFuzzSequence_2() throws {
        clearApp()
        app.navigateAndTap("op_digit0")
        app.navigateAndTap("op_ln")

        let lcd = app.staticTexts["lcd_display"].label
        XCTAssertTrue(lcd.contains("DIVIDE BY 0"), "Expected DIVIDE BY 0, got \(lcd)")
    }

    func testFuzzSequence_3() throws {
        clearApp()
        app.navigateAndTap("op_enter")
        app.navigateAndTap("op_enter")
        app.navigateAndTap("op_add")
        app.navigateAndTap("op_add")

        let lcd = app.staticTexts["lcd_display"].label
        XCTAssertTrue(lcd.contains("0"), "Expected 0, got \(lcd)")
    }

    func testFuzzSequence_4() throws {
        clearApp()
        app.navigateAndTap("op_digit3")
        app.navigateAndTap("op_digit0")
        app.navigateAndTap("op_digit8")
        app.navigateAndTap("op_digit7")
        app.navigateAndTap("op_digit7")
        app.navigateAndTap("op_digit4")
        app.navigateAndTap("op_digit3")
        app.navigateAndTap("op_ln")
        app.navigateAndTap("op_divide")
        app.navigateAndTap("op_digit2")
        app.navigateAndTap("op_power")
        app.navigateAndTap("op_enter")
        app.navigateAndTap("op_digit1")
        app.navigateAndTap("op_digit0")
        app.navigateAndTap("op_digit2")

        let lcd = app.staticTexts["lcd_display"].label
        XCTAssertTrue(lcd.contains("102"), "Expected 102, got \(lcd)")
    }

    func testFuzzSequence_5() throws {
        clearApp()
        app.navigateAndTap("op_digit7")
        app.navigateAndTap("op_multiply")
        app.navigateAndTap("op_sqrt")
        app.navigateAndTap("op_digit0")
        app.navigateAndTap("op_divide")
        app.navigateAndTap("op_digit6")
        app.navigateAndTap("op_reciprocal")
        app.navigateAndTap("op_divide")

        let lcd = app.staticTexts["lcd_display"].label
        XCTAssertTrue(lcd.contains("0"), "Expected 0, got \(lcd)")
    }

    func testFuzzSequence_6() throws {
        clearApp()
        app.navigateAndTap("op_digit7")
        app.navigateAndTap("op_add")
        app.navigateAndTap("op_power")
        app.navigateAndTap("op_digit8")
        app.navigateAndTap("op_digit0")
        app.navigateAndTap("op_digit5")
        app.navigateAndTap("op_enter")
        app.navigateAndTap("op_decimal")
        app.navigateAndTap("op_digit8")
        app.navigateAndTap("op_digit4")
        app.navigateAndTap("op_digit6")

        let lcd = app.staticTexts["lcd_display"].label
        XCTAssertTrue(lcd.contains("0.846"), "Expected 0.846, got \(lcd)")
    }

    func testFuzzSequence_7() throws {
        clearApp()
        app.navigateAndTap("op_digit3")
        app.navigateAndTap("op_digit2")
        app.navigateAndTap("op_e")
        app.navigateAndTap("op_digit3")
        app.navigateAndTap("op_toggleSign")
        app.navigateAndTap("op_toggleSign")
        app.navigateAndTap("op_sqrt")
        app.navigateAndTap("op_digit8")
        app.navigateAndTap("op_digit1")
        app.navigateAndTap("op_add")

        let lcd = app.staticTexts["lcd_display"].label
        XCTAssertTrue(lcd.contains("32,081"), "Expected 32,081, got \(lcd)")
    }

    func testFuzzSequence_8() throws {
        clearApp()
        app.navigateAndTap("op_digit3")
        app.navigateAndTap("op_e")
        app.navigateAndTap("op_digit2")
        app.navigateAndTap("op_divide")
        app.navigateAndTap("op_digit9")
        app.navigateAndTap("op_reciprocal")
        app.navigateAndTap("op_sqrt")
        app.navigateAndTap("op_toggleSign")
        app.navigateAndTap("op_power")
        app.navigateAndTap("op_digit6")
        app.navigateAndTap("op_digit2")
        app.navigateAndTap("op_digit1")
        app.navigateAndTap("op_ln")

        let lcd = app.staticTexts["lcd_display"].label
        XCTAssertTrue(lcd.contains("3.0445224377"), "Expected 3.0445224377, got \(lcd)")
    }

    func testFuzzSequence_9() throws {
        clearApp()
        app.navigateAndTap("op_digit9")
        app.navigateAndTap("op_digit2")
        app.navigateAndTap("op_digit7")
        app.navigateAndTap("op_digit3")
        app.navigateAndTap("op_e")
        app.navigateAndTap("op_digit8")
        app.navigateAndTap("op_add")
        app.navigateAndTap("op_reciprocal")

        let lcd = app.staticTexts["lcd_display"].label
        XCTAssertTrue(lcd.contains("1.0784E-12"), "Expected 1.0784E-12, got \(lcd)")
    }

    func testFuzzSequence_10() throws {
        clearApp()
        app.navigateAndTap("op_digit5")
        app.navigateAndTap("op_toggleSign")
        app.navigateAndTap("op_toggleSign")
        app.navigateAndTap("op_digit6")
        app.navigateAndTap("op_ln")
        app.navigateAndTap("op_digit8")
        app.navigateAndTap("op_ln")
        app.navigateAndTap("op_reciprocal")
        app.navigateAndTap("op_digit2")
        app.navigateAndTap("op_sqrt")

        let lcd = app.staticTexts["lcd_display"].label
        XCTAssertTrue(lcd.contains("2"), "Expected 2, got \(lcd)")
    }

    func testFuzzSequence_11() throws {
        clearApp()
        app.navigateAndTap("op_digit5")
        app.navigateAndTap("op_divide")
        app.navigateAndTap("op_digit7")
        app.navigateAndTap("op_digit5")
        app.navigateAndTap("op_add")
        app.navigateAndTap("op_e")
        app.navigateAndTap("op_digit8")
        app.navigateAndTap("op_reciprocal")
        app.navigateAndTap("op_divide")
        app.navigateAndTap("op_digit7")
        app.navigateAndTap("op_ln")
        app.navigateAndTap("op_decimal")
        app.navigateAndTap("op_digit1")
        app.navigateAndTap("op_digit7")
        app.navigateAndTap("op_digit1")

        let lcd = app.staticTexts["lcd_display"].label
        XCTAssertTrue(lcd.contains("0.171"), "Expected 0.171, got \(lcd)")
    }

    func testFuzzSequence_12() throws {
        clearApp()
        app.navigateAndTap("op_e")
        app.navigateAndTap("op_digit8")
        app.navigateAndTap("op_digit2")
        app.navigateAndTap("op_digit6")
        app.navigateAndTap("op_power")
        app.navigateAndTap("op_decimal")
        app.navigateAndTap("op_digit6")
        app.navigateAndTap("op_reciprocal")
        app.navigateAndTap("op_subtract")
        app.navigateAndTap("op_e")

        let lcd = app.staticTexts["lcd_display"].label
        XCTAssertTrue(lcd.contains("1E0"), "Expected 1E0, got \(lcd)")
    }

    func testFuzzSequence_13() throws {
        clearApp()
        app.navigateAndTap("op_add")
        app.navigateAndTap("op_digit4")
        app.navigateAndTap("op_digit8")
        app.navigateAndTap("op_digit4")
        app.navigateAndTap("op_digit7")
        app.navigateAndTap("op_divide")
        app.navigateAndTap("op_divide")
        app.navigateAndTap("op_digit8")
        app.navigateAndTap("op_power")
        app.navigateAndTap("op_enter")
        app.navigateAndTap("op_power")
        app.navigateAndTap("op_e")
        app.navigateAndTap("op_toggleSign")
        app.navigateAndTap("op_digit7")
        app.navigateAndTap("op_digit4")

        let lcd = app.staticTexts["lcd_display"].label
        XCTAssertTrue(lcd.contains("1E-74"), "Expected 1E-74, got \(lcd)")
    }
}
