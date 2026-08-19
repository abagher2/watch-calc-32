import XCTest
@testable import RPNCore

final class TestPow: XCTestCase {
    func testPowBug() {
        let engine = CalculatorEngine()
        // Push some arbitrary numbers to the stack
        engine.digit(9)
        engine.enter()
        engine.digit(9)
        engine.enter()
        engine.digit(9)
        engine.enter()
        
        engine.digit(6)
        engine.digit(4)
        engine.enter()
        engine.digit(0)
        engine.decimal()
        engine.digit(5)
        engine.executeMath("y^x")
        print("AFTER 0.5 y^x: \(engine.stack[0].real)")
        
        engine.digit(2)
        engine.executeMath("y^x")
        XCTAssertEqual(engine.stack[0].real, 64.0, accuracy: 0.0001)
        
        // Let's do it 3 times
        engine.digit(0)
        engine.decimal()
        engine.digit(5)
        engine.executeMath("y^x")
        XCTAssertEqual(engine.stack[0].real, 8.0, accuracy: 0.0001)
    }
}
