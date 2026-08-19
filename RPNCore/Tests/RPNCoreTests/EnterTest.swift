import XCTest
@testable import RPNCore

final class EnterTest: XCTestCase {
    func testEnterBug() throws {
        let engine = CalculatorEngine()
        engine.digit(1)
        engine.enter()
        print("AFTER 1 ENTER: displayX = \(engine.displayX), stackStrings = \(engine.stackStrings)")
        engine.digit(2)
        engine.enter()
        print("AFTER 2 ENTER: displayX = \(engine.displayX), stackStrings = \(engine.stackStrings)")
    }
}
