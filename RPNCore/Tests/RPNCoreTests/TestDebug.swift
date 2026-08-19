import XCTest
@testable import RPNCore

final class TestDebug: XCTestCase {
    func testEq() {
        let val = CalculatorValue(real: -4.0)
        let res = CalculatorValue.sqrt(val)
        print("SQRT = \(res.real)")
    }
}
