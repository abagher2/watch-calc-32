import XCTest

class StackCalc32MenusTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }


  private func navigateToArithmeticPad(app: XCUIApplication) {
    if app.buttons["op_multiply"].isHittable { return }
    navigateToNumericPad(app: app)
    app.navigateAndTap("sim_swipe_left")
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
      app.navigateAndTap("sim_swipe_down")
      Thread.sleep(forTimeInterval: 0.5)
      if app.buttons["op_digit5"].isHittable { return true }
      
      // We might have gone in the wrong direction, try swiping up twice
      app.navigateAndTap("sim_swipe_up")
      Thread.sleep(forTimeInterval: 0.5)
      app.navigateAndTap("sim_swipe_up")
      Thread.sleep(forTimeInterval: 0.5)
      if app.buttons["op_digit5"].isHittable { return true }
    }
    return false
  }

  private func navigateToNumericPad(app: XCUIApplication) {
    if centerVertically(app: app) { return }
    
    app.navigateAndTap("sim_swipe_right")
    Thread.sleep(forTimeInterval: 0.5)
    if centerVertically(app: app) { return }
    
    app.navigateAndTap("sim_swipe_left")
    Thread.sleep(forTimeInterval: 0.5)
    if centerVertically(app: app) { return }
    
    app.navigateAndTap("sim_swipe_left")
    Thread.sleep(forTimeInterval: 0.5)
    if centerVertically(app: app) { return }
  }

  private func navigateToUpperMatrixPad(app: XCUIApplication) {
    if app.buttons["op_sto"].isHittable { return }
    navigateToNumericPad(app: app)
    app.navigateAndTap("sim_swipe_down")
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
        let yellow = app.buttons["op_shiftYellow"]
        let blue = app.buttons["op_shiftBlue"]

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
            app.navigateAndTap(t.btn)
            
            if let title = t.title {
                if app.staticTexts[title].waitForExistence(timeout: 2.0) {
                    if app.buttons["sheet_dismiss_btn"].exists {
                        app.navigateAndTap("sheet_dismiss_btn")
                    } else if app.buttons["Cancel"].exists {
                        app.navigateAndTap("Cancel")
                    } else if app.buttons["Done"].exists {
                        app.navigateAndTap("Done")
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
            app.navigateAndTap(t.btn)
            
            if let title = t.title {
                if app.staticTexts[title].waitForExistence(timeout: 2.0) {
                    if app.buttons["sheet_dismiss_btn"].exists {
                        app.navigateAndTap("sheet_dismiss_btn")
                    } else if app.buttons["Cancel"].exists {
                        app.navigateAndTap("Cancel")
                    } else if app.buttons["Done"].exists {
                        app.navigateAndTap("Done")
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
            app.navigateAndTap(t.btn)
            
            if let title = t.title {
                if app.staticTexts[title].waitForExistence(timeout: 2.0) {
                    if app.buttons["sheet_dismiss_btn"].exists {
                        app.navigateAndTap("sheet_dismiss_btn")
                    } else if app.buttons["Cancel"].exists {
                        app.navigateAndTap("Cancel")
                    } else if app.buttons["Done"].exists {
                        app.navigateAndTap("Done")
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
        app.navigateAndTap("op_digit5")
        app.tapEnter() // ENTER
        
        // STO is on Matrix2 (swipe up up)
        navigateToUpperMatrixPad(app: app)
        Thread.sleep(forTimeInterval: 1.0)
        
        app.navigateAndTap("op_sto")
        // Should navigate to Alpha Entry pad
        XCTAssertTrue(app.buttons["alpha_A"].waitForExistence(timeout: 2.0), "Alpha pad should appear for STO")
        
        // Store in A
        app.navigateAndTap("alpha_A")
        Thread.sleep(forTimeInterval: 0.5)
        
        // Should auto-return
        XCTAssertFalse(app.buttons["alpha_A"].exists, "Alpha pad should dismiss after STO")
        Thread.sleep(forTimeInterval: 1.0)
        
        // RCL is on Matrix2 (swipe up up)
        navigateToUpperMatrixPad(app: app)
        Thread.sleep(forTimeInterval: 1.0)
        
        app.navigateAndTap("op_rcl")
        XCTAssertTrue(app.buttons["alpha_A"].waitForExistence(timeout: 2.0), "Alpha pad should appear for RCL")
        
        // Recall A
        app.navigateAndTap("alpha_A")
        Thread.sleep(forTimeInterval: 1.0)
        
        XCTAssertFalse(app.buttons["alpha_A"].exists, "Alpha pad should dismiss after RCL")
    }

  private func navigateToLFUPad(app: XCUIApplication) {
    if app.buttons["alpha_A"].isHittable { return }
    navigateToNumericPad(app: app)
    app.navigateAndTap("sim_swipe_right")
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
    app.navigateAndTap("op_shiftYellow")
    navigateToArithmeticPad(app: app)
    Thread.sleep(forTimeInterval: 0.1)
    app.navigateAndTap("op_backspace")
    app.tapEnter()
    app.navigateAndTap("Clear ALL")
    Thread.sleep(forTimeInterval: 1.5)
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.1)

    // Press EQN (blue shift STO)
    app.navigateAndTap("op_shiftBlue")
    navigateToUpperMatrixPad(app: app)
    app.navigateAndTap("op_sto")

    // Wait for the Equation list sheet
    XCTAssertTrue(app.buttons["btn_add_eqn"].waitForExistence(timeout: 2.0))
    app.navigateAndTap("btn_add_eqn") // "New Equation"

    // Now we are in LBL _
    // Tap A
    navigateToLFUPad(app: app)
    app.navigateAndTap("alpha_A")

    // Now we are in PRGM mode editing equation A
    // Press 5, 6, ENTER
    navigateToNumericPad(app: app)
    app.navigateAndTap("op_digit5")
    app.navigateAndTap("op_digit6")
    
    // Tap invisible ENTER just in case, but let's tap the real ENTER on Arithmetic pad
    navigateToArithmeticPad(app: app)
    app.tapEnter()
    
    // Press *
    app.navigateAndTap("op_multiply")
    
    // Press RCL X
    navigateToUpperMatrixPad(app: app)
    app.navigateAndTap("op_rcl")
    
    navigateToLFUPad(app: app)
    app.navigateAndTap("alpha_X")
    
    // Press +
    navigateToArithmeticPad(app: app)
    app.navigateAndTap("op_add")
    
    // Press 3
    navigateToNumericPad(app: app)
    app.navigateAndTap("op_digit3")
    
    let displayLabel = display.label
    print("DISPLAY_LABEL_IS: \(displayLabel)")
    
    XCTAssertFalse(displayLabel.contains("ENTER"), "Equation listing should not show ENTER")
  }
}
