import XCTest
@testable import RPNCore

final class CalculatorEngineTests_Extensive: XCTestCase {
    var engine: CalculatorEngine!

    override func setUp() {
        super.setUp()
        engine = CalculatorEngine()
    }

    func testStackSwap() {
        engine.digit(1)
        engine.executeMath("ENTER")
        engine.digit(2)
        engine.commitInput()
        XCTAssertEqual(engine.stack[0].real, 2.0)
        XCTAssertEqual(engine.stack[1].real, 1.0)
        
        engine.executeMath("𝑥≷𝑦")
        XCTAssertEqual(engine.stack[0].real, 1.0)
        XCTAssertEqual(engine.stack[1].real, 2.0)
    }
    
    func testBaseConversions() {
        engine.digit(1)
        engine.digit(0)
        engine.executeMath("HEX")
        XCTAssertEqual(engine.baseMode, .hex)
        XCTAssertEqual(engine.formatNumber(engine.stack[0].real), "Ah") // HP-style hex suffix
        
        engine.executeMath("DEC")
        XCTAssertEqual(engine.baseMode, .dec)
        
        engine.executeMath("BIN")
        XCTAssertEqual(engine.baseMode, .bin)
        XCTAssertEqual(engine.formatNumber(engine.stack[0].real), "1010b") // HP-style bin suffix
        
        engine.executeMath("OCT")
        XCTAssertEqual(engine.baseMode, .oct)
        XCTAssertEqual(engine.formatNumber(engine.stack[0].real), "12o") // HP-style oct suffix
    }

    func testTestX0Conditionals() {
        engine.digit(5)
        engine.executeMath("+/-")
        engine.commitInput()
        engine.executeMath("x>0")
        XCTAssertEqual(engine.transientMessage, "NO") // -5 > 0 is NO
        
        engine.executeMath("x<0")
        XCTAssertEqual(engine.transientMessage, "YES")
        
        engine.executeMath("x=0")
        XCTAssertEqual(engine.transientMessage, "NO")
        
        engine.executeMath("x!=0")
        XCTAssertEqual(engine.transientMessage, "YES")
        
        engine.executeMath("x<=0")
        XCTAssertEqual(engine.transientMessage, "YES")
    }
    
    func testTestXYConditionals() {
        engine.digit(5)
        engine.executeMath("ENTER")
        engine.digit(1)
        engine.digit(0)
        engine.commitInput()
        // Y = 5, X = 10
        
        engine.executeMath("x>y") // 10 > 5 => YES
        XCTAssertEqual(engine.transientMessage, "YES")
        
        engine.executeMath("C")
        engine.digit(5)
        engine.executeMath("ENTER")
        engine.digit(1)
        engine.digit(0)
        
        engine.executeMath("x<y")
        XCTAssertEqual(engine.transientMessage, "NO")
        
        engine.executeMath("x=y")
        XCTAssertEqual(engine.transientMessage, "NO")
        
        engine.executeMath("x!=y")
        XCTAssertEqual(engine.transientMessage, "YES")
        
        engine.executeMath("x<=y")
        XCTAssertEqual(engine.transientMessage, "NO")
    }
    
    func testHexDigitInput() {
        engine.executeMath("HEX")
        engine.submitAlpha("A")
        engine.submitAlpha("B")
        XCTAssertEqual(engine.displayX, "AB")
        engine.commitInput()
        XCTAssertEqual(engine.stack[0].real, 171.0) // 0xAB is 171
    }
    
    func testStoArithmetic() {
        engine.digit(1)
        engine.digit(0)
        engine.enter()
        engine.executeMath("STO")
        engine.submitAlpha("A")
        
        // 10 is in A
        engine.executeMath("C")
        engine.digit(5)
        engine.executeMath("STO")
        engine.submitAlpha("+")
        engine.submitAlpha("A") // A is now 15
        
        engine.executeMath("C")
        engine.digit(2)
        engine.executeMath("STO")
        engine.submitAlpha("×")
        engine.submitAlpha("A") // A is now 30
        
        engine.executeMath("RCL")
        engine.submitAlpha("A")
        XCTAssertEqual(engine.stack[0].real, 30.0)
    }
    
    func testViewCommand() {
        engine.digit(4)
        engine.digit(2)
        engine.executeMath("STO")
        engine.submitAlpha("B") // Store 42 in B
        
        engine.executeMath("C")
        engine.digit(9)
        engine.digit(9)
        
        engine.executeMath("VIEW")
        engine.submitAlpha("B")
        
        XCTAssertEqual(engine.transientMessage, "B = 42")
        // Stack shouldn't change
        XCTAssertEqual(engine.stack[0].real, 99.0)
    }
}
