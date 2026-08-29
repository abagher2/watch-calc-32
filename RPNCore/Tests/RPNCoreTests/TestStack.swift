import XCTest
@testable import RPNCore

final class TestStack: XCTestCase {
    func testStackSwap() {
        let engine = CalculatorEngine()
        engine.digit(1)
        engine.enter()
        engine.digit(2)
        engine.enter()
        engine.digit(3)
        engine.enter()
        engine.digit(4)
        engine.commitInput() // Force it so we see true internal state!
        
        print("Init stack:", engine.stack.map { $0.real })
        engine.executeMath("+")
        print("+1:", engine.stack.map { $0.real })
        engine.executeMath("+")
        print("+2:", engine.stack.map { $0.real })
        engine.executeMath("+")
        print("+3:", engine.stack.map { $0.real })
    }
}
