import XCTest
@testable import RPNCore

final class TempTest: XCTestCase {
    func testN() {
        let engine = CalculatorEngine()
        engine.variables["M"] = CalculatorValue(real: 0)
        engine.variables["S"] = CalculatorValue(real: 1)
        engine.variables["X"] = CalculatorValue(real: 0)
        
        // Setup N
        engine.isProgrammingMode = true
        engine.currentProgramLabel = "N"
        let N = CalculatorEngine.Program(label: "N", steps: ["RCL", "X", "RCL", "M", "-", "RCL", "S", "÷", "𝑥²", "2", "÷", "+/-", "𝑒ˣ", "RCL", "S", "÷", "2", "π", "×", "√𝑥", "÷", "RTN"].map {
            Instruction.custom($0)
        })
        let res = engine.evaluateProgram(N, variables: engine.variables)
        print("RES IS: \(String(describing: res?.real))")
        print("ERROR IS: \(String(describing: engine.errorMessage))")
    }
}
