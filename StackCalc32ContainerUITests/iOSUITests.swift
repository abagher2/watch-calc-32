import XCTest
import RPNCore

@MainActor final class iOSUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        #if os(iOS)
        XCUIDevice.shared.orientation = .portrait
        #endif
    }
    
    private func typeNumber(_ value: Double, app: XCUIApplication) {
        let str = String(format: "%g", value)
        var inExponent = false
        var negateMantissa = false

        if str.hasPrefix("-") {
            negateMantissa = true
        }

        for char in str {
            if char == "-" {
                if inExponent {
                    app.buttons["func_+/-"].tap()
                }
                continue
            } else if char == "+" {
                continue
            } else if char == "e" || char == "E" {
                inExponent = true
                app.buttons["func_E"].tap()
            } else if char == "." {
                app.buttons["btn_."].tap()
            } else {
                app.buttons["btn_\(char)"].tap()
            }
        }
        
        app.buttons["invisible_ENTER"].tap()

        if negateMantissa {
            app.buttons["func_+/-"].tap()
        }
    }

    private func clearAll(app: XCUIApplication) {
        app.buttons["btn_yellow_shift"].tap()
        app.buttons["func_←"].tap()
        
        let clearAllButton = app.buttons["Clear ALL"]
        if clearAllButton.waitForExistence(timeout: 2.0) {
            clearAllButton.tap()
        } else {
            // fallback if it requires scrolling
            #if os(watchOS)
            app.swipeUp()
            #endif
            if clearAllButton.exists { clearAllButton.tap() }
        }
    }

    func runSharedTestCase(_ testCase: SharedCalculatorTestCase) {
        let app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        setupSnapshot(app)
        app.launch()
        
        Thread.sleep(forTimeInterval: 1.0)
        clearAll(app: app)
        
        for step in testCase.steps {
            let op = step.op
            if op == "SHIFT_YELLOW" {
                app.buttons["btn_yellow_shift"].tap()
            } else if op == "SHIFT_BLUE" {
                app.buttons["btn_blue_shift"].tap()
            } else if op == "ENTER" {
                app.buttons["invisible_ENTER"].tap()
            } else if op == "<-" {
                app.buttons["func_←"].tap()
            } else if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(op) {
                app.buttons["btn_\(op)"].tap()
            } else if op == "A" {
                #if os(watchOS)
                let textField = app.textFields.firstMatch
                if textField.waitForExistence(timeout: 2.0) {
                    textField.tap()
                    textField.typeText("A\n")
                }
                #else
                if app.buttons["func_√𝑥"].exists {
                    app.buttons["func_√𝑥"].tap()
                } else {
                    app.buttons["func_√𝑥"].tap()
                }
                #endif
            } else if op == "LFU_0" {
                app.buttons["IP (Integer Part)"].tap()
            } else if op == "LFU_1" {
                app.buttons["FP (Fractional Part)"].tap()
            } else {
                let buttonId = "func_\(op)"
                if app.buttons[buttonId].exists {
                    app.buttons[buttonId].tap()
                } else {
                    app.buttons[op].tap()
                }
            }
            
            if let expected = step.expectedX {
                let display = app.staticTexts["lcd_display"]
                XCTAssertTrue(display.waitForExistence(timeout: 2.0))
                XCTAssertTrue(display.label.contains(expected), "[\(testCase.name)] Expected screen to contain \(expected), but got: \(display.label)")
            }
        }
    }

    func testBasicMathUI() throws {
        if let tc = SharedMathTestCases.cases.first(where: { $0.name == "BasicMathUI" }) {
            runSharedTestCase(tc)
        } else {
            XCTFail("Could not find BasicMathUI test case")
        }
    }

    func testCalculationEfficiency() throws {
        if let tc = SharedMathTestCases.cases.first(where: { $0.name == "CalculationEfficiency" }) {
            runSharedTestCase(tc)
        } else {
            XCTFail("Could not find CalculationEfficiency test case")
        }
    }

    func testSolve() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        setupSnapshot(app)
        app.launch()

        Thread.sleep(forTimeInterval: 1.0)
        clearAll(app: app)

        // Yellow shift + 7 = SOLVE
        app.buttons["btn_yellow_shift"].tap()
        app.buttons["btn_7"].tap()

        // Just checking it didn't crash and accepted the input
        XCTAssertTrue(app.exists)
    }

    func testAllRetroMenusVisual() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITesting", "-useRetroUI"]
        app.launch()
        
        Thread.sleep(forTimeInterval: 1.0)
        
        // Open MATH Menu (Yellow Shift + 4)
        app.buttons["btn_yellow_shift"].tap()
        app.buttons["btn_4"].tap()
        Thread.sleep(forTimeInterval: 1.5) // Pause to visually inspect
        
        // Open MODES Menu (Yellow Shift + .)
        app.buttons["btn_yellow_shift"].tap()
        app.buttons["btn_."].tap()
        Thread.sleep(forTimeInterval: 1.5) // Pause to visually inspect
        
        // Open DISP Menu (Yellow Shift + 0)
        app.buttons["btn_yellow_shift"].tap()
        app.buttons["btn_0"].tap()
        Thread.sleep(forTimeInterval: 1.5) // Pause to visually inspect
        
        // Open CLEAR Menu (Yellow Shift + <-)
        app.buttons["btn_yellow_shift"].tap()
        app.buttons["func_←"].tap()
        Thread.sleep(forTimeInterval: 1.5) // Pause to visually inspect
        
        XCTAssertTrue(app.exists)
    }

    func testStoRcl() throws {
        if let tc = SharedMathTestCases.cases.first(where: { $0.name == "StoRcl" }) {
            runSharedTestCase(tc)
        } else {
            XCTFail("Could not find StoRcl test case")
        }
    }

    func testAll32SIIMathOperations() throws {
        if let tc = SharedMathTestCases.cases.first(where: { $0.name == "All32SIIMathOperations" }) {
            runSharedTestCase(tc)
        } else {
            XCTFail("Could not find All32SIIMathOperations test case")
        }
    }
    
    func testModuloAndRemainder() throws {
        if let tc = SharedMathTestCases.cases.first(where: { $0.name == "ModuloAndRemainder" }) {
            runSharedTestCase(tc)
        } else {
            XCTFail("Could not find ModuloAndRemainder test case")
        }
    }

    func testMiToKm() throws {
        if let tc = SharedMathTestCases.cases.first(where: { $0.name == "MiToKm" }) {
            runSharedTestCase(tc)
        } else {
            XCTFail("Could not find MiToKm test case")
        }
    }
}

import XCTest

@MainActor final class iOSFullMathUITests: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
    #if os(iOS)
    XCUIDevice.shared.orientation = .portrait
    #endif
  }

  private func clearAll(app: XCUIApplication) {
      app.buttons["btn_yellow_shift"].tap()
      app.buttons["func_←"].tap()
      let clearAllButton = app.buttons["Clear ALL"]
      if clearAllButton.waitForExistence(timeout: 2.0) {
          clearAllButton.tap()
      } else {
          #if os(watchOS)
          app.swipeUp()
          #endif
          app.buttons["Clear ALL"].firstMatch.tap()
      }
      Thread.sleep(forTimeInterval: 1.0)
  }
  
  private func slowTap(_ element: XCUIElement) {
      element.tap()
      Thread.sleep(forTimeInterval: 0.5)
  }

  private func navigateToNumericPad(app: XCUIApplication) {}
  private func typeX(app: XCUIApplication, slow: Bool = false) {
#if os(iOS)
    if slow {
        slowTap(app.buttons["func_RCL"])
        Thread.sleep(forTimeInterval: 0.5)
        slowTap(app.buttons["btn_2"])
    } else {
        app.buttons["func_RCL"].tap()
        Thread.sleep(forTimeInterval: 0.5)
        app.buttons["btn_2"].tap()
    }
#else
    if slow {
        slowTap(app.buttons["func_X"])
    } else {
        app.buttons["func_X"].tap()
    }
#endif
  }

  private func navigateToArithmeticPad(app: XCUIApplication) {}
  private func navigateToAlphaPad(app: XCUIApplication) {}

  private func navigateToUpperMatrixPad(app: XCUIApplication) {
#if os(iOS)
    return
#else
    if app.buttons["func_STO"].exists { return }
    navigateToNumericPad(app: app)
    #if os(watchOS)
    app.otherElements["numpad_bg"].firstMatch.swipeDown()
    #endif
    Thread.sleep(forTimeInterval: 0.5)
    XCTAssertTrue(app.buttons["func_STO"].waitForExistence(timeout: 2.0))
#endif
  }

  private func navigateToLFUPad(app: XCUIApplication) {
#if os(iOS)
    return
#else
    if app.buttons["func_A"].exists { return }
    navigateToNumericPad(app: app)
    #if os(watchOS)
    app.otherElements["numpad_bg"].firstMatch.swipeRight()
    #endif
    Thread.sleep(forTimeInterval: 0.5)
    XCTAssertTrue(app.buttons["func_A"].waitForExistence(timeout: 2.0))
#endif
  }

  func testBasicMathUI() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    navigateToNumericPad(app: app)

    let btn4 = app.buttons["btn_4"]
    let btn2 = app.buttons["btn_2"]
    let btn5 = app.buttons["btn_5"]

    btn4.tap()
    btn2.tap()
    app.buttons["invisible_ENTER"].tap()
    btn5.tap()

    navigateToArithmeticPad(app: app)
    app.buttons.matching(identifier: "func_×").firstMatch.tap()

    XCTAssertEqual(display.label, "210")
  }

  func testCalculationEfficiency() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    navigateToNumericPad(app: app)

    let btn4 = app.buttons["btn_4"]
    let btn2 = app.buttons["btn_2"]
    let btn5 = app.buttons["btn_5"]

    btn4.tap()
    btn2.tap()
    app.buttons["invisible_ENTER"].tap()  // ENTER
    btn5.tap()

    navigateToArithmeticPad(app: app)
    app.buttons["func_×"].tap()

    // No longer auto-resets to numeric pad, so we explicitly navigate if needed
    navigateToNumericPad(app: app)
    btn5.tap()

    navigateToArithmeticPad(app: app)
    app.buttons["func_+"].tap()

    navigateToNumericPad(app: app)
    btn4.tap()
    btn2.tap()

    navigateToArithmeticPad(app: app)
    app.buttons["func_+"].tap()
  }

  func testSolve() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    clearAll(app: app)  // yellow shift

    navigateToNumericPad(app: app)
    _ = app.buttons["btn_7"].waitForExistence(timeout: 1.0)
    app.buttons["btn_7"].tap()  // SOLVE

    XCTAssertTrue(display.exists)
  }

  func testPlotting() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Jump to Matrix2View where STO is
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)

    // EQN is Blue Shift + STO
    app.buttons["btn_blue_shift"].tap()
    Thread.sleep(forTimeInterval: 0.5)
    app.buttons["func_STO"].tap()
    
    Thread.sleep(forTimeInterval: 1.0)
    app.buttons["btn_add_eqn"].tap()
    Thread.sleep(forTimeInterval: 1.5)

    // RPN sequence: X 2 y^x
    navigateToLFUPad(app: app)
    typeX(app: app)

    navigateToNumericPad(app: app)
    app.buttons["btn_2"].tap()

    navigateToLFUPad(app: app)
    app.buttons["func_𝑦ˣ"].tap()

    // ENTER to save equation
    app.staticTexts["lcd_display"].tap()

    // Plot it
    clearAll(app: app)
    navigateToNumericPad(app: app)
    app.buttons["func_PLOT"].tap()
    if app.buttons["Plot"].waitForExistence(timeout: 5.0) {
        app.buttons["Plot"].tap()
    } else {
        #if os(watchOS)
        app.swipeUp()
        #else
        app.collectionViews.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 0.5)
        #endif
        app.buttons["btn_plot_execute"].tap()
    }
  }

  func testNormalPDFPlotting() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Enter equation mode using EQN (Blue Shift + STO)
    navigateToUpperMatrixPad(app: app)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["func_STO"].tap()
    Thread.sleep(forTimeInterval: 1.0)
    app.buttons["btn_add_eqn"].tap()
    Thread.sleep(forTimeInterval: 1.5)

    // Sequence: X x^2 0.5 +/- × e^x 2 π × √x ÷
    navigateToLFUPad(app: app)
    typeX(app: app)

    // x^2 is yellow shift of √𝑥 in Matrix3View
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    clearAll(app: app)
    app.buttons["func_√𝑥"].tap()

    navigateToNumericPad(app: app)
    app.buttons["btn_0"].tap()
    app.buttons["btn_."].tap()
    app.buttons["btn_5"].tap()
    app.buttons["func_+/-"].tap()

    navigateToArithmeticPad(app: app)
    app.buttons["func_×"].tap()

    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    app.buttons["func_𝑒ˣ"].tap()

    navigateToNumericPad(app: app)
    app.buttons["btn_2"].tap()

    // π is blue shift of SIN in Matrix2View
    navigateToNumericPad(app: app)
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["func_SIN"].tap()

    navigateToArithmeticPad(app: app)
    app.buttons["func_×"].tap()

    // √𝑥 is in Matrix3View
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    app.buttons["func_√𝑥"].tap()

    navigateToArithmeticPad(app: app)
    app.buttons["func_÷"].tap()

    // Save
    app.staticTexts["lcd_display"].tap()

    // Plot
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["func_PLOT"].tap()
    if app.buttons["Plot"].waitForExistence(timeout: 5.0) {
        app.buttons["Plot"].tap()
    } else {
        #if os(watchOS)
        app.swipeUp()
        #else
        app.collectionViews.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 0.5)
        #endif
        app.buttons["btn_plot_execute"].tap()
    }
  }

  func testSigmoidPlotting() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Enter equation mode using EQN (Blue Shift + STO)
    navigateToUpperMatrixPad(app: app)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["func_STO"].tap()
    Thread.sleep(forTimeInterval: 1.0)
    app.buttons["btn_add_eqn"].tap()
    Thread.sleep(forTimeInterval: 1.5)

    // Sequence: X +/- e^x 1 + 1/x
    navigateToLFUPad(app: app)
    typeX(app: app)

    navigateToNumericPad(app: app)
    app.buttons["func_+/-"].tap()

    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    app.buttons["func_𝑒ˣ"].tap()

    navigateToNumericPad(app: app)
    app.buttons["btn_1"].tap()

    navigateToArithmeticPad(app: app)
    app.buttons["func_+"].tap()

    // 1/x is in Matrix3View
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    app.buttons["func_1/𝑥"].tap()

    // Save
    app.staticTexts["lcd_display"].tap()

    // Plot
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["func_PLOT"].tap()
    if app.buttons["Plot"].waitForExistence(timeout: 5.0) {
        app.buttons["Plot"].tap()
    } else {
        #if os(watchOS)
        app.swipeUp()
        #else
        app.collectionViews.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 0.5)
        #endif
        app.buttons["btn_plot_execute"].tap()
    }
  }

  func testViewMenu() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    app.buttons["btn_blue_shift"].tap()  // blue shift
    navigateToNumericPad(app: app)
    app.buttons["btn_0"].tap()  // VIEW

    // The stack view should appear
  }

  func testLayoutNoOverlap() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    XCTAssertTrue(app.staticTexts["lcd_display"].waitForExistence(timeout: 5.0))

    // Let UI settle
    Thread.sleep(forTimeInterval: 1.0)

    let lcdDisplay = app.staticTexts["lcd_display"]
    let btnC = app.buttons["C"]
    let btnZero = app.buttons["btn_0"]

    let lcdFrame = lcdDisplay.frame
    let cFrame = btnC.frame
    let zeroFrame = btnZero.frame

    // 1. LCD should be above the numpad (btnZero should be fully below lcdDisplay)
    XCTAssertLessThanOrEqual(
      lcdFrame.maxY, zeroFrame.minY, "LCD display overlaps with the numeric pad (btn 0)!")

    // 2. Numpad (btnZero) and C button should be on the same horizontal row in HP32SII layout
    XCTAssertLessThan(
      abs(zeroFrame.minY - cFrame.minY), 5.0,
      "Numeric pad (btn 0) and (C button) are not horizontally aligned!")

    // 3. Verify internal text does not visually overflow the button bounds
    let zeroText = btnZero.staticTexts.firstMatch
    if zeroText.exists {
      let textFrame = zeroText.frame
      XCTAssertGreaterThanOrEqual(
        textFrame.minY, zeroFrame.minY - 1, "Button text overflows the TOP of the button container!"
      )
      XCTAssertLessThanOrEqual(
        textFrame.maxY, zeroFrame.maxY + 1,
        "Button text overflows the BOTTOM of the button container, causing visual overflow!")
    }
  }
  func testIntegrationShading() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Set FN=
    navigateToLFUPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["func_XEQ"].tap()
    XCTAssertTrue(app.buttons["Evaluate"].waitForExistence(timeout: 5))
    app.buttons["Evaluate"].tap()
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 1.5) // Wait for sheet to fully dismiss

    // Push 1, push 2 (Integration limits)
    app.buttons["btn_1"].tap()
    app.buttons["invisible_ENTER"].tap()  // ENTER
    app.buttons["btn_2"].tap()

    // Tap integrate (Blue shift + 8)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["btn_8"].tap()

    // Tap Evaluate in the IntegratePromptView
    XCTAssertTrue(app.buttons["Evaluate"].waitForExistence(timeout: 5.0))
    app.buttons["Evaluate"].tap()
    
    // Wait a little for integration to run
    sleep(2)

    print("--- APP DEBUG DESCRIPTION ---")
    print(app.debugDescription)
    print("-----------------------------")

    // Plot should open automatically
    XCTAssertTrue(app.buttons["btn_plot_c"].waitForExistence(timeout: 25.0))
    app.buttons["btn_plot_c"].tap() // Dismiss plot
  }

  func testNumericIntegration() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Set FN=
    navigateToLFUPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["func_XEQ"].tap()
    XCTAssertTrue(app.staticTexts["NPDF"].waitForExistence(timeout: 5))
    app.staticTexts["NPDF"].tap()
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)

    // Push 0, push 1
    app.buttons["btn_0"].tap()
    app.buttons["invisible_ENTER"].tap()  // ENTER
    app.buttons["btn_1"].tap()

    // Integrate (Blue shift + 8)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["btn_8"].tap()
    
    // Tap Evaluate in the IntegratePromptView
    XCTAssertTrue(app.buttons["Evaluate"].waitForExistence(timeout: 5.0))
    app.buttons["Evaluate"].tap()
    
    // Wait a little for integration to run
    sleep(2)
  }

  func testPlottingWithRange() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Set limits for Plotting? We can just invoke PLOT
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["func_PLOT"].tap()
    if app.buttons["Plot"].waitForExistence(timeout: 5.0) {
        app.buttons["Plot"].tap()
    } else {
        #if os(watchOS)
        app.swipeUp()
        #else
        app.collectionViews.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 0.5)
        #endif
        app.buttons["btn_plot_execute"].tap()
    }
  }

  func testFNMode() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // FN=
    navigateToLFUPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["func_XEQ"].tap()

    XCTAssertTrue(app.staticTexts["NPDF"].waitForExistence(timeout: 5))
  }

  func testEquationEditing() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    // Tap blue shift + XEQ (FN=)
    navigateToLFUPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["func_XEQ"].tap()

    XCTAssertTrue(app.staticTexts["NPDF"].waitForExistence(timeout: 5))
    app.staticTexts["NPDF"].tap()
  }

  func testEquationEvaluation() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Jump to Matrix2View where STO is
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)

    // EQN is Blue Shift + STO
    app.buttons["btn_blue_shift"].tap()
    Thread.sleep(forTimeInterval: 0.5)
    app.buttons["func_STO"].tap()
    
    Thread.sleep(forTimeInterval: 1.0)
    app.buttons["btn_add_eqn"].tap()
    Thread.sleep(forTimeInterval: 1.5)

    // Equation mode left justifies and shows EQN in display
  }

  func testClearMenuFlow() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    navigateToNumericPad(app: app)

    // Input some numbers
    app.buttons["btn_5"].tap()
    app.buttons["invisible_ENTER"].tap()  // ENTER
    app.buttons["btn_9"].tap()
    Thread.sleep(forTimeInterval: 1.0)

        // Open CLEAR menu (Shift + <-)
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["func_←"].tap()

    // Should show Clear Menu
    XCTAssertTrue(app.navigationBars["Clear"].waitForExistence(timeout: 2.0))

    // Tap Clear x
    #if os(watchOS)
    app.buttons["Clear ALL"].tap()
    #else
    app.buttons["Clear ALL"].tap()
    #endif

    // Display should clear current input
    XCTAssertEqual(display.label, "0")

  }

  func testStackIndicator() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    navigateToNumericPad(app: app)

    // Empty stack arrow should NOT exist initially
    XCTAssertFalse(app.staticTexts["stack_indicator"].exists)

    // Input 5 ENTER ENTER ENTER ENTER to push stack beyond 4
    app.buttons["btn_5"].tap()
    app.buttons["invisible_ENTER"].tap()
    app.buttons["invisible_ENTER"].tap()
    app.buttons["invisible_ENTER"].tap()
    app.buttons["invisible_ENTER"].tap()

    // Arrow should exist now since stack has > 4
    XCTAssertTrue(app.staticTexts["stack_indicator"].waitForExistence(timeout: 2.0))

    // Clear all to empty the stack
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    clearAll(app: app)
    #if os(watchOS)
    app.swipeUp()
    #endif

    // Arrow should disappear
    XCTAssertFalse(app.staticTexts["stack_indicator"].exists)
  }

  private func typeNumber(_ value: Double, app: XCUIApplication) {
    let str = String(format: "%g", value)
    var inExponent = false
    var negateMantissa = false

    if str.hasPrefix("-") {
        negateMantissa = true
    }

    for char in str {
        if char == "-" {
            if inExponent {
                navigateToArithmeticPad(app: app)
                app.buttons["func_+/-"].tap()
            }
            continue
        } else if char == "+" {
            continue
        } else if char == "e" || char == "E" {
            inExponent = true
            navigateToArithmeticPad(app: app)
            app.buttons["func_E"].tap()
        } else if char == "." {
            navigateToNumericPad(app: app)
            app.buttons["btn_."].tap()
        } else {
            navigateToNumericPad(app: app)
            app.buttons["btn_\(char)"].tap()
        }
    }
    
    navigateToNumericPad(app: app)
    app.buttons["invisible_ENTER"].tap()

    if negateMantissa {
        navigateToArithmeticPad(app: app)
        app.buttons["func_+/-"].tap()
    }
  }


  
    @MainActor func testAppStoreScreenshots() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()
    
    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))
    
    // Screenshot 1: Main Numpad
    snapshot("1-Main")
    
    // Screenshot 2: Equation / Plotting entry (Blue Shift + STO)
    
    func slowTap(_ element: XCUIElement, name: String = "") {
        guard element.waitForExistence(timeout: 2.0) else { return }
        Thread.sleep(forTimeInterval: 0.3)
        element.tap()
        Thread.sleep(forTimeInterval: 0.6)
    }

    // Set Stack to 8 via FLAGS Menu to ensure it looks good
    slowTap(app.buttons["btn_blue_shift"], name: "Blue Shift")
    slowTap(app.buttons["func_×"], name: "FLAGS")
    Thread.sleep(forTimeInterval: 1.0)
    for _ in 0..<4 {
        slowTap(app.steppers.buttons["Increment"], name: "Stack Size +1")
    }
    if app.buttons["Done"].exists {
        app.buttons["Done"].tap()
    } else {
        app.swipeDown()
    }
    Thread.sleep(forTimeInterval: 1.0)

    // Go to Add Equation
    slowTap(app.buttons["btn_blue_shift"], name: "Blue Shift")
    slowTap(app.buttons["func_STO"], name: "EQN Mode")
    Thread.sleep(forTimeInterval: 1.0)
    slowTap(app.buttons["btn_add_eqn"], name: "New Equation")
    Thread.sleep(forTimeInterval: 1.5)
    
    // Type Normal PDF: (X - M)² ÷ S² ÷ -2 eˣ ÷ (S × √(2π))
    // X
    slowTap(app.buttons["func_RCL"], name: "RCL")
    slowTap(app.buttons["btn_2"], name: "X")
    
    // M
    slowTap(app.buttons["func_RCL"], name: "RCL")
    slowTap(app.buttons["invisible_ENTER"], name: "M")
    
    // -
    slowTap(app.buttons["func_-"], name: "-")
    
    // S
    slowTap(app.buttons["func_RCL"], name: "RCL")
    slowTap(app.buttons["btn_9"], name: "S")
    
    // ÷
    slowTap(app.buttons["func_÷"], name: "÷")
    
    // x² (Yellow Shift + √x)
    slowTap(app.buttons["btn_yellow_shift"], name: "Yellow Shift")
    slowTap(app.buttons["func_√𝑥"], name: "x²")
    
    // 0.5
    slowTap(app.buttons["btn_0"], name: "0")
    slowTap(app.buttons["btn_."], name: ".")
    slowTap(app.buttons["btn_5"], name: "5")
    
    // +/-
    slowTap(app.buttons["func_+/-"], name: "+/-")
    
    // ×
    slowTap(app.buttons["func_×"], name: "×")
    
    // eˣ
    slowTap(app.buttons["func_𝑒ˣ"], name: "𝑒ˣ")
    
    // S
    slowTap(app.buttons["func_RCL"], name: "RCL")
    slowTap(app.buttons["btn_9"], name: "S")
    
    // ÷
    slowTap(app.buttons["func_÷"], name: "÷")
    
    // 2
    slowTap(app.buttons["btn_2"], name: "2")
    
    // π (Blue Shift + SIN)
    slowTap(app.buttons["btn_blue_shift"], name: "Blue Shift")
    slowTap(app.buttons["func_SIN"], name: "π")
    
    // ×
    slowTap(app.buttons["func_×"], name: "×")
    
    // √x
    slowTap(app.buttons["func_√𝑥"], name: "√𝑥")
    
    // ÷
    slowTap(app.buttons["func_÷"], name: "÷")
    
    Thread.sleep(forTimeInterval: 1.0)
    snapshot("2-Equation")
    
    // Screenshot 3: Plot
    // Save Eqn (RTN -> Blue Shift + +)
    slowTap(app.buttons["btn_blue_shift"], name: "Blue Shift")
    slowTap(app.buttons["func_+"], name: "RTN")
    Thread.sleep(forTimeInterval: 1.0)
    
    // Set M to 0
    slowTap(app.buttons["btn_0"], name: "0")
    slowTap(app.buttons["func_STO"], name: "STO")
    slowTap(app.buttons["invisible_ENTER"], name: "M")
    
    // Set S to 1
    slowTap(app.buttons["btn_1"], name: "1")
    slowTap(app.buttons["func_STO"], name: "STO")
    slowTap(app.buttons["btn_9"], name: "S")
    
    // Set limits -2 to 2 for Integration / Plot
    slowTap(app.buttons["btn_2"], name: "2")
    slowTap(app.buttons["func_+/-"], name: "+/-")
    slowTap(app.buttons["invisible_ENTER"], name: "ENTER")
    slowTap(app.buttons["btn_2"], name: "2")
    
    // Plot (func_PLOT)
    slowTap(app.buttons["func_PLOT"], name: "Plot")
    
    #if !os(watchOS)
    app.collectionViews.firstMatch.swipeUp()
    Thread.sleep(forTimeInterval: 0.5)
    #endif
    if app.buttons["btn_integrate_execute"].waitForExistence(timeout: 2.0) {
        app.buttons["btn_integrate_execute"].tap()
    }
    
    // Wait for the plot animation and integration to draw fully
    Thread.sleep(forTimeInterval: 8.0)
    
    snapshot("3-Plot")
    
    // Relaunch for Exam Mode screenshot
    app.terminate()
    app.launch()
    XCTAssertTrue(app.staticTexts["lcd_display"].waitForExistence(timeout: 5))
    
    // Open FLAGS menu (Blue Shift + ×)
    app.buttons["btn_blue_shift"].tap()
    navigateToArithmeticPad(app: app)
    app.buttons["func_×"].tap()
    
    let examToggle = app.switches["Exam Mode"]
    if examToggle.waitForExistence(timeout: 2.0) {
        examToggle.tap()
        // Swipe down to dismiss the modal menu
        app.swipeDown()
        Thread.sleep(forTimeInterval: 1.0)
    }
    
    // Screenshot 4: Exam Mode
    snapshot("4-Exam")
  }


  func testVideoNormalPDF() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()
    
    #if os(iOS)
    XCUIDevice.shared.orientation = .portrait
    Thread.sleep(forTimeInterval: 2.0)
    #endif
    
    let display = app.staticTexts["lcd_display"]
    guard display.waitForExistence(timeout: 5) else { return }
    
    Thread.sleep(forTimeInterval: 1.0)
    
    func slowTap(_ element: XCUIElement, name: String = "") {
        guard element.waitForExistence(timeout: 2.0) else { return }
        print("CAPTION|\(name)")
        Thread.sleep(forTimeInterval: 0.3)
        element.tap()
        Thread.sleep(forTimeInterval: 0.6)
    }

    // Set Stack to 8 via FLAGS Menu
    slowTap(app.buttons["btn_blue_shift"], name: "Blue Shift")
    slowTap(app.buttons["func_×"], name: "FLAGS")
    Thread.sleep(forTimeInterval: 1.0)
    for _ in 0..<4 {
        slowTap(app.steppers.buttons["Increment"], name: "Stack Size +1")
    }
    if app.buttons["Done"].exists {
        app.buttons["Done"].tap()
    } else {
        app.swipeDown()
    }
    Thread.sleep(forTimeInterval: 1.0)

    // Go to Add Equation
    slowTap(app.buttons["btn_blue_shift"], name: "Blue Shift")
    slowTap(app.buttons["func_STO"], name: "EQN Mode")
    Thread.sleep(forTimeInterval: 1.0)
    slowTap(app.buttons["btn_add_eqn"], name: "New Equation")
    Thread.sleep(forTimeInterval: 1.5)
    
    // Type Normal PDF: (X - M)² ÷ S² ÷ -2 eˣ ÷ (S × √(2π))
    // X
    slowTap(app.buttons["func_RCL"], name: "RCL")
    slowTap(app.buttons["btn_2"], name: "X")
    
    // M
    slowTap(app.buttons["func_RCL"], name: "RCL")
    slowTap(app.buttons["invisible_ENTER"], name: "M")
    
    // -
    slowTap(app.buttons["func_-"], name: "-")
    
    // S
    slowTap(app.buttons["func_RCL"], name: "RCL")
    slowTap(app.buttons["btn_9"], name: "S")
    
    // ÷
    slowTap(app.buttons["func_÷"], name: "÷")
    
    // x² (Yellow Shift + √x)
    slowTap(app.buttons["btn_yellow_shift"], name: "Yellow Shift")
    slowTap(app.buttons["func_√𝑥"], name: "x²")
    
    // 0.5
    slowTap(app.buttons["btn_0"], name: "0")
    slowTap(app.buttons["btn_."], name: ".")
    slowTap(app.buttons["btn_5"], name: "5")
    
    // +/-
    slowTap(app.buttons["func_+/-"], name: "+/-")
    
    // ×
    slowTap(app.buttons["func_×"], name: "×")
    
    // eˣ
    slowTap(app.buttons["func_𝑒ˣ"], name: "𝑒ˣ")
    
    // S
    slowTap(app.buttons["func_RCL"], name: "RCL")
    slowTap(app.buttons["btn_9"], name: "S")
    
    // ÷
    slowTap(app.buttons["func_÷"], name: "÷")
    
    // 2
    slowTap(app.buttons["btn_2"], name: "2")
    
    // π (Blue Shift + SIN)
    slowTap(app.buttons["btn_blue_shift"], name: "Blue Shift")
    slowTap(app.buttons["func_SIN"], name: "π")
    
    // ×
    slowTap(app.buttons["func_×"], name: "×")
    
    // √x
    slowTap(app.buttons["func_√𝑥"], name: "√𝑥")
    
    // ÷
    slowTap(app.buttons["func_÷"], name: "÷")
    
    // Save Eqn (RTN -> Blue Shift + +)
    slowTap(app.buttons["btn_blue_shift"], name: "Blue Shift")
    slowTap(app.buttons["func_+"], name: "RTN")
    Thread.sleep(forTimeInterval: 1.0)
    
    // Set M to 0
    slowTap(app.buttons["btn_0"], name: "0")
    slowTap(app.buttons["func_STO"], name: "STO")
    slowTap(app.buttons["invisible_ENTER"], name: "M")
    
    // Set S to 1
    slowTap(app.buttons["btn_1"], name: "1")
    slowTap(app.buttons["func_STO"], name: "STO")
    slowTap(app.buttons["btn_9"], name: "S")
    
    // Set limits -2 to 2 for Integration / Plot
    slowTap(app.buttons["btn_2"], name: "2")
    slowTap(app.buttons["func_+/-"], name: "+/-")
    slowTap(app.buttons["invisible_ENTER"], name: "ENTER")
    slowTap(app.buttons["btn_2"], name: "2")
    
    // Plot (func_PLOT)
    slowTap(app.buttons["func_PLOT"], name: "Plot")
    
    #if !os(watchOS)
    app.collectionViews.firstMatch.swipeUp()
    Thread.sleep(forTimeInterval: 0.5)
    #endif
    if app.buttons["btn_integrate_execute"].waitForExistence(timeout: 2.0) {
        app.buttons["btn_integrate_execute"].tap()
    }
    
    // Wait for the plot animation and integration to draw fully
    Thread.sleep(forTimeInterval: 8.0)
    print("CAPTION|Result: 0.4772")
    Thread.sleep(forTimeInterval: 2.0)
    
    // Dismiss plot sheet
    app.swipeDown()
    Thread.sleep(forTimeInterval: 1.0)

    // Dismiss equation list sheet
    app.swipeDown()
    Thread.sleep(forTimeInterval: 1.0)
    
    // Open REGS Menu
    slowTap(app.buttons["btn_yellow_shift"], name: "Yellow Shift")
    slowTap(app.buttons["btn_0"], name: "REGS")
    
    Thread.sleep(forTimeInterval: 3.0)
  }

  func testStatPlotAndValues() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Enter point 1 (1, 2)
    app.buttons["btn_1"].tap()
    app.buttons["invisible_ENTER"].tap() // ENTER
    app.buttons["btn_2"].tap()
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["func_Σ+"].tap() // Σ+
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)

    // Enter point 2 (3, 4)
    app.buttons["btn_3"].tap()
    app.buttons["invisible_ENTER"].tap() // ENTER
    app.buttons["btn_4"].tap()
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["func_Σ+"].tap() // Σ+
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)

    // Calculate mean of X -> should be 2.
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["func_𝑦ˣ"].tap() // x-bar, y-bar menu
    
    // Tap x-bar
        #if os(watchOS)
    let meanButton = app.buttons["x-bar, y-bar (Mean)"]
    #else
    let meanButton = app.buttons["x̄ (Mean of x)"]
    #endif
    if meanButton.waitForExistence(timeout: 2.0) {
        meanButton.tap()
    }

    
    // Assert display is 2
    XCTAssertEqual(display.label, "3")
    
    // Trigger STAT PLOT
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["func_PLOT"].tap()
    
    // Wait for prompt to appear
    if app.buttons["Source"].waitForExistence(timeout: 2.0) {
        app.buttons["Source"].tap()
        app.buttons["Statistics Data"].tap()
        app.buttons["Plot"].tap()
    } else {
        #if os(watchOS)
        app.swipeUp()
        #else
        app.collectionViews.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 0.5)
        #endif
        app.buttons["btn_plot_execute"].tap()
    }
    
    // Wait a bit for plot to render
    Thread.sleep(forTimeInterval: 2.0)
    
    // The test passes if the plot doesn't crash.
    // Regression line should be visible in the view.
  }

    func testIntegrationPlotArea() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    // 1. Enter an equation: EQN -> Add -> Label "A" -> X -> x^2 -> Save
    navigateToUpperMatrixPad(app: app)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["func_STO"].tap() // EQN
    Thread.sleep(forTimeInterval: 1.0)

    app.buttons["btn_add_eqn"].tap()
    Thread.sleep(forTimeInterval: 2.0)

    navigateToLFUPad(app: app)
    typeX(app: app)

    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["func_√𝑥"].tap() // x^2

    // Save & Exit Programming Mode (Blue shift + +/RTN)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["func_+"].tap()
    Thread.sleep(forTimeInterval: 1.5) // Wait for state to settle

    // 2. Open plot menu
    navigateToNumericPad(app: app)
    app.buttons["func_PLOT"].tap()

    print("--- PLOT PROMPT SCREEN DEBUG DESCRIPTION ---")
    print(app.debugDescription)
    print("---------------------------------------------")

    // Ensure Equation is selected as source
    XCTAssertTrue(app.buttons["Equation"].waitForExistence(timeout: 2.0))
    app.buttons["Equation"].tap()

    // Scroll down to reveal execute buttons
    app.collectionViews.firstMatch.swipeUp()
    Thread.sleep(forTimeInterval: 0.5)

    XCTAssertTrue(app.buttons["Integrate & Plot Area"].waitForExistence(timeout: 2.0))
    app.buttons["Integrate & Plot Area"].tap()

    // Plot renders, integration occurs in the background
    Thread.sleep(forTimeInterval: 2.0)
    }

  
  func testPlotTapToCapture() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    // Plot a simple function: 1 ENTER X^2 PLOT
    app.buttons["btn_1"].tap()
    app.buttons["invisible_ENTER"].tap()
    
    // Tap PLOT
    app.buttons["func_PLOT"].tap()
    
    if app.buttons["Plot"].waitForExistence(timeout: 2.0) {
        app.buttons["Plot"].tap()
    } else {
        #if !os(watchOS)
        app.collectionViews.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 0.5)
        #endif
        app.buttons["btn_plot_execute"].tap()
    }

    // Wait for plot view
    let plotChart = app.otherElements["plot_chart"]
    XCTAssertTrue(plotChart.waitForExistence(timeout: 5.0))
    
    // Tap in the middle of the plot to capture coordinates
    plotChart.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    
    // Wait for plot to dismiss and check stack (display label should have a captured coordinate)
    Thread.sleep(forTimeInterval: 1.0)
    
    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 2.0))
    
    // We expect SOME numerical value pushed to the stack
    XCTAssertFalse(display.label.isEmpty)
    XCTAssertNotEqual(display.label, "1") // It should have changed from the initial 1
  }

  func testLongNumericEntryScrolling() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Enter a 12 digit number: 123456789012
    app.buttons["btn_1"].tap()
    app.buttons["btn_2"].tap()
    app.buttons["btn_3"].tap()
    app.buttons["btn_4"].tap()
    app.buttons["btn_5"].tap()
    app.buttons["btn_6"].tap()
    app.buttons["btn_7"].tap()
    app.buttons["btn_8"].tap()
    app.buttons["btn_9"].tap()
    app.buttons["btn_0"].tap()
    app.buttons["btn_1"].tap()
    app.buttons["btn_2"].tap()
    app.buttons["btn_3"].tap()
    app.buttons["btn_4"].tap()
    app.buttons["btn_5"].tap()
    
    // The screen display holds the full string unformatted during entry
    XCTAssertTrue(display.label.contains("123456789012345"))
    
    app.buttons["invisible_ENTER"].tap()
    
    // After ENTER, it is formatted to scientific notation (12 char limit)
    XCTAssertTrue(display.label.contains("E"))
  }



  func testAllConstantsLoad() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    let testConstants = [
        "Pi", "Euler's number", "Speed of light in vacuum",
        "Newtonian constant of gravitation", "Standard acceleration of gravity",
        "Avogadro constant", "Elementary charge", "Molar gas constant",
        "Planck constant", "Reduced Planck constant", "Electron mass",
        "Proton mass", "Neutron mass", "Vacuum magnetic permeability",
        "Vacuum electric permittivity", "Boltzmann constant", "Faraday constant",
        "Fine-structure constant", "Rydberg constant", "Bohr radius",
        "Bohr magneton", "Nuclear magneton", "Atomic mass constant",
        "Stefan-Boltzmann constant", "Characteristic impedance of vacuum",
        "Standard atmosphere", "Electron volt", "Parsec", "Light year",
        "Astronomical unit", "Inches to Centimeters", "Centimeters to Inches",
        "Feet to Meters", "Meters to Feet", "Miles to Kilometers",
        "Kilometers to Miles", "Pounds to Kilograms", "Kilograms to Pounds",
        "Ounces to Grams", "Grams to Ounces", "Gallons to Liters",
        "Liters to Gallons", "Degrees to Radians", "Radians to Degrees"
    ]

    for constantName in testConstants {
        // Open CONST menu via yellow-shift
#if os(watchOS)
        #if os(watchOS)
        app.swipeLeft()
        #endif // Go to arithmetic pad
#endif
        Thread.sleep(forTimeInterval: 0.2)
        
        app.buttons["btn_yellow_shift"].tap()
        app.buttons["func_PLOT"].tap()
        
        #if os(watchOS)
        XCTAssertTrue(app.staticTexts["CNST"].waitForExistence(timeout: 2.0))
        #else
        XCTAssertTrue(app.staticTexts["Constants"].waitForExistence(timeout: 2.0))
        #endif
        
        // Tap the first cell (Pi) to verify behavior
        if constantName == "Pi" {
            let piButton = app.buttons.element(matching: NSPredicate(format: "label CONTAINS[c] 'Pi'")).firstMatch
            if piButton.waitForExistence(timeout: 2.0) {
                piButton.tap()
                Thread.sleep(forTimeInterval: 0.8) // Wait for sheet to dismiss
                XCTAssertTrue(display.waitForExistence(timeout: 2.0))
                XCTAssertTrue(display.label.contains("3.1415"))
                app.buttons["func_←"].tap() // Clear for next
            } else {
                if app.buttons["Close"].exists {
                    app.buttons["Close"].tap()
                } else {
                    app.buttons["Cancel"].firstMatch.tap()
                }
            }
        } else {
            // Dismiss menu
            if app.buttons["Close"].exists {
                app.buttons["Close"].tap()
            } else {
                app.buttons["Cancel"].firstMatch.tap()
            }
        }
        
        // Swipe back to numeric pad to reset for next loop
#if os(watchOS)
        #if os(watchOS)
        app.swipeRight()
        #endif
#endif
        Thread.sleep(forTimeInterval: 0.2)
    }
  }
}


import XCTest

@MainActor class iOSMenusUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }


  private func navigateToArithmeticPad(app: XCUIApplication) {}
  private func navigateToNumericPad(app: XCUIApplication) {}
  private func navigateToUpperMatrixPad(app: XCUIApplication) {}

    func testAllMenusAndOverlays() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        setupSnapshot(app)
        app.launch()

        let display = app.staticTexts["lcd_display"]
        XCTAssertTrue(display.waitForExistence(timeout: 5))

        let pad = app.otherElements["numpad_bg"]
        let yellow = app.buttons["btn_yellow_shift"]
        let blue = app.buttons["btn_blue_shift"]

        // We start on pad 1 (Numeric)
        XCTAssertTrue(app.buttons["btn_5"].waitForExistence(timeout: 2.0))

        // Matrix1 page (swipe up)
        navigateToArithmeticPad(app: app)
        Thread.sleep(forTimeInterval: 1.0)

        let matrix1Triggers: [(shift: XCUIElement?, btn: String, title: String?)] = [
            (yellow, "func_+/-", "Modes"),
            (blue, "func_+/-", "Display"),
            (yellow, "func_←", "Clear")
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
            (blue, "btn_7", "Solve"),
            (blue, "btn_8", "Integrate"),
            (nil, "func_PLOT", "Plot")
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
            (blue, "func_𝑒ˣ", "PROB"),
            (yellow, "func_Σ+", "SUMS"),
            (blue, "func_LN", "L.R."),
            (blue, "func_𝑦ˣ", "MEAN"),
            (blue, "func_1/𝑥", "STD DEV")
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
        setupSnapshot(app)
        app.launch()
        
        let display = app.staticTexts["lcd_display"]
        XCTAssertTrue(display.waitForExistence(timeout: 5))
        
        // Push 5 to stack
        app.buttons["btn_5"].tap()
        display.tap() // ENTER
        
        // STO is on Matrix2 (swipe up up)
        navigateToUpperMatrixPad(app: app)
        Thread.sleep(forTimeInterval: 1.0)
        
        app.buttons["func_STO"].tap()
        
                // Should navigate to Alpha Prompt sheet
        #if os(watchOS)
        let textField = app.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 2.0), "Variables sheet should appear for STO")
        
        // Store in A
        textField.tap()
        textField.typeText("A\n")
        #else
        XCTAssertTrue(app.buttons["func_√𝑥"].waitForExistence(timeout: 2.0), "Alpha overlay should appear for STO")
        app.buttons["func_√𝑥"].tap()
        #endif

        Thread.sleep(forTimeInterval: 0.5)
        
                // Should auto-return
        #if os(watchOS)
        let notHittable = NSPredicate(format: "exists == false")
        expectation(for: notHittable, evaluatedWith: textField, handler: nil)
        waitForExpectations(timeout: 2.0, handler: nil)
        #endif

        Thread.sleep(forTimeInterval: 1.0)
        
        // RCL is on Matrix2 (swipe up up)
        navigateToUpperMatrixPad(app: app)
        Thread.sleep(forTimeInterval: 1.0)
        
                app.buttons["func_RCL"].tap()
        #if os(watchOS)
        XCTAssertTrue(textField.waitForExistence(timeout: 2.0), "Variables sheet should appear for RCL")
        
        // Recall A
        textField.tap()
        textField.typeText("A\n")
        #else
        XCTAssertTrue(app.buttons["func_√𝑥"].waitForExistence(timeout: 2.0), "Alpha overlay should appear for RCL")
        app.buttons["func_√𝑥"].tap()
        #endif

        Thread.sleep(forTimeInterval: 1.0)
        
        #if os(watchOS)
        XCTAssertFalse(textField.exists, "Variables sheet should dismiss after RCL")
        #endif
    }
    
    func testRetroThemeUIAndMenuParityInSimulator() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITesting", "-useRetroUI"]
        setupSnapshot(app)
        app.launch()
        
        XCTAssertTrue(app.staticTexts.firstMatch.waitForExistence(timeout: 5.0), "App UI must be present in iOS Simulator")
        
        // Perform numbers and calculation in Simulator
        if app.buttons["btn_4"].exists {
            app.buttons["btn_4"].tap()
            app.buttons["btn_2"].tap()
        }
        
        snapshot("01_RetroUI_Simulator_State")
    }
}



@MainActor final class iOSParityUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func setupApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-parityMode", "1", "-animations", "0", "-useRetroUI"]
        app.launch()
        
        app.buttons["btn_yellow_shift"].tap()
        app.buttons["func_←"].tap()
        
        let predicate = NSPredicate(format: "existsNoRetry == 1")
        expectation(for: predicate, evaluatedWith: app.buttons["Clear ALL"], handler: nil)
        waitForExpectations(timeout: 2.0, handler: nil)
        
        // Ensure starting state is empty
        app.buttons["Clear ALL"].tap()
        return app
    }
    
    func saveParityScreenshot(app: XCUIApplication, name: String) {
        let hexText = app.staticTexts["lcd_buffer_hex"]
        if hexText.waitForExistence(timeout: 5.0) {
            let hexValue = hexText.label
            if hexValue.count > 0 {
                let saveDir = ProcessInfo.processInfo.environment["PARITY_SAVE_DIR"] ?? "/tmp"
                let url = URL(fileURLWithPath: saveDir).appendingPathComponent(name + ".txt")
                try? hexValue.write(to: url, atomically: true, encoding: .utf8)
                print("Saved hex buffer to \(url.path)")
            } else {
                print("Failed to get hex buffer from lcd_buffer_hex.label")
            }
        } else {
            print("lcd_buffer_hex did not exist")
        }
    }

    func testParityComplexEquation() throws {
        let app = setupApp()
        app.buttons["btn_blue_shift"].tap()
        app.buttons["func_STO"].tap() // EQN
        app.buttons["func_SIN"].tap()
        app.buttons["btn_1"].tap() // Let's just do SIN 1 since there is no "(" key!
        app.buttons["func_+"].tap()
        app.buttons["func_𝑒ˣ"].tap()
        app.buttons["invisible_ENTER"].tap()
        Thread.sleep(forTimeInterval: 1.0)
        saveParityScreenshot(app: app, name: "parity_complex_eqn")
    }

    func testParityMultiLineScroll() throws {
        let app = setupApp()
        app.buttons["btn_blue_shift"].tap()
        app.buttons["func_STO"].tap() // EQN
        app.buttons["func_√𝑥"].tap() // A
        app.buttons["func_+"].tap()
        app.buttons["func_𝑒ˣ"].tap() // B
        app.buttons["func_+"].tap()
        app.buttons["btn_1"].tap() // C
        app.buttons["func_+"].tap()
        app.buttons["btn_2"].tap() // D
        app.buttons["func_+"].tap()
        app.buttons["btn_3"].tap() // E
        Thread.sleep(forTimeInterval: 0.5)
        saveParityScreenshot(app: app, name: "parity_multiline_1")
        app.buttons["btn_yellow_shift"].tap()
        app.buttons["btn_8"].tap() // UP ARROW
        Thread.sleep(forTimeInterval: 0.5)
        saveParityScreenshot(app: app, name: "parity_multiline_2")
    }

    func testParityBaseModes() throws {
        let app = setupApp()
        app.buttons["btn_1"].tap()
        app.buttons["btn_2"].tap()
        app.buttons["invisible_ENTER"].tap()
        app.buttons["btn_yellow_shift"].tap()
        app.buttons["func_×"].tap() // BASE
        app.buttons["func_LFU_0"].tap() // Hex
        Thread.sleep(forTimeInterval: 0.5)
        saveParityScreenshot(app: app, name: "parity_base_mode")
    }

    func testParitySoftkeyLFU() throws {
        let app = setupApp()
        app.buttons["btn_yellow_shift"].tap()
        app.buttons["func_PLOT"].tap() // CONST
        Thread.sleep(forTimeInterval: 0.5)
        saveParityScreenshot(app: app, name: "parity_softkey_1")
        app.buttons["func_LFU_5"].tap() // MORE
        Thread.sleep(forTimeInterval: 0.5)
        saveParityScreenshot(app: app, name: "parity_softkey_2")
    }

    func testParityScientific() throws {
        let app = setupApp()
        app.buttons["btn_yellow_shift"].tap()
        app.buttons["func_E"].tap() // DISP
        app.buttons["func_LFU_1"].tap() // SCI
        app.buttons["btn_4"].tap() // SCI 4
        app.buttons["btn_1"].tap()
        app.buttons["btn_."].tap()
        app.buttons["btn_2"].tap()
        app.buttons["btn_3"].tap()
        app.buttons["func_E"].tap()
        app.buttons["btn_5"].tap()
        app.buttons["invisible_ENTER"].tap()
        Thread.sleep(forTimeInterval: 0.5)
        saveParityScreenshot(app: app, name: "parity_scientific")
    }
}
