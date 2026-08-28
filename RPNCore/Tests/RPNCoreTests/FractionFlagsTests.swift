import XCTest
@testable import RPNCore

final class FractionFlagsTests: XCTestCase {
    var engine: CalculatorEngine!
    
    override func setUp() {
        super.setUp()
        engine = CalculatorEngine()
    }
    
    func testFractionFlags() {
        // Set denom to 60
        engine.digit(6)
        engine.digit(0)
        engine.executeMath("/c")
        
        // Push 1.5
        engine.digit(1)
        engine.executeMath(".")
        engine.digit(5)
        engine.executeMath("ENTER")
        
        // It should be fraction mode by default because /c enables it
        // 1.5 as optimal <= 60 is 1 1/2
        XCTAssertEqual(engine.stackStrings.first, "1 1/2")
        
        // Now set flag 8 (denom = /c and reduced)
        engine.handleCommand("SF")
        engine.handleCommand("8")
        
        // It's still 1 1/2 because 30/60 reduces to 1/2
        XCTAssertEqual(engine.stackStrings.first, "1 1/2")
        
        // Now set flag 9 (always = /c)
        engine.handleCommand("SF")
        engine.handleCommand("9")
        
        // Now it should be 1 30/60
        XCTAssertEqual(engine.stackStrings.first, "1 30/60")
        
        // Now clear flag 9 and 8
        engine.handleCommand("CF")
        engine.handleCommand("9")
        engine.handleCommand("CF")
        engine.handleCommand("8")
        
        XCTAssertEqual(engine.stackStrings.first, "1 1/2")
    }
}
