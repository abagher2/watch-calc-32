public enum Instruction: Equatable, Hashable {
    case operation(CalculatorOperation)
    case fix(Int)
    case sci(Int)
    case eng(Int)
    case all
    case rcl(String)
    case sto(String)
    case lbl(String)
    case gto(String)
    case xeq(String)
    case solve(String)
    case integrate(String)
    case sf(Int)
    case cf(Int)
    case fs(Int)
    case fc(Int)
    case custom(String)
    
    fileprivate static func parseInt(_ str: Substring) -> Int? {
        var result = 0
        var hasDigits = false
        var isNegative = false
        for c in str.utf8 {
            if c == 45 {
                isNegative = true
            } else if c >= 48 && c <= 57 {
                result = result * 10 + Int(c - 48)
                hasDigits = true
            } else if c == 32 {
                continue
            } else {
                return nil
            }
        }
        return hasDigits ? (isNegative ? -result : result) : nil
    }

    // For string initialization and backward compatibility
    public init?(fromString string: String) {
        if string.hasPrefix("FIX ") {
            if let p = Instruction.parseInt(string.dropFirst(4)) { self = .fix(p); return }
        }
        if string.hasPrefix("SCI ") {
            if let p = Instruction.parseInt(string.dropFirst(4)) { self = .sci(p); return }
        }
        if string.hasPrefix("ENG ") {
            if let p = Instruction.parseInt(string.dropFirst(4)) { self = .eng(p); return }
        }
        if string == "ALL" {
            self = .all; return
        }
        if string.hasPrefix("RCL ") && string.count >= 5 {
            self = .rcl(String(string.dropFirst(4))); return
        }
        if string.hasPrefix("STO ") && string.count >= 5 {
            self = .sto(String(string.dropFirst(4))); return
        }
        if string.hasPrefix("LBL ") {
            self = .lbl(String(string.dropFirst(4))); return
        }
        if string.hasPrefix("GTO ") {
            self = .gto(String(string.dropFirst(4))); return
        }
        if string.hasPrefix("XEQ ") {
            self = .xeq(String(string.dropFirst(4))); return
        }
        if string.hasPrefix("SF ") {
            if let p = Instruction.parseInt(string.dropFirst(3)) { self = .sf(p); return }
        }
        if string.hasPrefix("CF ") {
            if let p = Instruction.parseInt(string.dropFirst(3)) { self = .cf(p); return }
        }
        if string.hasPrefix("FS? ") {
            if let p = Instruction.parseInt(string.dropFirst(4)) { self = .fs(p); return }
        }
        if string.hasPrefix("FC? ") {
            if let p = Instruction.parseInt(string.dropFirst(4)) { self = .fc(p); return }
        }
        
        // Match operation by stringValue
        if let op = CalculatorOperation.allCases.first(where: { $0.stringValue == string }) {
            self = .operation(op)
            return
        }
        
        // Map other math constants safely
        if string.count == 1 {
            if let char = string.first, char >= "0" && char <= "9" {
                if let ascii = char.asciiValue {
                    let d = Int(ascii - 48)
                    if let op = CalculatorOperation(rawValue: CalculatorOperation.digit0.rawValue + d) {
                        self = .operation(op)
                        return
                    }
                }
            }
        }
        
        // Fallback for untranslated actions
        self = .custom(string)
    }
    
    public var stringValue: String {
        switch self {
        case .operation(let op): return op.stringValue
        case .fix(let p): return "FIX \(p)"
        case .sci(let p): return "SCI \(p)"
        case .eng(let p): return "ENG \(p)"
        case .all: return "ALL"
        case .rcl(let v): return "RCL \(v)"
        case .sto(let v): return "STO \(v)"
        case .lbl(let v): return "LBL \(v)"
        case .gto(let v): return "GTO \(v)"
        case .xeq(let v): return "XEQ \(v)"
        case .solve(let v): return "SOLVE \(v)"
        case .integrate(let v): return "∫ \(v)"
        case .sf(let p): return "SF \(p)"
        case .cf(let p): return "CF \(p)"
        case .fs(let p): return "FS? \(p)"
        case .fc(let p): return "FC? \(p)"
        case .custom(let str): return str
        }
    }
}
