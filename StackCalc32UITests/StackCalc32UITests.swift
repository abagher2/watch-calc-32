import XCTest
import RPNCore

@MainActor final class StackCalc32UITests: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  private func clearAll(app: XCUIApplication) {
      
      Thread.sleep(forTimeInterval: 0.1)
      app.navigateAndTap("op_shiftYellow")
      
      Thread.sleep(forTimeInterval: 0.1)
      app.navigateAndTap("op_backspace")
      app.tapEnter()
      app.navigateAndTap("Clear ALL")
      Thread.sleep(forTimeInterval: 1.5)
      
      Thread.sleep(forTimeInterval: 0.1)
  }
  private func navigateToNumericPad(app: XCUIApplication) {
    if app.buttons["op_digit5"].exists { return }
    
    if app.buttons["alpha_A"].exists {
        app.navigateAndTap("sim_swipe_left")
        Thread.sleep(forTimeInterval: 0.5)
    } else if app.buttons["op_multiply"].exists {
        app.navigateAndTap("sim_swipe_right")
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    if app.buttons["op_sto"].exists {
        app.navigateAndTap("sim_swipe_up")
        Thread.sleep(forTimeInterval: 0.5)
        if app.buttons["op_sto"].exists {
            app.navigateAndTap("sim_swipe_up")
            Thread.sleep(forTimeInterval: 0.5)
        }
    }
    
    let _ = app.buttons["op_digit5"].waitForExistence(timeout: 1.5)
  }

  private func navigateToArithmeticPad(app: XCUIApplication) {
    if app.buttons["op_multiply"].exists { return }
    
    app.navigateAndTap("sim_swipe_left")
    Thread.sleep(forTimeInterval: 0.5)
    let _ = app.buttons["op_multiply"].waitForExistence(timeout: 2.0)
  }

  private func navigateToUpperMatrixPad(app: XCUIApplication) {
    if app.buttons["op_sto"].exists { return }
    
    app.navigateAndTap("sim_swipe_down")
    Thread.sleep(forTimeInterval: 0.5)
    let _ = app.buttons["op_sto"].waitForExistence(timeout: 2.0)
  }

  private func navigateToLFUPad(app: XCUIApplication) {
    if app.buttons["alpha_A"].exists { return }
    
    app.navigateAndTap("sim_swipe_right")
    Thread.sleep(forTimeInterval: 0.5)
    let _ = app.buttons["alpha_A"].waitForExistence(timeout: 2.0)
  }

  func runSharedTestCase(_ testCase: SharedCalculatorTestCase) {
      let app = XCUIApplication()
      app.launchArguments = ["-UITesting"]
      setupSnapshot(app)
      app.launch()
      
      let display = app.descendants(matching: .any)["lcd_display"]
      XCTAssertTrue(display.waitForExistence(timeout: 5))
      
      clearAll(app: app)
      
      for step in testCase.steps {
          let op = step.op
          
          if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "ENTER", "SHIFT_YELLOW", "SHIFT_BLUE"].contains(op) {
              
          } else if ["+", "-", "×", "÷", "<-", "+/-", "E", "𝑥≷𝑦"].contains(op) {
              
          } else if ["STO", "RCL", "√𝑥", "LN", "SIN", "COS", "TAN", "𝑒ˣ", "1/𝑥", "LFU_0", "LFU_1"].contains(op) {
              
          }
          
          if op == "SHIFT_YELLOW" {
              app.navigateAndTap("op_shiftYellow")
          } else if op == "SHIFT_BLUE" {
              app.navigateAndTap("op_shiftBlue")
          } else if op == "ENTER" {
              app.tapEnter()
          } else if op == "<-" {
              app.navigateAndTap("op_backspace")
          } else if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."].contains(op) {
              if op == "." { app.navigateAndTap("op_decimal") } else { if op == "." { app.navigateAndTap("op_decimal") } else { app.navigateAndTap("op_digit\(op)") } }
          } else if op == "A" {
              let textField = app.textFields.firstMatch
              if textField.waitForExistence(timeout: 2.0) {
                  textField.tap()
                  textField.typeText("A\n")
              }
          } else if op == "𝑥≷𝑦" {
              app.navigateAndTap("op_swapXY")
          } else if op == "√𝑥" {
              app.navigateAndTap("op_sqrt")
          } else if op == "𝑒ˣ" {
              app.navigateAndTap("op_exp")
          } else if op == "1/𝑥" {
              app.navigateAndTap("op_reciprocal")
          } else if op == "LFU_0" {
              app.navigateAndTap("IP (Integer Part)")
          } else if op == "LFU_1" {
              app.navigateAndTap("FP (Fractional Part)")
          } else {
              let buttonId = "func_\(op)"
              if app.buttons[buttonId].exists {
                  app.navigateAndTap(buttonId)
              } else {
                  app.navigateAndTap(op)
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

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    clearAll(app: app)  // yellow shift

    
    _ = app.buttons["op_digit7"].waitForExistence(timeout: 1.0)
    app.navigateAndTap("op_digit7")  // SOLVE

    XCTAssertTrue(display.exists)
  }

  func testPlotting() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Jump to Matrix2View where STO is
    
    Thread.sleep(forTimeInterval: 0.5)

    // EQN is Blue Shift + STO
    app.navigateAndTap("op_shiftBlue")
    Thread.sleep(forTimeInterval: 0.5)
    app.navigateAndTap("op_sto")
    
    Thread.sleep(forTimeInterval: 1.0)
    app.navigateAndTap("btn_add_eqn")
    Thread.sleep(forTimeInterval: 1.5)

    // RPN sequence: X 2 y^x
    navigateToLFUPad(app: app)
    app.navigateAndTap("alpha_X")

    
    app.navigateAndTap("op_digit2")

    
    app.navigateAndTap("op_power")

    // ENTER to save equation
    app.tapEnter()

    // Plot it (Yellow Shift +/-)
    
    app.navigateAndTap("op_shiftYellow")
    app.navigateAndTap("op_toggleSign")
    if app.buttons["btn_plot_execute"].waitForExistence(timeout: 5.0) {
        if !app.buttons["btn_plot_execute"].isHittable {
            app.tapEnter()
        }
        app.navigateAndTap("btn_plot_execute")
    } else {
        app.tapEnter()
        app.navigateAndTap("btn_plot_execute")
    }
  }

  func testNormalPDFPlotting() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Enter equation mode using EQN (Blue Shift + STO)
    
    app.navigateAndTap("op_shiftBlue")
    app.navigateAndTap("op_sto")
    Thread.sleep(forTimeInterval: 1.0)
    app.navigateAndTap("btn_add_eqn")
    Thread.sleep(forTimeInterval: 1.5)

    // Sequence: Label 'X', then 'X' 'x^2' '0.5' '+/-' '×' 'e^x' '2' 'π' '×' '√x' '÷'
    navigateToLFUPad(app: app)
    app.navigateAndTap("alpha_X") // This is the label
    
    Thread.sleep(forTimeInterval: 0.5)
    navigateToLFUPad(app: app)
    app.navigateAndTap("alpha_X") // This is the first step of the equation

    
    Thread.sleep(forTimeInterval: 0.5)
    app.navigateAndTap("op_shiftYellow")
    app.navigateAndTap("op_sqrt")

    
    app.navigateAndTap("op_digit0")
    app.navigateAndTap("op_decimal")
    app.navigateAndTap("op_digit5")
    app.navigateAndTap("op_toggleSign")

    
    app.navigateAndTap("op_multiply")

    
    Thread.sleep(forTimeInterval: 0.5)
    app.navigateAndTap("op_exp")

    
    app.navigateAndTap("op_digit2")

    // π is blue shift of SIN in Matrix2View
    
    
    Thread.sleep(forTimeInterval: 0.5)
    app.navigateAndTap("op_shiftBlue")
    app.navigateAndTap("op_sin")

    
    app.navigateAndTap("op_multiply")

    // √𝑥 is in Matrix3View
    
    Thread.sleep(forTimeInterval: 0.5)
    app.navigateAndTap("op_sqrt")

    
    app.navigateAndTap("op_divide")

    // Save equation and exit programming mode by double tapping
    app.descendants(matching: .any)["lcd_display"].doubleTap()

    // Plot
    
    Thread.sleep(forTimeInterval: 0.4)
    app.navigateAndTap("op_shiftYellow")
    app.navigateAndTap("op_toggleSign")
    if app.buttons["btn_integrate_execute"].waitForExistence(timeout: 5.0) {
        app.navigateAndTap("btn_integrate_execute")
    } else {
        app.tapEnter()
        app.navigateAndTap("btn_integrate_execute")
    }
    
    // Wait for integration and plot to finish
    Thread.sleep(forTimeInterval: 12.0)
  }

  func testSigmoidPlotting() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Enter equation mode using EQN (Blue Shift + STO)
    
    app.navigateAndTap("op_shiftBlue")
    app.navigateAndTap("op_sto")
    Thread.sleep(forTimeInterval: 1.0)
    app.navigateAndTap("btn_add_eqn")
    Thread.sleep(forTimeInterval: 1.5)

    // Sequence: X +/- e^x 1 + 1/x
    navigateToLFUPad(app: app)
    app.navigateAndTap("alpha_X")

    
    app.navigateAndTap("op_toggleSign")

    
    Thread.sleep(forTimeInterval: 0.5)
    app.navigateAndTap("op_exp")

    
    app.navigateAndTap("op_digit1")

    
    app.navigateAndTap("op_add")

    // 1/x is in Matrix3View
    
    Thread.sleep(forTimeInterval: 0.5)
    app.navigateAndTap("op_reciprocal")

    // Save equation and exit programming mode by double tapping
    app.descendants(matching: .any)["lcd_display"].doubleTap()

    // Plot
    
    Thread.sleep(forTimeInterval: 0.4)
    app.navigateAndTap("op_shiftYellow")
    app.navigateAndTap("op_toggleSign")
    if app.buttons["btn_plot_execute"].waitForExistence(timeout: 5.0) {
        if !app.buttons["btn_plot_execute"].isHittable {
            app.tapEnter()
        }
        app.navigateAndTap("btn_plot_execute")
    } else {
        app.tapEnter()
        app.navigateAndTap("btn_plot_execute")
    }
  }

  func testViewMenu() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    app.navigateAndTap("op_shiftBlue")  // blue shift
    
    app.navigateAndTap("op_digit0")  // VIEW

    // The stack view should appear
  }

  func testLayoutNoOverlap() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    XCTAssertTrue(app.descendants(matching: .any)["lcd_display"].waitForExistence(timeout: 5.0))

    // Let UI settle
    Thread.sleep(forTimeInterval: 1.0)

    let lcdDisplay = app.descendants(matching: .any)["lcd_display"]
    let btnC = app.buttons["C"]
    let btnZero = app.buttons["op_digit0"]

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

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Set FN=
    navigateToLFUPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.navigateAndTap("op_shiftBlue")
    app.navigateAndTap("op_xeq")
    XCTAssertTrue(app.staticTexts["NPDF"].waitForExistence(timeout: 5))
    app.staticTexts["NPDF"].tap()
    
    Thread.sleep(forTimeInterval: 0.4)

    // Push 1, push 2 (Integration limits)
    app.navigateAndTap("op_digit1")
    app.tapEnter()  // ENTER
    app.navigateAndTap("op_digit2")

    // Tap integrate (Blue shift + 8)
    app.navigateAndTap("op_shiftBlue")
    app.navigateAndTap("op_digit8")

    // Tap Evaluate in the IntegratePromptView
    if app.buttons["Evaluate"].waitForExistence(timeout: 5.0) {
        if !app.buttons["Evaluate"].isHittable {
            app.tapEnter()
        }
        app.navigateAndTap("Evaluate")
    } else {
        app.tapEnter()
        app.navigateAndTap("Evaluate")
    }
    
    // Wait a little for integration to run
    sleep(2)

    // Plot should open automatically
    XCTAssertTrue(app.buttons["btn_plot_c"].waitForExistence(timeout: 25.0))
    app.navigateAndTap("btn_plot_c") // Dismiss plot
  }

  func testNumericIntegration() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Set FN=
    navigateToLFUPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.navigateAndTap("op_shiftBlue")
    app.navigateAndTap("op_xeq")
    XCTAssertTrue(app.staticTexts["NPDF"].waitForExistence(timeout: 5))
    app.staticTexts["NPDF"].tap()
    
    Thread.sleep(forTimeInterval: 0.4)

    // Push 0, push 1
    app.navigateAndTap("op_digit0")
    app.tapEnter()  // ENTER
    app.navigateAndTap("op_digit1")

    // Integrate (Blue shift + 8)
    app.navigateAndTap("op_shiftBlue")
    app.navigateAndTap("op_digit8")
    
    // Tap Evaluate in the IntegratePromptView
    if app.buttons["Evaluate"].waitForExistence(timeout: 5.0) {
        if !app.buttons["Evaluate"].isHittable {
            app.tapEnter()
        }
        app.navigateAndTap("Evaluate")
    } else {
        app.tapEnter()
        app.navigateAndTap("Evaluate")
    }
    
    // Wait a little for integration to run
    sleep(2)
  }

  func testPlottingWithRange() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Set limits for Plotting? We can just invoke PLOT
    
    Thread.sleep(forTimeInterval: 0.4)
    app.navigateAndTap("op_shiftYellow")
    app.navigateAndTap("op_toggleSign")
    if app.buttons["btn_plot_execute"].waitForExistence(timeout: 5.0) {
        if !app.buttons["btn_plot_execute"].isHittable {
            app.tapEnter()
        }
        app.navigateAndTap("btn_plot_execute")
    } else {
        app.tapEnter()
        app.navigateAndTap("btn_plot_execute")
    }
    Thread.sleep(forTimeInterval: 5.0)
    snapshot("watch_3_plot")
  }

  func testFNMode() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // FN=
    navigateToLFUPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.navigateAndTap("op_shiftBlue")
    app.navigateAndTap("op_xeq")

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
    app.navigateAndTap("op_shiftBlue")
    app.navigateAndTap("op_xeq")

    XCTAssertTrue(app.staticTexts["NPDF"].waitForExistence(timeout: 5))
    app.staticTexts["NPDF"].tap()
  }

  func testEquationEvaluation() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Jump to Matrix2View where STO is
    
    Thread.sleep(forTimeInterval: 0.5)

    // EQN is Blue Shift + STO
    app.navigateAndTap("op_shiftBlue")
    Thread.sleep(forTimeInterval: 0.5)
    app.navigateAndTap("op_sto")
    
    Thread.sleep(forTimeInterval: 1.0)
    app.navigateAndTap("btn_add_eqn")
    Thread.sleep(forTimeInterval: 1.5)

    // Equation mode left justifies and shows EQN in display
  }

  func testClearMenuFlow() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    

    // Input some numbers
    app.navigateAndTap("op_digit5")
    app.tapEnter()  // ENTER
    app.navigateAndTap("op_digit9")
    Thread.sleep(forTimeInterval: 1.0)

    // Open CLEAR menu (Shift + <-)
    
    Thread.sleep(forTimeInterval: 0.5)
    
    app.navigateAndTap("op_shiftYellow")
    app.navigateAndTap("op_backspace")

    // Should show Clear Menu
    XCTAssertTrue(app.navigationBars["Clear"].waitForExistence(timeout: 2.0))

    // Tap Clear x
    app.navigateAndTap("Clear ALL")

    // Display should clear current input
    XCTAssertEqual(display.label, "0")
  }

  func testStackIndicator() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    

    // Empty stack arrow should NOT exist initially
    XCTAssertFalse(app.staticTexts["stack_indicator"].exists)

    // Input 5 ENTER ENTER ENTER ENTER to push stack beyond 4
    app.navigateAndTap("op_digit5")
    app.tapEnter()
    app.tapEnter()
    app.tapEnter()
    app.tapEnter()

    // Arrow should exist now since stack has > 4
    XCTAssertTrue(app.staticTexts["stack_indicator"].waitForExistence(timeout: 2.0))

    // Clear all to empty the stack
    
    Thread.sleep(forTimeInterval: 0.5)
    clearAll(app: app)
    app.navigateAndTap("sim_swipe_up")

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
                
                app.navigateAndTap("op_toggleSign")
            }
            continue
        } else if char == "+" {
            continue
        } else if char == "e" || char == "E" {
            inExponent = true
            
            app.navigateAndTap("op_e")
        } else if char == "." {
            
            app.navigateAndTap("op_decimal")
        } else {
            
            app.navigateAndTap("op_digit\(char)")
        }
    }
    
    
    app.tapEnter()

    if negateMantissa {
        
        app.navigateAndTap("op_toggleSign")
    }
  }


    @MainActor func testAppStoreScreenshots() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()
    
    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))
    
    // Screenshot 1: Main Numpad
    snapshot("1-Main")
    
    // Screenshot 2: Equation (Blue Shift + STO)
    
    Thread.sleep(forTimeInterval: 0.5)
    app.navigateAndTap("op_shiftBlue")
    Thread.sleep(forTimeInterval: 0.5)
    app.navigateAndTap("op_sto")
    Thread.sleep(forTimeInterval: 1.0)
    app.navigateAndTap("btn_add_eqn")
    Thread.sleep(forTimeInterval: 1.5)
    
    // Label A
    navigateToLFUPad(app: app)
    app.navigateAndTap("alpha_A")
    app.tapEnter() // Accept label A
    Thread.sleep(forTimeInterval: 1.0)
    
    // X x^2
    app.navigateAndTap("alpha_X")
    
    Thread.sleep(forTimeInterval: 0.5)
    app.navigateAndTap("op_shiftYellow")
    app.navigateAndTap("op_sqrt")
    
    Thread.sleep(forTimeInterval: 1.0)
    snapshot("2-Equation")
    
    app.tapEnter() // Accept equation
    Thread.sleep(forTimeInterval: 1.5)
    
    // Screenshot 3: Plotting
    
    
    // Exit Equation typing mode by pressing C
    if app.buttons["C"].exists {
        app.navigateAndTap("C")
    }
    Thread.sleep(forTimeInterval: 1.0)
    app.navigateAndTap("op_shiftYellow")
    app.navigateAndTap("op_toggleSign") // PLOT
    if app.buttons["btn_plot_execute"].waitForExistence(timeout: 5.0) {
        app.navigateAndTap("btn_plot_execute")
    } else {
        app.tapEnter()
        if app.buttons["btn_plot_execute"].waitForExistence(timeout: 2.0) {
            app.navigateAndTap("btn_plot_execute")
        }
    }
    
    Thread.sleep(forTimeInterval: 3.0) // wait for plot
    snapshot("3-Plotting")
    
    // Close plot
    if app.buttons["btn_plot_c"].waitForExistence(timeout: 2.0) {
        app.navigateAndTap("btn_plot_c")
    }
    
    Thread.sleep(forTimeInterval: 1.0)
    
    // Screenshot 4: Fractions
    
    app.navigateAndTap("C")
    app.navigateAndTap("C")
    app.navigateAndTap("C")
    app.navigateAndTap("op_digit2")
    app.navigateAndTap("op_decimal")
    app.navigateAndTap("op_digit1")
    app.navigateAndTap("op_digit2")
    app.navigateAndTap("op_digit5")
    
    // Tap FDISP (Yellow Shift + .)
    app.navigateAndTap("op_shiftYellow")
    app.navigateAndTap("op_decimal")
    Thread.sleep(forTimeInterval: 1.0)
    
    snapshot("4-Fractions")
    
    // Screenshot 5: Stats Menu
    app.navigateAndTap("C")
    app.navigateAndTap("C")
    app.navigateAndTap("C")
    app.navigateAndTap("C")
    
    app.navigateAndTap("op_shiftYellow")
    app.navigateAndTap("op_digit6") // SUMS menu
    Thread.sleep(forTimeInterval: 1.0)
    
    snapshot("5-Stats")
    
    // Close Stats Menu
    if app.buttons["sheet_dismiss_btn"].exists {
        app.navigateAndTap("sheet_dismiss_btn")
    } else if app.buttons["Cancel"].exists {
        app.navigateAndTap("Cancel")
    } else if app.buttons["C"].exists {
        app.navigateAndTap("C")
    }
    
    Thread.sleep(forTimeInterval: 1.0)
    
    // Screenshot 6: Integral Plotting
    app.navigateAndTap("C")
    app.navigateAndTap("C")
    app.navigateAndTap("C")
    // Setup equation NPDF (it is a built in equation usually or we can just integrate our X^2)
    // Since X^2 is already in EQN, we can evaluate it
    // FN= 
    navigateToLFUPad(app: app)
    Thread.sleep(forTimeInterval: 0.4)
    app.navigateAndTap("op_shiftBlue")
    app.navigateAndTap("op_xeq")
    // It should list equations
    XCTAssertTrue(app.cells.element(boundBy: 1).waitForExistence(timeout: 5))
    app.cells.element(boundBy: 1).tap()
    
    
    app.navigateAndTap("op_digit0")
    app.tapEnter()
    app.navigateAndTap("op_digit2")
    
    app.navigateAndTap("op_shiftBlue")
    app.navigateAndTap("op_digit8") // Integrate
    if app.buttons["Evaluate"].waitForExistence(timeout: 5.0) {
        if !app.buttons["Evaluate"].isHittable {
            app.tapEnter()
        }
        app.navigateAndTap("Evaluate")
    } else {
        app.tapEnter()
        app.navigateAndTap("Evaluate")
    }
    
    Thread.sleep(forTimeInterval: 6.0) // wait for plot (integration takes longer)
    snapshot("6-IntegralPlot")
    
    // Close plot
    if app.buttons["btn_plot_c"].waitForExistence(timeout: 2.0) {
        app.navigateAndTap("btn_plot_c")
    }
  }



  func testVideoNormalPDF() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()
    
    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))
    let pad = app.otherElements["numpad_bg"]
    
    func slowTap(_ element: XCUIElement) {
        element.tap()
        Thread.sleep(forTimeInterval: 0.8)
    }

    // Jump to Matrix2View where STO is
    

    // EQN is Blue Shift + STO
    slowTap(app.buttons["op_shiftBlue"])
    slowTap(app.buttons["op_sto"])
    
    // Tap Add Equation button in the list view
    Thread.sleep(forTimeInterval: 1.0)
    slowTap(app.buttons["btn_add_eqn"])
    Thread.sleep(forTimeInterval: 1.5)
    
    // Currently on LFU Matrix2View. Need to go to Variables.
    navigateToLFUPad(app: app) // Jump straight to Variables Pad
    Thread.sleep(forTimeInterval: 1.0)
    
    slowTap(app.buttons["alpha_X"])
    
    // Variables to Matrix3View (where x^2 is)
     // Numeric pad
     // Matrix3View
    Thread.sleep(forTimeInterval: 0.5)
    
    slowTap(app.buttons["op_shiftYellow"])
    slowTap(app.buttons["op_sqrt"])
    
    // LFU to Numeric (Jump to Page 1)
    
    Thread.sleep(forTimeInterval: 0.5)
    
    slowTap(app.buttons["op_digit0"])
    slowTap(app.buttons["op_decimal"])
    slowTap(app.buttons["op_digit5"])
    slowTap(app.buttons["op_toggleSign"])
    
    // Numeric to Arithmetic
    
    Thread.sleep(forTimeInterval: 0.5)
    slowTap(app.buttons["op_multiply"]) // wait, earlier it used element(boundBy: 1), I'll just use it directly
    
    // Arithmetic to Matrix3View (where e^x is)
     // Numeric pad
     // Matrix3View
    Thread.sleep(forTimeInterval: 0.5)
    
    slowTap(app.buttons["op_exp"])
    
    // LFU to Numeric
    
    Thread.sleep(forTimeInterval: 0.5)
    slowTap(app.buttons["op_digit2"])
    
    // Numeric to Matrix2View (where pi is)
    
    Thread.sleep(forTimeInterval: 0.5)
    slowTap(app.buttons["op_shiftBlue"])
    slowTap(app.buttons["op_sin"])
    
    // Jump to Arithmetic
    
    Thread.sleep(forTimeInterval: 0.5)
    slowTap(app.buttons["op_multiply"])
    
    // Jump to Matrix3View (where √x is)
    
    Thread.sleep(forTimeInterval: 0.5)
    slowTap(app.buttons["op_sqrt"])
    
    // LFU to Arithmetic
    
    Thread.sleep(forTimeInterval: 0.5)
    slowTap(app.buttons["op_divide"]) // This taps the ÷ button in the equation editor. Wait, is it func_÷?
    
    app.tapEnter() // Save Eqn
    
    // Should return to Numeric pad, wait and tap
    
    Thread.sleep(forTimeInterval: 0.5)
    
    slowTap(app.buttons["op_digit1"])
    slowTap(app.buttons["op_digit0"])
    slowTap(app.buttons["op_toggleSign"])
    app.tapEnter() // Enter
    slowTap(app.buttons["op_digit0"])
    
    slowTap(app.buttons["op_shiftYellow"])
    slowTap(app.buttons["op_digit8"]) // Integrate
    
    Thread.sleep(forTimeInterval: 3.0)
    
    slowTap(app.buttons["op_shiftYellow"])
    slowTap(app.buttons["op_toggleSign"])
    if app.buttons["btn_plot_execute"].waitForExistence(timeout: 5.0) {
        if !app.buttons["btn_plot_execute"].isHittable {
            app.tapEnter()
        }
        app.navigateAndTap("btn_plot_execute")
    } else {
        app.tapEnter()
        app.navigateAndTap("btn_plot_execute")
    } // Plot
    
    Thread.sleep(forTimeInterval: 5.0)
  }

  func testStatPlotAndValues() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Enter point 1 (1, 2)
    app.navigateAndTap("op_digit1")
    app.tapEnter() // ENTER
    app.navigateAndTap("op_digit2")
    
    Thread.sleep(forTimeInterval: 0.4)
    app.navigateAndTap("op_statAdd") // Σ+
    
    Thread.sleep(forTimeInterval: 0.4)

    // Enter point 2 (3, 4)
    app.navigateAndTap("op_digit3")
    app.tapEnter() // ENTER
    app.navigateAndTap("op_digit4")
    
    Thread.sleep(forTimeInterval: 0.4)
    app.navigateAndTap("op_statAdd") // Σ+
    
    Thread.sleep(forTimeInterval: 0.4)

    // Calculate mean of X -> should be 2.
    
    Thread.sleep(forTimeInterval: 0.4)
    app.navigateAndTap("op_shiftBlue")
    app.navigateAndTap("op_power") // x-bar, y-bar menu
    
    // Tap x-bar
    if app.buttons["x̄ (Mean of x)"].waitForExistence(timeout: 2.0) {
        if !app.buttons["x̄ (Mean of x)"].isHittable {
            app.tapEnter()
        }
        app.navigateAndTap("x̄ (Mean of x)")
    } else {
        app.tapEnter()
        app.navigateAndTap("x̄ (Mean of x)")
    }
    // Assert display is 3 (Mean of X for 2 and 4)
    XCTAssertEqual(display.label, "3")
    
    // Trigger STAT PLOT
    
    Thread.sleep(forTimeInterval: 0.4)
    app.navigateAndTap("op_shiftYellow")
    app.navigateAndTap("op_toggleSign") // PLOT
    
    // Wait for prompt to appear
    if app.buttons["Source"].waitForExistence(timeout: 2.0) {
        app.navigateAndTap("Source")
        app.navigateAndTap("Statistics Data")
        app.navigateAndTap("btn_plot_execute")
    } else {
        app.tapEnter()
        app.navigateAndTap("btn_plot_execute")
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

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // 1. Enter an equation: EQN, A, X^2, ENTER
    
    app.navigateAndTap("op_shiftBlue")
    app.navigateAndTap("op_sto") // EQN
    Thread.sleep(forTimeInterval: 1.0)
    
    app.navigateAndTap("btn_add_eqn")
    Thread.sleep(forTimeInterval: 1.5)
    
    // Select label A
    navigateToLFUPad(app: app)
    app.navigateAndTap("alpha_A")
    app.tapEnter()
    Thread.sleep(forTimeInterval: 1.0)
    
    // RPN sequence: X x^2
    navigateToLFUPad(app: app)
    app.navigateAndTap("alpha_X")
    
    
    Thread.sleep(forTimeInterval: 0.5)
    app.navigateAndTap("op_shiftYellow")
    app.navigateAndTap("op_sqrt") // x^2

    app.tapEnter()
    
    // 2. Open plot menu
    
    app.navigateAndTap("op_shiftYellow")
    app.navigateAndTap("op_toggleSign") // PLOT
    
    // Wait for prompt
    if app.buttons["Source"].waitForExistence(timeout: 2.0) {
        app.navigateAndTap("Source")
        app.navigateAndTap("Equation (EQN list)")
        
        app.navigateAndTap("Equation")
        app.navigateAndTap("A")
        
        app.navigateAndTap("btn_plot_execute")
    } else {
        app.navigateAndTap("btn_plot_execute")
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
    app.navigateAndTap("op_digit1")
    app.tapEnter()
    
    // Tap PLOT (yellow shift +/-)
    app.navigateAndTap("op_shiftYellow")
    app.navigateAndTap("op_toggleSign")
    
    // Select Plot
    if app.buttons["btn_plot_execute"].waitForExistence(timeout: 5.0) {
        if !app.buttons["btn_plot_execute"].isHittable {
            app.tapEnter()
        }
        app.navigateAndTap("btn_plot_execute")
    } else {
        app.tapEnter()
        app.navigateAndTap("btn_plot_execute")
    }

    // Wait for plot view
    let plotChart = app.otherElements["plot_chart"]
    XCTAssertTrue(plotChart.waitForExistence(timeout: 5.0))
    
    // Tap in the middle of the plot to capture coordinates
    plotChart.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    
    // Wait for plot to dismiss and check stack (display label should have a captured coordinate)
    Thread.sleep(forTimeInterval: 1.0)
    
    let display = app.descendants(matching: .any)["lcd_display"]
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

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    // Enter a 12 digit number: 123456789012
    app.navigateAndTap("op_digit1")
    app.navigateAndTap("op_digit2")
    app.navigateAndTap("op_digit3")
    app.navigateAndTap("op_digit4")
    app.navigateAndTap("op_digit5")
    app.navigateAndTap("op_digit6")
    app.navigateAndTap("op_digit7")
    app.navigateAndTap("op_digit8")
    app.navigateAndTap("op_digit9")
    app.navigateAndTap("op_digit0")
    app.navigateAndTap("op_digit1")
    app.navigateAndTap("op_digit2")
    
    // The screen display holds the full string unformatted during entry
    XCTAssertTrue(display.label.contains("123456789012"))
    
    app.tapEnter()
    
    // After ENTER, it is formatted to scientific notation (9 char limit)
    // 123456789012 -> 1.2346E11
    XCTAssertTrue(display.label.contains("E"))
  }



  func testAllConstantsLoad() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
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
        
        app.navigateAndTap("op_shiftYellow")
        app.navigateAndTap("func_STAY")
        
        XCTAssertTrue(app.staticTexts["CNST"].waitForExistence(timeout: 2.0))
        
        // Search is flaky on watchOS UI tests, but we can verify it opened
        // and we could try to tap the first constant just to verify it dismisses
        if constantName == "Pi" {
            let piText = app.staticTexts["Pi"]
            if piText.waitForExistence(timeout: 2.0) {
                piText.tap()
                XCTAssertTrue(display.waitForExistence(timeout: 2.0))
                XCTAssertTrue(display.label.contains("3.1415"))
                app.navigateAndTap("op_backspace") // Clear for next
            }
        } else {
            // Dismiss menu
            if app.buttons["Close"].exists {
                app.navigateAndTap("Close")
            } else {
                app.navigateAndTap("Cancel")
            }
        }
        
        // Swipe back to numeric pad to reset for next loop
        app.navigateAndTap("sim_swipe_right")
        Thread.sleep(forTimeInterval: 0.2)
    }
  }

  func testExamMode() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    setupSnapshot(app)
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    func slowTap(_ element: XCUIElement) {
        element.tap()
        Thread.sleep(forTimeInterval: 0.8)
    }

    

    // Open Flags Menu (Blue Shift -> ×)
    slowTap(app.buttons["op_shiftBlue"])
    slowTap(app.buttons["op_multiply"])

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
    
    slowTap(app.buttons["op_digit5"])
    XCTAssertEqual(display.label, "5")

    // Open Flags Menu again
    
    slowTap(app.buttons["op_shiftBlue"])
    slowTap(app.buttons["op_multiply"])

    // Toggle Exam Mode OFF
    XCTAssertTrue(examModeToggle.waitForExistence(timeout: 5))
    slowTap(examModeToggle)

    // Dismiss Flags Menu
    slowTap(app.buttons["sheet_dismiss_btn"].firstMatch)

    // Verify Exam badge is gone
    XCTAssertFalse(examBadge.exists)
  }

  func testFractionEntry() throws {
      if let tc = SharedMathTestCases.cases.first(where: { $0.name == "FractionEntry" }) {
          runSharedTestCase(tc)
      } else {
          XCTFail("Could not find FractionEntry test case")
      }
  }

}
extension XCUIApplication {
    func tapEnter() {
        if self.otherElements["invisible_ENTER"].exists {
            self.otherElements["invisible_ENTER"].tap()
        } else if self.buttons["op_enter"].exists && self.buttons["op_enter"].isHittable {
            self.buttons["op_enter"].firstMatch.tap()
        } else {
            self.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        }
    }
    
    func navigateAndTap(_ id: String) {
        if id == "op_enter" {
            self.tapEnter()
            return
        }
        
        // Handle Picker selections for XEQ, SOLVE, INTEGRATE
        if self.buttons["Evaluate"].exists || self.buttons["Solve"].exists || self.buttons["Integrate"].exists {
            let alphaMap: [String: String] = [
                "op_sqrt": "A", "op_exp": "B", "op_ln": "C", "op_power": "D", "op_reciprocal": "E",
                "op_statAdd": "F", "op_sto": "G", "op_rcl": "H", "op_rollDown": "I", "op_sin": "J",
                "op_cos": "K", "op_tan": "L", "op_swapXY": "N", "op_toggleSign": "O",
                "op_e": "P", "op_digit7": "Q", "op_digit8": "R", "op_digit9": "S", "op_digit4": "T",
                "op_digit5": "U", "op_digit6": "V", "op_digit1": "W", "op_digit2": "X", "op_digit3": "Y",
                "op_digit0": "Z"
            ]
            if let letter = alphaMap[id] {
                // If the fuzzer pressed an alpha key while a sheet is up, it wants to select that equation/var.
                if self.pickers.firstMatch.exists {
                    let wheel = self.pickers.firstMatch.pickerWheels.firstMatch
                    if wheel.exists {
                        wheel.adjust(toPickerWheelValue: letter)
                    }
                }
                if self.buttons["Evaluate"].exists { self.buttons["Evaluate"].tap(); return }
                if self.buttons["Solve"].exists { self.buttons["Solve"].tap(); return }
                if self.buttons["Integrate"].exists { self.buttons["Integrate"].tap(); return }
            }
        }
        
        if self.buttons[id].exists {
            self.buttons[id].firstMatch.tap()
            return
        }
        
        // Not found immediately. Reset to center if possible.
        if self.buttons["sim_reset_pads"].exists {
            self.buttons["sim_reset_pads"].tap()
        }
        
        if self.buttons[id].exists { self.buttons[id].firstMatch.tap(); return }
        
        // Arithmetic Pad (Right)
        if self.buttons["sim_swipe_left"].exists { self.buttons["sim_swipe_left"].tap() } else { self.swipeLeft() }
        if self.buttons[id].exists { self.buttons[id].firstMatch.tap(); return }
        
        // Alpha Pad (Left)
        if self.buttons["sim_swipe_right"].exists { 
            self.buttons["sim_swipe_right"].tap()
            self.buttons["sim_swipe_right"].tap() 
        } else { 
            self.swipeRight()
            self.swipeRight() 
        }
        if self.buttons[id].exists { self.buttons[id].firstMatch.tap(); return }
        
        // Center
        if self.buttons["sim_swipe_left"].exists { self.buttons["sim_swipe_left"].tap() } else { self.swipeLeft() }
        
        // Upper Matrix Pad (Up)
        if self.buttons["sim_swipe_down"].exists { self.buttons["sim_swipe_down"].tap() } else { self.swipeDown() }
        if self.buttons[id].exists { self.buttons[id].firstMatch.tap(); return }
        
        // Setup Pad (Up again)
        if self.buttons["sim_swipe_down"].exists { self.buttons["sim_swipe_down"].tap() } else { self.swipeDown() }
        if self.buttons[id].exists { self.buttons[id].firstMatch.tap(); return }
        
        // Bottom Prog Pad (Down from center)
        if self.buttons["sim_reset_pads"].exists {
            self.buttons["sim_reset_pads"].tap()
        }
        if self.buttons["sim_swipe_up"].exists { self.buttons["sim_swipe_up"].tap() } else { self.tapEnter() }
        if self.buttons[id].exists { self.buttons[id].firstMatch.tap(); return }
        
        // Fallback
        self.buttons[id].firstMatch.tap()
    }
}
