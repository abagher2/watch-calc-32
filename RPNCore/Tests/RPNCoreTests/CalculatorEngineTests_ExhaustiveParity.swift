import XCTest
@testable import RPNCore

final class CalculatorEngineTests_ExhaustiveParity: XCTestCase {
    var engine: CalculatorEngine!

    override func setUp() {
        super.setUp()
        engine = CalculatorEngine()
    }

    func testExhaustiveParity() {
        let testCases: [(name: String, keys: [String], expected: Double)] = [
            ("Addition", ["2", "ENTER", "3", "+"], 5.0),
            ("Subtraction", ["5", "ENTER", "2", "-"], 3.0),
            ("Multiplication", ["4", "ENTER", "5", "×"], 20.0),
            ("Division", ["1", "0", "ENTER", "2", "÷"], 5.0),
            ("Square Root", ["1", "6", "√x"], 4.0),
            ("Natural Log", ["2", "LN"], log(2)),
            ("Reciprocal", ["4", "1/x"], 0.25),
            ("Sign Toggle", ["5", "+/-"], -5.0),
            ("Exponent (e^x)", ["1", "e^x"], exp(1)),
            ("Base 10 Exponent", ["2", "10^x"], 100.0),
            ("Power (y^x)", ["2", "ENTER", "3", "y^x"], 8.0),
            ("Swap x<>y", ["1", "ENTER", "2", "ENTER", "3", "x<>y"], 2.0),
            ("Roll Down", ["1", "ENTER", "2", "ENTER", "3", "ENTER", "4", "R↓"], 3.0),
            ("Stat Addition", ["1", "0", "ENTER", "2", "0", "Σ+"], 1.0)
        ]

        for tc in testCases {
            engine = CalculatorEngine()
            
            for key in tc.keys {
                if let d = Int(key) {
                    engine.digit(d)
                } else if key == "." {
                    engine.decimal()
                } else {
                    engine.executeMath(key)
                }
            }
            engine.commitInput()
            
            let actual = engine.stack[0].real
            let delta = abs(tc.expected - actual)
            let relDelta = tc.expected != 0 ? delta / abs(tc.expected) : delta
            
            XCTAssertTrue((delta <= 0.001 || relDelta <= 0.0001) && !actual.isNaN, "Test \(tc.name) failed! Expected \(tc.expected), got \(actual)")
        }
    }
}
