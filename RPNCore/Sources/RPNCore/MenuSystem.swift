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
        else { return nil }
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
            MenuItem(label: "CLx"),
            MenuItem(label: "CLΣ", action: "CLΣ"),
            MenuItem(label: "CLVARS"),
            MenuItem(label: "CLREGS"),
            MenuItem(label: "CLSTK"),
            MenuItem(label: "CLPRGM"),
            MenuItem(label: "CLALL")
        ]
        case .parts: return [
            MenuItem(label: "INT", action: "INTG"), MenuItem(label: "FRAC"), MenuItem(label: "ABS"), MenuItem(label: "SGN")
        ]
        case .prob: return [
            MenuItem(label: "Cn,r", action: "nCr"),
            MenuItem(label: "Pn,r", action: "nPr"),
            MenuItem(label: "n!",   action: "𝑥!"),
            MenuItem(label: "RAND")
        ]
        case .sums: return [
            MenuItem(label: "Σx"), MenuItem(label: "Σy"), MenuItem(label: "Σx²"), MenuItem(label: "Σy²"), MenuItem(label: "Σxy"), MenuItem(label: "n")
        ]
        /// .stat is the top-level entry point for the statistics sub-menu group (triggered by SD/YELLOW+Σ+).
        /// On iOS/watch it shows the four statistical sub-menus as navigation items.
        /// On firmware, the SD key triggers .statMean directly (LFU-row navigation).
        case .stat: return [
            MenuItem(label: "𝑥̄,ȳ",  action: "STATMEAN"),
            MenuItem(label: "s,σ",  action: "STATSTDDEV"),
            MenuItem(label: "L.R.", action: "STATLR"),
            MenuItem(label: "SUMS", action: "STATSUMS")
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
