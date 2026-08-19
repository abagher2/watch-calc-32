import XCTest
@testable import RPNCore

final class TestPrecision: XCTestCase {
    func testPrecisionLength() {
        let engine = CalculatorEngine()
        engine.clearAll()
        
        // "1 enter 7 /"
        engine.digit(1)
        engine.enter()
        engine.digit(7)
        engine.executeMath("÷")
        
        // Assert that the length of the formatted string doesn't exceed 12
        XCTAssertTrue(engine.displayX.count <= 12, "Formatted length exceeds 12 characters: \(engine.displayX) (Length: \(engine.displayX.count))")
    }
}
