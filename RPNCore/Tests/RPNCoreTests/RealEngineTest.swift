import XCTest
@testable import RPNCore

final class RealEngineTest: XCTestCase {
    func testUserScenario() {
        let engine = CalculatorEngine()
        engine.digit(1)
        engine.enter()
        engine.digit(2)
        engine.enter()
        engine.digit(3)
        engine.enter()
        engine.digit(4)
        engine.enter()
        engine.digit(5)
        engine.enter()
        engine.digit(6)
        engine.enter()
        engine.digit(7)
        engine.enter()
        engine.digit(8)
        
        print("FINAL STACK STRINGS:", engine.stackStrings)
        print("LOGICAL STACK COUNT:", engine.stack.count)
    }
}
