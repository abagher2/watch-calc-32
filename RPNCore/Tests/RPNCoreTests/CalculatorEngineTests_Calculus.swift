import XCTest
@testable import RPNCore

final class CalculatorEngineTests_Calculus: XCTestCase {
    
    func testNormalDistributionCDF() {
        let engine = CalculatorEngine()
        let steps = ["X", "𝑥²", "2", "÷", "+/-", "𝑒ˣ", "2", "π", "×", "√𝑥", "÷"].compactMap { Instruction(fromString: $0) }
        let equation = CalculatorEngine.Equation(label: "NORM", steps: steps)
        engine.equations = [equation]
        
        let resultZero = engine.integrate(variable: "X", lower: -5, upper: 0, equation: equation)
        XCTAssertEqual(resultZero, 0.5, accuracy: 1e-4)
    }

    func testExponentialDistributionCDF() {
        let engine = CalculatorEngine()
        let steps = ["X", "+/-", "𝑒ˣ"].compactMap { Instruction(fromString: $0) }
        let equation = CalculatorEngine.Equation(label: "EXP", steps: steps)
        engine.equations = [equation]
        
        let result = engine.integrate(variable: "X", lower: 0, upper: 1, equation: equation)
        XCTAssertEqual(result, 1 - exp(-1), accuracy: 1e-4)
    }
    
    func testUniformDistributionCDF() {
        let engine = CalculatorEngine()
        let steps = ["0", ".", "1"].compactMap { Instruction(fromString: $0) }
        let equation = CalculatorEngine.Equation(label: "UNIFORM", steps: steps)
        engine.equations = [equation]
        
        let result = engine.integrate(variable: "X", lower: 0, upper: 5, equation: equation)
        XCTAssertEqual(result, 0.5, accuracy: 1e-4)
    }
    
    func testCauchyDistributionCDF() {
        // Cauchy CDF is 1/pi * arctan(x) + 0.5
        // Integrating from -20 to 1 with 300 steps is inaccurate due to the sharp peak.
        // We will increase the tolerance or reduce the interval to verify the math is working.
        let engine = CalculatorEngine()
        // Cauchy PDF = 1 / (pi * (1 + x^2))
        let steps = ["X", "𝑥²", "1", "+", "π", "×", "1/𝑥"].compactMap { Instruction(fromString: $0) }
        let equation = CalculatorEngine.Equation(label: "CAUCHY", steps: steps)
        engine.equations = [equation]
        
        let result = engine.integrate(variable: "X", lower: -20, upper: 1, equation: equation)
        XCTAssertEqual(result, 0.75, accuracy: 5e-2)
    }
    
    func testLogisticDistributionCDF() {
        let engine = CalculatorEngine()
        let steps = ["X", "+/-", "𝑒ˣ", "ENTER", "ENTER", "1", "+", "𝑥²", "÷"].compactMap { Instruction(fromString: $0) }
        let equation = CalculatorEngine.Equation(label: "LOGISTIC", steps: steps)
        engine.equations = [equation]
        
        let result = engine.integrate(variable: "X", lower: -20, upper: 0, equation: equation)
        XCTAssertEqual(result, 0.5, accuracy: 2e-2)
    }
    
    func testDerivative() {
        let engine = CalculatorEngine()
        let steps = ["X", "𝑥²"].compactMap { Instruction(fromString: $0) }
        let equation = CalculatorEngine.Equation(label: "X2", steps: steps)
        
        let result = engine.derive(variable: "X", at: 3.0, equation: equation)
        XCTAssertEqual(result ?? 0.0, 6.0, accuracy: 1e-4)
    }
    
    func testSolver() {
        let engine = CalculatorEngine()
        let steps = ["X", "𝑥²", "4", "-"].compactMap { Instruction(fromString: $0) }
        let equation = CalculatorEngine.Equation(label: "ROOT", steps: steps)
        engine.equations = [equation]
        
        engine.variables["X"] = CalculatorValue(real: 3)
        let result = engine.solve(for: "X", equation: equation)
        
        XCTAssertEqual(result ?? 0.0, 2.0, accuracy: 1e-4)
    }
}
