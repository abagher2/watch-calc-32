import XCTest
@testable import RPNCore

final class CalculatorEngineTests_Errors: XCTestCase {
    func testDivideByZero() {
        let engine = CalculatorEngine()
        engine.digit(5)
        engine.enter()
        engine.digit(0)
        engine.executeMath("÷")
        XCTAssertEqual(engine.errorMessage, "DIVIDE BY 0")
        
        // Clearing the error
        engine.executeMath("C")
        XCTAssertNil(engine.errorMessage)
    }
    
    func testSqrtOfNegative() {
        let engine = CalculatorEngine()
        engine.digit(5)
        engine.toggleSign() // -5
        engine.executeMath("√x")
        XCTAssertEqual(engine.errorMessage, "SQRT(NEG)")
    }
    
    func testEquationPromptAndEnter() {
        let engine = CalculatorEngine()
        
        // Create an equation program "A" that computes X * 2
        let p = CalculatorEngine.Program(label: "A", steps: ["X", "2", "×"])
        engine.programs.append(p)
        
        // Start equation evaluation
        engine.executeMath("EQN")
        XCTAssertTrue(engine.isEquationMode)
        
        // Hit ENTER to evaluate equation "A"
        engine.alphaAction = .evalEquation
        engine.submitAlpha("A")
        
        // It should prompt for variable "X"
        XCTAssertEqual(engine.alphaAction, .promptVar)
        XCTAssertEqual(engine.alphaPrompt, "X?")
        
        // Enter 15 for X
        engine.digit(1)
        engine.digit(5)
        
        // Hit ENTER to submit X=15
        engine.enter()
        
        // Engine should have evaluated 15 * 2 = 30 and pushed to stack
        XCTAssertEqual(engine.stack[0].real, 30.0)
        XCTAssertFalse(engine.isEquationMode)
    }
}
