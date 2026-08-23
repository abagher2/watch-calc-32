import XCTest
@testable import RPNCore

final class CalculatorEngineTests_ThoroughParity: XCTestCase {
    
    func testThoroughParity() {
        var passed = 0
        var failed = 0
        
        for tc in SharedCalculatorThoroughTestCases.cases {
            let engine = CalculatorEngine()
            
            for step in tc.steps {
                let key = step.op
                if let d = Int(key) {
                    engine.digit(d)
                } else if key == "." {
                    engine.decimal()
                } else if key == "+/-" {
                    engine.toggleSign()
                } else if key == "ENTER" {
                    engine.enter()
                } else if key == "<-" {
                    engine.backspace()
                } else if key == "E" {
                    engine.startExponent()
                } else if engine.isWaitingForAlpha || engine.isWaitingForLabel {
                    engine.submitAlpha(key)
                } else {
                    engine.executeMath(key)
                }
                if tc.name == "Equation_Eval_X2" {
                    print("Equation_Eval_X2 step \(key): stack is \(engine.stack.map { $0.real }), isBuildingNumber: \(engine.isBuildingNumber), currentInputLength: \(engine.currentInputLength)")
                }
            }
            engine.commitInput()
            
            if tc.name == "Equation_Eval_X2" {
                print("Equation_Eval_X2 final stack: \(engine.stack.map { $0.real })")
            }
            
            if let lastExpected = tc.steps.last?.expectedX, let expectedVal = Double(lastExpected) {
                let actual = engine.stack[0].real
                let delta = abs(expectedVal - actual)
                let relDelta = expectedVal != 0 ? delta / abs(expectedVal) : delta
                
                if (delta <= 0.001 || relDelta <= 0.0001) && !actual.isNaN {
                    passed += 1
                } else {
                    failed += 1
                    XCTFail("Test \(tc.name) failed! Expected \(expectedVal), got \(actual)")
                }
            } else if let lastExpected = tc.steps.last?.expectedX {
                let actualStr = engine.errorMessage ?? engine.formatNumber(engine.stack[0].real)
                if actualStr == lastExpected || (engine.errorMessage == nil && lastExpected == "NaN" && engine.stack[0].real.isNaN) {
                    passed += 1
                } else {
                    failed += 1
                    XCTFail("Test \(tc.name) failed! Expected \(lastExpected), got \(actualStr)")
                }
            } else {
                // If there's no expected value, just count as passed if no crash.
                passed += 1
            }
        }
        
        print("Thorough Parity: Passed \(passed), Failed \(failed) out of \(SharedCalculatorThoroughTestCases.cases.count)")
        XCTAssertEqual(failed, 0)
    }
}
