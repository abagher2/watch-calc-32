import XCTest
@testable import RPNCore

final class NuancedParityTests: XCTestCase {

    func testFractionDenominatorControl() {
        let engine = CalculatorEngine()
        
        // Push 16 to stack, then execute /c
        engine.executeMath("1")
        engine.executeMath("6")
        engine.executeMath("/c")
        
        XCTAssertEqual(engine.maxDenominator, 16.0)
        XCTAssertTrue(engine.isFractionMode)
        XCTAssertTrue(engine.flags[7])
        
        // Execute FDISP to toggle it off
        engine.executeMath("FDISP")
        XCTAssertFalse(engine.isFractionMode)
        XCTAssertFalse(engine.flags[7])
        
        engine.executeMath("FDISP")
        XCTAssertTrue(engine.isFractionMode)
        
        // Now test 8/16 vs 1/2 using flags 8 and 9
        // Flag 8 = Exact Denominator, Flag 9 = No Reducing
        engine.executeMath("0")
        engine.executeMath(".")
        engine.executeMath("5")
        engine.executeMath("ENTER")
        
        engine.flags[8] = true
        engine.flags[9] = true
        engine.updateDisplay() // Should trigger fraction re-render if it was UI, but we can check values
        
        XCTAssertEqual(engine.stack[0].real, 0.5)
    }

    func testStorageArithmetic() {
        let engine = CalculatorEngine()
        let controller = RetroUIController(engine: engine)
        
        // 10 STO A
        engine.executeMath("1")
        engine.executeMath("0")
        engine.alphaAction = .sto
        controller.processAction(.lfu0) // Assuming A is lfu0 alpha? Let's just use submitAlpha
        engine.submitAlpha("A")
        
        // 5 STO + A
        engine.executeMath("5")
        engine.executeMath("ENTER")
        engine.alphaAction = .sto
        engine.alphaAction = .stoAdd // STO +
        engine.submitAlpha("A")
        
        // RCL A
        engine.alphaAction = .rcl
        engine.submitAlpha("A")
        
        XCTAssertEqual(engine.stack[0].real, 15.0)
        
        // 2 STO * A
        engine.executeMath("2")
        engine.alphaAction = .sto
        engine.alphaAction = .stoMul // STO *
        engine.submitAlpha("A")
        
        engine.alphaAction = .rcl
        engine.submitAlpha("A")
        
        XCTAssertEqual(engine.stack[0].real, 30.0)
    }

    func testIndirectAddressing() {
        let engine = CalculatorEngine()
        let controller = RetroUIController(engine: engine)
        
        // 1 STO i
        engine.executeMath("1")
        engine.alphaAction = .sto
        engine.submitAlpha("i")
        
        // 99 STO (i) -> should go to A
        engine.executeMath("9")
        engine.executeMath("9")
        engine.alphaAction = .sto
        engine.submitAlpha("(i)")
        
        // RCL A
        engine.alphaAction = .rcl
        engine.submitAlpha("A")
        
        XCTAssertEqual(engine.stack[0].real, 99.0)
        
        // 28 STO i (Points to Σn)
        engine.executeMath("2")
        engine.executeMath("8")
        engine.alphaAction = .sto
        engine.submitAlpha("i")
        
        // 5 STO (i)
        engine.executeMath("5")
        engine.executeMath("ENTER")
        engine.alphaAction = .sto
        engine.submitAlpha("(i)")
        
        XCTAssertEqual(engine.statN, 5.0)
    }

    func testComplexNumbers() {
        let engine = CalculatorEngine()
        let controller = RetroUIController(engine: engine)
        
        // 3 ENTER 4 CMPLX -> 3 + 4i
        engine.executeMath("3")
        engine.executeMath("ENTER")
        engine.executeMath("4")
        engine.executeMath("CMPLX")
        
        XCTAssertEqual(engine.stack[0].real, 3.0)
        XCTAssertEqual(engine.stack[0].imag, 4.0)
        
        // + 1 -> 4 + 4i
        engine.executeMath("1")
        engine.executeMath("+")
        
        XCTAssertEqual(engine.stack[0].real, 4.0)
        XCTAssertEqual(engine.stack[0].imag, 4.0)
    }
    
    func testViewVariable() {
        let engine = CalculatorEngine()
        let controller = RetroUIController(engine: engine)
        
        engine.executeMath("9")
        engine.alphaAction = .sto
        engine.submitAlpha("A")
        
        engine.alphaAction = .view
        engine.submitAlpha("A")
        
        XCTAssertEqual(engine.transientMessage, "A = 9") // Formatted
        
        // Test that pressing a key clears transient
        engine.executeMath("1")
        XCTAssertNil(engine.transientMessage)
    }

    func testErrorSwallowing() {
        let engine = CalculatorEngine()
        
        // DIVIDE BY 0
        engine.executeMath("1")
        engine.executeMath("ENTER")
        engine.executeMath("0")
        engine.executeMath("÷")
        
        XCTAssertEqual(engine.errorMessage, "DIVIDE BY 0")
        
        // Pressing + should SWALLOW the + and just clear the error
        engine.executeMath("+")
        XCTAssertNil(engine.errorMessage)
        
        // Stack should still be [0, 1]
        XCTAssertEqual(engine.stack[0].real, 0.0)
        XCTAssertEqual(engine.stack[1].real, 1.0)
    }
    
    func testPromptAbort() {
        let engine = CalculatorEngine()
        
        // SF _
        engine.executeMath("SF")
        XCTAssertTrue(engine.isWaitingForFlag)
        XCTAssertEqual(engine.promptString, "SF _")
        
        // Pressing SIN is swallowed, prompt stays alive
        engine.executeMath("SIN")
        XCTAssertTrue(engine.isWaitingForFlag)
        XCTAssertEqual(engine.promptString, "SF _")
        
        engine.executeMath("C") // Clears it
        XCTAssertFalse(engine.isWaitingForFlag)
        XCTAssertNil(engine.promptString)
    }
}
