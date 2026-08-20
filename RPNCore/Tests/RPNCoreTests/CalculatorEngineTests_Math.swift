import XCTest
@testable import RPNCore

final class CalculatorEngineTests_Math: XCTestCase {
    
    var engine: CalculatorEngine!

    override func setUp() {
        super.setUp()
        engine = CalculatorEngine()
    }
    
    override func tearDown() {
        engine = nil
        super.tearDown()
    }
    
    private func type(_ val: String) {
        for char in val {
            if char == "." {
                engine.decimal()
            } else if let digit = char.wholeNumberValue {
                engine.digit(digit)
            } else if char == "-" {
                engine.toggleSign()
            }
        }
    }

    private func typeAndEnter(_ val: String) {
        type(val)
        engine.enter()
    }
    
    func testMathSIN() {
        type("30")
        engine.executeMath("SIN")
        XCTAssertEqual(engine.stack[0].real, 0.5, accuracy: 0.0001)
    }

    func testMathCOS() {
        type("60")
        engine.executeMath("COS")
        XCTAssertEqual(engine.stack[0].real, 0.5, accuracy: 0.0001)
    }
    
    func testMathTAN() {
        type("45")
        engine.executeMath("TAN")
        XCTAssertEqual(engine.stack[0].real, 1.0, accuracy: 0.0001)
    }

    func testMathASIN() {
        type("0.5")
        engine.executeMath("ASIN")
        XCTAssertEqual(engine.stack[0].real, 30.0, accuracy: 0.0001)
    }
    
    func testMathACOS() {
        type("0.5")
        engine.executeMath("ACOS")
        XCTAssertEqual(engine.stack[0].real, 60.0, accuracy: 0.0001)
    }
    
    func testMathATAN() {
        type("1")
        engine.executeMath("ATAN")
        XCTAssertEqual(engine.stack[0].real, 45.0, accuracy: 0.0001)
    }
    
    func testMathLN() {
        type("10")
        engine.executeMath("LN")
        XCTAssertEqual(engine.stack[0].real, 2.30258, accuracy: 0.0001)
    }
    
    func testMathLOG() {
        type("10")
        engine.executeMath("LOG")
        XCTAssertEqual(engine.stack[0].real, 1.0, accuracy: 0.0001)
    }
    
    func testMathEX() {
        type("1")
        engine.executeMath("e^x")
        XCTAssertEqual(engine.stack[0].real, 2.71828, accuracy: 0.0001)
    }
    
    func testMath10X() {
        type("2")
        engine.executeMath("10^x")
        XCTAssertEqual(engine.stack[0].real, 100.0, accuracy: 0.0001)
    }
    
    func testMathSQRT() {
        type("9")
        engine.executeMath("√x")
        XCTAssertEqual(engine.stack[0].real, 3.0, accuracy: 0.0001)
    }
    
    func testMathSQR() {
        type("3")
        engine.executeMath("x^2")
        XCTAssertEqual(engine.stack[0].real, 9.0, accuracy: 0.0001)
    }
    
    func testMathINV() {
        type("2")
        engine.executeMath("1/x")
        XCTAssertEqual(engine.stack[0].real, 0.5, accuracy: 0.0001)
    }
    
    func testMathYX() {
        typeAndEnter("2")
        type("3")
        engine.executeMath("y^x")
        XCTAssertEqual(engine.stack[0].real, 8.0, accuracy: 0.0001)
    }
    
    func testMathFactorial() {
        type("5")
        engine.executeMath("n!")
        XCTAssertEqual(engine.stack[0].real, 120.0, accuracy: 0.0001)
    }
    
    func testMathPI() {
        engine.executeMath("π")
        XCTAssertEqual(engine.stack[0].real, 3.14159, accuracy: 0.0001)
    }
    
    func testMathPercent() {
        typeAndEnter("50")
        type("10")
        engine.executeMath("%")
        XCTAssertEqual(engine.stack[0].real, 5.0, accuracy: 0.0001)
        XCTAssertEqual(engine.stack[1].real, 50.0, accuracy: 0.0001)
    }
    
    func testMathPercentChange() {
        typeAndEnter("40")
        type("50")
        engine.executeMath("%CHG")
        XCTAssertEqual(engine.stack[0].real, 25.0, accuracy: 0.0001)
        XCTAssertEqual(engine.stack[1].real, 40.0, accuracy: 0.0001)
    }
    
    func testMathPermutationsAndCombinations() {
        // 5 P 2 = 20
        typeAndEnter("5")
        type("2")
        engine.executeMath("nPr")
        XCTAssertEqual(engine.stack[0].real, 20.0, accuracy: 0.0001)
        
        // 5 C 2 = 10
        typeAndEnter("5")
        type("2")
        engine.executeMath("nCr")
        XCTAssertEqual(engine.stack[0].real, 10.0, accuracy: 0.0001)
        
        // Test INVALID DATA
        typeAndEnter("2")
        type("5")
        engine.executeMath("nPr")
        XCTAssertEqual(engine.errorMessage, "INVALID DATA")
        engine.errorMessage = nil
    }
    
    func testMathRandom() {
        engine.executeMath("RAND")
        let val = engine.stack[0].real
        XCTAssertTrue(val >= 0 && val < 1)
        
        // Seed test
        typeAndEnter("42")
        engine.executeMath("SEED")
        XCTAssertEqual(engine.stack[0].real, 0.0) // seed drops it
    }
}
