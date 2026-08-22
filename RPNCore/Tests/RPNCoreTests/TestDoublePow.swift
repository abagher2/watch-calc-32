import XCTest
@testable import RPNCore

final class TestDoublePow: XCTestCase {
    func testDoublePow() {
        let engine = CalculatorEngine()
        engine.digit(2)
        engine.enter()
        engine.digit(3)
        engine.enter()
        engine.digit(2)
        
        engine.executeMath("𝑦ˣ")
        print("After first y^x, stack[0] = \(engine.stack[0].real)")
        
        engine.executeMath("𝑦ˣ")
        print("After second y^x, stack[0] = \(engine.stack[0].real)")
    }
}
