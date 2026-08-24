public class RetroUI {
    public var lfuManager: LFUManager
    public var activeMenu: CalculatorMenu?
    public var waitingForMenuDigit: MenuItem?
    public var menuAlphaQuery: String = ""
    public var menuOffset: Int = 0
    public var isShowingFullPrecision: Bool = false
    public var isShowingRegisters: Bool = false
    public var regsOffset: Int = 0
    
    // Advanced Mode emulation vars
    public enum SoftkeyMode { case none, solve, integrate, plot, xeq }
    public var softkeyMode: SoftkeyMode = .none
    public var softkeyProgram: CalculatorEngine.Program? = nil
    public var softkeySelectedVar: String = "X"
    
    // Formatter hook injected by platform
    public var doubleFormatter: ((Double, CalculatorEngine.DisplayMode) -> String)?
    
    public init(lfuManager: LFUManager) {
        self.lfuManager = lfuManager
    }
    
    public func render(engine: CalculatorEngine, renderer: Renderer) {
        renderer.clear()
        
        if engine.isTestMode {
            for y in 0..<240 {
                for x in 0..<400 {
                    if (x + y) % 2 == 0 { renderer.setPixel(x: x, y: y, color: true) }
                }
            }
            let testNode = FirmwareBackground(color: false, child: FirmwareFrame(width: 340, height: 80, child: FirmwareText("HP-32SII TEST OK", font: .display, color: true)))
            testNode.draw(in: renderer, x: 30, y: 80)
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
        
        // Split indicators into two groups
        var leftIndicators: [FirmwareView] = []
        var rightIndicators: [FirmwareView] = []
        
        for (index, indicator) in indicators.enumerated() {
            if index < indicators.count / 2 { leftIndicators.append(indicator) }
            else { rightIndicators.append(indicator) }
        }
        
        let leftRow = FirmwareHStack(alignment: .center, spacing: 6, children: leftIndicators)
        let rightRow = FirmwareHStack(alignment: .center, spacing: 6, children: rightIndicators)
        let topBar = FirmwarePadding(top: 6, leading: 6, trailing: 6, child: FirmwareHStack(alignment: .center, children: [
            leftRow,
            FirmwareSpacer(),
            rightRow
        ]))
        
        // --- 2. Main Content Area ---
        var mainContent: FirmwareView = FirmwareSpacer()
        
        if isShowingFullPrecision {
            let valStr = "\(engine.stack.first?.real ?? 0.0)"
            var i = 0
            let maxChars = 12
            var textNodes: [FirmwareView] = []
            while i < valStr.count {
                let start = valStr.index(valStr.startIndex, offsetBy: i)
                let end = valStr.index(start, offsetBy: min(maxChars, valStr.count - i))
                textNodes.append(FirmwareText(String(valStr[start..<end]), font: .medium, color: true))
                i += maxChars
            }
            mainContent = FirmwarePadding(leading: 6, child: FirmwareVStack(alignment: .leading, spacing: -12, children: textNodes))
            
        } else if engine.isBuildingNumber || engine.isWaitingForAlpha {
            var charNodes: [FirmwareView] = []
            engine.displayXBuffer.withUnsafeBufferPointer { ptr in
                let len = min(engine.displayXLength, 64)
                for i in 0..<len {
                    if let scalar = UnicodeScalar(UInt32(ptr[i])) {
                        charNodes.append(FirmwareText(String(scalar), font: .large))
                    }
                }
            }
            let hasCursor = engine.isBuildingNumber || engine.prgmIsBuildingNumber || engine.isWaitingForAlpha
            if hasCursor {
                // Approximate a block cursor underneath
                charNodes.append(FirmwareVStack(alignment: .center, children: [
                    FirmwareSpacer(minWidth: 18, minHeight: FontData.Large.charHeight - 6),
                    FirmwareRect(width: 18, height: 6, color: true)
                ]))
            }
            
            let textStack = FirmwareHStack(alignment: .bottom, spacing: 0, children: charNodes)
            let textW = textStack.size(in: renderer).width
            
            if textW > 396 {
                // Overflow mode: right-align and add '<'
                mainContent = FirmwareHStack(alignment: .bottom, spacing: 0, children: [
                    FirmwareText("<", font: .large),
                    FirmwareFrame(width: 396 - renderer.getStringWidth("<", size: .large), alignment: .trailing, child: textStack)
                ])
            } else {
                mainContent = FirmwarePadding(leading: 6, child: textStack)
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
            
            var stackLines: [FirmwareView] = []
            for i in 0..<4 {
                let regIdx = regsOffset + (3 - i)
                let name = getRegName(regIdx)
                let valStr = doubleFormatter?(getRegVal(regIdx), engine.displayMode) ?? "\(getRegVal(regIdx))"
                stackLines.append(FirmwareText("\(name) \(valStr)", font: .small))
            }
            mainContent = FirmwarePadding(leading: 6, child: FirmwareVStack(alignment: .leading, spacing: 6, children: stackLines))
            
        } else {
            // HP-32SII Single Number Display (X register)
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
            
            let textW = renderer.getStringWidth(valStr, size: .large)
            if textW > 390 {
                mainContent = FirmwareHStack(alignment: .bottom, spacing: 0, children: [
                    FirmwareText("<", font: .large),
                    FirmwareFrame(width: 390 - renderer.getStringWidth("<", size: .large), alignment: .trailing, child: FirmwareText(valStr, font: .large))
                ])
            } else {
                mainContent = FirmwarePadding(leading: 6, child: FirmwareText(valStr, font: .large))
            }
        }
        
        // Wraps main content vertically
        let body = FirmwareFrame(width: 400, height: 160, alignment: .leading, vAlignment: .center, child: mainContent)
        
        // --- 3. Bottom Softkeys (Menus / LFU) ---
        var footer: FirmwareView = FirmwareSpacer()
        let hideSoftkeys = isShowingRegisters || isShowingFullPrecision
        
        if !hideSoftkeys {
            let menuActive = activeMenu != nil || waitingForMenuDigit != nil || softkeyMode != .none || engine.alphaAction == .fnEq
            if menuActive {
                if let menu = activeMenu {
                    // Temporarily using renderer.renderMenu as it might still contain manual logic
                    // We'll wrap it in a custom FirmwareView or skip rewriting renderMenu for this pass
                    // wait, renderMenu draws directly to renderer!
                    // Let's implement the menu drawing here directly as a FirmwareView
                    var items = MenuSystem.filter(menu: menu, query: menuAlphaQuery)
                    let visibleItems = Array(items.dropFirst(menuOffset))
                    
                    var softkeyNodes: [FirmwareView] = []
                    for i in 0..<min(6, visibleItems.count) {
                        let segment = renderer.menuSegments[i]
                        let item = visibleItems[i]
                        let label = (i == 5 && visibleItems.count > 6) ? "..." : item.label
                        let btnText = FirmwareText(label, font: .tiny, color: false)
                        let btnBackground = FirmwareBackground(color: true, child: FirmwareFrame(width: segment.w, height: 36, child: btnText))
                        softkeyNodes.append(btnBackground)
                    }
                    footer = FirmwareHStack(alignment: .bottom, spacing: 0, children: softkeyNodes)
                } else if softkeyMode != .none {
                    var items: [MenuItem] = []
                    if softkeyProgram == nil {
                        for prog in engine.programs {
                            items.append(MenuItem(label: prog.label, action: "SOFTKEY_PRG_\(prog.label)"))
                        }
                    } else {
                        let vars = softkeyProgram!.extractVariables()
                        for v in vars.sorted() {
                            let hasVal = (engine.variables[v]?.real ?? 0.0) != 0.0
                            let label = hasVal ? "@\(v)" : " \(v)"
                            items.append(MenuItem(label: label, action: "SOFTKEY_VAR_\(v)"))
                        }
                        if softkeyMode == .plot || softkeyMode == .xeq {
                            items.append(MenuItem(label: "EXEC", action: "SOFTKEY_EXEC"))
                        }
                    }
                    
                    var softkeyNodes: [FirmwareView] = []
                    for i in 0..<min(6, items.count) {
                        let segment = renderer.menuSegments[i]
                        let item = items[i]
                        let btnText = FirmwareText(item.label, font: .tiny, color: false)
                        let btnBackground = FirmwareBackground(color: true, child: FirmwareFrame(width: segment.w, height: 36, child: btnText))
                        softkeyNodes.append(btnBackground)
                    }
                    footer = FirmwareHStack(alignment: .bottom, spacing: 0, children: softkeyNodes)
                } else if engine.alphaAction == .fnEq {
                    var items: [MenuItem] = []
                    for prog in engine.programs {
                        items.append(MenuItem(label: prog.label, action: prog.label))
                    }
                    let visibleItems = Array(items.dropFirst(menuOffset))
                    
                    var softkeyNodes: [FirmwareView] = []
                    for i in 0..<min(6, visibleItems.count) {
                        let segment = renderer.menuSegments[i]
                        let item = visibleItems[i]
                        let label = (i == 5 && visibleItems.count > 6) ? "..." : item.label
                        let btnText = FirmwareText(label, font: .tiny, color: false)
                        let btnBackground = FirmwareBackground(color: true, child: FirmwareFrame(width: segment.w, height: 36, child: btnText))
                        softkeyNodes.append(btnBackground)
                    }
                    footer = FirmwareHStack(alignment: .bottom, spacing: 0, children: softkeyNodes)
                }
            } else if !engine.isGeneratingPlot && !engine.isPlotLoading {
                if engine.requestPlot {
                    var softkeyNodes: [FirmwareView] = []
                    for i in 0..<6 {
                        let segment = renderer.menuSegments[i]
                        let isSelected = engine.selectedPlotMarkerIndex == i
                        let btnText = FirmwareText("R\(i + 1)", font: .tiny, color: isSelected)
                        let btnBackground = FirmwareBackground(color: !isSelected, child: FirmwareFrame(width: segment.w, height: 36, child: btnText))
                        softkeyNodes.append(btnBackground)
                    }
                    footer = FirmwareHStack(alignment: .bottom, spacing: 0, children: softkeyNodes)
                } else {
                    // Fallback to manual LFU drawing for now (since we don't know its internals)
                    // We'll wrap it in a custom FirmwareView block
                    // Since LFUManager is its own thing, we will draw it manually in the screen tree
                }
            }
        }
        
        let screen = FirmwareVStack(alignment: .leading, spacing: 0, children: [
            FirmwareFrame(width: 400, height: 40, alignment: .leading, vAlignment: .top, child: topBar),
            body,
            FirmwareFrame(width: 400, height: 40, alignment: .leading, vAlignment: .bottom, child: footer)
        ])
        
        screen.draw(in: renderer, x: 0, y: 0)
        
        // Handle custom rendering bypasses
        if !hideSoftkeys && !(activeMenu != nil || waitingForMenuDigit != nil || softkeyMode != .none || engine.alphaAction == .fnEq) && !engine.isGeneratingPlot && !engine.isPlotLoading && !engine.requestPlot {
             renderer.renderLFU(manager: lfuManager)
        }
        if engine.isEquationMode && !(engine.isProgrammingMode || engine.isBuildingNumber || engine.isWaitingForAlpha) {
            // Draw equation plotting logic on top (this should probably be refactored into the FirmwareView tree too)
            // But we'll leave this untouched for parity correctness
        }
    }
}


