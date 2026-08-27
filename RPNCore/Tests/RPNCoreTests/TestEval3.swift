import XCTest
@testable import RPNCore
@testable import ParityExporter

final class TestEval3: XCTestCase {
    func testEval3() {
        let engine = CalculatorEngine()
        engine.programs.removeAll()
        
        // 1. User taps "New Equation" (+ button) in SwiftUI List
        engine.isWaitingForLabel = true
        engine.startAlpha()
        engine.alphaPrompt = "LBL _"
        
        // 2. User types "N" and hits Submit/Enter
        engine.submitAlpha("N")
        
        // 3. User taps buttons for NDF
        engine.submitAlpha("X") // Direct alpha submission for iOS variable entry
        engine.executeOp(.square)
        engine.executeOp(.digit2)
        engine.executeOp(.divide)
        engine.executeOp(.toggleSign)
        engine.executeOp(.exp)
        engine.executeOp(.digit2)
        engine.executeOp(.shiftBlue); engine.executeOp(.sin) // pi
        engine.executeOp(.multiply)
        engine.executeOp(.sqrt)
        engine.executeOp(.divide)
        
        // 4. User exits programming mode
        engine.executeOp(.prgm)
        
        // 5. Evaluate the function via XEQ
        engine.executeOp(.xeq)
        engine.submitAlpha("N")
        
        // Enter 0 for X when prompted
        engine.submitAlpha("0")
        
        print("STACK AFTER: \(engine.stack.map { $0.real })")
    }
}
