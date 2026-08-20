import XCTest
@testable import RPNCore

final class ClearStatTests: XCTestCase {
    func testClearStatParity() throws {
        let engine = CalculatorEngine()
        
        print("--- SETUP ROLL DOWN ---")
        engine.executeMath("1")
        engine.executeMath("ENTER")
        engine.executeMath("2")
        engine.executeMath("ENTER")
        engine.executeMath("3")
        engine.executeMath("ENTER")
        engine.executeMath("4")
        engine.executeMath("R↓")
        
        print("X: \(engine.stack[0].real)")
        
        print("--- CLEAR X ---")
        engine.executeMath("C") // First C
        engine.executeMath("C") // Second C
        print("X: \(engine.stack[0].real)")
        print("Y: \(engine.stack[1].real)")
        
        print("--- CLEAR STAT ---")
        engine.executeMath("CLΣ") // Directly test the action
        print("X: \(engine.stack[0].real)")
        print("Y: \(engine.stack[1].real)")
    }
}
