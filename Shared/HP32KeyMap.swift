#if canImport(Foundation)
import Foundation
#endif

public struct HP32Key: Identifiable, Equatable {
#if canImport(Foundation)
    public let id = UUID()
#else
    public var id: String { label + action }
#endif
    public let row: Int
    public let col: Int
    public let rowSpan: Int
    public let colSpan: Int
    public let label: String
    public let yellowLabel: String
    public let blueLabel: String
    public let alphaLabel: String
    public let action: String
    
    public init(row: Int, col: Int, rowSpan: Int = 1, colSpan: Int = 1, label: String, yellowLabel: String, blueLabel: String, alphaLabel: String, action: String) {
        self.row = row
        self.col = col
        self.rowSpan = rowSpan
        self.colSpan = colSpan
        self.label = label
        self.yellowLabel = yellowLabel
        self.blueLabel = blueLabel
        self.alphaLabel = alphaLabel
        self.action = action
    }
    
    public static func == (lhs: HP32Key, rhs: HP32Key) -> Bool {
        lhs.id == rhs.id
    }
}

public struct HP32KeyMap {
    public static let standardGrid: [HP32Key] = [
        // Top Section (Functions)
        // Row 0 (6 cols) - LFU Pad (Dynamic)
        HP32Key(row: 0, col: 0, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "LFU_0"),
        HP32Key(row: 0, col: 1, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "LFU_1"),
        HP32Key(row: 0, col: 2, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "LFU_2"),
        HP32Key(row: 0, col: 3, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "LFU_3"),
        HP32Key(row: 0, col: 4, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "LFU_4"),
        HP32Key(row: 0, col: 5, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "LFU_5"),
        
        // Row 1 (6 cols) - Math Row
        HP32Key(row: 1, col: 0, rowSpan: 1, label: "√𝑥", yellowLabel: "𝑥²", blueLabel: "PARTS", alphaLabel: "A", action: "√x"),
        HP32Key(row: 1, col: 1, rowSpan: 1, label: "𝑒ˣ", yellowLabel: "10ˣ", blueLabel: "PROB", alphaLabel: "B", action: "e^x"),
        HP32Key(row: 1, col: 2, rowSpan: 1, label: "LN", yellowLabel: "LOG", blueLabel: "L.R.", alphaLabel: "C", action: "LN"),
        HP32Key(row: 1, col: 3, rowSpan: 1, label: "𝑦ˣ", yellowLabel: "ˣ√𝑦", blueLabel: "x̄,ȳ", alphaLabel: "D", action: "y^x"),
        HP32Key(row: 1, col: 4, rowSpan: 1, label: "¹/𝑥", yellowLabel: "𝑥!", blueLabel: "s,σ", alphaLabel: "E", action: "1/x"),
        HP32Key(row: 1, col: 5, rowSpan: 1, label: "Σ+", yellowLabel: "Σ-", blueLabel: "SUMS", alphaLabel: "F", action: "Σ+"),
        
        // Row 2 (6 cols)
        HP32Key(row: 2, col: 0, rowSpan: 1, label: "STO", yellowLabel: "CMPLX", blueLabel: "EQN", alphaLabel: "G", action: "STO"),
        HP32Key(row: 2, col: 1, rowSpan: 1, label: "RCL", yellowLabel: "RND", blueLabel: "SCRL", alphaLabel: "H", action: "RCL"),
        HP32Key(row: 2, col: 2, rowSpan: 1, label: "R↓", yellowLabel: "HYP", blueLabel: "R↑", alphaLabel: "I", action: "R↓"),
        HP32Key(row: 2, col: 3, rowSpan: 1, label: "SIN", yellowLabel: "ASIN", blueLabel: "π", alphaLabel: "J", action: "SIN"),
        HP32Key(row: 2, col: 4, rowSpan: 1, label: "COS", yellowLabel: "ACOS", blueLabel: "%", alphaLabel: "K", action: "COS"),
        HP32Key(row: 2, col: 5, rowSpan: 1, label: "TAN", yellowLabel: "ATAN", blueLabel: "%CHG", alphaLabel: "L", action: "TAN"),
        
        // Row 3 (5 cols)
        // Note: ENTER spans 2 columns in the UI, but we place it at col 0.
        HP32Key(row: 3, col: 0, rowSpan: 1, colSpan: 2, label: "ENTER", yellowLabel: "LAST𝑥", blueLabel: "SHOW", alphaLabel: "M", action: "ENTER"),
        HP32Key(row: 3, col: 2, rowSpan: 1, label: "x<>y", yellowLabel: "MEM", blueLabel: "𝑥><?", alphaLabel: "N", action: "𝑥><𝑦"),
        HP32Key(row: 3, col: 3, rowSpan: 1, label: "+/-", yellowLabel: "MODES", blueLabel: "MOD", alphaLabel: "O", action: "+/-"),
        HP32Key(row: 3, col: 4, rowSpan: 1, label: "E", yellowLabel: "DISP", blueLabel: "INT÷", alphaLabel: "P", action: "E"),
        HP32Key(row: 3, col: 5, rowSpan: 1, label: "<-", yellowLabel: "CLEAR", blueLabel: "", alphaLabel: "", action: "<-"),
        
        // Bottom Section (Numpad)
        // Row 4 (5 cols)
        HP32Key(row: 4, col: 0, rowSpan: 1, label: "XEQ", yellowLabel: "FN=", blueLabel: "", alphaLabel: "", action: "XEQ"),
        HP32Key(row: 4, col: 1, rowSpan: 1, label: "7", yellowLabel: "↓", blueLabel: "SOLVE", alphaLabel: "Q", action: "7"),
        HP32Key(row: 4, col: 2, rowSpan: 1, label: "8", yellowLabel: "↑", blueLabel: "∫", alphaLabel: "R", action: "8"),
        HP32Key(row: 4, col: 3, rowSpan: 1, label: "9", yellowLabel: "▸km", blueLabel: "▸mi", alphaLabel: "S", action: "9"),
        HP32Key(row: 4, col: 4, rowSpan: 1, label: "÷", yellowLabel: "x?y", blueLabel: "x?0", alphaLabel: "", action: "÷"),
        
        // Row 5 (5 cols)
        HP32Key(row: 5, col: 0, rowSpan: 1, label: "yellow", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "SHIFT_YELLOW"),
        HP32Key(row: 5, col: 1, rowSpan: 1, label: "4", yellowLabel: "▸θ,r", blueLabel: "▸𝑦,𝑥", alphaLabel: "T", action: "4"),
        HP32Key(row: 5, col: 2, rowSpan: 1, label: "5", yellowLabel: "▸HR", blueLabel: "▸HMS", alphaLabel: "U", action: "5"),
        HP32Key(row: 5, col: 3, rowSpan: 1, label: "6", yellowLabel: "▸DEG", blueLabel: "▸RAD", alphaLabel: "V", action: "6"),
        HP32Key(row: 5, col: 4, rowSpan: 1, label: "×", yellowLabel: "BASE", blueLabel: "FLAGS", alphaLabel: "", action: "×"),
        
        // Row 6 (5 cols)
        HP32Key(row: 6, col: 0, rowSpan: 1, label: "blue", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "SHIFT_BLUE"),
        HP32Key(row: 6, col: 1, rowSpan: 1, label: "1", yellowLabel: "▸kg", blueLabel: "▸lb", alphaLabel: "W", action: "1"),
        HP32Key(row: 6, col: 2, rowSpan: 1, label: "2", yellowLabel: "▸°C", blueLabel: "▸°F", alphaLabel: "X", action: "2"),
        HP32Key(row: 6, col: 3, rowSpan: 1, label: "3", yellowLabel: "▸cm", blueLabel: "▸in", alphaLabel: "Y", action: "3"),
        HP32Key(row: 6, col: 4, rowSpan: 1, label: "-", yellowLabel: "▸l", blueLabel: "▸gal", alphaLabel: "", action: "-"),
        
        // Row 7 (5 cols)
        HP32Key(row: 7, col: 0, rowSpan: 1, label: "C", yellowLabel: "", blueLabel: "OFF", alphaLabel: "", action: "C"),
        HP32Key(row: 7, col: 1, rowSpan: 1, label: "0", yellowLabel: "REGS", blueLabel: "VIEW", alphaLabel: "Z", action: "0"),
        HP32Key(row: 7, col: 2, rowSpan: 1, label: ".", yellowLabel: "FDISP", blueLabel: "/c", alphaLabel: "", action: "."),
        HP32Key(row: 7, col: 3, rowSpan: 1, label: "PLOT", yellowLabel: "CONST", blueLabel: "", alphaLabel: "", action: "PLOT"),
        HP32Key(row: 7, col: 4, rowSpan: 1, label: "+", yellowLabel: "LBL", blueLabel: "RTN", alphaLabel: "", action: "+")
    ]
    
        public static let landscapeGrid: [HP32Key] = [
        // Voyage Layout (HP-15C style geometry)
        // 4 Rows total, 11 columns. Numpad on the right (4 rows x 4 cols).
        // Middle separator (col 6) with vertical ENTER. Functions on the left (4 rows x 6 cols).
        
        // Row 0
        HP32Key(row: 0, col: 0, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "LFU_0"),
        HP32Key(row: 0, col: 1, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "LFU_1"),
        HP32Key(row: 0, col: 2, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "LFU_2"),
        HP32Key(row: 0, col: 3, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "LFU_3"),
        HP32Key(row: 0, col: 4, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "LFU_4"),
        HP32Key(row: 0, col: 5, rowSpan: 1, label: "", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "LFU_5"),
        HP32Key(row: 0, col: 6, rowSpan: 1, label: "<-", yellowLabel: "CLEAR", blueLabel: "", alphaLabel: "", action: "<-"),
        HP32Key(row: 0, col: 7, rowSpan: 1, label: "7", yellowLabel: "↓", blueLabel: "SOLVE", alphaLabel: "Q", action: "7"),
        HP32Key(row: 0, col: 8, rowSpan: 1, label: "8", yellowLabel: "↑", blueLabel: "∫", alphaLabel: "R", action: "8"),
        HP32Key(row: 0, col: 9, rowSpan: 1, label: "9", yellowLabel: "▸km", blueLabel: "▸mi", alphaLabel: "S", action: "9"),
        HP32Key(row: 0, col: 10, rowSpan: 1, label: "÷", yellowLabel: "x?y", blueLabel: "x?0", alphaLabel: "", action: "÷"),
        
        // Row 1
        HP32Key(row: 1, col: 0, rowSpan: 1, label: "√𝑥", yellowLabel: "𝑥²", blueLabel: "PARTS", alphaLabel: "A", action: "√x"),
        HP32Key(row: 1, col: 1, rowSpan: 1, label: "𝑒ˣ", yellowLabel: "10ˣ", blueLabel: "PROB", alphaLabel: "B", action: "e^x"),
        HP32Key(row: 1, col: 2, rowSpan: 1, label: "LN", yellowLabel: "LOG", blueLabel: "L.R.", alphaLabel: "C", action: "LN"),
        HP32Key(row: 1, col: 3, rowSpan: 1, label: "𝑦ˣ", yellowLabel: "ˣ√𝑦", blueLabel: "x̄,ȳ", alphaLabel: "D", action: "y^x"),
        HP32Key(row: 1, col: 4, rowSpan: 1, label: "¹/𝑥", yellowLabel: "𝑥!", blueLabel: "s,σ", alphaLabel: "E", action: "1/x"),
        HP32Key(row: 1, col: 5, rowSpan: 1, label: "Σ+", yellowLabel: "Σ-", blueLabel: "SUMS", alphaLabel: "F", action: "Σ+"),
        HP32Key(row: 1, col: 6, rowSpan: 1, label: "XEQ", yellowLabel: "FN=", blueLabel: "", alphaLabel: "", action: "XEQ"),
        HP32Key(row: 1, col: 7, rowSpan: 1, label: "4", yellowLabel: "▸θ,r", blueLabel: "▸𝑦,𝑥", alphaLabel: "T", action: "4"),
        HP32Key(row: 1, col: 8, rowSpan: 1, label: "5", yellowLabel: "▸HR", blueLabel: "▸HMS", alphaLabel: "U", action: "5"),
        HP32Key(row: 1, col: 9, rowSpan: 1, label: "6", yellowLabel: "▸DEG", blueLabel: "▸RAD", alphaLabel: "V", action: "6"),
        HP32Key(row: 1, col: 10, rowSpan: 1, label: "×", yellowLabel: "BASE", blueLabel: "FLAGS", alphaLabel: "", action: "×"),
        
        // Row 2
        HP32Key(row: 2, col: 0, rowSpan: 1, label: "STO", yellowLabel: "CMPLX", blueLabel: "EQN", alphaLabel: "G", action: "STO"),
        HP32Key(row: 2, col: 1, rowSpan: 1, label: "RCL", yellowLabel: "RND", blueLabel: "SCRL", alphaLabel: "H", action: "RCL"),
        HP32Key(row: 2, col: 2, rowSpan: 1, label: "R↓", yellowLabel: "HYP", blueLabel: "R↑", alphaLabel: "I", action: "R↓"),
        HP32Key(row: 2, col: 3, rowSpan: 1, label: "SIN", yellowLabel: "ASIN", blueLabel: "π", alphaLabel: "J", action: "SIN"),
        HP32Key(row: 2, col: 4, rowSpan: 1, label: "COS", yellowLabel: "ACOS", blueLabel: "%", alphaLabel: "K", action: "COS"),
        HP32Key(row: 2, col: 5, rowSpan: 1, label: "TAN", yellowLabel: "ATAN", blueLabel: "%CHG", alphaLabel: "L", action: "TAN"),
        HP32Key(row: 2, col: 6, rowSpan: 2, label: "ENTER", yellowLabel: "LAST𝑥", blueLabel: "SHOW", alphaLabel: "M", action: "ENTER"),
        HP32Key(row: 2, col: 7, rowSpan: 1, label: "1", yellowLabel: "▸kg", blueLabel: "▸lb", alphaLabel: "W", action: "1"),
        HP32Key(row: 2, col: 8, rowSpan: 1, label: "2", yellowLabel: "▸°C", blueLabel: "▸°F", alphaLabel: "X", action: "2"),
        HP32Key(row: 2, col: 9, rowSpan: 1, label: "3", yellowLabel: "▸cm", blueLabel: "▸in", alphaLabel: "Y", action: "3"),
        HP32Key(row: 2, col: 10, rowSpan: 1, label: "-", yellowLabel: "▸l", blueLabel: "▸gal", alphaLabel: "", action: "-"),
        
        // Row 3
        HP32Key(row: 3, col: 0, rowSpan: 1, label: "C", yellowLabel: "", blueLabel: "OFF", alphaLabel: "", action: "C"),
        HP32Key(row: 3, col: 1, rowSpan: 1, label: "yellow", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "SHIFT_YELLOW"),
        HP32Key(row: 3, col: 2, rowSpan: 1, label: "blue", yellowLabel: "", blueLabel: "", alphaLabel: "", action: "SHIFT_BLUE"),
        HP32Key(row: 3, col: 3, rowSpan: 1, label: "x<>y", yellowLabel: "MEM", blueLabel: "𝑥><?", alphaLabel: "N", action: "𝑥><𝑦"),
        HP32Key(row: 3, col: 4, rowSpan: 1, label: "+/-", yellowLabel: "MODES", blueLabel: "MOD", alphaLabel: "O", action: "+/-"),
        HP32Key(row: 3, col: 5, rowSpan: 1, label: "E", yellowLabel: "DISP", blueLabel: "INT÷", alphaLabel: "P", action: "E"),
        HP32Key(row: 3, col: 7, rowSpan: 1, label: "0", yellowLabel: "REGS", blueLabel: "VIEW", alphaLabel: "Z", action: "0"),
        HP32Key(row: 3, col: 8, rowSpan: 1, label: ".", yellowLabel: "FDISP", blueLabel: "/c", alphaLabel: "", action: "."),
        HP32Key(row: 3, col: 9, rowSpan: 1, label: "PLOT", yellowLabel: "CONST", blueLabel: "", alphaLabel: "", action: "PLOT"),
        HP32Key(row: 3, col: 10, rowSpan: 1, label: "+", yellowLabel: "LBL", blueLabel: "RTN", alphaLabel: "", action: "+")
    ]
}



public func alphaLabel(for action: String) -> String? {
    if let key = HP32KeyMap.standardGrid.first(where: { $0.action == action || $0.label == action }) {
        if !key.alphaLabel.isEmpty {
            return key.alphaLabel
        }
    }
    return nil
}
