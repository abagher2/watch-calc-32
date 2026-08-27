import XCTest
@testable import RPNCore
@testable import ParityExporter

final class TestEval4: XCTestCase {
    func testEval4() {
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
        
        print("PROGRAM STEPS: \(engine.currentProgramSteps)")
        
        // 4. User exits programming mode
        engine.executeOp(.prgm)
        
        let p = engine.programs.first(where: { $0.label == "N" })!
        print("PROGRAM INSTRUCTION: \(p.steps)")
    }
}
