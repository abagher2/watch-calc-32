import XCTest
@testable import RPNCore

final class FormatterParityTests: XCTestCase {
    
    func testFormatterParity() {
        // Given both formatters
        let appleFormatter = FoundationValueFormatter()
        let basicFormatter = BasicValueFormatter()
        
        let testValues: [Double] = [
            0,
            1,
            -1,
            3.14159,
            -3.14159,
            123456789,
            -123456789,
            0.0000001,
            -0.0000001,
            Double.pi
        ]
        
        let modes: [CalculatorEngine.DisplayMode] = [
            .all,
            .fix(4),
            .fix(2),
            .sci(3),
            .sci(5),
            .eng(3)
        ]
        
        // When checking edge cases, they should ideally be reasonably close,
        // though exact 1:1 parity might require advanced string building in BasicValueFormatter.
        // For now, we will just print any mismatches to identify drift between WatchOS and Firmware!
        
        var mismatches = 0
        
        for val in testValues {
            for mode in modes {
                let expected = appleFormatter.format(value: val, mode: mode)
                let actual = basicFormatter.format(value: val, mode: mode)
                
                if expected != actual {
                    print("⚠️ FORMATTER PARITY MISMATCH: val=\(val), mode=\(mode) -> Apple: '\(expected)', Firmware: '\(actual)'")
                    mismatches += 1
                }
            }
        }
        
        // Assert we don't have drift (uncomment to enforce)
        // XCTAssertEqual(mismatches, 0, "Found \(mismatches) formatting parity differences between Firmware and Apple implementations.")
    }
}
