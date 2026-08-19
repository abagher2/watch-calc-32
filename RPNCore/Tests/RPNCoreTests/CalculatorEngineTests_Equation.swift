import XCTest
@testable import RPNCore

final class CalculatorEngineTests_Equation: XCTestCase {
    var engine: CalculatorEngine!

    override func setUp() {
        super.setUp()
        engine = CalculatorEngine()
    }

    func testEquationEntry() {
        engine.executeMath("PRGM")
        
        engine.digit(5)
        engine.digit(6)
        
        engine.executeMath("ENTER")
        
        engine.executeMath("×") // 56 *
        
        engine.startRcl()
        engine.submitAlpha("X") // 56 * X
        
        engine.executeMath("+") // 56 * X +
        
        engine.digit(3) // 56 * X + 3
        
        let expectedSteps = ["56", "×", "RCL X", "+", "3"]
        XCTAssertEqual(engine.currentProgramSteps, expectedSteps)
    }

    func testNormalPDFEntry() {
        engine.executeMath("CLEAR")
        engine.executeMath("PRGM")
        
        // 1 ÷ S
        engine.digit(1)
        engine.executeMath("ENTER")
        engine.startRcl()
        engine.submitAlpha("S")
        engine.executeMath("÷")
        
        // ÷ √ ( 2 × π )
        engine.digit(2)
        engine.executeMath("ENTER")
        engine.executeMath("π")
        engine.executeMath("×")
        engine.executeMath("√x")
        engine.executeMath("÷")
        
        // e^ ( ... )
        engine.startRcl()
        engine.submitAlpha("X")
        engine.startRcl()
        engine.submitAlpha("M")
        engine.executeMath("-")
        engine.executeMath("x^2")
        engine.executeMath("+/-")
        
        engine.digit(2)
        engine.executeMath("ENTER")
        engine.startRcl()
        engine.submitAlpha("S")
        engine.executeMath("x^2")
        engine.executeMath("×")
        engine.executeMath("÷")
        
        engine.executeMath("e^x")
        
        // Final multiply
        engine.executeMath("×")
        
        let expectedSteps = [
            "1", "RCL S", "÷",
            "2", "π", "×", "√x", "÷",
            "RCL X", "RCL M", "-", "x^2", "+/-",
            "2", "RCL S", "x^2", "×", "÷",
            "e^x", "×"
        ]
        
        XCTAssertEqual(engine.currentProgramSteps, expectedSteps)
    }
}
