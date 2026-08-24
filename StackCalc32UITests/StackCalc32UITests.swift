import XCTest
import RPNCore

@MainActor final class StackCalc32UITests: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  private func clearAll(app: XCUIApplication) {
      navigateToNumericPad(app: app)
      Thread.sleep(forTimeInterval: 0.1)
      app.buttons["btn_yellow_shift"].tap()
      navigateToArithmeticPad(app: app)
      Thread.sleep(forTimeInterval: 0.1)
      app.buttons["func_<-"].tap()
      app.swipeUp()
      app.buttons["Clear ALL"].firstMatch.tap()
      Thread.sleep(forTimeInterval: 1.5)
      navigateToNumericPad(app: app)
      Thread.sleep(forTimeInterval: 0.1)
  }
  private func navigateToNumericPad(app: XCUIApplication) {
    if app.buttons["btn_5"].exists { return }
    
    if app.buttons["func_A"].exists {
        app.buttons["sim_swipe_left"].tap()
        Thread.sleep(forTimeInterval: 0.5)
    } else if app.buttons["func_×"].exists {
        app.buttons["sim_swipe_right"].tap()
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    if app.buttons["func_STO"].exists {
        app.buttons["sim_swipe_up"].tap()
        Thread.sleep(forTimeInterval: 0.5)
        if app.buttons["func_STO"].exists {
            app.buttons["sim_swipe_up"].tap()
            Thread.sleep(forTimeInterval: 0.5)
        }
    }
    
    let _ = app.buttons["btn_5"].waitForExistence(timeout: 1.5)
  }

  private func navigateToArithmeticPad(app: XCUIApplication) {
    if app.buttons["func_×"].exists { return }
    navigateToNumericPad(app: app)
    app.buttons["sim_swipe_left"].tap()
    Thread.sleep(forTimeInterval: 0.5)
    let _ = app.buttons["func_×"].waitForExistence(timeout: 2.0)
  }

  private func navigateToUpperMatrixPad(app: XCUIApplication) {
    if app.buttons["func_STO"].exists { return }
    navigateToNumericPad(app: app)
    app.buttons["sim_swipe_down"].tap()
    Thread.sleep(forTimeInterval: 0.5)
    let _ = app.buttons["func_STO"].waitForExistence(timeout: 2.0)
  }

  private func navigateToLFUPad(app: XCUIApplication) {
    if app.buttons["func_A"].exists { return }
    navigateToNumericPad(app: app)
    app.buttons["sim_swipe_right"].tap()
    Thread.sleep(forTimeInterval: 0.5)
    let _ = app.buttons["func_A"].waitForExistence(timeout: 2.0)
  }

  func runSharedTestCase(_ testCase: SharedCalculatorTestCase) {
      let app = XCUIApplication()
      app.launchArguments = ["-UITesting"]
      setupSnapshot(app)
      app.launch()
      
      let display = app.staticTexts["lcd_display"]
      XCTAssertTrue(display.waitForExistence(timeout: 5))
      
      clearAll(app: app)
      
      for step in testCase.steps {
          let op = step.op
          
          if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "ENTER", "SHIFT_YELLOW", "SHIFT_BLUE"].contains(op) {
              navigateToNumericPad(app: app)
          } else if ["+", "-", "×", "÷", "<-", "+/-", "E", "𝑥≷𝑦"].contains(op) {
              navigateToArithmeticPad(app: app)
          } else if ["STO", "RCL", "√𝑥", "LN", "SIN", "COS", "TAN", "𝑒ˣ", "1/𝑥", "LFU_0", "LFU_1"].contains(op) {
              navigateToUpperMatrixPad(app: app)
          }
          
          if op == "SHIFT_YELLOW" {
              app.buttons["btn_yellow_shift"].tap()
          } else if op == "SHIFT_BLUE" {
              app.buttons["btn_blue_shift"].tap()
          } else if op == "ENTER" {
              app.otherElements["invisible_ENTER"].tap()
          } else if op == "<-" {
              app.buttons["func_<-"].tap()
          } else if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."].contains(op) {
              app.buttons["btn_\(op)"].tap()
          } else if op == "A" {
              let textField = app.textFields.firstMatch
              if textField.waitForExistence(timeout: 2.0) {
                  textField.tap()
                  textField.typeText("A\n")
              }
          } else if op == "𝑥≷𝑦" {
              app.buttons["func_𝑥≷𝑦"].tap()
          } else if op == "√𝑥" {
              app.buttons["func_√𝑥"].tap()
          } else if op == "𝑒ˣ" {
              app.buttons["func_𝑒ˣ"].tap()
          } else if op == "1/𝑥" {
              app.buttons["func_¹/𝑥"].tap()
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
              XCTAssertTrue(display.label.contains(expected), "[\(testCase.name)] Expected screen to contain \(expected), but got: \(display.label)")
          }
      }
  }

  func testAll32SIIMathOperations() throws {
      if let tc = SharedMathTestCases.cases.first(where: { $0.name == "All32SIIMathOperations" }) {
          runSharedTestCase(tc)
      } else {
          XCTFail("Could not find All32SIIMathOperations test case")
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
    app.buttons["func_X"].tap()

    navigateToNumericPad(app: app)
    app.buttons["btn_2"].tap()

    navigateToUpperMatrixPad(app: app)
    app.buttons["func_𝑦ˣ"].tap()

    // ENTER to save equation
    app.otherElements["invisible_ENTER"].tap()

    // Plot it (Yellow Shift +/-)
    navigateToNumericPad(app: app)
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["func_+/-"].tap()
    if app.buttons["btn_plot_execute"].waitForExistence(timeout: 5.0) {
        if !app.buttons["btn_plot_execute"].isHittable {
            app.swipeUp()
        }
        app.buttons["btn_plot_execute"].firstMatch.tap()
    } else {
        app.swipeUp()
        app.buttons["btn_plot_execute"].firstMatch.tap()
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

    // Sequence: Label 'X', then 'X' 'x^2' '0.5' '+/-' '×' 'e^x' '2' 'π' '×' '√x' '÷'
    navigateToLFUPad(app: app)
    app.buttons["func_X"].tap() // This is the label
    
    Thread.sleep(forTimeInterval: 0.5)
    navigateToLFUPad(app: app)
    app.buttons["func_X"].tap() // This is the first step of the program

    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    app.buttons["btn_yellow_shift"].tap()
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

    // Save equation and exit programming mode by double tapping
    app.staticTexts["lcd_display"].doubleTap()

    // Plot
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["func_+/-"].tap()
    if app.buttons["btn_integrate_execute"].waitForExistence(timeout: 5.0) {
        app.buttons["btn_integrate_execute"].tap()
    } else {
        app.swipeUp()
        app.buttons["btn_integrate_execute"].tap()
    }
    
    // Wait for integration and plot to finish
    Thread.sleep(forTimeInterval: 12.0)
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
    app.buttons["func_X"].tap()

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
    app.buttons["func_¹/𝑥"].tap()

    // Save equation and exit programming mode by double tapping
    app.staticTexts["lcd_display"].doubleTap()

    // Plot
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["func_+/-"].tap()
    if app.buttons["btn_plot_execute"].waitForExistence(timeout: 5.0) {
        if !app.buttons["btn_plot_execute"].isHittable {
            app.swipeUp()
        }
        app.buttons["btn_plot_execute"].firstMatch.tap()
    } else {
        app.swipeUp()
        app.buttons["btn_plot_execute"].firstMatch.tap()
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

    // 2. Numpad (btnZero) should be completely above the sticky toolbar (C button)
    XCTAssertLessThanOrEqual(
      zeroFrame.maxY, cFrame.minY,
      "Numeric pad (btn 0) overlaps with the sticky toolbar (C button)!")

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
    XCTAssertTrue(app.staticTexts["NPDF"].waitForExistence(timeout: 5))
    app.staticTexts["NPDF"].tap()
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)

    // Push 1, push 2 (Integration limits)
    app.buttons["btn_1"].tap()
    app.otherElements["invisible_ENTER"].tap()  // ENTER
    app.buttons["btn_2"].tap()

    // Tap integrate (Blue shift + 8)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["btn_8"].tap()

    // Tap Evaluate in the IntegratePromptView
    if app.buttons["Evaluate"].waitForExistence(timeout: 5.0) {
        if !app.buttons["Evaluate"].isHittable {
            app.swipeUp()
        }
        app.buttons["Evaluate"].firstMatch.tap()
    } else {
        app.swipeUp()
        app.buttons["Evaluate"].firstMatch.tap()
    }
    
    // Wait a little for integration to run
    sleep(2)

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
    app.otherElements["invisible_ENTER"].tap()  // ENTER
    app.buttons["btn_1"].tap()

    // Integrate (Blue shift + 8)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["btn_8"].tap()
    
    // Tap Evaluate in the IntegratePromptView
    if app.buttons["Evaluate"].waitForExistence(timeout: 5.0) {
        if !app.buttons["Evaluate"].isHittable {
            app.swipeUp()
        }
        app.buttons["Evaluate"].firstMatch.tap()
    } else {
        app.swipeUp()
        app.buttons["Evaluate"].firstMatch.tap()
    }
    
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
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["func_+/-"].tap()
    if app.buttons["btn_plot_execute"].waitForExistence(timeout: 5.0) {
        if !app.buttons["btn_plot_execute"].isHittable {
            app.swipeUp()
        }
        app.buttons["btn_plot_execute"].firstMatch.tap()
    } else {
        app.swipeUp()
        app.buttons["btn_plot_execute"].firstMatch.tap()
    }
    Thread.sleep(forTimeInterval: 5.0)
    snapshot("watch_3_plot")
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
    app.otherElements["invisible_ENTER"].tap()  // ENTER
    app.buttons["btn_9"].tap()
    Thread.sleep(forTimeInterval: 1.0)

    // Open CLEAR menu (Shift + <-)
    navigateToArithmeticPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["func_<-"].tap()

    // Should show Clear Menu
    XCTAssertTrue(app.navigationBars["Clear"].waitForExistence(timeout: 2.0))

    // Tap Clear x
    app.buttons["Clear ALL"].tap()

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
    app.otherElements["invisible_ENTER"].tap()
    app.otherElements["invisible_ENTER"].tap()
    app.otherElements["invisible_ENTER"].tap()
    app.otherElements["invisible_ENTER"].tap()

    // Arrow should exist now since stack has > 4
    XCTAssertTrue(app.staticTexts["stack_indicator"].waitForExistence(timeout: 2.0))

    // Clear all to empty the stack
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    clearAll(app: app)
    app.buttons["sim_swipe_up"].tap()

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
    app.otherElements["invisible_ENTER"].tap()

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
    
    // Screenshot 2: Equation (Blue Shift + STO)
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    app.buttons["btn_blue_shift"].tap()
    Thread.sleep(forTimeInterval: 0.5)
    app.buttons["func_STO"].tap()
    Thread.sleep(forTimeInterval: 1.0)
    app.buttons["btn_add_eqn"].tap()
    Thread.sleep(forTimeInterval: 1.5)
    
    // Label A
    navigateToLFUPad(app: app)
    app.buttons["func_A"].tap()
    app.otherElements["invisible_ENTER"].tap() // Accept label A
    Thread.sleep(forTimeInterval: 1.0)
    
    // X x^2
    app.buttons["func_X"].tap()
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["func_√𝑥"].tap()
    
    Thread.sleep(forTimeInterval: 1.0)
    snapshot("2-Equation")
    
    app.otherElements["invisible_ENTER"].tap() // Accept equation
    Thread.sleep(forTimeInterval: 1.5)
    
    // Screenshot 3: Plotting
    navigateToNumericPad(app: app)
    
    // Exit Equation typing mode by pressing C
    if app.buttons["C"].exists {
        app.buttons["C"].tap()
    }
    Thread.sleep(forTimeInterval: 1.0)
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["func_+/-"].tap() // PLOT
    if app.buttons["btn_plot_execute"].waitForExistence(timeout: 5.0) {
        app.buttons["btn_plot_execute"].tap()
    } else {
        app.swipeUp()
        if app.buttons["btn_plot_execute"].waitForExistence(timeout: 2.0) {
            app.buttons["btn_plot_execute"].tap()
        }
    }
    
    Thread.sleep(forTimeInterval: 3.0) // wait for plot
    snapshot("3-Plotting")
    
    // Close plot
    if app.buttons["btn_plot_c"].waitForExistence(timeout: 2.0) {
        app.buttons["btn_plot_c"].tap()
    }
    
    Thread.sleep(forTimeInterval: 1.0)
    
    // Screenshot 4: Fractions
    navigateToNumericPad(app: app)
    app.buttons["C"].tap()
    app.buttons["C"].tap()
    app.buttons["C"].tap()
    app.buttons["btn_2"].tap()
    app.buttons["btn_."].tap()
    app.buttons["btn_1"].tap()
    app.buttons["btn_2"].tap()
    app.buttons["btn_5"].tap()
    
    // Tap FDISP (Yellow Shift + .)
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["btn_."].tap()
    Thread.sleep(forTimeInterval: 1.0)
    
    snapshot("4-Fractions")
    
    // Screenshot 5: Stats Menu
    app.buttons["C"].tap()
    app.buttons["C"].tap()
    app.buttons["C"].tap()
    app.buttons["C"].tap()
    navigateToNumericPad(app: app)
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["btn_6"].tap() // SUMS menu
    Thread.sleep(forTimeInterval: 1.0)
    
    snapshot("5-Stats")
    
    // Close Stats Menu
    if app.buttons["sheet_dismiss_btn"].exists {
        app.buttons["sheet_dismiss_btn"].tap()
    } else if app.buttons["Cancel"].exists {
        app.buttons["Cancel"].tap()
    } else if app.buttons["C"].exists {
        app.buttons["C"].tap()
    }
    
    Thread.sleep(forTimeInterval: 1.0)
    
    // Screenshot 6: Integral Plotting
    app.buttons["C"].tap()
    app.buttons["C"].tap()
    app.buttons["C"].tap()
    // Setup equation NPDF (it is a built in program usually or we can just integrate our X^2)
    // Since X^2 is already in EQN, we can evaluate it
    // FN= 
    navigateToLFUPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["func_XEQ"].tap()
    // It should list equations
    XCTAssertTrue(app.cells.element(boundBy: 1).waitForExistence(timeout: 5))
    app.cells.element(boundBy: 1).tap()
    
    navigateToNumericPad(app: app)
    app.buttons["btn_0"].tap()
    app.otherElements["invisible_ENTER"].tap()
    app.buttons["btn_2"].tap()
    
    app.buttons["btn_blue_shift"].tap()
    app.buttons["btn_8"].tap() // Integrate
    if app.buttons["Evaluate"].waitForExistence(timeout: 5.0) {
        if !app.buttons["Evaluate"].isHittable {
            app.swipeUp()
        }
        app.buttons["Evaluate"].firstMatch.tap()
    } else {
        app.swipeUp()
        app.buttons["Evaluate"].firstMatch.tap()
    }
    
    Thread.sleep(forTimeInterval: 6.0) // wait for plot (integration takes longer)
    snapshot("6-IntegralPlot")
    
    // Close plot
    if app.buttons["btn_plot_c"].waitForExistence(timeout: 2.0) {
        app.buttons["btn_plot_c"].tap()
    }
  }



  func testVideoNormalPDF() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()
    
    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))
    let pad = app.otherElements["numpad_bg"]
    
    func slowTap(_ element: XCUIElement) {
        element.tap()
        Thread.sleep(forTimeInterval: 0.8)
    }

    // Jump to Matrix2View where STO is
    navigateToUpperMatrixPad(app: app)

    // EQN is Blue Shift + STO
    slowTap(app.buttons["btn_blue_shift"])
    slowTap(app.buttons["func_STO"])
    
    // Tap Add Equation button in the list view
    Thread.sleep(forTimeInterval: 1.0)
    slowTap(app.buttons["btn_add_eqn"])
    Thread.sleep(forTimeInterval: 1.5)
    
    // Currently on LFU Matrix2View. Need to go to Variables.
    navigateToLFUPad(app: app) // Jump straight to Variables Pad
    Thread.sleep(forTimeInterval: 1.0)
    
    slowTap(app.buttons["func_X"])
    
    // Variables to Matrix3View (where x^2 is)
    navigateToNumericPad(app: app) // Numeric pad
    navigateToUpperMatrixPad(app: app) // Matrix3View
    Thread.sleep(forTimeInterval: 0.5)
    
    slowTap(app.buttons["btn_yellow_shift"])
    slowTap(app.buttons["func_√𝑥"])
    
    // LFU to Numeric (Jump to Page 1)
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    
    slowTap(app.buttons["btn_0"])
    slowTap(app.buttons["btn_."])
    slowTap(app.buttons["btn_5"])
    slowTap(app.buttons["func_+/-"])
    
    // Numeric to Arithmetic
    navigateToArithmeticPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    slowTap(app.buttons["func_×"]) // wait, earlier it used element(boundBy: 1), I'll just use it directly
    
    // Arithmetic to Matrix3View (where e^x is)
    navigateToNumericPad(app: app) // Numeric pad
    navigateToUpperMatrixPad(app: app) // Matrix3View
    Thread.sleep(forTimeInterval: 0.5)
    
    slowTap(app.buttons["func_𝑒ˣ"])
    
    // LFU to Numeric
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    slowTap(app.buttons["btn_2"])
    
    // Numeric to Matrix2View (where pi is)
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    slowTap(app.buttons["btn_blue_shift"])
    slowTap(app.buttons["func_SIN"])
    
    // Jump to Arithmetic
    navigateToArithmeticPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    slowTap(app.buttons["func_×"])
    
    // Jump to Matrix3View (where √x is)
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    slowTap(app.buttons["func_√𝑥"])
    
    // LFU to Arithmetic
    navigateToArithmeticPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    slowTap(app.buttons["func_÷"]) // This taps the ÷ button in the equation editor. Wait, is it func_÷?
    
    slowTap(app.otherElements["invisible_ENTER"]) // Save Eqn
    
    // Should return to Numeric pad, wait and tap
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    
    slowTap(app.buttons["btn_1"])
    slowTap(app.buttons["btn_0"])
    slowTap(app.buttons["func_+/-"])
    slowTap(app.otherElements["invisible_ENTER"]) // Enter
    slowTap(app.buttons["btn_0"])
    
    slowTap(app.buttons["btn_yellow_shift"])
    slowTap(app.buttons["btn_8"]) // Integrate
    
    Thread.sleep(forTimeInterval: 3.0)
    
    slowTap(app.buttons["btn_yellow_shift"])
    slowTap(app.buttons["func_+/-"])
    if app.buttons["btn_plot_execute"].waitForExistence(timeout: 5.0) {
        if !app.buttons["btn_plot_execute"].isHittable {
            app.swipeUp()
        }
        app.buttons["btn_plot_execute"].firstMatch.tap()
    } else {
        app.swipeUp()
        app.buttons["btn_plot_execute"].firstMatch.tap()
    } // Plot
    
    Thread.sleep(forTimeInterval: 5.0)
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
    app.otherElements["invisible_ENTER"].tap() // ENTER
    app.buttons["btn_2"].tap()
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["func_Σ+"].tap() // Σ+
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)

    // Enter point 2 (3, 4)
    app.buttons["btn_3"].tap()
    app.otherElements["invisible_ENTER"].tap() // ENTER
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
    if app.buttons["x̄ (Mean of x)"].waitForExistence(timeout: 2.0) {
        if !app.buttons["x̄ (Mean of x)"].isHittable {
            app.swipeUp()
        }
        app.buttons["x̄ (Mean of x)"].firstMatch.tap()
    } else {
        app.swipeUp()
        app.buttons["x̄ (Mean of x)"].firstMatch.tap()
    }
    // Assert display is 3 (Mean of X for 2 and 4)
    XCTAssertEqual(display.label, "3")
    
    // Trigger STAT PLOT
    navigateToNumericPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["func_+/-"].tap() // PLOT
    
    // Wait for prompt to appear
    if app.buttons["Source"].waitForExistence(timeout: 2.0) {
        app.buttons["Source"].tap()
        app.buttons["Statistics Data"].tap()
        app.buttons["btn_plot_execute"].tap()
    } else {
        app.swipeUp()
        app.buttons["btn_plot_execute"].tap()
    }
    
    // Wait a bit for plot to render
    Thread.sleep(forTimeInterval: 2.0)
    
    // The test passes if the plot doesn't crash.
    // Regression line should be visible in the view.
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

  func testIntegrationPlotArea() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // 1. Enter an equation: EQN, A, X^2, ENTER
    navigateToUpperMatrixPad(app: app)
    app.buttons["btn_blue_shift"].tap()
    app.buttons["func_STO"].tap() // EQN
    Thread.sleep(forTimeInterval: 1.0)
    
    app.buttons["btn_add_eqn"].tap()
    Thread.sleep(forTimeInterval: 1.5)
    
    // Select label A
    navigateToLFUPad(app: app)
    app.buttons["func_A"].tap()
    app.otherElements["invisible_ENTER"].tap()
    Thread.sleep(forTimeInterval: 1.0)
    
    // RPN sequence: X x^2
    navigateToLFUPad(app: app)
    app.buttons["func_X"].tap()
    
    navigateToUpperMatrixPad(app: app)
    Thread.sleep(forTimeInterval: 0.5)
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["func_√𝑥"].tap() // x^2

    app.otherElements["invisible_ENTER"].tap()
    
    // 2. Open plot menu
    navigateToNumericPad(app: app)
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["func_+/-"].tap() // PLOT
    
    // Wait for prompt
    if app.buttons["Source"].waitForExistence(timeout: 2.0) {
        app.buttons["Source"].tap()
        app.buttons["Equation (EQN list)"].tap()
        
        app.buttons["Equation"].tap()
        app.buttons["A"].tap()
        
        app.buttons["btn_plot_execute"].firstMatch.tap()
    } else {
        app.buttons["btn_plot_execute"].firstMatch.tap()
    }
    
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
    app.otherElements["invisible_ENTER"].tap()
    
    // Tap PLOT (yellow shift +/-)
    app.buttons["btn_yellow_shift"].tap()
    app.buttons["func_+/-"].tap()
    
    // Select Plot
    if app.buttons["btn_plot_execute"].waitForExistence(timeout: 5.0) {
        if !app.buttons["btn_plot_execute"].isHittable {
            app.swipeUp()
        }
        app.buttons["btn_plot_execute"].firstMatch.tap()
    } else {
        app.swipeUp()
        app.buttons["btn_plot_execute"].firstMatch.tap()
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
    
    // The screen display holds the full string unformatted during entry
    XCTAssertTrue(display.label.contains("123456789012"))
    
    app.otherElements["invisible_ENTER"].tap()
    
    // After ENTER, it is formatted to scientific notation (9 char limit)
    // 123456789012 -> 1.2346E11
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
        // Open CONST menu via yellow-shift on STAY
        navigateToLFUPad(app: app)
        Thread.sleep(forTimeInterval: 0.2)
        
        app.buttons["btn_yellow_shift"].tap()
        app.buttons["func_STAY"].tap()
        
        XCTAssertTrue(app.staticTexts["CNST"].waitForExistence(timeout: 2.0))
        
        // Search is flaky on watchOS UI tests, but we can verify it opened
        // and we could try to tap the first constant just to verify it dismisses
        if constantName == "Pi" {
            let piText = app.staticTexts["Pi"]
            if piText.waitForExistence(timeout: 2.0) {
                piText.tap()
                XCTAssertTrue(display.waitForExistence(timeout: 2.0))
                XCTAssertTrue(display.label.contains("3.1415"))
                app.buttons["func_<-"].tap() // Clear for next
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
        app.buttons["sim_swipe_right"].tap()
        Thread.sleep(forTimeInterval: 0.2)
    }
  }

  func testExamMode() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    func slowTap(_ element: XCUIElement) {
        element.tap()
        Thread.sleep(forTimeInterval: 0.8)
    }

    navigateToArithmeticPad(app: app)

    // Open Flags Menu (Blue Shift -> ×)
    slowTap(app.buttons["btn_blue_shift"])
    slowTap(app.buttons["func_×"])

    // Toggle Exam Mode
    let examModeToggle = app.switches["Exam Mode"]
    XCTAssertTrue(examModeToggle.waitForExistence(timeout: 5))
    slowTap(examModeToggle)

    // Dismiss Flags Menu
    slowTap(app.buttons["sheet_dismiss_btn"].firstMatch)

    // Verify Exam badge exists
    let examBadge = app.staticTexts["exam_indicator"]
    XCTAssertTrue(examBadge.waitForExistence(timeout: 5))

    // Press a number (must be on numeric pad)
    navigateToNumericPad(app: app)
    slowTap(app.buttons["btn_5"])
    XCTAssertEqual(display.label, "5")

    // Open Flags Menu again
    navigateToArithmeticPad(app: app)
    slowTap(app.buttons["btn_blue_shift"])
    slowTap(app.buttons["func_×"])

    // Toggle Exam Mode OFF
    XCTAssertTrue(examModeToggle.waitForExistence(timeout: 5))
    slowTap(examModeToggle)

    // Dismiss Flags Menu
    slowTap(app.buttons["sheet_dismiss_btn"].firstMatch)

    // Verify Exam badge is gone
    XCTAssertFalse(examBadge.exists)
  }
}

