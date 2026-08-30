import XCTest
@testable import RPNCore

final class TestExtraction2: XCTestCase {
    func testEval() {
        let engine = CalculatorEngine()
        engine.equations.removeAll()
        
        let stepsStr = ["X", "𝑥²", "2", "÷", "+/-", "𝑒ˣ", "2", "π", "×", "√𝑥", "÷"]
        let steps = stepsStr.compactMap { Instruction(fromString: $0) }
        let equation = CalculatorEngine.Equation(label: "N", steps: steps)
        
        engine.variables["X"] = CalculatorValue(real: 0.0)
        
        // Emulate evaluateEquation loop with prints
        engine.isEquationEditMode = false
        engine.isBuildingNumber = false
        engine.stackLiftEnabled = true
        engine.stack = Array(repeating: CalculatorValue(), count: 4)
        
        for step in steps {
            switch step {
            case .operation(let op):
                let raw = op.rawValue
                if raw >= CalculatorOperation.digit0.rawValue && raw <= CalculatorOperation.digit9.rawValue {
                    let d = raw - CalculatorOperation.digit0.rawValue
                    if !engine.isBuildingNumber {
                        if engine.stackLiftEnabled && !engine.stack.isEmpty {
                            engine.pushToStack(engine.stack[0])
                        }
                        engine.isBuildingNumber = true
                        engine.currentInputLength = 0
                    }
                    if engine.currentInputLength < 64 {
                        engine.currentInputBuffer[engine.currentInputLength] = UInt8(48 + d)
                        engine.currentInputLength += 1
                    }
                } else {
                    if engine.isBuildingNumber { engine.commitInput() }
                    engine.execute(step)
                }
            case .custom(let str):
                if engine.isBuildingNumber { engine.commitInput() }
                if let val = engine.variables[str] {
                    engine.push(val)
                    engine.stackLiftEnabled = true
                } else {
                    engine.execute(step)
                }
            default:
                if engine.isBuildingNumber { engine.commitInput() }
                engine.execute(step)
            }
            
            print("After \(step.stringValue): Stack = \(engine.stack.prefix(4).map { $0.real })")
        }
    }
}
