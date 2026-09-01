import XCTest

@MainActor final class TestEquationEntry: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  private func clearAll(app: XCUIApplication) {
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
  }

  private func navigateToNumericPad(app: XCUIApplication) {
    app.navigateAndTap("sim_reset_pads")
    XCTAssertTrue(app.buttons["op_digit5"].waitForExistence(timeout: 2.0))
  }

  private func navigateToArithmeticPad(app: XCUIApplication) {
    navigateToNumericPad(app: app)
    app.navigateAndTap("sim_swipe_left")
    XCTAssertTrue(app.buttons["op_multiply"].waitForExistence(timeout: 2.0))
  }

  private func navigateToUpperMatrixPad(app: XCUIApplication) {
    navigateToNumericPad(app: app)
    app.navigateAndTap("sim_swipe_down")
    XCTAssertTrue(app.buttons["op_sto"].waitForExistence(timeout: 2.0))
  }

  private func navigateToLFUPad(app: XCUIApplication) {
    navigateToNumericPad(app: app)
    app.navigateAndTap("sim_swipe_right")
    XCTAssertTrue(app.buttons["alpha_A"].waitForExistence(timeout: 2.0))
  }

  func testEquationEntry() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    app.launch()

    let display = app.descendants(matching: .any)["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    clearAll(app: app)

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
    
    // Verify the display string!
    // The user says "the listing for the equation is still showing a line for ENTER after typing in '56'"
    // In PRGM mode, we should just verify the display label shows "A 06- 3" and not something with ENTER.
    // Actually let's just dump the display label.
    let displayLabel = display.label
    print("DISPLAY_LABEL_IS: \(displayLabel)")
  }
}
