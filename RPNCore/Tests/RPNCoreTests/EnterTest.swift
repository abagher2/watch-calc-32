import XCTest
@testable import RPNCore

final class EnterTest: XCTestCase {
    func testEnterBug() throws {
        let engine = CalculatorEngine()
        engine.digit(1)
        engine.enter()
        print("AFTER 1 ENTER: displayX = \(engine.displayX), stackStrings = \(engine.stackStrings)")
        engine.digit(2)
        engine.enter()
        print("AFTER 2 ENTER: displayX = \(engine.displayX), stackStrings = \(engine.stackStrings)")
    }
    
    func testMultiPartFormulaBug() throws {
        let engine = CalculatorEngine()
        engine.digit(1)
        engine.digit(2)
        engine.digit(0)
        engine.digit(0)
        engine.digit(0)
        engine.enter()
        print("AFTER 12000 ENTER: \(engine.displayX) (stack: \(engine.stackStrings))")
        
        engine.decimal()
        engine.digit(2)
        print("AFTER .2: \(engine.displayX) (stack: \(engine.stackStrings))")
        
        engine.handleCommand("×")
        print("AFTER ×: \(engine.displayX) (stack: \(engine.stackStrings))")
        
        engine.decimal()
        engine.digit(9)
        print("AFTER .9: \(engine.displayX) (stack: \(engine.stackStrings))")
        
        engine.handleCommand("÷")
        print("AFTER ÷: \(engine.displayX) (stack: \(engine.stackStrings))")
        
        let resultStr = engine.displayX.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: " ", with: "")
        print("FINAL STRING TO PARSE: '\(resultStr)'")
        let result = Double(resultStr) ?? 0.0
        XCTAssertEqual(result, 2666.6667, accuracy: 0.001)
    }
}
