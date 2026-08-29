import Foundation
@testable import RPNCore
public struct SharedCalculatorThoroughTestCases {
    public static var cases: [SharedCalculatorTestCase] = {
        var generated: [SharedCalculatorTestCase] = []
        
        // Helper function for quick math tests
        func addMathTest(name: String, x: Int, y: Int, op: String, expected: Double) {
            var stepObjects: [SharedCalculatorStep] = []
            for char in String(x) { stepObjects.append(SharedCalculatorStep(String(char))) }
            stepObjects.append(SharedCalculatorStep("ENTER"))
            for char in String(y) { stepObjects.append(SharedCalculatorStep(String(char))) }
            stepObjects.append(SharedCalculatorStep(op, expectedX: "\(expected)"))
            generated.append(SharedCalculatorTestCase(name: name, steps: stepObjects))
        }

        // --- 1. BASIC ARITHMETIC (100+ cases generated) ---
        for i in 1...20 {
            for j in 1...5 {
                let x = i * 7
                let y = j * 3
                
                // Add
                addMathTest(name: "Thorough_Add_\(x)_\(y)", x: x, y: y, op: "+", expected: Double(x + y))
                // Sub
                addMathTest(name: "Thorough_Sub_\(x)_\(y)", x: x, y: y, op: "-", expected: Double(x - y))
                // Mul
                addMathTest(name: "Thorough_Mul_\(x)_\(y)", x: x, y: y, op: "×", expected: Double(x * y))
                // Div
                addMathTest(name: "Thorough_Div_\(x * y)_\(y)", x: x * y, y: y, op: "÷", expected: Double(x))
                // Pow
                if j <= 3 {
                    addMathTest(name: "Thorough_Pow_\(x)_\(y)", x: x, y: y, op: "𝑦ˣ", expected: pow(Double(x), Double(y)))
                }
            }
        }

        // --- 2. TRIGONOMETRY (Degrees & Radians) ---
        let anglesDeg = [0, 30, 45, 60, 90, 180, 270, 360]
        for angle in anglesDeg {
            var sinSteps = [SharedCalculatorStep("MODES"), SharedCalculatorStep("LFU_0")]
            for char in String(angle) { sinSteps.append(SharedCalculatorStep(String(char))) }
            sinSteps.append(SharedCalculatorStep("SIN"))
            generated.append(SharedCalculatorTestCase(name: "Thorough_Trig_DEG_SIN_\(angle)", steps: sinSteps))
            
            var cosSteps = [SharedCalculatorStep("MODES"), SharedCalculatorStep("LFU_0")]
            for char in String(angle) { cosSteps.append(SharedCalculatorStep(String(char))) }
            cosSteps.append(SharedCalculatorStep("COS"))
            generated.append(SharedCalculatorTestCase(name: "Thorough_Trig_DEG_COS_\(angle)", steps: cosSteps))
            
            var tanSteps = [SharedCalculatorStep("MODES"), SharedCalculatorStep("LFU_0")]
            for char in String(angle) { tanSteps.append(SharedCalculatorStep(String(char))) }
            tanSteps.append(SharedCalculatorStep("TAN"))
            generated.append(SharedCalculatorTestCase(name: "Thorough_Trig_DEG_TAN_\(angle)", steps: tanSteps))
        }

        // --- 3. EDGE CASES & LARGE NUMBERS ---
        func addMathTestStr(name: String, steps: [String], expected: String) {
            var stepObjects: [SharedCalculatorStep] = []
            for (i, step) in steps.enumerated() {
                if i == steps.count - 1 {
                    stepObjects.append(SharedCalculatorStep(step, expectedX: expected))
                } else {
                    stepObjects.append(SharedCalculatorStep(step))
                }
            }
            generated.append(SharedCalculatorTestCase(name: name, steps: stepObjects))
        }

        addMathTestStr(name: "Edge_DivZero", steps: ["5", "ENTER", "0", "÷"], expected: "DIVIDE BY 0")
        addMathTestStr(name: "Edge_LogZero", steps: ["0", "LN"], expected: "DIVIDE BY 0")
        addMathTestStr(name: "Edge_SqrtNeg", steps: ["1", "+/-", "√𝑥"], expected: "INVALID DATA")
        addMathTestStr(name: "Edge_FactNeg", steps: ["2", "+/-", "𝑥!"], expected: "INVALID DATA")
        addMathTestStr(name: "Edge_FactFrac", steps: ["2", ".", "5", "𝑥!"], expected: "3.3233509704")

        generated.append(SharedCalculatorTestCase(
            name: "Edge_TinyNumber",
            steps: [
                SharedCalculatorStep("1"), SharedCalculatorStep("E"), SharedCalculatorStep("9"), SharedCalculatorStep("9"), SharedCalculatorStep("+/-"),
                SharedCalculatorStep("ENTER", expectedX: "1e-99")
            ]
        ))
        
        generated.append(SharedCalculatorTestCase(
            name: "Edge_LargeNumber",
            steps: [
                SharedCalculatorStep("1"), SharedCalculatorStep("E"), SharedCalculatorStep("9"), SharedCalculatorStep("9"),
                SharedCalculatorStep("ENTER", expectedX: "1e+99")
            ]
        ))

        // Weird variable names
        let weirdVar1 = "VAR_NAME_EXTREMELY_LONG_BUFFER_OVERFLOW_TEST_1234567890"
        generated.append(SharedCalculatorTestCase(
            name: "Edge_WeirdVariable_Long",
            steps: [
                SharedCalculatorStep("4"), SharedCalculatorStep("2"), SharedCalculatorStep("ENTER"), SharedCalculatorStep("STO"), SharedCalculatorStep(weirdVar1),
                SharedCalculatorStep("CLEAR"),
                SharedCalculatorStep("RCL"), SharedCalculatorStep(weirdVar1, expectedX: "42")
            ]
        ))

        let weirdVar2 = "Emoji_∆_ø"
        generated.append(SharedCalculatorTestCase(
            name: "Edge_WeirdVariable_Unicode",
            steps: [
                SharedCalculatorStep("3"), SharedCalculatorStep("."), SharedCalculatorStep("1"), SharedCalculatorStep("4"),
                SharedCalculatorStep("STO"), SharedCalculatorStep(weirdVar2),
                SharedCalculatorStep("CLEAR"),
                SharedCalculatorStep("RCL"), SharedCalculatorStep(weirdVar2, expectedX: "3.14")
            ]
        ))

        // --- 4. CALCULUS & EQUATIONS ---
        // Program 1: X^2 (Evaluate, Plot, Integrate)
        // LBL A
        // RCL X
        // x^2
        // RTN
        let prgmSteps = [
            "PRGM", "LBL", "A", "ENTER",
            "RCL", "X", "ENTER", "𝑥²", "RTN", "PRGM", "CLEAR"
        ]
        
        return generated
    }()
}
