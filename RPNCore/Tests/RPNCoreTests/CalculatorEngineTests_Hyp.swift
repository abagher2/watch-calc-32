import XCTest
@testable import RPNCore

final class CalculatorEngineTests_Hyp: XCTestCase {
    func testHyperbolicMath() {
        let engine = CalculatorEngine()
        
        // sinh(1) ≈ 1.1752
        engine.push(CalculatorValue(real: 1.0))
        engine.executeMath("HYP")
        engine.executeMath("SIN")
        
        XCTAssertEqual(engine.stack[0].real, sinh(1.0), accuracy: 1e-5)
        XCTAssertFalse(engine.isHypPending) // flag resets
        
        // cosh(0) = 1
        engine.push(CalculatorValue(real: 0.0))
        engine.executeMath("HYP")
        engine.executeMath("COS")
        XCTAssertEqual(engine.stack[0].real, cosh(0.0), accuracy: 1e-5)
    }
}
