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
      app.buttons["func_<-"].tap()
      app.swipeUp()
      app.buttons["Clear ALL"].firstMatch.tap()
      Thread.sleep(forTimeInterval: 1.5)
      navigateToNumericPad(app: app)
      Thread.sleep(forTimeInterval: 0.1)
  }

  private func navigateToNumericPad(app: XCUIApplication) {
    if app.buttons["btn_5"].exists { return }
    app.buttons["sim_swipe_right"].tap()
    if app.buttons["btn_5"].waitForExistence(timeout: 1.5) { return }
    app.buttons["sim_swipe_left"].tap()
    if app.buttons["btn_5"].waitForExistence(timeout: 1.5) { return }
    app.buttons["sim_swipe_left"].tap()
    if app.buttons["btn_5"].waitForExistence(timeout: 1.5) { return }
    app.buttons["sim_swipe_up"].tap()
    if app.buttons["btn_5"].waitForExistence(timeout: 1.5) { return }
  }

  private func navigateToArithmeticPad(app: XCUIApplication) {
    if app.buttons["func_×"].exists { return }
    navigateToNumericPad(app: app)
    app.buttons["sim_swipe_left"].tap()
    Thread.sleep(forTimeInterval: 0.5)
    XCTAssertTrue(app.buttons["func_×"].waitForExistence(timeout: 2.0))
  }

  private func navigateToUpperMatrixPad(app: XCUIApplication) {
    if app.buttons["func_STO"].exists { return }
    navigateToNumericPad(app: app)
    app.buttons["sim_swipe_down"].tap()
    XCTAssertTrue(app.buttons["func_STO"].waitForExistence(timeout: 2.0))
  }

  private func navigateToLFUPad(app: XCUIApplication) {
    if app.buttons["func_A"].exists { return }
    navigateToNumericPad(app: app)
    app.buttons["sim_swipe_right"].tap()
    Thread.sleep(forTimeInterval: 0.5)
    XCTAssertTrue(app.buttons["func_A"].waitForExistence(timeout: 2.0))
  }

  func testEquationEntry() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-UITesting"]
    app.launch()

    let display = app.staticTexts["lcd_display"]
    XCTAssertTrue(display.waitForExistence(timeout: 5))

    clearAll(app: app)

    // Press EQN (blue shift STO)
    app.buttons["btn_blue_shift"].tap()
    navigateToUpperMatrixPad(app: app)
    app.buttons["func_STO"].tap()

    // Wait for the Equation list sheet
    XCTAssertTrue(app.buttons["btn_add_eqn"].waitForExistence(timeout: 2.0))
    app.buttons["btn_add_eqn"].tap() // "New Equation"

    // Now we are in LBL _
    // Tap A
    navigateToLFUPad(app: app)
    app.buttons["func_A"].tap()

    // Now we are in PRGM mode editing equation A
    // Press 5, 6, ENTER
    navigateToNumericPad(app: app)
    app.buttons["btn_5"].tap()
    app.buttons["btn_6"].tap()
    
    // Tap invisible ENTER just in case, but let's tap the real ENTER on Arithmetic pad
    navigateToArithmeticPad(app: app)
    app.buttons["btn_ENTER"].tap()
    
    // Press *
    app.buttons["func_×"].tap()
    
    // Press RCL X
    navigateToUpperMatrixPad(app: app)
    app.buttons["func_RCL"].tap()
    
    navigateToLFUPad(app: app)
    app.buttons["func_X"].tap()
    
    // Press +
    navigateToArithmeticPad(app: app)
    app.buttons["func_+"].tap()
    
    // Press 3
    navigateToNumericPad(app: app)
    app.buttons["btn_3"].tap()
    
    // Verify the display string!
    // The user says "the listing for the equation is still showing a line for ENTER after typing in '56'"
    // In PRGM mode, we should just verify the display label shows "A 06- 3" and not something with ENTER.
    // Actually let's just dump the display label.
    let displayLabel = display.label
    print("DISPLAY_LABEL_IS: \(displayLabel)")
  }
}
