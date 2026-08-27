import XCTest
@testable import RPNCore

final class PromptTests: XCTestCase {
    
    func testExecutePromptsForMissingVars() throws {
        let engine = CalculatorEngine()
        engine.clearPrograms()
        
        // N = normal PDF: e^(-0.5*((X-M)/S)^2)/(S*sqrt(2*Pi))
        engine.executeMath("PRGM")
        engine.executeMath("LBL")
        engine.submitAlpha("N")
        engine.executeMath("RCL")
        engine.submitAlpha("X")
        engine.executeMath("RCL")
        engine.submitAlpha("M")
        engine.executeMath("-")
        engine.executeMath("RCL")
        engine.submitAlpha("S")
        engine.executeMath("÷")
        
        let pdfSteps = ["𝑥²", "2", "÷", "+/-", "𝑒ˣ", "RCL", "S", "÷", "2", "π", "×", "√𝑥", "÷", "RTN"]
        for step in pdfSteps {
            if step == "S" {
                engine.submitAlpha("S")
            } else {
                engine.executeMath(step)
            }
        }
        
        // Execute N
        print("STEPS:", engine.programs.first?.steps.map { $0.stringValue } ?? [])
        print("VARS:", engine.programs.first?.extractVariables() ?? [])
        engine.executeMath("XEQ")
        engine.submitAlpha("N")
        
        // Should prompt for X
        XCTAssertEqual(engine.alphaAction, .promptVar)
        XCTAssertEqual(engine.alphaPrompt, "X?")
        
        // Provide X = 0
        engine.executeMath("0")
        engine.executeMath("ENTER")
        
        // Should prompt for M
        XCTAssertEqual(engine.alphaAction, .promptVar)
        XCTAssertEqual(engine.alphaPrompt, "M?")
        
        // Provide M = 0
        engine.executeMath("0")
        engine.executeMath("ENTER")
        
        // Should prompt for S
        XCTAssertEqual(engine.alphaAction, .promptVar)
        XCTAssertEqual(engine.alphaPrompt, "S?")
        
        // Provide S = 1
        engine.executeMath("1")
        engine.executeMath("ENTER")
        
        // Should evaluate and return ~0.3989 (1 / sqrt(2*pi))
        let res = engine.stack[0].real
        XCTAssertEqual(res, 0.3989422804, accuracy: 1e-4)
    }
    
    func testSolvePromptsForMissingVars() throws {
        let engine = CalculatorEngine()
        engine.clearPrograms()
        engine.programs.append(CalculatorEngine.Program(label: "A", steps: [
            Instruction(fromString: "RCL X")!,
            Instruction(fromString: "RCL Y")!,
            Instruction(fromString: "+")!
        ]))
        
        engine.executeMath("FN=")
        engine.submitAlpha("A")
        
        // Solve for X
        engine.executeMath("SOLVE")
        engine.submitAlpha("X")
        
        // Should skip X, and prompt for Y!
        XCTAssertEqual(engine.alphaAction, .promptVar)
        XCTAssertEqual(engine.alphaPrompt, "Y?")
        
        // Provide Y = 5
        engine.executeMath("5")
        engine.executeMath("ENTER")
        
        // The solve should find X = -5
        let res = engine.stack[0].real
        XCTAssertEqual(res, -5.0, accuracy: 1e-4)
    }

    func testIntegratePromptsForMissingVars() throws {
        let engine = CalculatorEngine()
        engine.clearPrograms()
        engine.programs.append(CalculatorEngine.Program(label: "A", steps: [
            Instruction(fromString: "RCL X")!,
            Instruction(fromString: "RCL M")!,
            Instruction(fromString: "+")!
        ]))
        
        engine.executeMath("FN=")
        engine.submitAlpha("A")
        
        // STO M = 2 explicitly
        engine.push(CalculatorValue(real: 2))
        engine.executeMath("STO")
        engine.submitAlpha("M")
        
        // Limits: 0 to 10
        engine.push(CalculatorValue(real: 0))
        engine.push(CalculatorValue(real: 10))
        
        engine.executeMath("∫")
        engine.submitAlpha("X")
        
        // It should NOT prompt for M since it is STO'd
        XCTAssertNotEqual(engine.alphaAction, .promptVar)
        
        // The integral of (X + 2) from 0 to 10 is 0.5*10^2 + 2*10 = 50 + 20 = 70
        let res = engine.stack[0].real
        XCTAssertEqual(res, 70.0, accuracy: 1e-4)
    }
}
