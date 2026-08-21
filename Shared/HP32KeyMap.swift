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
    public static let standardGrid: [HP32Key] = [
        // Top Section (Functions)
        // Row 0 (6 cols) - LFU Pad (Dynamic)
        HP32Key(row: 0, col: 0, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu0),
        HP32Key(row: 0, col: 1, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu1),
        HP32Key(row: 0, col: 2, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu2),
        HP32Key(row: 0, col: 3, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu3),
        HP32Key(row: 0, col: 4, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu4),
        HP32Key(row: 0, col: 5, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu5),
        
        // Row 1 (6 cols) - Math Row
        HP32Key(row: 1, col: 0, rowSpan: 1, label: "√𝑥", yellowLabel: "𝑥²", blueLabel: "PARTS", alphaLabel: "A", yellowAction: .square, blueAction: .parts, primaryAction: .sqrt),
        HP32Key(row: 1, col: 1, rowSpan: 1, label: "𝑒ˣ", yellowLabel: "10ˣ", blueLabel: "PROB", alphaLabel: "B", yellowAction: .exp10, blueAction: .prob, primaryAction: .exp),
        HP32Key(row: 1, col: 2, rowSpan: 1, label: "LN", yellowLabel: "LOG", blueLabel: "L.R.", alphaLabel: "C", yellowAction: .log, blueAction: .lr, primaryAction: .ln),
        HP32Key(row: 1, col: 3, rowSpan: 1, label: "𝑦ˣ", yellowLabel: "ˣ√𝑦", blueLabel: "x̄,ȳ", alphaLabel: "D", yellowAction: .xRootY, blueAction: .statMean, primaryAction: .power),
        HP32Key(row: 1, col: 4, rowSpan: 1, label: "¹/𝑥", yellowLabel: "𝑥!", blueLabel: "s,σ", alphaLabel: "E", yellowAction: .factorial, blueAction: .statStdDev, primaryAction: .reciprocal),
        HP32Key(row: 1, col: 5, rowSpan: 1, label: "Σ+", yellowLabel: "Σ-", blueLabel: "SUMS", alphaLabel: "F", yellowAction: .statSub, blueAction: .sums, primaryAction: .statAdd),
        
        // Row 2 (6 cols)
        HP32Key(row: 2, col: 0, rowSpan: 1, label: "STO", yellowLabel: "CMPLX", blueLabel: "EQN", alphaLabel: "G", yellowAction: .cmplx, blueAction: .eqn, primaryAction: .sto),
        HP32Key(row: 2, col: 1, rowSpan: 1, label: "RCL", yellowLabel: "RND", blueLabel: "SCRL", alphaLabel: "H", yellowAction: .rnd, blueAction: .scrl, primaryAction: .rcl),
        HP32Key(row: 2, col: 2, rowSpan: 1, label: "R↓", yellowLabel: "HYP", blueLabel: "R↑", alphaLabel: "I", yellowAction: .hyp, blueAction: .rollUp, primaryAction: .rollDown),
        HP32Key(row: 2, col: 3, rowSpan: 1, label: "SIN", yellowLabel: "ASIN", blueLabel: "π", alphaLabel: "J", yellowAction: .asin, blueAction: .pi, primaryAction: .sin),
        HP32Key(row: 2, col: 4, rowSpan: 1, label: "COS", yellowLabel: "ACOS", blueLabel: "%", alphaLabel: "K", yellowAction: .acos, blueAction: .percent, primaryAction: .cos),
        HP32Key(row: 2, col: 5, rowSpan: 1, label: "TAN", yellowLabel: "ATAN", blueLabel: "%CHG", alphaLabel: "L", yellowAction: .atan, blueAction: .percentChange, primaryAction: .tan),
        
        // Row 3 (5 cols)
        // Note: ENTER spans 2 columns in the UI, but we place it at col 0.
        HP32Key(row: 3, col: 0, rowSpan: 1, colSpan: 2, label: "ENTER", yellowLabel: "LAST𝑥", blueLabel: "SHOW", alphaLabel: "M", yellowAction: .lastx, blueAction: .show, primaryAction: .enter),
        HP32Key(row: 3, col: 2, rowSpan: 1, label: "x<>y", yellowLabel: "MEM", blueLabel: "𝑥><?", alphaLabel: "N", yellowAction: .mem, blueAction: .swapXYPrompt, primaryAction: .swapXY),
        HP32Key(row: 3, col: 3, rowSpan: 1, label: "+/-", yellowLabel: "MODES", blueLabel: "MOD", alphaLabel: "O", yellowAction: .modes, blueAction: .modulo, primaryAction: .toggleSign),
        HP32Key(row: 3, col: 4, rowSpan: 1, label: "E", yellowLabel: "DISP", blueLabel: "INT÷", alphaLabel: "P", yellowAction: .disp, blueAction: .intDiv, primaryAction: .e),
        HP32Key(row: 3, col: 5, rowSpan: 1, label: "<-", yellowLabel: "CLEAR", blueLabel: "", alphaLabel: "", yellowAction: .clear, blueAction: nil, primaryAction: .backspace),
        
        // Bottom Section (Numpad)
        // Row 4 (5 cols)
        HP32Key(row: 4, col: 0, rowSpan: 1, label: "XEQ", yellowLabel: "FN=", blueLabel: "", alphaLabel: "", yellowAction: .fnEq, blueAction: nil, primaryAction: .xeq),
        HP32Key(row: 4, col: 1, rowSpan: 1, label: "7", yellowLabel: "↓", blueLabel: "SOLVE", alphaLabel: "Q", yellowAction: nil, blueAction: .solve, primaryAction: .digit7),
        HP32Key(row: 4, col: 2, rowSpan: 1, label: "8", yellowLabel: "↑", blueLabel: "∫", alphaLabel: "R", yellowAction: nil, blueAction: .integrate, primaryAction: .digit8),
        HP32Key(row: 4, col: 3, rowSpan: 1, label: "9", yellowLabel: "▸km", blueLabel: "▸mi", alphaLabel: "S", yellowAction: .toKm, blueAction: .toMi, primaryAction: .digit9),
        HP32Key(row: 4, col: 4, rowSpan: 1, label: "÷", yellowLabel: "x?y", blueLabel: "x?0", alphaLabel: "", yellowAction: .testXY, blueAction: .testX0, primaryAction: .divide),
        
        // Row 5 (5 cols)
        HP32Key(row: 5, col: 0, rowSpan: 1, label: "yellow", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .shiftYellow),
        HP32Key(row: 5, col: 1, rowSpan: 1, label: "4", yellowLabel: "▸θ,r", blueLabel: "▸𝑦,𝑥", alphaLabel: "T", yellowAction: .toPolar, blueAction: .toRectangular, primaryAction: .digit4),
        HP32Key(row: 5, col: 2, rowSpan: 1, label: "5", yellowLabel: "▸HR", blueLabel: "▸HMS", alphaLabel: "U", yellowAction: .toHr, blueAction: .toHms, primaryAction: .digit5),
        HP32Key(row: 5, col: 3, rowSpan: 1, label: "6", yellowLabel: "▸DEG", blueLabel: "▸RAD", alphaLabel: "V", yellowAction: .toDeg, blueAction: .toRad, primaryAction: .digit6),
        HP32Key(row: 5, col: 4, rowSpan: 1, label: "×", yellowLabel: "BASE", blueLabel: "FLAGS", alphaLabel: "", yellowAction: .base, blueAction: .flags, primaryAction: .multiply),
        
        // Row 6 (5 cols)
        HP32Key(row: 6, col: 0, rowSpan: 1, label: "blue", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .shiftBlue),
        HP32Key(row: 6, col: 1, rowSpan: 1, label: "1", yellowLabel: "▸kg", blueLabel: "▸lb", alphaLabel: "W", yellowAction: .toKg, blueAction: .toLb, primaryAction: .digit1),
        HP32Key(row: 6, col: 2, rowSpan: 1, label: "2", yellowLabel: "▸°C", blueLabel: "▸°F", alphaLabel: "X", yellowAction: .toCelsius, blueAction: .toFahrenheit, primaryAction: .digit2),
        HP32Key(row: 6, col: 3, rowSpan: 1, label: "3", yellowLabel: "▸cm", blueLabel: "▸in", alphaLabel: "Y", yellowAction: .toCm, blueAction: .toIn, primaryAction: .digit3),
        HP32Key(row: 6, col: 4, rowSpan: 1, label: "-", yellowLabel: "▸l", blueLabel: "▸gal", alphaLabel: "", yellowAction: .toLiters, blueAction: .toGal, primaryAction: .subtract),
        
        // Row 7 (5 cols)
        HP32Key(row: 7, col: 0, rowSpan: 1, label: "C", yellowLabel: "", blueLabel: "OFF", alphaLabel: "", yellowAction: nil, blueAction: .off, primaryAction: .c),
        HP32Key(row: 7, col: 1, rowSpan: 1, label: "0", yellowLabel: "REGS", blueLabel: "VIEW", alphaLabel: "Z", yellowAction: .regs, blueAction: .view, primaryAction: .digit0),
        HP32Key(row: 7, col: 2, rowSpan: 1, label: ".", yellowLabel: "FDISP", blueLabel: "/c", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .decimal),
        HP32Key(row: 7, col: 3, rowSpan: 1, label: "PLOT", yellowLabel: "CNST", blueLabel: "", alphaLabel: "", yellowAction: .const, blueAction: nil, primaryAction: .plot),
        HP32Key(row: 7, col: 4, rowSpan: 1, label: "+", yellowLabel: "LBL", blueLabel: "RTN", alphaLabel: "", yellowAction: .lbl, blueAction: .rtn, primaryAction: .add)
    ]
    
        public static let landscapeGrid: [HP32Key] = [
        // Voyage Layout (HP-15C style geometry)
        // 4 Rows total, 11 columns. Numpad on the right (4 rows x 4 cols).
        // Middle separator (col 6) with vertical ENTER. Functions on the left (4 rows x 6 cols).
        
        // Row 0
        HP32Key(row: 0, col: 0, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu0),
        HP32Key(row: 0, col: 1, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu1),
        HP32Key(row: 0, col: 2, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu2),
        HP32Key(row: 0, col: 3, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu3),
        HP32Key(row: 0, col: 4, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu4),
        HP32Key(row: 0, col: 5, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .lfu5),
        HP32Key(row: 0, col: 6, rowSpan: 1, label: "<-", yellowLabel: "CLEAR", blueLabel: "", alphaLabel: "", yellowAction: .clear, blueAction: nil, primaryAction: .backspace),
        HP32Key(row: 0, col: 7, rowSpan: 1, label: "7", yellowLabel: "↓", blueLabel: "SOLVE", alphaLabel: "Q", yellowAction: nil, blueAction: .solve, primaryAction: .digit7),
        HP32Key(row: 0, col: 8, rowSpan: 1, label: "8", yellowLabel: "↑", blueLabel: "∫", alphaLabel: "R", yellowAction: nil, blueAction: .integrate, primaryAction: .digit8),
        HP32Key(row: 0, col: 9, rowSpan: 1, label: "9", yellowLabel: "▸km", blueLabel: "▸mi", alphaLabel: "S", yellowAction: .toKm, blueAction: .toMi, primaryAction: .digit9),
        HP32Key(row: 0, col: 10, rowSpan: 1, label: "÷", yellowLabel: "x?y", blueLabel: "x?0", alphaLabel: "", yellowAction: .testXY, blueAction: .testX0, primaryAction: .divide),
        
        // Row 1
        HP32Key(row: 1, col: 0, rowSpan: 1, label: "√𝑥", yellowLabel: "𝑥²", blueLabel: "PARTS", alphaLabel: "A", yellowAction: .square, blueAction: .parts, primaryAction: .sqrt),
        HP32Key(row: 1, col: 1, rowSpan: 1, label: "𝑒ˣ", yellowLabel: "10ˣ", blueLabel: "PROB", alphaLabel: "B", yellowAction: .exp10, blueAction: .prob, primaryAction: .exp),
        HP32Key(row: 1, col: 2, rowSpan: 1, label: "LN", yellowLabel: "LOG", blueLabel: "L.R.", alphaLabel: "C", yellowAction: .log, blueAction: .lr, primaryAction: .ln),
        HP32Key(row: 1, col: 3, rowSpan: 1, label: "𝑦ˣ", yellowLabel: "ˣ√𝑦", blueLabel: "x̄,ȳ", alphaLabel: "D", yellowAction: .xRootY, blueAction: .statMean, primaryAction: .power),
        HP32Key(row: 1, col: 4, rowSpan: 1, label: "¹/𝑥", yellowLabel: "𝑥!", blueLabel: "s,σ", alphaLabel: "E", yellowAction: .factorial, blueAction: .statStdDev, primaryAction: .reciprocal),
        HP32Key(row: 1, col: 5, rowSpan: 1, label: "Σ+", yellowLabel: "Σ-", blueLabel: "SUMS", alphaLabel: "F", yellowAction: .statSub, blueAction: .sums, primaryAction: .statAdd),
        HP32Key(row: 1, col: 6, rowSpan: 1, label: "XEQ", yellowLabel: "FN=", blueLabel: "", alphaLabel: "", yellowAction: .fnEq, blueAction: nil, primaryAction: .xeq),
        HP32Key(row: 1, col: 7, rowSpan: 1, label: "4", yellowLabel: "▸θ,r", blueLabel: "▸𝑦,𝑥", alphaLabel: "T", yellowAction: .toPolar, blueAction: .toRectangular, primaryAction: .digit4),
        HP32Key(row: 1, col: 8, rowSpan: 1, label: "5", yellowLabel: "▸HR", blueLabel: "▸HMS", alphaLabel: "U", yellowAction: .toHr, blueAction: .toHms, primaryAction: .digit5),
        HP32Key(row: 1, col: 9, rowSpan: 1, label: "6", yellowLabel: "▸DEG", blueLabel: "▸RAD", alphaLabel: "V", yellowAction: .toDeg, blueAction: .toRad, primaryAction: .digit6),
        HP32Key(row: 1, col: 10, rowSpan: 1, label: "×", yellowLabel: "BASE", blueLabel: "FLAGS", alphaLabel: "", yellowAction: .base, blueAction: .flags, primaryAction: .multiply),
        
        // Row 2
        HP32Key(row: 2, col: 0, rowSpan: 1, label: "STO", yellowLabel: "CMPLX", blueLabel: "EQN", alphaLabel: "G", yellowAction: .cmplx, blueAction: .eqn, primaryAction: .sto),
        HP32Key(row: 2, col: 1, rowSpan: 1, label: "RCL", yellowLabel: "RND", blueLabel: "SCRL", alphaLabel: "H", yellowAction: .rnd, blueAction: .scrl, primaryAction: .rcl),
        HP32Key(row: 2, col: 2, rowSpan: 1, label: "R↓", yellowLabel: "HYP", blueLabel: "R↑", alphaLabel: "I", yellowAction: .hyp, blueAction: .rollUp, primaryAction: .rollDown),
        HP32Key(row: 2, col: 3, rowSpan: 1, label: "SIN", yellowLabel: "ASIN", blueLabel: "π", alphaLabel: "J", yellowAction: .asin, blueAction: .pi, primaryAction: .sin),
        HP32Key(row: 2, col: 4, rowSpan: 1, label: "COS", yellowLabel: "ACOS", blueLabel: "%", alphaLabel: "K", yellowAction: .acos, blueAction: .percent, primaryAction: .cos),
        HP32Key(row: 2, col: 5, rowSpan: 1, label: "TAN", yellowLabel: "ATAN", blueLabel: "%CHG", alphaLabel: "L", yellowAction: .atan, blueAction: .percentChange, primaryAction: .tan),
        HP32Key(row: 2, col: 6, rowSpan: 2, label: "ENTER", yellowLabel: "LAST𝑥", blueLabel: "SHOW", alphaLabel: "M", yellowAction: .lastx, blueAction: .show, primaryAction: .enter),
        HP32Key(row: 2, col: 7, rowSpan: 1, label: "1", yellowLabel: "▸kg", blueLabel: "▸lb", alphaLabel: "W", yellowAction: .toKg, blueAction: .toLb, primaryAction: .digit1),
        HP32Key(row: 2, col: 8, rowSpan: 1, label: "2", yellowLabel: "▸°C", blueLabel: "▸°F", alphaLabel: "X", yellowAction: .toCelsius, blueAction: .toFahrenheit, primaryAction: .digit2),
        HP32Key(row: 2, col: 9, rowSpan: 1, label: "3", yellowLabel: "▸cm", blueLabel: "▸in", alphaLabel: "Y", yellowAction: .toCm, blueAction: .toIn, primaryAction: .digit3),
        HP32Key(row: 2, col: 10, rowSpan: 1, label: "-", yellowLabel: "▸l", blueLabel: "▸gal", alphaLabel: "", yellowAction: .toLiters, blueAction: .toGal, primaryAction: .subtract),
        
        // Row 3
        HP32Key(row: 3, col: 0, rowSpan: 1, label: "C", yellowLabel: "", blueLabel: "OFF", alphaLabel: "", yellowAction: nil, blueAction: .off, primaryAction: .c),
        HP32Key(row: 3, col: 1, rowSpan: 1, label: "yellow", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .shiftYellow),
        HP32Key(row: 3, col: 2, rowSpan: 1, label: "blue", yellowLabel: "", blueLabel: "", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .shiftBlue),
        HP32Key(row: 3, col: 3, rowSpan: 1, label: "x<>y", yellowLabel: "MEM", blueLabel: "𝑥><?", alphaLabel: "N", yellowAction: .mem, blueAction: .swapXYPrompt, primaryAction: .swapXY),
        HP32Key(row: 3, col: 4, rowSpan: 1, label: "+/-", yellowLabel: "MODES", blueLabel: "MOD", alphaLabel: "O", yellowAction: .modes, blueAction: .modulo, primaryAction: .toggleSign),
        HP32Key(row: 3, col: 5, rowSpan: 1, label: "E", yellowLabel: "DISP", blueLabel: "INT÷", alphaLabel: "P", yellowAction: .disp, blueAction: .intDiv, primaryAction: .e),
        HP32Key(row: 3, col: 7, rowSpan: 1, label: "0", yellowLabel: "REGS", blueLabel: "VIEW", alphaLabel: "Z", yellowAction: .regs, blueAction: .view, primaryAction: .digit0),
        HP32Key(row: 3, col: 8, rowSpan: 1, label: ".", yellowLabel: "FDISP", blueLabel: "/c", alphaLabel: "", yellowAction: nil, blueAction: nil, primaryAction: .decimal),
        HP32Key(row: 3, col: 9, rowSpan: 1, label: "PLOT", yellowLabel: "CNST", blueLabel: "", alphaLabel: "", yellowAction: .const, blueAction: nil, primaryAction: .plot),
        HP32Key(row: 3, col: 10, rowSpan: 1, label: "+", yellowLabel: "LBL", blueLabel: "RTN", alphaLabel: "", yellowAction: .lbl, blueAction: .rtn, primaryAction: .add)
    ]
}



public func alphaLabel(for primaryAction: CalculatorOperation?) -> String? {
    if let key = HP32KeyMap.standardGrid.first(where: { $0.primaryAction == primaryAction || (primaryAction != nil && $0.label == primaryAction!.stringValue) }) {
        if !key.alphaLabel.isEmpty {
            return key.alphaLabel
        }
    }
    return nil
}
