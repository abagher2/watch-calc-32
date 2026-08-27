import XCTest
@testable import RPNCore

final class TestExtraction: XCTestCase {
    func testExtract() {
        let program1 = CalculatorEngine.Program(label: "N", steps: ["RCL X", "𝑥²"].compactMap { Instruction(fromString: $0) })
        let vars1 = program1.extractVariables()
        XCTAssertEqual(vars1, ["X"], "vars1 should be X but is \(vars1)")
        
        let program2 = CalculatorEngine.Program(label: "N", steps: ["X", "𝑥²"].compactMap { Instruction(fromString: $0) })
        let vars2 = program2.extractVariables()
        XCTAssertEqual(vars2, ["X"], "vars2 should be X but is \(vars2)")
    }
}
