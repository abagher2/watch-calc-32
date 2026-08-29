

public struct SharedCalculatorStep {
    public let op: String
    public let expectedX: String?
    
    public init(_ op: String, expectedX: String? = nil) {
        self.op = op
        self.expectedX = expectedX
    }
}

public struct SharedCalculatorTestCase {
    public let name: String
    public let steps: [SharedCalculatorStep]
    
    public init(name: String, steps: [SharedCalculatorStep]) {
        self.name = name
        self.steps = steps
    }
}

public struct SharedMathTestCases {
    public static let cases: [SharedCalculatorTestCase] = [

        // Fraction Entry Test
        SharedCalculatorTestCase(
            name: "FractionEntry",
            steps: [
                SharedCalculatorStep("1"),
                SharedCalculatorStep("."),
                SharedCalculatorStep("2"),
                SharedCalculatorStep("."),
                SharedCalculatorStep("3", expectedX: "1 2/3"),
                SharedCalculatorStep("ENTER", expectedX: "1 2/3")
            ]
        ),

        // 1. Basic Math UI (42 ENTER 5 x = 210)
        SharedCalculatorTestCase(
            name: "BasicMathUI",
            steps: [
                SharedCalculatorStep("4"),
                SharedCalculatorStep("2"),
                SharedCalculatorStep("ENTER"),
                SharedCalculatorStep("5"),
                SharedCalculatorStep("×", expectedX: "210")
            ]
        ),
        
        // 2. Calculation Efficiency (42 ENTER 5 x 5 + 42 + = 257)
        SharedCalculatorTestCase(
            name: "CalculationEfficiency",
            steps: [
                SharedCalculatorStep("4"),
                SharedCalculatorStep("2"),
                SharedCalculatorStep("ENTER"),
                SharedCalculatorStep("5"),
                SharedCalculatorStep("×"),
                SharedCalculatorStep("5"),
                SharedCalculatorStep("+"),
                SharedCalculatorStep("4"),
                SharedCalculatorStep("2"),
                SharedCalculatorStep("+", expectedX: "257")
            ]
        ),
        
        // 3. STO & RCL (42 ENTER STO A, Backspace/Clear, RCL A = 42)
        SharedCalculatorTestCase(
            name: "StoRcl",
            steps: [
                SharedCalculatorStep("4"),
                SharedCalculatorStep("2"),
                SharedCalculatorStep("ENTER"),
                SharedCalculatorStep("STO"),
                SharedCalculatorStep("A"),
                SharedCalculatorStep("<-"), // Clear the display
                SharedCalculatorStep("RCL"),
                SharedCalculatorStep("A", expectedX: "42")
            ]
        ),
        
        // 4. Modulo and Remainder (10 ENTER 3 MOD = 1, 10 ENTER 3 INT÷ = 3, swap = 1)
        SharedCalculatorTestCase(
            name: "ModuloAndRemainder",
            steps: [
                // INT÷ (÷R) gives quotient in X, remainder in Y                
                // Part B: INT÷
                SharedCalculatorStep("1"),
                SharedCalculatorStep("0"),
                SharedCalculatorStep("ENTER"),
                SharedCalculatorStep("3"),
                SharedCalculatorStep("SHIFT_BLUE"),
                SharedCalculatorStep("E", expectedX: "3"), // INT÷ is blue E
                SharedCalculatorStep("𝑥≷𝑦", expectedX: "1") // swap to see Y (remainder)
            ]
        ),
        
        // 5. Mi to Km (10 mi -> km = 16.0934)
        SharedCalculatorTestCase(
            name: "MiToKm",
            steps: [
                SharedCalculatorStep("1"),
                SharedCalculatorStep("0"),
                SharedCalculatorStep("SHIFT_YELLOW"),
                SharedCalculatorStep("9", expectedX: "16.0934") // yellow 9 is ->km
            ]
        ),
        
        // 6. All 32S II Math Operations
        SharedCalculatorTestCase(
            name: "All32SIIMathOperations",
            steps: [
                // 1. Error correction: INVALID DATA
                SharedCalculatorStep("1"),
                SharedCalculatorStep("+/-"),
                SharedCalculatorStep("√𝑥", expectedX: "INVALID DATA"),

                SharedCalculatorStep("<-"),
                
                // 2. Division by zero
                SharedCalculatorStep("5"),
                SharedCalculatorStep("ENTER"),
                SharedCalculatorStep("0"),
                SharedCalculatorStep("÷", expectedX: "DIVIDE BY 0"),
                SharedCalculatorStep("<-"),
                
                // 3. Test Factorial of non-integer
                SharedCalculatorStep("2"),
                SharedCalculatorStep("."),
                SharedCalculatorStep("5"),
                SharedCalculatorStep("ENTER"),
                SharedCalculatorStep("SHIFT_YELLOW"),
                SharedCalculatorStep("1/𝑥", expectedX: "INVALID DATA"), // yellow 1/x is x!
                SharedCalculatorStep("<-"),
                
                // 4. Valid Factorial
                SharedCalculatorStep("5"),
                SharedCalculatorStep("SHIFT_YELLOW"),
                SharedCalculatorStep("1/𝑥", expectedX: "120"),
                SharedCalculatorStep("<-"),
                
                // 5. Domain error on ASIN
                SharedCalculatorStep("1"),
                SharedCalculatorStep("0"),
                SharedCalculatorStep("SHIFT_YELLOW"),
                SharedCalculatorStep("SIN", expectedX: "INVALID DATA"), // yellow SIN is ASIN
                SharedCalculatorStep("<-"),
                
                // 6. Test LN Error (<= 0)
                SharedCalculatorStep("1"),
                SharedCalculatorStep("0"),
                SharedCalculatorStep("ENTER"),
                SharedCalculatorStep("+/-"),
                SharedCalculatorStep("LN", expectedX: "INVALID DATA"),
                SharedCalculatorStep("<-"),
                
                // 7. Parts Menu (IP)
                SharedCalculatorStep("1"),
                SharedCalculatorStep("0"),
                SharedCalculatorStep("."),
                SharedCalculatorStep("3"),
                SharedCalculatorStep("SHIFT_BLUE"),
                SharedCalculatorStep("√𝑥"), // blue √x is PARTS menu
                SharedCalculatorStep("LFU_0", expectedX: "10"),
                SharedCalculatorStep("<-"),
                
                // 8. Parts Menu (FP)
                SharedCalculatorStep("1"),
                SharedCalculatorStep("0"),
                SharedCalculatorStep("."),
                SharedCalculatorStep("3"),
                SharedCalculatorStep("SHIFT_BLUE"),
                SharedCalculatorStep("√𝑥"), // blue √x is PARTS menu
                SharedCalculatorStep("LFU_1", expectedX: "0.3")
            ]
        )
    ]
}
