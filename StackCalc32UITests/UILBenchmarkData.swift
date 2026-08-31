import Foundation

struct UILProblem {
    let description: String
    let keys: [String]
}

class LCG {
    var state: UInt32
    init(seed: UInt32) { state = seed }
    func next() -> Double {
        state = (state &* 1664525) &+ 1013904223
        return Double(state) / Double(UInt32.max)
    }
    func nextInt(upTo max: Int) -> Int {
        return Int(next() * Double(max))
    }
}

indirect enum ASTNode {
    case num(Double)
    case unary([String], ASTNode)
    case binary([String], ASTNode, ASTNode)
    
    func toRPN() -> [String] {
        switch self {
        case .num(let v):
            return UILBenchmarkData.keys(for: v)
        case .unary(let opKeys, let node):
            return node.toRPN() + opKeys
        case .binary(let opKeys, let left, let right):
            return left.toRPN() + right.toRPN() + opKeys
        }
    }
}

struct UILBenchmarkData {
    static let problems: [UILProblem] = generateProblems()
    
    static func keys(for number: Double) -> [String] {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 5
        formatter.usesGroupingSeparator = false
        // ensure positive to avoid '-' string parsing issues; handle sign below
        let str = formatter.string(from: NSNumber(value: abs(number))) ?? "0"
        
        var keys = str.compactMap { char -> String? in
            if char == "." { return "op_decimal" }
            if char >= "0" && char <= "9" { return "op_digit\(char)" }
            return nil
        }
        if number < 0 {
            keys.append("op_toggleSign")
        }
        return keys
    }
    
    static func generateProblems() -> [UILProblem] {
        var problems: [UILProblem] = []
        let rng = LCG(seed: 42)
        
        let unaries = [
            ["matrix_√x"], ["matrix_e^x"], ["matrix_LN"], ["matrix_1/x"],
            ["matrix_SIN"], ["matrix_COS"], ["matrix_TAN"],
            ["shift_f", "func_->kg"], ["shift_f", "func_->°C"], ["shift_f", "func_->cm"],
            ["shift_g", "func_->lb"], ["shift_g", "func_->°F"], ["shift_g", "func_->in"]
        ]
        
        let binaries = [
            ["arith_+"], ["arith_-"], ["arith_×"], ["arith_÷"], ["matrix_y^x"]
        ]
        
        // Helper to generate a random AST
        func generateAST(depth: Int) -> ASTNode {
            if depth == 0 {
                // Return a number between 0.1 and 100.0 to avoid domain errors in ASIN/ACOS
                let val = (rng.next() * 0.9 + 0.1)
                return .num(val)
            }
            
            let nodeType = rng.nextInt(upTo: 3)
            if nodeType == 0 {
                return .num(rng.next() * 100.0)
            } else if nodeType == 1 {
                let op = unaries[rng.nextInt(upTo: unaries.count)]
                return .unary(op, generateAST(depth: depth - 1))
            } else {
                let op = binaries[rng.nextInt(upTo: binaries.count)]
                return .binary(op, generateAST(depth: depth - 1), generateAST(depth: depth - 1))
            }
        }
        
        for i in 1...100 {
            // Generate an AST of depth 3 (ensures complex, nested structures)
            let ast = generateAST(depth: 3)
            var seq: [String] = []
            
            // Randomly insert format or angle modes at the start
            if rng.nextInt(upTo: 2) == 0 {
                seq.append("shift_f")
                seq.append("func_MODES")
                seq.append("Radians (RAD)")
            } else {
                seq.append("shift_f")
                seq.append("func_MODES")
                seq.append("Degrees (DEG)")
            }
            
            seq.append(contentsOf: ast.toRPN())
            
            problems.append(UILProblem(description: "Generated \(i)", keys: seq))
        }
        
        return problems
    }
}
