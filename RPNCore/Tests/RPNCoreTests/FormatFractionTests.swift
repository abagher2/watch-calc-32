import XCTest
@testable import RPNCore

final class FormatFractionTests: XCTestCase {
    func testFractionInputFormatting() {
        let engine = CalculatorEngine()
        engine.digit(1)
        engine.decimal()
        engine.digit(2)
        engine.decimal()
        engine.digit(3)
        
        let result = engine.displayXBuffer.withUnsafeBufferPointer { ptr -> String in
            var bytes: [UInt8] = []
            for i in 0..<engine.displayXLength {
                bytes.append(ptr[i])
            }
            return String(decoding: bytes, as: UTF8.self)
        }
        print("Fraction formatted result:", result)
        XCTAssertEqual(result, "1 2/3")
    }
}
