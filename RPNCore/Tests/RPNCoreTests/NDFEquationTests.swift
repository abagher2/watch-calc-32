import XCTest
@testable import RPNCore

final class NDFEquationTests: XCTestCase {
    
    // Simulate creating the NDF program via the Firmware physical buttons (RetroUIController)
    func testFirmwareNDFEquationCreation() {
        let engine = CalculatorEngine()
        engine.programs.removeAll()
        let controller = RetroUIController(engine: engine)
        
        // 1. Enter EQN mode using BLUE + STO
        controller.processAction(.shiftBlue)
        controller.processAction(.sto) // This is EQN
        
        XCTAssertTrue(engine.requestEqn)
        
        // 2. Press LFU_0 (Softkey for "NEW")
        controller.processAction(.lfu0)
        
        // 3. System prompts for LBL. Type 'N' (which is on the swapXY key).
        // RetroUIController immediately accepts the alpha char, no ENTER needed.
        XCTAssertTrue(engine.isWaitingForLabel)
        XCTAssertEqual(engine.alphaPrompt, "LBL _")
        controller.processAction(.swapXY) // Alpha 'N'
        
        XCTAssertTrue(engine.isProgrammingMode)
        XCTAssertEqual(engine.currentProgramLabel, "N")
        
        // 4. Type the NDF steps
        controller.processAction(.rcl)
        controller.processAction(.digit2) // Alpha X
        
        // Continue with math ops
        let mathSteps: [CalculatorOperation] = [
            .shiftYellow, .sqrt, // x^2
            .digit2,
            .divide,
            .toggleSign,
            .exp, // e^x
            .digit2,
            .shiftBlue, .sin, // pi
            .multiply,
            .sqrt,
            .divide
        ]
        for step in mathSteps {
            controller.processAction(step)
        }
        
        // Exit programming mode by pressing PRGM
        controller.processAction(.prgm)
        XCTAssertFalse(engine.isProgrammingMode)
        
        // Print steps to debug
        let steps = engine.programs.first(where: { $0.label == "N" })?.steps.map { $0.stringValue } ?? []
        print("FIRMWARE STEPS: \(steps)")
        
        // 5. Evaluate the function using XEQ 'N' via softkeys
        controller.processAction(.xeq)
        
        // Softkey 0 is program "N"
        controller.processAction(.lfu0)
        
        // Now softkeys are variables: [0]: " X", [1]: "EXEC"
        // Set X = 0
        controller.processAction(.digit0)
        controller.processAction(.lfu0) // Stores 0 in X
        
        // Execute the program
        controller.processAction(.lfu1) // EXEC
        
        XCTAssertEqual(engine.stack[0].real, 0.3989422804014327, accuracy: 1e-6)
    }
    
    // Simulate creating the NDF program via iOS/watchOS UI (Direct Engine Calls)
    func testiOSWatchOSNDFEquationCreation() {
        let engine = CalculatorEngine()
        engine.programs.removeAll()
        
        // 1. User taps "New Equation" (+ button) in SwiftUI List
        engine.isWaitingForLabel = true
        engine.startAlpha()
        engine.alphaPrompt = "LBL _"
        
        // 2. User types "N" and hits Submit/Enter
        engine.submitAlpha("N")
        
        XCTAssertTrue(engine.isProgrammingMode)
        XCTAssertEqual(engine.currentProgramLabel, "N")
        
        // 3. User taps buttons for NDF
        engine.submitAlpha("X") // Direct alpha submission for iOS variable entry
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
        
        let steps2 = engine.programs.first(where: { $0.label == "N" })?.steps.map { $0.stringValue } ?? []
        print("IOS STEPS: \(steps2)")
        
        // 5. Evaluate the function via XEQ
        engine.executeOp(.xeq)
        engine.submitAlpha("N")
        
        XCTAssertEqual(engine.pendingEquationVars, ["X"])
        
        // Enter 0 for X when prompted
        engine.submitAlpha("0")
        
        XCTAssertEqual(engine.stack[0].real, 0.3989422804014327, accuracy: 1e-6)
    }
}
