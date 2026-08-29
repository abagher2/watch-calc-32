public struct MenuItem: Equatable {
    public let label: String // Displayed on the soft key or menu picker
    public let action: String // The string sent to the engine
    public let requiresDigit: Bool // E.g., FIX requires a trailing digit
    public let symbol: String? // For CONST searching
    public let description: String? // For CONST searching
    #if !hasFeature(Embedded)
    public let isBoolean: Bool
    public let isSoftwareOnly: Bool
    public let isFirmwareOnly: Bool
    #endif
    
    #if !hasFeature(Embedded)
    public init(label: String, action: String? = nil, requiresDigit: Bool = false, symbol: String? = nil, description: String? = nil, isBoolean: Bool = false, isSoftwareOnly: Bool = false, isFirmwareOnly: Bool = false) {
        self.label = label
        self.action = action ?? label
        self.requiresDigit = requiresDigit
        self.symbol = symbol
        self.description = description
        self.isBoolean = isBoolean
        self.isSoftwareOnly = isSoftwareOnly
        self.isFirmwareOnly = isFirmwareOnly
    }
    #else
    public init(label: String, action: String? = nil, requiresDigit: Bool = false, symbol: String? = nil, description: String? = nil) {
        self.label = label
        self.action = action ?? label
        self.requiresDigit = requiresDigit
        self.symbol = symbol
        self.description = description
    }
    #endif
}

public enum CalculatorMenu: String, CaseIterable, Identifiable {
    public var id: String { rawValue }
    case disp = "DISP"
    case modes = "MODES"
    case base = "BASE"
    case const = "CONST"
    case flags = "FLAGS"
    case clear = "CLEAR"
    case parts = "PARTS"
    case prob = "PROB"
    case sums = "SUMS"
    case stat = "STAT"
    case mem = "MEM"
    case testXY = "𝑥?𝑦"
    case testX0 = "𝑥?0"
    case statMean = "𝑥̄,𝑦̄"
    case statStdDev = "s,σ"
    case lr = "L.R."
    case stack = "STACK"
    case eqn = "EQN"
    
    public init?(rawValue: String) {
        if rawValue == "DISP" { self = .disp }
        else if rawValue == "MODES" { self = .modes }
        else if rawValue == "BASE" { self = .base }
        else if rawValue == "CONST" { self = .const }
        else if rawValue == "FLAGS" { self = .flags }
        else if rawValue == "CLEAR" { self = .clear }
        else if rawValue == "PARTS" { self = .parts }
        else if rawValue == "PROB" { self = .prob }
        else if rawValue == "SUMS" { self = .sums }
        else if rawValue == "STAT" { self = .stat }
        else if rawValue == "MEM" { self = .mem }
        else if rawValue == "𝑥?𝑦" { self = .testXY }
        else if rawValue == "𝑥?0" { self = .testX0 }
        else if rawValue == "𝑥̄,𝑦̄" { self = .statMean }
        else if rawValue == "s,σ" { self = .statStdDev }
        else if rawValue == "L.R." { self = .lr }
        else if rawValue == "STACK" { self = .stack }
        else if rawValue == "EQN" { self = .eqn }
        else { return nil }
    }
    
    // Static arrays to prevent re-allocating [MenuItem] on every access.
    public static let modesItems: [MenuItem] = [
        MenuItem(label: "DEG", description: "Degrees (360)"),
        MenuItem(label: "RAD", description: "Radians (2π)"),
        MenuItem(label: "GRAD", description: "Gradians (400)"),
        MenuItem(label: ".", description: "Dot decimal separator"),
        MenuItem(label: ",", description: "Comma decimal separator")
    ]
    public static let dispItems: [MenuItem] = [
        MenuItem(label: "FIX", requiresDigit: true, description: "Fixed decimal places"),
        MenuItem(label: "SCI", requiresDigit: true, description: "Scientific notation"),
        MenuItem(label: "ENG", requiresDigit: true, description: "Engineering notation"),
        MenuItem(label: "SIG", requiresDigit: true, description: "Significant figures"),
        MenuItem(label: "ALL", description: "Show all trailing digits")
    ]
    public static let baseItems: [MenuItem] = [
        MenuItem(label: "HEX", description: "Hexadecimal (Base 16)"),
        MenuItem(label: "DEC", description: "Decimal (Base 10)"),
        MenuItem(label: "OCT", description: "Octal (Base 8)"),
        MenuItem(label: "BIN", description: "Binary (Base 2)")
    ]
    public static let constItems: [MenuItem] = [
        MenuItem(label: "π", action: "π", symbol: "π", description: "Pi"),
        MenuItem(label: "e", action: "e", symbol: "e", description: "Euler's number"),
        MenuItem(label: "h", action: "h", symbol: "h", description: "Planck's constant"),
        MenuItem(label: "c", action: "c", symbol: "c", description: "Speed of light"),
        MenuItem(label: "G", action: "G", symbol: "G", description: "Gravitational constant"),
        MenuItem(label: "Na", action: "Na", symbol: "Na", description: "Avogadro's number"),
        MenuItem(label: "R", action: "R", symbol: "R", description: "Gas constant"),
        MenuItem(label: "k", action: "k", symbol: "k", description: "Boltzmann constant")
    ]
    
        public static var flagsItems: [MenuItem] {
        var items: [MenuItem] = []
        
        items.append(MenuItem(label: "STACK ▸", action: "STACK"))
        #if !hasFeature(Embedded)
        items.append(MenuItem(label: "THEME", action: "THEME"))
        #endif
        
        #if hasFeature(Embedded)
        items.append(MenuItem(label: "SF", requiresDigit: true))
        items.append(MenuItem(label: "CF", requiresDigit: true))
        items.append(MenuItem(label: "FS?", requiresDigit: true))
        items.append(MenuItem(label: "FC?", requiresDigit: true))
        #endif
        
        #if !hasFeature(Embedded)
        items.append(MenuItem(label: "Flag 0", action: "FLAG 0", isBoolean: true, isSoftwareOnly: true))
        items.append(MenuItem(label: "Flag 1", action: "FLAG 1", isBoolean: true, isSoftwareOnly: true))
        items.append(MenuItem(label: "Flag 2", action: "FLAG 2", isBoolean: true, isSoftwareOnly: true))
        items.append(MenuItem(label: "Flag 3", action: "FLAG 3", isBoolean: true, isSoftwareOnly: true))
        items.append(MenuItem(label: "Flag 4", action: "FLAG 4", isBoolean: true, isSoftwareOnly: true))
        items.append(MenuItem(label: "Flag 5", action: "FLAG 5", isBoolean: true, isSoftwareOnly: true))
        items.append(MenuItem(label: "Flag 6", action: "FLAG 6", isBoolean: true, isSoftwareOnly: true))
        items.append(MenuItem(label: "Flag 7", action: "FLAG 7", description: "Fractions Mode Enabled", isBoolean: true, isSoftwareOnly: true))
        items.append(MenuItem(label: "Flag 8", action: "FLAG 8", description: "Reduced fraction closest to /c factor", isBoolean: true, isSoftwareOnly: true))
        items.append(MenuItem(label: "Flag 9", action: "FLAG 9", description: "Force unreduced /c denominator factor", isBoolean: true, isSoftwareOnly: true))
        items.append(MenuItem(label: "Flag 10", action: "FLAG 10", isBoolean: true, isSoftwareOnly: true))
        items.append(MenuItem(label: "Flag 11", action: "FLAG 11", isBoolean: true, isSoftwareOnly: true))
        #endif
        
        return items
    }

    public static let stackItems: [MenuItem] = [
        MenuItem(label: "4-LVL", action: "STK4", description: "Classic 4-Level XYZT Stack"),
        MenuItem(label: "8-LVL", action: "STK8", description: "Extended 8-Level Stack"),
        MenuItem(label: "INF", action: "STKINF", description: "Infinite Stack Size")
    ]
    public static let clearItems: [MenuItem] = [
        MenuItem(label: "x", action: "CLx", description: "Clear X register"),
        MenuItem(label: "VARS", action: "CLVARS", description: "Clear all variables"),
        MenuItem(label: "ALL", action: "CLALL", description: "Clear variables and programs"),
        MenuItem(label: "Σ", action: "CLΣ", description: "Clear sum/statistical registers"),
        MenuItem(label: "REGS", action: "CLREGS", description: "Clear storage registers"),
        MenuItem(label: "STK", action: "CLSTK", description: "Clear stack"),
        MenuItem(label: "PGM", action: "CLPRGM", description: "Clear programs")
    ]
    public static let partsItems: [MenuItem] = [
        MenuItem(label: "INT", action: "INTG", description: "Integer part"),
        MenuItem(label: "FRAC", description: "Fractional part"),
        MenuItem(label: "ABS", description: "Absolute value"),
        MenuItem(label: "SGN", description: "Sign (-1, 0, 1)")
    ]
    public static let probItems: [MenuItem] = [
        MenuItem(label: "Cn,r", action: "nCr", description: "Combinations"),
        MenuItem(label: "Pn,r", action: "nPr", description: "Permutations"),
        MenuItem(label: "n!",   action: "𝑥!", description: "Factorial / Gamma"),
        MenuItem(label: "RAND", description: "Random number (0≤x<1)"),
        MenuItem(label: "SD", description: "Seed random number")
    ]
    public static let sumsItems: [MenuItem] = [
        MenuItem(label: "Σx", description: "Sum of X values"),
        MenuItem(label: "Σy", description: "Sum of Y values"),
        MenuItem(label: "Σx²", description: "Sum of X squared"),
        MenuItem(label: "Σy²", description: "Sum of Y squared"),
        MenuItem(label: "Σxy", description: "Sum of X * Y"),
        MenuItem(label: "n", description: "Number of data points")
    ]
    public static let statItems: [MenuItem] = [
        MenuItem(label: "𝑥̄,ȳ",  action: "STATMEAN", description: "Means"),
        MenuItem(label: "s,σ",  action: "STATSTDDEV", description: "Standard Deviations"),
        MenuItem(label: "L.R.", action: "STATLR", description: "Linear Regression"),
        MenuItem(label: "SUMS", action: "STATSUMS", description: "Statistical Sums")
    ]
    public static let memItems: [MenuItem] = [
        MenuItem(label: "VARS", description: "Used variables memory"),
        MenuItem(label: "PRGM", description: "Programs memory"),
        MenuItem(label: "REGS", description: "Registers memory")
    ]
    public static let testXYItems: [MenuItem] = [
        MenuItem(label: "x=y", description: "Test if x equals y"),
        MenuItem(label: "x≠y", description: "Test if x not equals y"),
        MenuItem(label: "x>y", description: "Test if x greater than y"),
        MenuItem(label: "x<y", description: "Test if x less than y"),
        MenuItem(label: "x≥y", description: "Test if x greater/equal to y"),
        MenuItem(label: "x≤y", description: "Test if x less/equal to y")
    ]
    public static let statMeanItems: [MenuItem] = [
        MenuItem(label: "x̄", action: "x-bar", description: "Mean of X values"),
        MenuItem(label: "ȳ", action: "y-bar", description: "Mean of Y values"),
        MenuItem(label: "x̄w", action: "xw", description: "Weighted mean of X")
    ]
    public static let statStdDevItems: [MenuItem] = [
        MenuItem(label: "sx", action: "s", description: "Sample std dev of X (n-1)"),
        MenuItem(label: "sy", description: "Sample std dev of Y (n-1)"),
        MenuItem(label: "σx", action: "σ", description: "Population std dev of X (n)"),
        MenuItem(label: "σy", action: "σy", description: "Population std dev of Y (n)")
    ]
    public static let lrItems: [MenuItem] = [
        MenuItem(label: "ŷ", action: "ŷ,r", description: "Estimated Y / Correlation"),
        MenuItem(label: "x̂", action: "x̂", description: "Estimated X"),
        MenuItem(label: "r", action: "ŷ,r", description: "Correlation coefficient"),
        MenuItem(label: "m", description: "Inclination (slope)"),
        MenuItem(label: "b", description: "Y-intercept")
    ]
    public static let testX0Items: [MenuItem] = [
        MenuItem(label: "x=0", description: "Test if x equals 0"),
        MenuItem(label: "x≠0", description: "Test if x not equals 0"),
        MenuItem(label: "x>0", description: "Test if x greater than 0"),
        MenuItem(label: "x<0", description: "Test if x less than 0"),
        MenuItem(label: "x≥0", description: "Test if x greater/equal to 0"),
        MenuItem(label: "x≤0", description: "Test if x less/equal to 0")
    ]

    public func getItems(engine: CalculatorEngine?) -> [MenuItem] {
        switch self {
        case .modes: return CalculatorMenu.modesItems
        case .disp: return CalculatorMenu.dispItems
        case .base: return CalculatorMenu.baseItems
        case .const: return CalculatorMenu.constItems
        case .flags: return CalculatorMenu.flagsItems
        case .stack: return CalculatorMenu.stackItems
        case .clear: return CalculatorMenu.clearItems
        case .parts: return CalculatorMenu.partsItems
        case .prob: return CalculatorMenu.probItems
        case .sums: return CalculatorMenu.sumsItems
        case .stat: return CalculatorMenu.statItems
        case .mem: return CalculatorMenu.memItems
        case .testXY: return CalculatorMenu.testXYItems
        case .statMean: return CalculatorMenu.statMeanItems
        case .statStdDev: return CalculatorMenu.statStdDevItems
        case .lr: return CalculatorMenu.lrItems
        case .testX0: return CalculatorMenu.testX0Items
        case .eqn:
            var eqnItems: [MenuItem] = []
            if engine?.alphaAction != .fnEq {
                eqnItems.append(MenuItem(label: "NEW", action: "EQN_NEW"))
            }
            
            if let engine = engine {
                for prog in engine.programs {
                    let label = prog.label.isEmpty ? "EQN" : prog.label
                    if engine.alphaAction == .fnEq {
                        eqnItems.append(MenuItem(label: label, action: label, description: prog.steps.map { $0.stringValue }.joined(separator: " ")))
                    } else {
                        eqnItems.append(MenuItem(label: label, action: "EQN_EDIT_\(label)", description: prog.steps.map { $0.stringValue }.joined(separator: " ")))
                    }
                }
            }
            return eqnItems
        }
    }

    public var title: String {
        switch self {
        case .disp:        return "Display"
        case .modes:       return "Modes"
        case .base:        return "Base"
        case .clear:       return "Clear"
        case .flags:       return "Flags"
        case .mem:         return "Memory"
        case .parts:       return "Parts"
        case .prob:        return "Probability"
        case .sums:        return "Sums"
        case .stat:        return "Statistics"
        case .statMean:    return "Mean"
        case .statStdDev:  return "Std Dev"
        case .lr:          return "Linear Reg"
        case .testXY:      return "Test x ? y"
        case .testX0:      return "Test x ? 0"
        case .const:       return "Constants"
        case .stack:       return "Stack Size"
        case .eqn:         return "Equations"
        }
    }
}

public class MenuSystem {
    public static func filter(menu: CalculatorMenu, query: String, engine: CalculatorEngine?) -> [MenuItem] {
        let q = query.lowercased()
        if q.isEmpty { return menu.getItems(engine: engine) }
        
        return menu.getItems(engine: engine).filter { item in
            if let sym = item.symbol?.lowercased(), sym.contains(q) { return true }
            if let desc = item.description?.lowercased(), desc.contains(q) { return true }
            return item.label.lowercased().contains(q)
        }
    }
}

#if hasFeature(Embedded)
extension String {
    func contains(_ other: String) -> Bool {
        return false
    }
}
#endif
