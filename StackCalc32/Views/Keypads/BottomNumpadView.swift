import SwiftUI
import RPNCore

struct BottomNumpadView: View {
    @Environment(CalculatorEngine.self) var engine
    @EnvironmentObject var themeManager: ThemeManager

    @Binding var horizontalPage: Int
    @Binding var verticalPage: Int

    var body: some View {
        Group {
            if horizontalPage == 0 {
                AlphaLFUPadView { op in handleMenuOp(op) }
            } else if horizontalPage == 2 {
                ArithmeticPadView { op in handleMenuOp(op) }
            } else {
                if verticalPage == 0 {
                    NumericPadView() { op in handleMenuOp(op) }
                } else {
                    UpperMatrixPadView { op in handleMenuOp(op) }
                }
            }
        }
        .contentShape(Rectangle())
        .background(
            Color.black.opacity(0.01)
                .accessibilityIdentifier("numpad_bg")
        )
    }

    private func handleMenuOp(_ op: CalculatorOperation) {
        // Special direct-input ops
        if op == .sto {
            engine.startSto()
            withAnimation { horizontalPage = 0 }
            return
        } else if op == .rcl {
            engine.startRcl()
            withAnimation { horizontalPage = 0 }
            return
        }

        // CalculatorMenu menus — route via engine.activeMenu (covers all menus, including
        // clear/flags/mem/regs/const which were previously posted as unhandled notifications)
        if let menu = menuForOp(op) {
            engine.activeMenu = menu
            autoReturn()
            return
        }

        // Special-sheet ops like .eqn/.solve/.show are passed through here.
        // Regular keys (digits, +, -, etc.) have ALREADY been executed by dispatchKey in CalcButton.
        if menuCommands.contains(op) {
            engine.executeOp(op)
        }

        if horizontalPage == 0 && op == .enter {
            if engine.autoReturnToMainPad {
                withAnimation { horizontalPage = 1 }
            }
        }
        if verticalPage != 0 && engine.autoReturnToMainPad && !engine.isProgrammingMode {
            withAnimation { verticalPage = 0 }
        }
        if horizontalPage == 2 && engine.autoReturnToMainPad && !engine.isProgrammingMode {
            withAnimation { horizontalPage = 1 }
        }
        
        // Auto-swipe to Alpha pad when waiting for variable after STO+ / STO- / STOx / STO/
        if engine.isWaitingForAlpha && (engine.alphaAction == .stoAdd || engine.alphaAction == .stoSub || engine.alphaAction == .stoMul || engine.alphaAction == .stoDiv) {
            withAnimation { horizontalPage = 0 }
        }
    }

    private func menuForOp(_ op: CalculatorOperation) -> CalculatorMenu? {
        switch op {
        case .disp:       return .disp
        case .modes:      return .modes
        case .base:       return .base
        case .testXY:     return .testXY
        case .testX0:     return .testX0
        case .prob:       return .prob
        case .parts:      return .parts
        case .sums:       return .sums
        case .statMean:   return .statMean
        case .statStdDev: return .statStdDev
        case .lr:         return .lr
        case .clear:      return .clear
        case .flags:      return .flags
        case .mem:        return .mem
        case .const:      return .const
        default:          return nil
        }
    }


    private func autoReturn() {
        if engine.autoReturnToMainPad && horizontalPage == 1 && verticalPage != 0 {
            withAnimation { verticalPage = 0 }
        }
        if horizontalPage == 2 {
            withAnimation { horizontalPage = 1 }
        }
    }
}

// MARK: - Sub-pad views (unchanged)

struct NumericPadView: View {
    var onAction: (CalculatorOperation) -> Void = { _ in }
    var body: some View {
        Grid(horizontalSpacing: 2, verticalSpacing: 2) {
            GridRow {
                CalcButton("7", yellow: "↓", blue: "SOLVE", isDigit: true, action: onAction)
                CalcButton("8", yellow: "↑", blue: "∫", isDigit: true, action: onAction)
                CalcButton("9", yellow: "▸km", blue: "▸mi", isDigit: true, action: onAction)
            }
            GridRow {
                CalcButton("4", yellow: "▸θ,𝑟", blue: "▸𝑦,𝑥", isDigit: true, action: onAction)
                CalcButton("5", yellow: "▸HR", blue: "▸HMS", isDigit: true, action: onAction)
                CalcButton("6", yellow: "▸DEG", blue: "▸RAD", isDigit: true, action: onAction)
            }
            GridRow {
                CalcButton("1", yellow: "▸kg", blue: "▸lb", isDigit: true, action: onAction)
                CalcButton("2", yellow: "▸C", blue: "▸F", isDigit: true, action: onAction)
                CalcButton("3", yellow: "▸cm", blue: "▸in", isDigit: true, action: onAction)
            }
            GridRow {
                CalcButton("0", yellow: "REGS", blue: "VIEW", isDigit: true, action: onAction)
                CalcButton(".", yellow: "FDISP", blue: "/c", isDigit: true, action: onAction)
                CalcButton("+/-", yellow: "PLOT", blue: "", isDigit: false, action: onAction)
            }
        }
    }
}

struct ArithmeticPadView: View {
    @Environment(CalculatorEngine.self) var engine
    @EnvironmentObject var themeManager: ThemeManager
    let onAction: (CalculatorOperation) -> Void
    var body: some View {
        Grid(horizontalSpacing: 2, verticalSpacing: 2) {
            GridRow {
                CalcButton("÷", yellow: "𝑥?𝑦", blue: "𝑥?0", isDigit: false) { onAction($0) }
                CalcButton("+/-", yellow: "MODES", blue: "|x|", isDigit: false) { onAction($0) }
                CalcButton("E", yellow: "DISP", blue: "÷R", isDigit: false) { onAction($0) }
            }
            GridRow {
                CalcButton("×", yellow: "BASE", blue: "FLAGS", isDigit: false) { onAction($0) }
                CalcButton("𝑥≷𝑦", yellow: "MEM", blue: "𝑥≷?", isDigit: false) { onAction($0) }
                CalcButton("<-", yellow: "CLEAR", blue: "", isDigit: false) { onAction($0) }
            }
            GridRow {
                CalcButton("-", yellow: "▸l", blue: "▸gal", isDigit: false) { onAction($0) }
                CalcButton("ENTER", yellow: "LAST𝑥", blue: "SHOW", isDigit: true) { onAction($0) }
                    .gridCellColumns(2)
            }
            GridRow {
                CalcButton("+", yellow: "LBL", blue: "RTN", isDigit: false) { onAction($0) }
                CalcButton(engine.autoReturnToMainPad ? "STAY" : "STAY ✓", yellow: "CNST", blue: "", isDigit: false) { op in
                    if op == .const {
                        onAction(op)
                    } else {
                        engine.autoReturnToMainPad.toggle()
                    }
                }
                .gridCellColumns(2)
            }
        }
    }
}

struct AlphaLFUPadView: View {
    @Environment(CalculatorEngine.self) var engine
    let onAction: (CalculatorOperation) -> Void

    private func uiLabel(for op: String) -> String {
        if op.isEmpty { return "" }
        switch op {
        case "𝑦ˣ": return "𝑦ˣ"
        case "xVy": return "ˣ√𝑦"
        case "x,y": return "𝑥,𝑦"
        case "1/𝑥": return "¹/𝑥"
        case "𝑥!": return "𝑥!"
        case "√𝑥": return "√𝑥"
        case "𝑥²": return "𝑥²"
        case "𝑒ˣ": return "𝑒ˣ"
        case "10ˣ": return "10ˣ"
        default: return op
        }
    }

    var body: some View {
        let _ = engine.lfuManager.slots
        Grid(horizontalSpacing: 2, verticalSpacing: 2) {
            GridRow {
                CalcButton("A", yellow: "I", blue: "Q", isAlpha: true) { op in onAction(op) }
                CalcButton("B", yellow: "J", blue: "R", isAlpha: true) { op in onAction(op) }
                CalcButton("C", yellow: "K", blue: "S", isAlpha: true) { op in onAction(op) }
            }
            GridRow {
                CalcButton("D", yellow: "L", blue: "T", isAlpha: true) { op in onAction(op) }
                CalcButton("E", yellow: "M", blue: "U", isAlpha: true) { op in onAction(op) }
                CalcButton("F", yellow: "N", blue: "V", isAlpha: true) { op in onAction(op) }
            }
            GridRow {
                CalcButton("G", yellow: "O", blue: "W", isAlpha: true) { op in onAction(op) }
                CalcButton("H", yellow: "P", blue: "_", isAlpha: true) { op in onAction(op) }
                CalcButton("XEQ", yellow: uiLabel(for: engine.lfuManager.getFunction(for: 0)), blue: "FN=", isAlpha: true) { op in
                    onAction(op)
                }
            }
            GridRow {
                CalcButton("X", yellow: uiLabel(for: engine.lfuManager.getFunction(for: 1)), blue: uiLabel(for: engine.lfuManager.getFunction(for: 2)), isAlpha: true) { op in
                    onAction(op)
                }
                CalcButton("Y", yellow: uiLabel(for: engine.lfuManager.getFunction(for: 3)), blue: uiLabel(for: engine.lfuManager.getFunction(for: 4)), isAlpha: true) { op in
                    onAction(op)
                }
                CalcButton("Z", yellow: "i", blue: "(i)", isAlpha: true) { op in
                    onAction(op)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct UpperMatrixPadView: View {
    let onAction: (CalculatorOperation) -> Void
    var body: some View {
        Grid(horizontalSpacing: 2, verticalSpacing: 2) {
            GridRow {
                CalcButton("𝑦ˣ", yellow: "ˣ√𝑦", blue: "𝑥̄,𝑦̄", isDigit: false) { onAction($0) }
                CalcButton("¹/𝑥", yellow: "𝑥!", blue: "s,σ", isDigit: false) { onAction($0) }
                CalcButton("Σ+", yellow: "SUMS", blue: "Σ-", isDigit: false) { onAction($0) }
            }
            GridRow {
                CalcButton("√𝑥", yellow: "𝑥²", blue: "PARTS", isDigit: false) { onAction($0) }
                CalcButton("𝑒ˣ", yellow: "10ˣ", blue: "PROB", isDigit: false) { onAction($0) }
                CalcButton("LN", yellow: "LOG", blue: "L.R.", isDigit: false) { onAction($0) }
            }
            GridRow {
                CalcButton("SIN", yellow: "ASIN", blue: "π", isDigit: false) { onAction($0) }
                CalcButton("COS", yellow: "ACOS", blue: "%", isDigit: false) { onAction($0) }
                CalcButton("TAN", yellow: "ATAN", blue: "%CHG", isDigit: false) { onAction($0) }
            }
            GridRow {
                CalcButton("STO", yellow: "CMPLX", blue: "EQN", isDigit: false) { onAction($0) }
                CalcButton("RCL", yellow: "RND", blue: "SCRL", isDigit: false) { onAction($0) }
                CalcButton("R↓", yellow: "HYP", blue: "R↑", isDigit: false) { onAction($0) }
            }
        }
    }
}

struct StackPadView: View {
    @Environment(CalculatorEngine.self) var engine
    let onDismiss: () -> Void

    var visibleStack: [(Int, String)] {
        let logicalStack = engine.getLogicalStack()
        var maxIndex = 0
        for i in (0..<logicalStack.count).reversed() {
            if logicalStack[i].real != 0 || logicalStack[i].imag != 0 {
                maxIndex = i
                break
            }
        }
        return Array(engine.stackStrings.prefix(maxIndex + 1).enumerated())
    }

    var body: some View {
        List {
            ForEach(visibleStack, id: \.0) { index, val in
                HStack {
                    Text(levelName(index))
                        .foregroundColor(.gray)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                    Spacer()
                    Text(val)
                        .font(.system(size: 16, weight: .regular, design: .monospaced))
                }
            }
            .onDelete { indexSet in
                for index in indexSet { engine.removeStackItem(at: index) }
            }
            .onMove { indices, newOffset in
                engine.moveStackItem(fromOffsets: indices, toOffset: newOffset)
            }
        }
        .navigationTitle("Stack")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { onDismiss() }.accessibilityIdentifier("sheet_dismiss_btn")
            }
        }
    }

    private func levelName(_ index: Int) -> String {
        switch index {
        case 0: return "X"
        case 1: return "Y"
        case 2: return "Z"
        case 3: return "T"
        default: return "L\(index + 1)"
        }
    }
}
