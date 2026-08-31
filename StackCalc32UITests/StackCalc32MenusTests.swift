import XCTest

class StackCalc32MenusTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }


  private func navigateToArithmeticPad(app: XCUIApplication) {
    if app.buttons["op_multiply"].isHittable { return }
    navigateToNumericPad(app: app)
    app.buttons["sim_swipe_left"].tap()
    Thread.sleep(forTimeInterval: 0.5)
    if !app.buttons["op_multiply"].waitForExistence(timeout: 2.0) {
      print("ARITHMETIC PAD DEBUG DESC:")
      print(app.debugDescription)
      XCTFail("Failed to find func_×")
    }
  }

  private func centerVertically(app: XCUIApplication) -> Bool {
    if app.buttons["op_digit5"].isHittable { return true }
    if app.buttons["op_sto"].isHittable {
      app.buttons["sim_swipe_down"].tap()
      Thread.sleep(forTimeInterval: 0.5)
      if app.buttons["op_digit5"].isHittable { return true }
      
      // We might have gone in the wrong direction, try swiping up twice
      app.buttons["sim_swipe_up"].tap()
      Thread.sleep(forTimeInterval: 0.5)
      app.buttons["sim_swipe_up"].tap()
      Thread.sleep(forTimeInterval: 0.5)
      if app.buttons["op_digit5"].isHittable { return true }
    }
    return false
  }

  private func navigateToNumericPad(app: XCUIApplication) {
    if centerVertically(app: app) { return }
    
    app.buttons["sim_swipe_right"].tap()
    Thread.sleep(forTimeInterval: 0.5)
    if centerVertically(app: app) { return }
    
    app.buttons["sim_swipe_left"].tap()
    Thread.sleep(forTimeInterval: 0.5)
    if centerVertically(app: app) { return }
    
    app.buttons["sim_swipe_left"].tap()
    Thread.sleep(forTimeInterval: 0.5)
    if centerVertically(app: app) { return }
  }

  private func navigateToUpperMatrixPad(app: XCUIApplication) {
    if app.buttons["op_sto"].isHittable { return }
    navigateToNumericPad(app: app)
    app.buttons["sim_swipe_down"].tap()
    Thread.sleep(forTimeInterval: 0.5)
    XCTAssertTrue(app.buttons["op_sto"].waitForExistence(timeout: 2.0))
  }

    func testAllMenusAndOverlays() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()

        let display = app.descendants(matching: .any)["lcd_display"]
        XCTAssertTrue(display.waitForExistence(timeout: 5))

        let pad = app.otherElements["numpad_bg"]
        let yellow = app.buttons["btn_yellow_shift"]
        let blue = app.buttons["btn_blue_shift"]

        // We start on pad 1 (Numeric)
        XCTAssertTrue(app.buttons["op_digit5"].waitForExistence(timeout: 2.0))

        // Matrix1 page (swipe up)
        navigateToArithmeticPad(app: app)
        Thread.sleep(forTimeInterval: 1.0)

        let matrix1Triggers: [(shift: XCUIElement?, btn: String, title: String?)] = [
            (yellow, "op_toggleSign", "Modes"),
            (blue, "op_toggleSign", "Display"),
            (yellow, "op_backspace", "Clear")
        ]
        
        for t in matrix1Triggers {
            navigateToArithmeticPad(app: app)
            if let s = t.shift { s.tap() }
            app.buttons[t.btn].tap()
            
            if let title = t.title {
                if app.staticTexts[title].waitForExistence(timeout: 2.0) {
                    if app.buttons["sheet_dismiss_btn"].exists {
                        app.buttons["sheet_dismiss_btn"].firstMatch.tap()
                    } else if app.buttons["Cancel"].exists {
                        app.buttons["Cancel"].firstMatch.tap()
                    } else if app.buttons["Done"].exists {
                        app.buttons["Done"].firstMatch.tap()
                    } else {
                        app.staticTexts[title].swipeDown()
                    }
                    Thread.sleep(forTimeInterval: 1.0)
                }
            }
        }
        
        // Back to NumericPad (swipe down)
        navigateToNumericPad(app: app)
        Thread.sleep(forTimeInterval: 1.0)
        
        let numericTriggers: [(shift: XCUIElement?, btn: String, title: String?)] = [
            (blue, "op_digit7", "Solve"),
            (blue, "op_digit8", "Integrate"),
            (yellow, "op_toggleSign", "Plot")
        ]

        for t in numericTriggers {
            // Need to reset to page 1 to tap numeric keypad elements reliably if something hijacked it
            navigateToNumericPad(app: app)
            Thread.sleep(forTimeInterval: 0.5)
            
            if let s = t.shift { s.tap() }
            app.buttons[t.btn].tap()
            
            if let title = t.title {
                if app.staticTexts[title].waitForExistence(timeout: 2.0) {
                    if app.buttons["sheet_dismiss_btn"].exists {
                        app.buttons["sheet_dismiss_btn"].firstMatch.tap()
                    } else if app.buttons["Cancel"].exists {
                        app.buttons["Cancel"].firstMatch.tap()
                    } else if app.buttons["Done"].exists {
                        app.buttons["Done"].firstMatch.tap()
                    } else {
                        app.staticTexts[title].swipeDown()
                    }
                    Thread.sleep(forTimeInterval: 1.0)
                }
            }
        }

        // To Matrix3 (swipe up up up)
        navigateToUpperMatrixPad(app: app)
        Thread.sleep(forTimeInterval: 1.0)

        let matrix3Triggers: [(shift: XCUIElement?, btn: String, title: String?)] = [
            (blue, "op_exp", "PROB"),
            (yellow, "op_statAdd", "SUMS"),
            (blue, "op_ln", "L.R."),
            (blue, "op_power", "MEAN"),
            (blue, "op_reciprocal", "STD DEV")
        ]
        
        for t in matrix3Triggers {
            navigateToUpperMatrixPad(app: app)
            
            
            if let s = t.shift { s.tap() }
            app.buttons[t.btn].tap()
            
            if let title = t.title {
                if app.staticTexts[title].waitForExistence(timeout: 2.0) {
                    if app.buttons["sheet_dismiss_btn"].exists {
                        app.buttons["sheet_dismiss_btn"].firstMatch.tap()
                    } else if app.buttons["Cancel"].exists {
                        app.buttons["Cancel"].firstMatch.tap()
                    } else if app.buttons["Done"].exists {
                        app.buttons["Done"].firstMatch.tap()
                    } else {
                        app.staticTexts[title].swipeDown()
                    }
                    Thread.sleep(forTimeInterval: 1.0)
                }
            }
        }

        XCTAssertTrue(display.exists, "Display should still be alive after all menu testing")
    }

    func testAlphaEntryOverlayForSTOAndRCL() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()
        
        let display = app.descendants(matching: .any)["lcd_display"]
        XCTAssertTrue(display.waitForExistence(timeout: 5))
        
        // Push 5 to stack
        app.buttons["op_digit5"].tap()
        app.otherElements["invisible_ENTER"].tap() // ENTER
        
        // STO is on Matrix2 (swipe up up)
        navigateToUpperMatrixPad(app: app)
        Thread.sleep(forTimeInterval: 1.0)
        
        app.buttons["op_sto"].tap()
        // Should navigate to Alpha Entry pad
        XCTAssertTrue(app.buttons["alpha_A"].waitForExistence(timeout: 2.0), "Alpha pad should appear for STO")
        
        // Store in A
        app.buttons["alpha_A"].tap()
        Thread.sleep(forTimeInterval: 0.5)
        
        // Should auto-return
        XCTAssertFalse(app.buttons["alpha_A"].exists, "Alpha pad should dismiss after STO")
        Thread.sleep(forTimeInterval: 1.0)
        
        // RCL is on Matrix2 (swipe up up)
        navigateToUpperMatrixPad(app: app)
        Thread.sleep(forTimeInterval: 1.0)
        
        app.buttons["op_rcl"].tap()
        XCTAssertTrue(app.buttons["alpha_A"].waitForExistence(timeout: 2.0), "Alpha pad should appear for RCL")
        
        // Recall A
        app.buttons["alpha_A"].tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        XCTAssertFalse(app.buttons["alpha_A"].exists, "Alpha pad should dismiss after RCL")
    }

  private func navigateToLFUPad(app: XCUIApplication) {
    if app.buttons["alpha_A"].isHittable { return }
    navigateToNumericPad(app: app)
    app.buttons["sim_swipe_right"].tap()
    Thread.sleep(forTimeInterval: 0.5)
    XCTAssertTrue(app.buttons["alpha_A"].waitForExistence(timeout: 2.0))
  }

  func testEquationEntry() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.1)
    app.buttons["btn_yellow_shift"].tap()
    navigateToArithmeticPad(app: app)
    Thread.sleep(forTimeInterval: 0.1)
    app.buttons["op_backspace"].tap()
    app.swipeUp()
    app.buttons["Clear ALL"].firstMatch.tap()
    Thread.sleep(forTimeInterval: 1.5)
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.1)

    // Press EQN (blue shift STO)
    app.buttons["btn_blue_shift"].tap()
    navigateToUpperMatrixPad(app: app)
    app.buttons["op_sto"].tap()

    // Wait for the Equation list sheet
    XCTAssertTrue(app.buttons["btn_add_eqn"].waitForExistence(timeout: 2.0))
    app.buttons["btn_add_eqn"].tap() // "New Equation"

    // Now we are in LBL _
    // Tap A
    navigateToLFUPad(app: app)
    app.buttons["alpha_A"].tap()

    // Now we are in PRGM mode editing equation A
    // Press 5, 6, ENTER
    navigateToNumericPad(app: app)
    app.buttons["op_digit5"].tap()
    app.buttons["op_digit6"].tap()
    
    // Tap invisible ENTER just in case, but let's tap the real ENTER on Arithmetic pad
    navigateToArithmeticPad(app: app)
    app.buttons["op_enter"].tap()
    
    // Press *
    app.buttons["op_multiply"].tap()
    
    // Press RCL X
    navigateToUpperMatrixPad(app: app)
    app.buttons["op_rcl"].tap()
    
    navigateToLFUPad(app: app)
    app.buttons["alpha_X"].tap()
    
    // Press +
    navigateToArithmeticPad(app: app)
    app.buttons["op_add"].tap()
    
    // Press 3
    navigateToNumericPad(app: app)
    app.buttons["op_digit3"].tap()
    
    let displayLabel = display.label
    print("DISPLAY_LABEL_IS: \(displayLabel)")
    
    XCTAssertFalse(displayLabel.contains("ENTER"), "Equation listing should not show ENTER")
  }
}
