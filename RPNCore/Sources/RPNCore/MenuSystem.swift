public struct MenuItem: Equatable {
    public let label: String // Displayed on the soft key or menu picker
    public let action: String // The string sent to the engine
    public let requiresDigit: Bool // E.g., FIX requires a trailing digit
    public let symbol: String? // For CONST searching
    public let description: String? // For CONST searching
    
    public init(label: String, action: String? = nil, requiresDigit: Bool = false, symbol: String? = nil, description: String? = nil) {
        self.label = label
        self.action = action ?? label
        self.requiresDigit = requiresDigit
        self.symbol = symbol
        self.description = description
    }
}

public enum CalculatorMenu: CaseIterable, RawRepresentable {
    case disp
    case modes
    case base
    case const
    case flags
    case clear
    case parts
    case prob
    case sums
    case stat
    case eqn
    case mem
    case testXY
    case testX0
    case statMean
    case statStdDev
    case lr
    
    public typealias RawValue = String
    
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
        else if rawValue == "EQN" { self = .eqn }
        else if rawValue == "MEM" { self = .mem }
        else if rawValue == "x?y" { self = .testXY }
        else if rawValue == "x?0" { self = .testX0 }
        else if rawValue == "x̄,ȳ" { self = .statMean }
        else if rawValue == "s,σ" { self = .statStdDev }
        else if rawValue == "L.R." { self = .lr }
        else { return nil }
    }
    
    public var rawValue: String {
        if self == .disp { return "DISP" }
        if self == .modes { return "MODES" }
        if self == .base { return "BASE" }
        if self == .const { return "CONST" }
        if self == .flags { return "FLAGS" }
        if self == .clear { return "CLEAR" }
        if self == .parts { return "PARTS" }
        if self == .prob { return "PROB" }
        if self == .sums { return "SUMS" }
        if self == .stat { return "STAT" }
        if self == .eqn { return "EQN" }
        if self == .mem { return "MEM" }
        if self == .testXY { return "x?y" }
        if self == .testX0 { return "x?0" }
        if self == .statMean { return "x̄,ȳ" }
        if self == .statStdDev { return "s,σ" }
        if self == .lr { return "L.R." }
        return ""
    }
    
    public var items: [MenuItem] {
        switch self {
        case .modes: return [
            MenuItem(label: "DEG"), MenuItem(label: "RAD"), MenuItem(label: "GRAD")
        ]
        case .disp: return [
            MenuItem(label: "FIX", requiresDigit: true),
            MenuItem(label: "SCI", requiresDigit: true),
            MenuItem(label: "ENG", requiresDigit: true),
            MenuItem(label: "ALL")
        ]
        case .base: return [
            MenuItem(label: "HEX"), MenuItem(label: "DEC"), MenuItem(label: "OCT"), MenuItem(label: "BIN")
        ]
        case .const: return [
            MenuItem(label: "π", action: "π", symbol: "π", description: "Pi"),
            MenuItem(label: "e", action: "e", symbol: "e", description: "Euler's number"),
            MenuItem(label: "h", action: "h", symbol: "h", description: "Planck's constant"),
            MenuItem(label: "c", action: "c", symbol: "c", description: "Speed of light"),
            MenuItem(label: "G", action: "G", symbol: "G", description: "Gravitational constant"),
            MenuItem(label: "Na", action: "Na", symbol: "Na", description: "Avogadro's number"),
            MenuItem(label: "R", action: "R", symbol: "R", description: "Gas constant"),
            MenuItem(label: "k", action: "k", symbol: "k", description: "Boltzmann constant")
            // Can add all 40+ constants later
        ]
        case .flags: return [
            MenuItem(label: "SF", requiresDigit: true),
            MenuItem(label: "CF", requiresDigit: true),
            MenuItem(label: "FS?", requiresDigit: true),
            MenuItem(label: "FC?", requiresDigit: true),
            MenuItem(label: "4-LVL", action: "STK4"),
            MenuItem(label: "8-LVL", action: "STK8"),
            MenuItem(label: "INF", action: "STKINF")
        ]
        case .clear: return [
            MenuItem(label: "Σ", action: "CLΣ"), MenuItem(label: "PRGM", action: "CLPRGM"),
            MenuItem(label: "REGS", action: "CLREGS"), MenuItem(label: "ALL", action: "CLALL")
        ]
        case .parts: return [
            MenuItem(label: "INT", action: "INTG"), MenuItem(label: "FRAC"), MenuItem(label: "ABS"), MenuItem(label: "SGN")
        ]
        case .prob: return [
            MenuItem(label: "nPr"), MenuItem(label: "nCr"), MenuItem(label: "!", action: "x!"), MenuItem(label: "RAND")
        ]
        case .sums: return [
            MenuItem(label: "Σx"), MenuItem(label: "Σy"), MenuItem(label: "Σx²"), MenuItem(label: "Σy²"), MenuItem(label: "Σxy"), MenuItem(label: "n")
        ]
        case .stat: return [
            MenuItem(label: "x̄"), MenuItem(label: "ȳ"), MenuItem(label: "s"), MenuItem(label: "σ"), MenuItem(label: "L.R."), MenuItem(label: "ŷ")
        ]
        case .mem: return [
            MenuItem(label: "VARS"), MenuItem(label: "PRGM"), MenuItem(label: "REGS")
        ]
        case .testXY: return [
            MenuItem(label: "x=y"), MenuItem(label: "x≠y"), MenuItem(label: "x>y"), MenuItem(label: "x<y"), MenuItem(label: "x≥y"), MenuItem(label: "x≤y")
        ]
        case .statMean: return [
            MenuItem(label: "x̄", action: "x-bar"), MenuItem(label: "ȳ", action: "y-bar"), MenuItem(label: "x̄w", action: "xw")
        ]
        case .statStdDev: return [
            MenuItem(label: "sx", action: "s"), MenuItem(label: "sy"), MenuItem(label: "σx", action: "σ"), MenuItem(label: "σy", action: "σy")
        ]
        case .lr: return [
            MenuItem(label: "ŷ", action: "ŷ,r"), MenuItem(label: "x̂", action: "x̂"), MenuItem(label: "r", action: "ŷ,r"), MenuItem(label: "m"), MenuItem(label: "b")
        ]
        case .testX0: return [
            MenuItem(label: "x=0"), MenuItem(label: "x≠0"), MenuItem(label: "x>0"), MenuItem(label: "x<0"), MenuItem(label: "x≥0"), MenuItem(label: "x≤0")
        ]
        default: return []
        }
    }
}

public class MenuSystem {
    public static func filter(menu: CalculatorMenu, query: String) -> [MenuItem] {
        let q = query.lowercased()
        if q.isEmpty { return menu.items }
        
        return menu.items.filter { item in
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
