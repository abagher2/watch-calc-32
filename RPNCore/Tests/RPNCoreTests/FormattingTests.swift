import XCTest
@testable import RPNCore

final class FormattingTests: XCTestCase {
    func testThousandsGroupingSeparator() {
        let engine = CalculatorEngine()
        
        // Default decimal is period, grouping should be comma
        engine.useCommaForDecimal = false
        XCTAssertEqual(engine.formatNumber(1234567.89), "1,234,567.89")
        XCTAssertEqual(engine.formatNumber(-9876543.21), "-9,876,543.2")
        XCTAssertEqual(engine.formatNumber(1000), "1,000")
        
        // If comma is decimal, grouping should be period
        engine.useCommaForDecimal = true
        XCTAssertEqual(engine.formatNumber(1234567.89), "1.234.567,89")
        XCTAssertEqual(engine.formatNumber(-9876543.21), "-9.876.543,2")
        XCTAssertEqual(engine.formatNumber(1000), "1.000")
    }

    func testInputTypingCommas() {
        let engine = CalculatorEngine()
        engine.useCommaForDecimal = false
        
        engine.digit(1)
        engine.digit(2)
        engine.digit(3)
        engine.digit(4)
        engine.digit(5)
        engine.digit(6)
        engine.digit(7)
        
        XCTAssertEqual(engine.displayX, "1,234,567")
        
        engine.decimal()
        engine.digit(8)
        engine.digit(9)
        
        XCTAssertEqual(engine.displayX, "1,234,567.89")
        
        // EEX formatting
        engine.startExponent()
        engine.digit(1)
        XCTAssertEqual(engine.displayX, "1,234,567.89E1")
    }

}