import XCTest
@testable import RPNCore


final class TestEval6: XCTestCase {
    func testEval6() {
        let engine = CalculatorEngine()
        engine.equations.removeAll()
        
        // 1. User taps "New Equation" (+ button) in SwiftUI List
        engine.isWaitingForLabel = true
        engine.startAlpha()
        engine.alphaPrompt = "LBL _"
        
        // 2. User types "N" and hits Submit/Enter
        engine.submitAlpha("N")
        
        // 3. User taps buttons for NDF
        engine.submitAlpha("X")
        engine.executeOp(.square)
        engine.executeOp(.digit2)
        engine.executeOp(.divide)
        engine.executeOp(.toggleSign)
        engine.executeOp(.exp)
        engine.executeOp(.digit2)
        engine.executeOp(.pi)
        engine.executeOp(.multiply)
        engine.executeOp(.sqrt)
        engine.executeOp(.divide)
        
        // 4. User exits programming mode
        engine.executeOp(.prgm)
        
        // 5. Evaluate the function via XEQ
        engine.executeOp(.xeq)
        engine.submitAlpha("N")
        
        print("WAITING VARS BEFORE 0: \(engine.pendingEquationVars)")
        print("ALPHA PROMPT BEFORE 0: \(engine.alphaPrompt ?? "nil")")
        print("ALPHA ACTION BEFORE 0: \(engine.alphaAction)")
        
        // Enter 0 for X when prompted
        engine.submitAlpha("0")
        
        print("VARS AFTER 0: \(engine.variables)")
        print("ALPHA ACTION AFTER 0: \(engine.alphaAction)")
        print("STACK AFTER: \(engine.stack.map { $0.real })")
    }
}
