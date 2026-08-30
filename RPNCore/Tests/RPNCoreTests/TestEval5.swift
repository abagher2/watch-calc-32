import XCTest
@testable import RPNCore

final class TestEval5: XCTestCase {
    func testFirmwareTrace() {
        let engine = CalculatorEngine()
        let controller = RetroUIController(engine: engine)
        engine.equations.removeAll()
        
        // 1. Enter Equation Mode
        controller.processAction(.shiftYellow); controller.processAction(.c) // LBL
        
        // 2. Type 'N'
        controller.processAction(.swapXY) // Alpha 'N'
        
        // 3. Enter Equation
        controller.processAction(.rcl); controller.processAction(.swapXY) // RCL X
        controller.processAction(.shiftYellow); controller.processAction(.sqrt) // x^2
        controller.processAction(.digit2)
        controller.processAction(.divide)
        controller.processAction(.toggleSign)
        controller.processAction(.shiftYellow); controller.processAction(.ln) // e^x
        controller.processAction(.digit2)
        controller.processAction(.shiftBlue); controller.processAction(.sin) // pi
        controller.processAction(.multiply)
        controller.processAction(.sqrt)
        controller.processAction(.divide)
        
        // 4. Exit Equation Mode
        controller.processAction(.c)
        
        let steps = engine.equations.first(where: { $0.label == "N" })?.steps.map { $0.stringValue } ?? []
        print("FIRMWARE STEPS: \(steps)")
        
        // 5. Evaluate the function using XEQ 'N' via softkeys
        controller.processAction(.xeq)
        controller.processAction(.lfu0) // Softkey 0 is equation "N"
        
        // Set X = 0
        controller.processAction(.digit0)
        controller.processAction(.lfu0) // Stores 0 in X
        
        print("VARS: \(engine.variables)")
        
        // Execute the equation
        controller.processAction(.lfu1) // EXEC
        
        print("STACK AFTER FIRMWARE: \(engine.stack.map { $0.real })")
    }
}
