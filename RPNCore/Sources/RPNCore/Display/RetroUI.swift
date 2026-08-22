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
    
    // Advanced Mode emulation vars
    public enum C47Mode { case none, solve, integrate, plot, xeq }
    public var c47Mode: C47Mode = .none
    public var c47Program: CalculatorEngine.Program? = nil
    public var c47SelectedVar: String = "X"
    
    // Formatter hook injected by platform
    public var doubleFormatter: ((Double, CalculatorEngine.DisplayMode) -> String)?
    
    public init(lfuManager: LFUManager) {
        self.lfuManager = lfuManager
    }
    
    public func render(engine: CalculatorEngine, renderer: Renderer) {
        renderer.clear()
        
        if engine.isTestMode {
            for y in 0..<64 {
                for x in 0..<128 {
                    if (x + y) % 2 == 0 { renderer.setPixel(x: x, y: y, color: true) }
                }
            }
            renderer.fillRect(x: 10, y: 20, w: 108, h: 24, color: false)
            renderer.drawString("HP-32SII TEST OK", x: 14, y: 26, size: .small, color: true)
            return
        }
        
        // --- 1. Top Annunciators (Indicators) ---
        var indicators: [FirmwareView] = []
        if engine.shiftState == 1 { indicators.append(FirmwareText("↰", font: .small)) }
        if engine.shiftState == 2 { indicators.append(FirmwareText("↱", font: .small)) }
        if engine.angleMode == .rad { indicators.append(FirmwareText("RAD", font: .small)) }
        else if engine.angleMode == .grd { indicators.append(FirmwareText("GRD", font: .small)) }
        
        if engine.complexMode { indicators.append(FirmwareText("CMPLX", font: .small)) }
        if engine.isExamMode { indicators.append(FirmwareText("EXAM", font: .small)) }
        if !engine.autoReturnToMainPad { indicators.append(FirmwareText("STAY", font: .small)) }
        
        if engine.isProgrammingMode || engine.isEquationMode {
            indicators.append(FirmwareText("EQN", font: .small))
        }
        
        if engine.isHypPending { indicators.append(FirmwareText("HYP", font: .small)) }
        if engine.isWaitingForAlpha { indicators.append(FirmwareText("A..Z", font: .small)) }
        if engine.isStatPlot { indicators.append(FirmwareText("STAT", font: .small)) }
        if engine.hasStackData { indicators.append(FirmwareText("↑", font: .small)) }
        
        if engine.baseMode == .hex { indicators.append(FirmwareText("HEX", font: .small)) }
        else if engine.baseMode == .oct { indicators.append(FirmwareText("OCT", font: .small)) }
        else if engine.baseMode == .bin { indicators.append(FirmwareText("BIN", font: .small)) }
        
        // Split indicators into two groups to prevent overflowing the 128px screen limit
        var leftIndicators: [FirmwareView] = []
        var rightIndicators: [FirmwareView] = []
        
        for (index, indicator) in indicators.enumerated() {
            if index < indicators.count / 2 {
                leftIndicators.append(indicator)
            } else {
                rightIndicators.append(indicator)
            }
        }
        
        // Distribute spacing tightly to prevent truncation (especially of EQN)
        let leftRow = FirmwareHStack(alignment: .center, spacing: 2, children: leftIndicators)
        leftRow.draw(in: renderer, x: 2, y: 2)
        
        let rightRow = FirmwareHStack(alignment: .center, spacing: 2, children: rightIndicators)
        // Measure right side to right-align it
        let rightWidth = 126 - 2 // Arbitrary right bound
        rightRow.draw(in: renderer, x: max(64, rightWidth - 50), y: 2) // We can just draw at x: 64 to split it

        
        // --- 2. Bottom Softkeys (Menus / LFU) ---
        let hideSoftkeys = isShowingRegisters || isShowingFullPrecision
        if !hideSoftkeys {
            let menuActive = activeMenu != nil || waitingForMenuDigit != nil || c47Mode != .none
            if menuActive {
                if let menu = activeMenu {
                    renderer.renderMenu(menu: menu, query: menuAlphaQuery, offset: menuOffset)
                } else if c47Mode != .none {
                    // Emulate Advanced Menu (Simplified for Layout)
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
                    
                    for i in 0..<min(6, items.count) {
                        let item = items[i]
                        let segment = renderer.menuSegments[i]
                        renderer.fillRect(x: segment.x, y: 54, w: segment.w, h: 10, color: true)
                        let textW = renderer.getStringWidth(item.label, size: .tiny)
                        let textX = max(segment.x, segment.x + (segment.w - textW) / 2)
                        renderer.drawString(item.label, x: textX, y: 55, size: .tiny, color: false)
                    }
                } else if let pending = waitingForMenuDigit {
                    FirmwareText("\(pending.action) _", font: .tiny).draw(in: renderer, x: 2, y: 53)
                }
    
            } else if !engine.isGeneratingPlot && !engine.isPlotLoading {
                if engine.requestPlot {
                    for i in 0..<6 {
                        let segment = renderer.menuSegments[i]
                        let isSelected = engine.selectedPlotMarkerIndex == i
                        renderer.fillRect(x: segment.x, y: 54, w: segment.w, h: 10, color: !isSelected)
                        let label = "R\(i + 1)"
                        let textW = renderer.getStringWidth(label, size: .tiny)
                        let textX = max(segment.x, segment.x + (segment.w - textW) / 2)
                        renderer.drawString(label, x: textX, y: 55, size: .tiny, color: isSelected)
                    }
                } else {
                    renderer.renderLFU(manager: lfuManager)
                }
            }
        }
        
        // --- 3. Main Content Area (Y: 12 to 52) ---
        if isShowingFullPrecision {
            let valStr = "\(engine.stack.first?.real ?? 0.0)"
            var i = 0
            let maxChars = 14
            var textNodes: [FirmwareView] = []
            while i < valStr.count {
                let start = valStr.index(valStr.startIndex, offsetBy: i)
                let end = valStr.index(start, offsetBy: min(maxChars, valStr.count - i))
                textNodes.append(FirmwareText(String(valStr[start..<end]), font: .medium, color: true))
                i += maxChars
            }
            // Use spacing -4 to mimic the previous lineY += 12 behavior (16 - 4 = 12)
            let overlay = FirmwarePadding(top: 14, leading: 2, child: FirmwareVStack(alignment: .leading, spacing: -4, children: textNodes))
            overlay.draw(in: renderer, x: 0, y: 0)
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
            
            // Display a single register at a time, left-justified
            let regIdx = regsOffset
            let name = getRegName(regIdx)
            let valStr = doubleFormatter?(getRegVal(regIdx), engine.displayMode) ?? "\(getRegVal(regIdx))"
            
            let displayStr = "\(name)\(valStr)"
            let textW = renderer.getStringWidth(displayStr, size: .display)
            if textW > 124 {
                FirmwareText("<", font: .display).draw(in: renderer, x: 0, y: 24)
                let overflowOffset = 124 - textW
                FirmwareText(displayStr, font: .display).draw(in: renderer, x: overflowOffset, y: 24)
            } else {
                FirmwareText(displayStr, font: .display).draw(in: renderer, x: 2, y: 24)
            }
        } else if let error = engine.errorMessage {
            FirmwareText(error, font: .display).draw(in: renderer, x: 2, y: 24)
        } else if let status = engine.statusMessage {
            FirmwareText(status, font: .display).draw(in: renderer, x: 2, y: 24)
        } else if let transient = engine.transientMessage {
            FirmwareText(transient, font: .display).draw(in: renderer, x: 2, y: 24)
        } else if let prompt = engine.promptString {
            FirmwareText("\(prompt) _", font: .display).draw(in: renderer, x: 2, y: 24)
        } else if engine.isGeneratingPlot || engine.isPlotLoading {
            FirmwareText("LOADING PLOT...", font: .small).draw(in: renderer, x: 2, y: 24)
        } else if engine.requestPlot && !engine.plotData.isEmpty {
            // Render Plot graph curve and point cursor searching via LFU keys
            let minX = engine.plotData.map { $0.0 }.min() ?? -10.0
            let maxX = engine.plotData.map { $0.0 }.max() ?? 10.0
            let minY = engine.plotData.map { $0.1 }.min() ?? -10.0
            let maxY = engine.plotData.map { $0.1 }.max() ?? 10.0
            
            let rangeX = max(1e-6, maxX - minX)
            let rangeY = max(1e-6, maxY - minY)
            
            for pt in engine.plotData {
                let px = Int(((pt.0 - minX) / rangeX) * 127.0)
                let py = 52 - Int(((pt.1 - minY) / rangeY) * 38.0)
                renderer.setPixel(x: px, y: py, color: true)
            }
            
            if let idx = engine.selectedPlotMarkerIndex {
                var selectedPoint: (Double, Double)? = nil
                if idx < engine.plotMarkers.count {
                    selectedPoint = engine.plotMarkers[idx]
                } else if !engine.plotData.isEmpty {
                    let step = engine.plotData.count / 6
                    let sampleIdx = min(engine.plotData.count - 1, idx * step)
                    selectedPoint = engine.plotData[sampleIdx]
                }
                
                if let (ptX, ptY) = selectedPoint {
                    let px = Int(((ptX - minX) / rangeX) * 127.0)
                    let py = 52 - Int(((ptY - minY) / rangeY) * 38.0)
                    
                    renderer.setPixel(x: px - 1, y: py, color: true)
                    renderer.setPixel(x: px + 1, y: py, color: true)
                    renderer.setPixel(x: px, y: py - 1, color: true)
                    renderer.setPixel(x: px, y: py + 1, color: true)
                    
                    let xStr = doubleFormatter?(ptX, engine.displayMode) ?? "\(ptX)"
                    let yStr = doubleFormatter?(ptY, engine.displayMode) ?? "\(ptY)"
                    renderer.drawString("X:\(xStr) Y:\(yStr)", x: 2, y: 12, size: .small, color: true)
                }
            }
        } else if engine.isProgrammingMode || engine.isEquationMode {
            // Draw 4 lines of equations, correctly spaced
            let steps = engine.currentProgramSteps
            let maxScroll = max(0, steps.count - 4)
            programScrollOffset = min(programScrollOffset, maxScroll)
            let startIndex = max(0, steps.count - 4 - programScrollOffset)
            
            var eqLines: [FirmwareView] = []
            for i in startIndex..<min(steps.count, startIndex + 4) {
                let stepNum = i + 1
                let stepNumStr = stepNum < 10 ? "0\(stepNum)" : "\(stepNum)"
                eqLines.append(FirmwareText("\(stepNumStr): \(steps[i])", font: .small))
            }
            let eqStack = FirmwareVStack(alignment: .leading, spacing: 2, children: eqLines)
            eqStack.draw(in: renderer, x: 2, y: 14)
            
        } else if engine.isBuildingNumber || engine.isWaitingForAlpha {
            let hasCursor = engine.isBuildingNumber || engine.prgmIsBuildingNumber || engine.isWaitingForAlpha
            var textW = 0
            engine.displayXBuffer.withUnsafeBufferPointer { ptr in
                let len = min(engine.displayXLength, 64)
                for i in 0..<len {
                    if let glyph = FontData.Display.glyph(forScalar: UInt32(ptr[i])) {
                        textW += glyph.width + 1
                    }
                }
            }
            if hasCursor {
                if let glyph = FontData.Display.glyph(forScalar: 95) { // '_'
                    textW += glyph.width + 1
                }
            }
            
            var startX = 2
            if textW > 124 {
                FirmwareText("<", font: .display).draw(in: renderer, x: 0, y: 24)
                startX = 124 - textW
            }
            
            engine.displayXBuffer.withUnsafeBufferPointer { ptr in
                let len = min(engine.displayXLength, 64)
                for i in 0..<len {
                    let w = renderer.drawChar(UInt32(ptr[i]), x: startX, y: 24, size: .display, color: true)
                    startX += w + 1
                }
            }
            if hasCursor {
                _ = renderer.drawChar(95, x: startX, y: 24, size: .display, color: true)
            }
        } else {
            // HP-32SII Single Number Display (X register) - Left-Justified starting at X: 2
            var valStr = ""
            #if hasFeature(Embedded)
            engine.displayXBuffer.withUnsafeBufferPointer { ptr in
                let len = min(engine.displayXLength, 64)
                let buf = UnsafeBufferPointer(start: ptr.baseAddress, count: len)
                valStr = String(decoding: buf, as: UTF8.self)
            }
            #else
            let xVal = engine.stack.first?.real ?? 0.0
            valStr = doubleFormatter?(xVal, engine.displayMode) ?? "\(xVal)"
            #endif
            
            let textW = renderer.getStringWidth(valStr, size: .display)
            if textW > 124 {
                FirmwareText("<", font: .display).draw(in: renderer, x: 0, y: 24)
                let overflowOffset = 124 - textW
                FirmwareText(valStr, font: .display).draw(in: renderer, x: overflowOffset, y: 24)
            } else {
                FirmwareText(valStr, font: .display).draw(in: renderer, x: 2, y: 24)
            }
        }
    }
}


