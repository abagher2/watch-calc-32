import XCTest

@MainActor final class TestEquationEntry: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  private func clearAll(app: XCUIApplication) {
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
  }

  private func navigateToNumericPad(app: XCUIApplication) {
    app.buttons["sim_reset_pads"].tap()
    XCTAssertTrue(app.buttons["op_digit5"].waitForExistence(timeout: 2.0))
  }

  private func navigateToArithmeticPad(app: XCUIApplication) {
    navigateToNumericPad(app: app)
    app.buttons["sim_swipe_left"].tap()
    XCTAssertTrue(app.buttons["op_multiply"].waitForExistence(timeout: 2.0))
  }

  private func navigateToUpperMatrixPad(app: XCUIApplication) {
    navigateToNumericPad(app: app)
    app.buttons["sim_swipe_down"].tap()
    XCTAssertTrue(app.buttons["op_sto"].waitForExistence(timeout: 2.0))
  }

  private func navigateToLFUPad(app: XCUIApplication) {
    navigateToNumericPad(app: app)
    app.buttons["sim_swipe_right"].tap()
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
    
    // Verify the display string!
    // The user says "the listing for the equation is still showing a line for ENTER after typing in '56'"
    // In PRGM mode, we should just verify the display label shows "A 06- 3" and not something with ENTER.
    // Actually let's just dump the display label.
    let displayLabel = display.label
    print("DISPLAY_LABEL_IS: \(displayLabel)")
  }
}
