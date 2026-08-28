import XCTest
@testable import RPNCore

final class MiscEdgeCasesTests: XCTestCase {
    var engine: CalculatorEngine!
    
    override func setUp() {
        super.setUp()
        engine = CalculatorEngine()
    }
    
    func testRecallDenominator() {
        // Set denom to 20
        engine.digit(2)
        engine.digit(0)
        engine.executeMath("/c")
        
        // Push 1 and do 1 /c to recall
        engine.digit(1)
        engine.executeMath("/c")
        
        XCTAssertEqual(engine.stack[0].real, 20.0)
    }
    
    func testZeroDenominator() {
        // Set denom to 0 (should default to 4095)
        engine.digit(0)
        engine.executeMath("/c")
        
        // Recall it
        engine.digit(1)
        engine.executeMath("/c")
        
        XCTAssertEqual(engine.stack[0].real, 4095.0)
    }

    func testGammaFactorial() {
        // 0.5 ! should be approx 0.8862 (Gamma(1.5))
        engine.digit(0)
        engine.executeMath(".")
        engine.digit(5)
        engine.executeMath("𝑥!")
        
        XCTAssertEqual(engine.stack[0].real, 0.8862269254527579, accuracy: 0.0001)
        
        // Test negative non-integer: -0.5 ! -> Gamma(0.5) -> approx 1.77245
        engine.digit(0)
        engine.executeMath(".")
        engine.digit(5)
        engine.executeMath("+/-")
        engine.executeMath("𝑥!")
        
        XCTAssertEqual(engine.stack[0].real, 1.7724538509055159, accuracy: 0.0001)
        
        // Test negative integer: -1 ! -> INVALID DATA
        engine.executeMath("CLEAR")
        engine.digit(1)
        engine.executeMath("+/-")
        engine.executeMath("𝑥!")
        XCTAssertEqual(engine.errorMessage, "INVALID DATA")
    }
}
