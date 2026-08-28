import XCTest
@testable import RPNCore

final class IndirectAddressingTests: XCTestCase {
    var engine: CalculatorEngine!
    
    override func setUp() {
        super.setUp()
        engine = CalculatorEngine()
    }
    
    func testIndirectAddressingManualSTO() {
        // "3", "STO", "i"
        engine.digit(3)
        engine.startSto()
        engine.submitAlpha("i")
        
        // "99", "STO", "(i)"
        engine.digit(9)
        engine.digit(9)
        engine.startSto()
        engine.submitAlpha("(i)")
        
        // Verify C contains 99
        XCTAssertEqual(engine.variables["C"]?.real, 99.0)
    }
    
    func testIndirectAddressingManualRCL() {
        engine.variables["D"] = CalculatorValue(real: 42.0)
        
        engine.digit(4)
        engine.startSto()
        engine.submitAlpha("i")
        
        engine.startRcl()
        engine.submitAlpha("(i)")
        
        XCTAssertEqual(engine.stack[0].real, 42.0)
    }

    func testIndirectAddressingManualSwap() {
        engine.variables["E"] = CalculatorValue(real: 100.0)
        
        engine.digit(5)
        engine.startSto()
        engine.submitAlpha("i")
        
        engine.digit(2)
        engine.digit(0)
        engine.digit(0)
        engine.startSwapVar()
        engine.submitAlpha("(i)")
        
        XCTAssertEqual(engine.stack[0].real, 100.0)
        XCTAssertEqual(engine.variables["E"]?.real, 200.0)
    }

    func testIndirectAddressingStats() {
        // Stats registers start at 28
        engine.digit(2)
        engine.digit(8)
        engine.startSto()
        engine.submitAlpha("i")
        
        engine.digit(1)
        engine.digit(2)
        engine.digit(3)
        engine.startSto()
        engine.submitAlpha("(i)")
        
        XCTAssertEqual(engine.variables["Σn"]?.real, 123.0)
    }
}
