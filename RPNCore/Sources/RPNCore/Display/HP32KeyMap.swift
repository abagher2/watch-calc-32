#if canImport(Foundation)
import Foundation
#endif
#if canImport(RPNCore)
import RPNCore
#endif

public struct HP32Key: Identifiable, Equatable {
#if canImport(Foundation)
    public let id = UUID()
#else
    public var id: String { label + (primaryAction?.stringValue ?? "") }
#endif
    public let row: Int
    public let col: Int
    public let rowSpan: Int
    public let colSpan: Int
    public let label: String
    public let yellowLabel: String
    public let blueLabel: String
    public let alphaLabel: String
    public let yellowAction: CalculatorOperation?
    public let blueAction: CalculatorOperation?
    public let primaryAction: CalculatorOperation?
    
    public init(row: Int, col: Int, rowSpan: Int = 1, colSpan: Int = 1, label: String, yellowLabel: String, blueLabel: String, alphaLabel: String, yellowAction: CalculatorOperation?, blueAction: CalculatorOperation?, primaryAction: CalculatorOperation?) {
        self.row = row
        self.col = col
        self.rowSpan = rowSpan
        self.colSpan = colSpan
        self.label = label
        self.yellowLabel = yellowLabel
        self.blueLabel = blueLabel
        self.alphaLabel = alphaLabel
        self.yellowAction = yellowAction
        self.blueAction = blueAction
        self.primaryAction = primaryAction
    }
    
    public static func == (lhs: HP32Key, rhs: HP32Key) -> Bool {
        lhs.id == rhs.id
    }
}

public struct HP32KeyMap {
    #if hasFeature(Embedded)
    static let offLabel = "OFF"
    #else
    static let offLabel = ""
    #endif
    
        private static let standardGrid_chunk0: [HP32Key] = [
        // Top Section (Functions)
        // Row 0 (6 cols) - LFU Pad (Dynamic)
        HP32Key(row: 0, col: 0, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu0),
        HP32Key(row: 0, col: 1, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu1),
        HP32Key(row: 0, col: 2, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu2),
        HP32Key(row: 0, col: 3, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu3),
        HP32Key(row: 0, col: 4, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu4),
        HP32Key(row: 0, col: 5, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu5),
        
        // Row 1 (6 cols) - Math Row,
        HP32Key(row: 1, col: 0, rowSpan: 1, label: "√𝑥", yellowLabel: "𝑥²", blueLabel: "PARTS", alphaLabel: "A", yellowAction: .square, blueAction: .parts, primaryAction: .sqrt),
        HP32Key(row: 1, col: 1, rowSpan: 1, label: "𝑒ˣ", yellowLabel: "10ˣ", blueLabel: "PROB", alphaLabel: "B", yellowAction: .exp10, blueAction: .prob, primaryAction: .exp),
        HP32Key(row: 1, col: 2, rowSpan: 1, label: "LN", yellowLabel: "LOG", blueLabel: "L.R.", alphaLabel: "C", yellowAction: .log, blueAction: .lr, primaryAction: .ln)
    ]
    private static let standardGrid_chunk1: [HP32Key] = [
        HP32Key(row: 1, col: 3, rowSpan: 1, label: "𝑦ˣ", yellowLabel: "ˣ√𝑦", blueLabel: "𝑥̄,𝑦̄", alphaLabel: "D", yellowAction: .xRootY, blueAction: .statMean, primaryAction: .power),
        HP32Key(row: 1, col: 4, rowSpan: 1, label: "¹/𝑥", yellowLabel: "𝑥!", blueLabel: "s,σ", alphaLabel: "E", yellowAction: .factorial, blueAction: .statStdDev, primaryAction: .reciprocal),
        HP32Key(row: 1, col: 5, rowSpan: 1, label: "Σ+", yellowLabel: "Σ-", blueLabel: "SUMS", alphaLabel: "F", yellowAction: .statSub, blueAction: .sums, primaryAction: .statAdd),
        
        // Row 2 (6 cols),
        HP32Key(row: 2, col: 0, rowSpan: 1, label: "STO", yellowLabel: "CMPLX", blueLabel: "EQN", alphaLabel: "G", yellowAction: .cmplx, blueAction: .eqn, primaryAction: .sto),
        HP32Key(row: 2, col: 1, rowSpan: 1, label: "RCL", yellowLabel: "RND", blueLabel: "SCRL", alphaLabel: "H", yellowAction: .rnd, blueAction: .scrl, primaryAction: .rcl),
        HP32Key(row: 2, col: 2, rowSpan: 1, label: "R↓", yellowLabel: "HYP", blueLabel: "R↑", alphaLabel: "I", yellowAction: .hyp, blueAction: .rollUp, primaryAction: .rollDown),
        HP32Key(row: 2, col: 3, rowSpan: 1, label: "SIN", yellowLabel: "ASIN", blueLabel: "π", alphaLabel: "J", yellowAction: .asin, blueAction: .pi, primaryAction: .sin),
        HP32Key(row: 2, col: 4, rowSpan: 1, label: "COS", yellowLabel: "ACOS", blueLabel: "%", alphaLabel: "K", yellowAction: .acos, blueAction: .percent, primaryAction: .cos),
        HP32Key(row: 2, col: 5, rowSpan: 1, label: "TAN", yellowLabel: "ATAN", blueLabel: "%CHG", alphaLabel: "L", yellowAction: .atan, blueAction: .percentChange, primaryAction: .tan),
        
        // Row 3 (5 cols)
        // Note: ENTER spans 2 columns in the UI, but we place it at col 0.,
        HP32Key(row: 3, col: 0, rowSpan: 1, colSpan: 2, label: "ENTER", yellowLabel: "LAST𝑥", blueLabel: "SHOW", alphaLabel: "M", yellowAction: .lastx, blueAction: .show, primaryAction: .enter)
    ]
    private static let standardGrid_chunk2: [HP32Key] = [
        HP32Key(row: 3, col: 2, rowSpan: 1, label: "𝑥≷𝑦", yellowLabel: "MEM", blueLabel: "𝑥≷?", alphaLabel: "N", yellowAction: .mem, blueAction: .swapXYPrompt, primaryAction: .swapXY),
        HP32Key(row: 3, col: 3, rowSpan: 1, label: "+/-", yellowLabel: "MODES", blueLabel: "|x|", alphaLabel: "O", yellowAction: .modes, blueAction: .abs, primaryAction: .toggleSign),
        HP32Key(row: 3, col: 4, rowSpan: 1, label: "E", yellowLabel: "DISP", blueLabel: "÷R", alphaLabel: "P", yellowAction: .disp, blueAction: .intDiv, primaryAction: .e),
        HP32Key(row: 3, col: 5, rowSpan: 1, label: "<-", yellowLabel: "CLEAR", blueLabel: "", alphaLabel: "", yellowAction: .clear, blueAction: nil, primaryAction: .backspace),
        
        // Bottom Section (Numpad)
        // Row 4 (5 cols),
        HP32Key(row: 4, col: 0, rowSpan: 1, label: "XEQ", yellowLabel: "FN=", blueLabel: "", alphaLabel: "", yellowAction: .fnEq, blueAction: nil, primaryAction: .xeq),
        HP32Key(row: 4, col: 1, rowSpan: 1, label: "7", yellowLabel: "↓", blueLabel: "SOLVE", alphaLabel: "Q", yellowAction: .scrollDown, blueAction: .solve, primaryAction: .digit7),
        HP32Key(row: 4, col: 2, rowSpan: 1, label: "8", yellowLabel: "↑", blueLabel: "∫", alphaLabel: "R", yellowAction: .scrollUp, blueAction: .integrate, primaryAction: .digit8),
        HP32Key(row: 4, col: 3, rowSpan: 1, label: "9", yellowLabel: "▸km", blueLabel: "▸mi", alphaLabel: "S", yellowAction: .toKm, blueAction: .toMi, primaryAction: .digit9),
        HP32Key(row: 4, col: 4, rowSpan: 1, label: "÷", yellowLabel: "𝑥?𝑦", blueLabel: "𝑥?0", alphaLabel: "", yellowAction: .testXY, blueAction: .testX0, primaryAction: .divide),
        
        // Row 5 (5 cols),
        HP32Key(row: 5, col: 0, rowSpan: 1, label: "yellow", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .shiftYellow)
    ]
    private static let standardGrid_chunk3: [HP32Key] = [
        HP32Key(row: 5, col: 1, rowSpan: 1, label: "4", yellowLabel: "▸θ,𝑟", blueLabel: "▸𝑦,𝑥", alphaLabel: "T", yellowAction: .toPolar, blueAction: .toRectangular, primaryAction: .digit4),
        HP32Key(row: 5, col: 2, rowSpan: 1, label: "5", yellowLabel: "▸HR", blueLabel: "▸HMS", alphaLabel: "U", yellowAction: .toHr, blueAction: .toHms, primaryAction: .digit5),
        HP32Key(row: 5, col: 3, rowSpan: 1, label: "6", yellowLabel: "▸DEG", blueLabel: "▸RAD", alphaLabel: "V", yellowAction: .toDeg, blueAction: .toRad, primaryAction: .digit6),
        HP32Key(row: 5, col: 4, rowSpan: 1, label: "×", yellowLabel: "BASE", blueLabel: "FLAGS", alphaLabel: "", yellowAction: .base, blueAction: .flags, primaryAction: .multiply),
        
        // Row 6 (5 cols),
        HP32Key(row: 6, col: 0, rowSpan: 1, label: "blue", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .shiftBlue),
        HP32Key(row: 6, col: 1, rowSpan: 1, label: "1", yellowLabel: "▸kg", blueLabel: "▸lb", alphaLabel: "W", yellowAction: .toKg, blueAction: .toLb, primaryAction: .digit1),
        HP32Key(row: 6, col: 2, rowSpan: 1, label: "2", yellowLabel: "▸°C", blueLabel: "▸°F", alphaLabel: "X", yellowAction: .toCelsius, blueAction: .toFahrenheit, primaryAction: .digit2),
        HP32Key(row: 6, col: 3, rowSpan: 1, label: "3", yellowLabel: "▸cm", blueLabel: "▸in", alphaLabel: "Y", yellowAction: .toCm, blueAction: .toIn, primaryAction: .digit3),
        HP32Key(row: 6, col: 4, rowSpan: 1, label: "-", yellowLabel: "▸l", blueLabel: "▸gal", alphaLabel: "", yellowAction: .toLiters, blueAction: .toGal, primaryAction: .subtract),
        
        // Row 7 (5 cols),
        HP32Key(row: 7, col: 0, rowSpan: 1, label: "C", yellowLabel: "", blueLabel: offLabel, alphaLabel: "", yellowAction: nil, blueAction: .off, primaryAction: .c)
    ]
    private static let standardGrid_chunk4: [HP32Key] = [
        HP32Key(row: 7, col: 1, rowSpan: 1, label: "0", yellowLabel: "REGS", blueLabel: "VIEW", alphaLabel: "Z", yellowAction: .regs, blueAction: .view, primaryAction: .digit0),
        HP32Key(row: 7, col: 2, rowSpan: 1, label: ".", yellowLabel: "FDISP", blueLabel: "/c", alphaLabel: "", yellowAction: .fdisp, blueAction: .slashc, primaryAction: .decimal),
        HP32Key(row: 7, col: 3, rowSpan: 1, label: "PLOT", yellowLabel: "CNST", blueLabel: "", alphaLabel: "", yellowAction: .const, blueAction: nil, primaryAction: .plot),
        HP32Key(row: 7, col: 4, rowSpan: 1, label: "+", yellowLabel: "LBL", blueLabel: "RTN", alphaLabel: "", yellowAction: .lbl, blueAction: .rtn, primaryAction: .add)
    ]
    public static let standardGrid: [HP32Key] = standardGrid_chunk0 + standardGrid_chunk1 + standardGrid_chunk2 + standardGrid_chunk3 + standardGrid_chunk4
#if canImport(CoreGraphics)
    public static let landscapeGrid: [HP32Key] = [
        HP32Key(row: 0, col: 0, rowSpan: 1, colSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu0),
        HP32Key(row: 0, col: 1, rowSpan: 1, colSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu1),
        HP32Key(row: 0, col: 2, rowSpan: 1, colSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu2),
        HP32Key(row: 0, col: 3, rowSpan: 1, colSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu3),
        HP32Key(row: 0, col: 4, rowSpan: 1, colSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu4),
        HP32Key(row: 0, col: 5, rowSpan: 1, colSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu5),
        HP32Key(row: 1, col: 0, rowSpan: 1, colSpan: 1, label: "√𝑥", yellowLabel: "𝑥²", blueLabel: "PARTS", alphaLabel: "A", yellowAction: .square, blueAction: .parts, primaryAction: .sqrt),
        HP32Key(row: 1, col: 1, rowSpan: 1, colSpan: 1, label: "𝑒ˣ", yellowLabel: "10ˣ", blueLabel: "PROB", alphaLabel: "B", yellowAction: .exp10, blueAction: .prob, primaryAction: .exp),
        HP32Key(row: 1, col: 2, rowSpan: 1, colSpan: 1, label: "LN", yellowLabel: "LOG", blueLabel: "L.R.", alphaLabel: "C", yellowAction: .log, blueAction: .lr, primaryAction: .ln),
        HP32Key(row: 1, col: 3, rowSpan: 1, colSpan: 1, label: "𝑦ˣ", yellowLabel: "ˣ√𝑦", blueLabel: "𝑥̄,𝑦̄", alphaLabel: "D", yellowAction: .xRootY, blueAction: .statMean, primaryAction: .power),
        HP32Key(row: 1, col: 4, rowSpan: 1, colSpan: 1, label: "¹/𝑥", yellowLabel: "𝑥!", blueLabel: "s,σ", alphaLabel: "E", yellowAction: .factorial, blueAction: .statStdDev, primaryAction: .reciprocal),
        HP32Key(row: 1, col: 5, rowSpan: 1, colSpan: 1, label: "Σ+", yellowLabel: "Σ-", blueLabel: "SUMS", alphaLabel: "F", yellowAction: .statSub, blueAction: .sums, primaryAction: .statAdd),
        HP32Key(row: 2, col: 0, rowSpan: 1, colSpan: 1, label: "STO", yellowLabel: "CMPLX", blueLabel: "EQN", alphaLabel: "G", yellowAction: .cmplx, blueAction: .eqn, primaryAction: .sto),
        HP32Key(row: 2, col: 1, rowSpan: 1, colSpan: 1, label: "RCL", yellowLabel: "RND", blueLabel: "SCRL", alphaLabel: "H", yellowAction: .rnd, blueAction: .scrl, primaryAction: .rcl),
        HP32Key(row: 2, col: 2, rowSpan: 1, colSpan: 1, label: "R↓", yellowLabel: "HYP", blueLabel: "R↑", alphaLabel: "I", yellowAction: .hyp, blueAction: .rollUp, primaryAction: .rollDown),
        HP32Key(row: 2, col: 3, rowSpan: 1, colSpan: 1, label: "SIN", yellowLabel: "ASIN", blueLabel: "π", alphaLabel: "J", yellowAction: .asin, blueAction: .pi, primaryAction: .sin),
        HP32Key(row: 2, col: 4, rowSpan: 1, colSpan: 1, label: "COS", yellowLabel: "ACOS", blueLabel: "%", alphaLabel: "K", yellowAction: .acos, blueAction: .percent, primaryAction: .cos),
        HP32Key(row: 2, col: 5, rowSpan: 1, colSpan: 1, label: "TAN", yellowLabel: "ATAN", blueLabel: "%CHG", alphaLabel: "L", yellowAction: .atan, blueAction: .percentChange, primaryAction: .tan),
        HP32Key(row: 3, col: 0, rowSpan: 1, colSpan: 1, label: "C", yellowLabel: "", blueLabel: offLabel, alphaLabel: "", yellowAction: nil, blueAction: .off, primaryAction: .c),
        HP32Key(row: 3, col: 1, rowSpan: 1, colSpan: 1, label: "yellow", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .shiftYellow),
        HP32Key(row: 3, col: 2, rowSpan: 1, colSpan: 1, label: "blue", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .shiftBlue),
        HP32Key(row: 3, col: 3, rowSpan: 1, colSpan: 1, label: "XEQ", yellowLabel: "FN=", blueLabel: "", alphaLabel: "", yellowAction: .fnEq, blueAction: nil, primaryAction: .xeq),
        HP32Key(row: 3, col: 4, rowSpan: 1, colSpan: 1, label: "𝑥≷𝑦", yellowLabel: "MEM", blueLabel: "𝑥≷?", alphaLabel: "N", yellowAction: .mem, blueAction: .swapXYPrompt, primaryAction: .swapXY),
        HP32Key(row: 3, col: 5, rowSpan: 1, colSpan: 1, label: "<-", yellowLabel: "CLEAR", blueLabel: "", alphaLabel: "", yellowAction: .clear, blueAction: nil, primaryAction: .backspace),
        HP32Key(row: 0, col: 6, rowSpan: 1, colSpan: 1, label: "+/-", yellowLabel: "MODES", blueLabel: "|x|", alphaLabel: "O", yellowAction: .modes, blueAction: .abs, primaryAction: .toggleSign),
        HP32Key(row: 1, col: 6, rowSpan: 1, colSpan: 1, label: "E", yellowLabel: "DISP", blueLabel: "÷R", alphaLabel: "P", yellowAction: .disp, blueAction: .intDiv, primaryAction: .e),
        HP32Key(row: 2, col: 6, rowSpan: 2, colSpan: 1, label: "ENTER", yellowLabel: "LAST𝑥", blueLabel: "SHOW", alphaLabel: "M", yellowAction: .lastx, blueAction: .show, primaryAction: .enter),
        HP32Key(row: 0, col: 7, rowSpan: 1, colSpan: 1, label: "7", yellowLabel: "↓", blueLabel: "SOLVE", alphaLabel: "Q", yellowAction: .scrollDown, blueAction: .solve, primaryAction: .digit7),
        HP32Key(row: 0, col: 8, rowSpan: 1, colSpan: 1, label: "8", yellowLabel: "↑", blueLabel: "∫", alphaLabel: "R", yellowAction: .scrollUp, blueAction: .integrate, primaryAction: .digit8),
        HP32Key(row: 0, col: 9, rowSpan: 1, colSpan: 1, label: "9", yellowLabel: "▸km", blueLabel: "▸mi", alphaLabel: "S", yellowAction: .toKm, blueAction: .toMi, primaryAction: .digit9),
        HP32Key(row: 0, col: 10, rowSpan: 1, colSpan: 1, label: "÷", yellowLabel: "𝑥?𝑦", blueLabel: "𝑥?0", alphaLabel: "", yellowAction: .testXY, blueAction: .testX0, primaryAction: .divide),
        HP32Key(row: 1, col: 7, rowSpan: 1, colSpan: 1, label: "4", yellowLabel: "▸θ,𝑟", blueLabel: "▸𝑦,𝑥", alphaLabel: "T", yellowAction: .toPolar, blueAction: .toRectangular, primaryAction: .digit4),
        HP32Key(row: 1, col: 8, rowSpan: 1, colSpan: 1, label: "5", yellowLabel: "▸HR", blueLabel: "▸HMS", alphaLabel: "U", yellowAction: .toHr, blueAction: .toHms, primaryAction: .digit5),
        HP32Key(row: 1, col: 9, rowSpan: 1, colSpan: 1, label: "6", yellowLabel: "▸DEG", blueLabel: "▸RAD", alphaLabel: "V", yellowAction: .toDeg, blueAction: .toRad, primaryAction: .digit6),
        HP32Key(row: 1, col: 10, rowSpan: 1, colSpan: 1, label: "×", yellowLabel: "BASE", blueLabel: "FLAGS", alphaLabel: "", yellowAction: .base, blueAction: .flags, primaryAction: .multiply),
        HP32Key(row: 2, col: 7, rowSpan: 1, colSpan: 1, label: "1", yellowLabel: "▸kg", blueLabel: "▸lb", alphaLabel: "W", yellowAction: .toKg, blueAction: .toLb, primaryAction: .digit1),
        HP32Key(row: 2, col: 8, rowSpan: 1, colSpan: 1, label: "2", yellowLabel: "▸°C", blueLabel: "▸°F", alphaLabel: "X", yellowAction: .toCelsius, blueAction: .toFahrenheit, primaryAction: .digit2),
        HP32Key(row: 2, col: 9, rowSpan: 1, colSpan: 1, label: "3", yellowLabel: "▸cm", blueLabel: "▸in", alphaLabel: "Y", yellowAction: .toCm, blueAction: .toIn, primaryAction: .digit3),
        HP32Key(row: 2, col: 10, rowSpan: 1, colSpan: 1, label: "-", yellowLabel: "▸l", blueLabel: "▸gal", alphaLabel: "", yellowAction: .toLiters, blueAction: .toGal, primaryAction: .subtract),
        HP32Key(row: 3, col: 7, rowSpan: 1, colSpan: 1, label: "0", yellowLabel: "REGS", blueLabel: "VIEW", alphaLabel: "Z", yellowAction: .regs, blueAction: .view, primaryAction: .digit0),
        HP32Key(row: 3, col: 8, rowSpan: 1, colSpan: 1, label: ".", yellowLabel: "FDISP", blueLabel: "/c", alphaLabel: "", yellowAction: .fdisp, blueAction: .slashc, primaryAction: .decimal),
        HP32Key(row: 3, col: 9, rowSpan: 1, colSpan: 1, label: "PLOT", yellowLabel: "CNST", blueLabel: "", alphaLabel: "", yellowAction: .const, blueAction: nil, primaryAction: .plot),
        HP32Key(row: 3, col: 10, rowSpan: 1, colSpan: 1, label: "+", yellowLabel: "LBL", blueLabel: "RTN", alphaLabel: "", yellowAction: .lbl, blueAction: .rtn, primaryAction: .add)
    ]

#endif
}



public func alphaLabel(for primaryAction: CalculatorOperation?) -> String? {
    if let key = HP32KeyMap.standardGrid.first(where: { $0.primaryAction == primaryAction || (primaryAction != nil && $0.label == primaryAction!.stringValue) }) {
        if !key.alphaLabel.isEmpty {
            return key.alphaLabel
        }
    }
    return nil
}

#if canImport(CoreGraphics)
    public let physicalKeyOffsets: [String: (x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat)] = [
        "SOFT1": (x: 7.600, y: 94.000, w: 7.5, h: 6.0),
        "SOFT2": (x: 18.600, y: 94.000, w: 7.5, h: 6.0),
        "SOFT3": (x: 29.600, y: 94.000, w: 7.5, h: 6.0),
        "SOFT4": (x: 40.600, y: 94.000, w: 7.5, h: 6.0),
        "SOFT5": (x: 51.600, y: 94.000, w: 7.5, h: 6.0),
        "SOFT6": (x: 62.600, y: 94.000, w: 7.5, h: 6.0),
        "√𝑥": (x: 7.600, y: 82.000, w: 7.5, h: 6.0),
        "𝑒ˣ": (x: 18.600, y: 82.000, w: 7.5, h: 6.0),
        "LN": (x: 29.600, y: 82.000, w: 7.5, h: 6.0),
        "𝑦ˣ": (x: 40.600, y: 82.000, w: 7.5, h: 6.0),
        "1/𝑥": (x: 51.600, y: 82.000, w: 7.5, h: 6.0),
        "Σ+": (x: 62.600, y: 82.000, w: 7.5, h: 6.0),
        "STO": (x: 7.600, y: 70.000, w: 7.5, h: 6.0),
        "RCL": (x: 18.600, y: 70.000, w: 7.5, h: 6.0),
        "R↓": (x: 29.600, y: 70.000, w: 7.5, h: 6.0),
        "SIN": (x: 40.600, y: 70.000, w: 7.5, h: 6.0),
        "COS": (x: 51.600, y: 70.000, w: 7.5, h: 6.0),
        "TAN": (x: 62.600, y: 70.000, w: 7.5, h: 6.0),
        "ENTER": (x: 13.100, y: 58.000, w: 16.0, h: 6.0),
        "𝑥≷𝑦": (x: 29.600, y: 58.000, w: 7.5, h: 6.0),
        "+/-": (x: 40.600, y: 58.000, w: 7.5, h: 6.0),
        "E": (x: 51.600, y: 58.000, w: 7.5, h: 6.0),
        "<-": (x: 62.600, y: 58.000, w: 7.5, h: 6.0),
        "XEQ": (x: 7.600, y: 46.000, w: 7.5, h: 6.0),
        "7": (x: 29.600, y: 46.000, w: 7.5, h: 6.0),
        "8": (x: 40.600, y: 46.000, w: 7.5, h: 6.0),
        "9": (x: 51.600, y: 46.000, w: 7.5, h: 6.0),
        "÷": (x: 62.600, y: 46.000, w: 7.5, h: 6.0),
        "f": (x: 7.600, y: 34.000, w: 8.0, h: 6.0),
        "4": (x: 29.600, y: 34.000, w: 7.5, h: 6.0),
        "5": (x: 40.600, y: 34.000, w: 7.5, h: 6.0),
        "6": (x: 51.600, y: 34.000, w: 7.5, h: 6.0),
        "×": (x: 62.600, y: 34.000, w: 7.5, h: 6.0),
        "g": (x: 7.600, y: 22.000, w: 8.0, h: 6.0),
        "1": (x: 29.600, y: 22.000, w: 7.5, h: 6.0),
        "2": (x: 40.600, y: 22.000, w: 7.5, h: 6.0),
        "3": (x: 51.600, y: 22.000, w: 7.5, h: 6.0),
        "-": (x: 62.600, y: 22.000, w: 7.5, h: 6.0),
        "C": (x: 7.600, y: 10.000, w: 8.0, h: 6.0),
        "0": (x: 29.600, y: 10.000, w: 7.5, h: 6.0),
        ".": (x: 40.600, y: 10.000, w: 7.5, h: 6.0),
        "PLOT": (x: 51.600, y: 10.000, w: 7.5, h: 6.0),
        "+": (x: 62.600, y: 10.000, w: 7.5, h: 6.0),
    ]
#endif
