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
        engine.executeMath("√𝑥")
        engine.executeMath("÷")
        
        // e^ ( ... )
        engine.startRcl()
        engine.submitAlpha("X")
        engine.startRcl()
        engine.submitAlpha("M")
        engine.executeMath("-")
        engine.executeMath("𝑥²")
        engine.executeMath("+/-")
        
        engine.digit(2)
        engine.executeMath("ENTER")
        engine.startRcl()
        engine.submitAlpha("S")
        engine.executeMath("𝑥²")
        engine.executeMath("×")
        engine.executeMath("÷")
        
        engine.executeMath("𝑒ˣ")
        
        // Final multiply
        engine.executeMath("×")
        
        let expectedSteps = [
            "1", "RCL S", "÷",
            "2", "π", "×", "√𝑥", "÷",
            "RCL X", "RCL M", "-", "𝑥²", "+/-",
            "2", "RCL S", "𝑥²", "×", "÷",
            "𝑒ˣ", "×"
        ]
        
        XCTAssertEqual(engine.currentProgramSteps, expectedSteps)
    }

    func testEquationModeBlacklist() {
        engine.executeMath("EQN")
        XCTAssertTrue(engine.isEquationMode)
        
        // Allowed commands
        engine.digit(5)
        engine.executeMath("ENTER")
        engine.executeMath("+")
        
        // Blacklisted commands (should not append, and should set error)
        engine.executeMath("STO")
        XCTAssertEqual(engine.errorMessage, "INVALID DATA")
        engine.errorMessage = nil
        
        engine.executeMath("SF 1")
        XCTAssertEqual(engine.errorMessage, "INVALID DATA")
        engine.errorMessage = nil
        
        engine.executeMath("CMPLX")
        XCTAssertEqual(engine.errorMessage, "INVALID DATA")
        engine.errorMessage = nil
        
        engine.executeMath("HEX")
        XCTAssertEqual(engine.errorMessage, "INVALID DATA")
        engine.errorMessage = nil
        
        engine.executeMath("XEQ")
        XCTAssertEqual(engine.errorMessage, "INVALID DATA")
        engine.errorMessage = nil
        
        XCTAssertEqual(engine.currentEquation, "5 ENTER +")
    }
    
    func testEquationDeltaFunctions() {
        // Create an equation: 5 * (X > 0)
        engine.executeMath("EQN")
        engine.digit(5)
        engine.executeMath("ENTER")
        engine.startRcl()
        engine.submitAlpha("X")
        engine.executeMath("x>0")
        engine.executeMath("×")
        
        engine.executeMath("ENTER") // Commit equation? 
        let program = CalculatorEngine.Program(label: "A", steps: ["5", "RCL X", "x>0", "×"].compactMap { Instruction(fromString: $0) })
        engine.programs.append(program)
        
        // Case 1: X = 10 -> (10 > 0) is 1.0 -> 5 * 1.0 = 5.0
        engine.variables["X"] = CalculatorValue(real: 10.0)
        if let result1 = engine.evaluateProgram(program, variables: engine.variables) {
            engine.push(result1)
        }
        print("STACK POST EVAL 1: \(engine.stack[0].real), \(engine.stack[1].real), \(engine.stack[2].real)")
        XCTAssertEqual(engine.stack[0].real, 5.0)
        
        // Case 2: X = -5 -> (-5 > 0) is 0.0 -> 5 * 0.0 = 0.0
        engine.variables["X"] = CalculatorValue(real: -5.0)
        if let result2 = engine.evaluateProgram(program, variables: engine.variables) {
            engine.push(result2)
        }
        print("STACK POST EVAL 2: \(engine.stack[0].real), \(engine.stack[1].real), \(engine.stack[2].real)")
        XCTAssertEqual(engine.stack[0].real, 0.0)
    }
}
