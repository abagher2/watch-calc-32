public class RetroUI {
    public var lfuManager: LFUManager
    public var activeMenu: CalculatorMenu?
    public var waitingForMenuDigit: MenuItem?
    public var menuAlphaQuery: String = ""
    public var menuOffset: Int = 0
    public var programScrollOffset: Int = 0
    
    public var isShowingFullPrecision: Bool = false
    public var isShowingRegisters: Bool = false
    public var regsOffset: Int = 0
    
    // C47 Mode emulation vars
    public enum C47Mode { case none, solve, integrate, plot, xeq }
    public var c47Mode: C47Mode = .none
    public var c47Program: CalculatorEngine.Program? = nil
    
    // Formatter hook injected by platform
    public var doubleFormatter: ((Double, CalculatorEngine.DisplayMode) -> String)?
    
    public init(lfuManager: LFUManager) {
        self.lfuManager = lfuManager
    }
    
    public func render(engine: CalculatorEngine, renderer: Renderer) {
        renderer.clear()
        
        // --- 1. Top Annunciators (Indicators) ---
        var indicators: [View] = []
        if engine.shiftState == 1 { indicators.append(Text("f", font: .small)) }
        if engine.shiftState == 2 { indicators.append(Text("g", font: .small)) }
        if engine.angleMode == .rad { indicators.append(Text("RAD", font: .small)) }
        else if engine.angleMode == .grd { indicators.append(Text("GRD", font: .small)) }
        
        if engine.complexMode { indicators.append(Text("CMPLX", font: .small)) }
        if engine.isExamMode { indicators.append(Text("EXAM", font: .small)) }
        if !engine.autoReturnToMainPad { indicators.append(Text("STAY", font: .small)) }
        
        if engine.isProgrammingMode || engine.isEquationMode {
            indicators.append(Text("EQN", font: .small))
        }
        
        if engine.isHypPending { indicators.append(Text("HYP", font: .small)) }
        if engine.isWaitingForAlpha { indicators.append(Text("A..Z", font: .small)) }
        if engine.isStatPlot { indicators.append(Text("STAT", font: .small)) }
        if engine.hasStackData { indicators.append(Text("↑", font: .small)) }
        
        if engine.baseMode == .hex { indicators.append(Text("HEX", font: .small)) }
        else if engine.baseMode == .oct { indicators.append(Text("OCT", font: .small)) }
        else if engine.baseMode == .bin { indicators.append(Text("BIN", font: .small)) }
        
        let indicatorRow = HStack(alignment: .center, spacing: 4, children: indicators)
        indicatorRow.draw(in: renderer, x: 2, y: 2)
        
        // --- 2. Bottom Softkeys (Menus / LFU) ---
        let menuActive = activeMenu != nil || waitingForMenuDigit != nil || c47Mode != .none
        if menuActive {
            if let menu = activeMenu {
                renderer.renderMenu(menu: menu, query: menuAlphaQuery, offset: menuOffset)
            } else if c47Mode != .none {
                // Emulate C47 Menu (Simplified for Layout)
                var items: [MenuItem] = []
                if c47Program == nil {
                    for prog in engine.programs {
                        items.append(MenuItem(label: prog.label, action: "C47_PRG_\(prog.label)"))
                    }
                } else {
                    var vars = Set<String>()
                    for step in c47Program!.steps {
                        if step.count == 1 && step.first!.isLetter { vars.insert(step) }
                        else if step.hasPrefix("STO ") { vars.insert(String(step.dropFirst(4))) }
                        else if step.hasPrefix("RCL ") { vars.insert(String(step.dropFirst(4))) }
                    }
                    for v in vars.sorted() {
                        let hasVal = (engine.variables[v]?.real ?? 0.0) != 0.0
                        let label = hasVal ? "@\(v)" : " \(v)"
                        items.append(MenuItem(label: label, action: "C47_VAR_\(v)"))
                    }
                    if c47Mode == .plot || c47Mode == .xeq {
                        items.append(MenuItem(label: "EXEC", action: "C47_EXEC"))
                    }
                }
                
                let segmentWidth = 128 / 6
                for i in 0..<min(6, items.count) {
                    let item = items[i]
                    let xOffset = i * segmentWidth
                    renderer.fillRect(x: xOffset, y: 54, w: segmentWidth - 1, h: 10, color: true)
                    let textW = renderer.getStringWidth(item.label, size: .tiny)
                    let textX = max(xOffset, xOffset + (segmentWidth - 1 - textW) / 2)
                    renderer.drawString(item.label, x: textX, y: 55, size: .tiny, color: false)
                }
            } else if let pending = waitingForMenuDigit {
                Text("\(pending.action) _", font: .tiny).draw(in: renderer, x: 2, y: 53)
            }
        } else if !engine.isGeneratingPlot && !engine.isPlotLoading {
            renderer.renderLFU(manager: lfuManager)
        }
        
        // --- 3. Main Content Area (Y: 12 to 52) ---
        if isShowingFullPrecision {
            let valStr = "\(engine.stack.first?.real ?? 0.0)"
            var lineY = 14
            var i = 0
            let maxChars = 14
            while i < valStr.count {
                let start = valStr.index(valStr.startIndex, offsetBy: i)
                let end = valStr.index(start, offsetBy: min(maxChars, valStr.count - i))
                renderer.drawString(String(valStr[start..<end]), x: 2, y: lineY, size: .medium, color: true)
                lineY += 12
                i += maxChars
            }
        } else if isShowingRegisters {
            let getRegVal: (Int) -> Double = { idx in
                if idx < 4 { return engine.stack.count > idx ? engine.stack[idx].real : 0.0 }
                else {
                    let vIdx = idx - 4
                    if vIdx < 26 {
                        let c = String(Character(UnicodeScalar(65 + vIdx)!))
                        return engine.variables[c]?.real ?? 0.0
                    }
                    return 0.0
                }
            }
            let getRegName: (Int) -> String = { idx in
                if idx == 0 { return "X:" }
                if idx == 1 { return "Y:" }
                if idx == 2 { return "Z:" }
                if idx == 3 { return "T:" }
                let vIdx = idx - 4
                if vIdx < 26 { return "\(String(Character(UnicodeScalar(65 + vIdx)!))):" }
                return "?:"
            }
            
            var stackLines: [View] = []
            for i in 0..<4 {
                let regIdx = regsOffset + (3 - i)
                let name = getRegName(regIdx)
                let valStr = doubleFormatter?(getRegVal(regIdx), engine.displayMode) ?? "\(getRegVal(regIdx))"
                stackLines.append(Text("\(name) \(valStr)", font: .small))
            }
            VStack(alignment: .leading, spacing: 2, children: stackLines).draw(in: renderer, x: 2, y: 12)
        } else if let error = engine.errorMessage {
            Text(error, font: .display).draw(in: renderer, x: 2, y: 24)
        } else if let status = engine.statusMessage {
            Text(status, font: .display).draw(in: renderer, x: 2, y: 24)
        } else if let transient = engine.transientMessage {
            Text(transient, font: .display).draw(in: renderer, x: 2, y: 24)
        } else if let prompt = engine.promptString {
            Text("\(prompt) _", font: .display).draw(in: renderer, x: 2, y: 24)
        } else if engine.isGeneratingPlot || engine.isPlotLoading {
            Text("LOADING PLOT...", font: .small).draw(in: renderer, x: 2, y: 24)
        } else if engine.isProgrammingMode || engine.isEquationMode {
            // Draw 4 lines of equations, correctly spaced
            let steps = engine.currentProgramSteps
            let maxScroll = max(0, steps.count - 4)
            programScrollOffset = min(programScrollOffset, maxScroll)
            let startIndex = max(0, steps.count - 4 - programScrollOffset)
            
            var eqLines: [View] = []
            for i in startIndex..<min(steps.count, startIndex + 4) {
                let stepNum = i + 1
                let stepNumStr = stepNum < 10 ? "0\(stepNum)" : "\(stepNum)"
                eqLines.append(Text("\(stepNumStr): \(steps[i])", font: .small))
            }
            let eqStack = VStack(alignment: .leading, spacing: 2, children: eqLines)
            eqStack.draw(in: renderer, x: 2, y: 14)
            
        } else if engine.isBuildingNumber || engine.isWaitingForAlpha {
            let hasCursor = engine.isBuildingNumber || engine.prgmIsBuildingNumber || engine.isWaitingForAlpha
            var displayStr = ""
            engine.displayXBuffer.withUnsafeBufferPointer { ptr in
                let len = min(engine.displayXLength, 64)
                let buf = UnsafeBufferPointer(start: ptr.baseAddress, count: len)
                displayStr = String(decoding: buf, as: UTF8.self)
            }
            
            if hasCursor {
                displayStr += "_"
            }
            
            let textW = renderer.getStringWidth(displayStr, size: .display)
            if textW > 124 {
                Text("<", font: .display).draw(in: renderer, x: 0, y: 24)
                let overflowOffset = 124 - textW
                Text(displayStr, font: .display).draw(in: renderer, x: overflowOffset, y: 24)
            } else {
                Text(displayStr, font: .display).draw(in: renderer, x: 2, y: 24)
            }
        } else {
            // HP-32SII Single Number Display (X register) - Left-Justified starting at X: 2
            let xVal = engine.stack.first?.real ?? 0.0
            let valStr = doubleFormatter?(xVal, engine.displayMode) ?? "\(xVal)"
            
            let textW = renderer.getStringWidth(valStr, size: .display)
            if textW > 124 {
                Text("<", font: .display).draw(in: renderer, x: 0, y: 24)
                let overflowOffset = 124 - textW
                Text(valStr, font: .display).draw(in: renderer, x: overflowOffset, y: 24)
            } else {
                Text(valStr, font: .display).draw(in: renderer, x: 2, y: 24)
            }
        }



    }
}

