import XCTest
@testable import RPNCore

final class CalculatorEngineTests: XCTestCase {
    
    func testStackPush() {
        let engine = CalculatorEngine()
        let steps = ["X", "𝑥²", "4", "-"].compactMap { Instruction(fromString: $0) }
        let equation = CalculatorEngine.Equation(label: "ROOT", steps: steps)
        engine.digit(1)
        engine.enter()
        engine.digit(2)
        engine.enter()
        engine.digit(3)
        XCTAssertEqual(engine.displayX, "3") 
        XCTAssertEqual(engine.stackStrings[0], "3") // X
        XCTAssertEqual(engine.stackStrings[1], "2") // Y
        XCTAssertEqual(engine.stackStrings[2], "1") // Z
    }

    func testVariables() {
        let engine = CalculatorEngine()
        engine.digit(4)
        engine.digit(2)
        engine.startSto()
        engine.submitAlpha("A")
        
        engine.clearX()
        XCTAssertEqual(engine.displayX, "0")
        
        engine.startRcl()
        engine.submitAlpha("A")
        XCTAssertEqual(engine.displayX, "42")
    }

    func testUnitConversions() {
        let engine = CalculatorEngine()
        engine.digit(1)
        engine.digit(0)
        engine.digit(0)
        engine.executeMath("->°C")
        // 100 F to C is approx 37.7778
        XCTAssertEqual(engine.stack[0].real, 37.77777777777778, accuracy: 0.0001)
    }
}
