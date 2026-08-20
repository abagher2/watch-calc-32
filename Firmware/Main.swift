func parseUInt(_ str: String) -> Int? {
    var result = 0
    var hasDigits = false
    for c in str.utf8 {
        if c >= 48 && c <= 57 {
            result = result * 10 + Int(c - 48)
            hasDigits = true
        } else if c == 45 {
            // ignore minus for now or handle appropriately if needed
            return nil
        } else {
            return nil
        }
    }
    return hasDigits ? result : nil
}

@main
struct WatchCalcFirmware {
    static var activeMenu: CalculatorMenu? = nil
    static var menuAlphaQuery: String = ""
    static var waitingForMenuDigit: MenuItem? = nil
    static var menuItemsDisplayCache: [MenuItem] = []


@inline(never)
static func dispatchUART(_ buf: UnsafePointer<UInt8>, _ len: Int, _ engine: CalculatorEngine, _ lfu: LFUManager) {
    let str = String(decoding: UnsafeBufferPointer(start: buf, count: len), as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
    
    if str == "50" { // "C"
        WatchCalcFirmware.isSleeping = false
    }
    
    if WatchCalcFirmware.isSleeping {
        return
    }
    
    if let op = CalculatorOperation.allCases.first(where: { $0.stringValue == str }) {
        processAction(op, engine: engine, lfuManager: lfu)
    } else if let id = parseUInt(str), let op = CalculatorOperation(rawValue: id) {
        processAction(op, engine: engine, lfuManager: lfu)
    } else {
        engine.executeMath(str)
    }
}

@inline(never)
static func processAction(_ op: CalculatorOperation, engine: CalculatorEngine, lfuManager: LFUManager) {
    var finalOp = op
    
    if finalOp == .show {
        isShowingFullPrecision = true
        needsDisplay = true
        return
    }
    
    if isShowingFullPrecision {
        if finalOp == .c || finalOp == .clear || finalOp == .backspace {
            isShowingFullPrecision = false
            needsDisplay = true
        }
        return
    }

    if isShowingRegisters {
        if engine.shiftState == 1 && finalOp == .digit8 { // Up arrow
            regsOffset = max(0, regsOffset - 1)
            engine.shiftState = 0
            needsDisplay = true
            return
        }
        if engine.shiftState == 1 && finalOp == .digit7 { // Down arrow
            regsOffset += 1
            engine.shiftState = 0
            needsDisplay = true
            return
        }
        if finalOp == .c || finalOp == .clear || finalOp == .backspace || finalOp == .enter {
            isShowingRegisters = false
            needsDisplay = true
            return
        }
        isShowingRegisters = false
    }
    
    if finalOp == .regs {
        isShowingRegisters = true
        regsOffset = 0
        activeMenu = nil
        needsDisplay = true
        return
    }
    
    // C47 Modes
    if finalOp == .solve || finalOp == .integrate || finalOp == .plot || finalOp == .xeq {
        if finalOp == .solve { c47Mode = .solve }
        if finalOp == .integrate { c47Mode = .integrate }
        if finalOp == .plot { c47Mode = .plot }
        if finalOp == .xeq { c47Mode = .xeq }
        c47Program = nil
        activeMenu = nil
        needsDisplay = true
        return
    }
    
    if c47Mode != .none {
        if finalOp == .c || finalOp == .clear || finalOp == .backspace {
            c47Mode = .none
            c47Program = nil
            needsDisplay = true
            return
        }
        
        if finalOp.stringValue.hasPrefix("C47_PRG_") {
            let progLabel = String(finalOp.stringValue.dropFirst(8))
            c47Program = engine.programs.first(where: { $0.label == progLabel })
            needsDisplay = true
            return
        }
        
        if finalOp.stringValue.hasPrefix("C47_VAR_") {
            let varName = String(finalOp.stringValue.dropFirst(8))
            if engine.isBuildingNumber {
                engine.commitInput()
                engine.variables[varName] = engine.stack.first ?? CalculatorValue()
            } else {
                if c47Mode == .solve, let prog = c47Program {
                    let target = engine.stack.first?.real ?? 0.0
                    engine.statusMessage = "CALCULATING"
                    // Execute solve
                    _ = engine.solve(for: varName, program: prog, target: target)
                    engine.statusMessage = nil
                    c47Mode = .none
                    c47Program = nil
                } else if c47Mode == .integrate, let prog = c47Program {
                    let upper = engine.stack.count > 0 ? engine.stack[0].real : 0.0
                    let lower = engine.stack.count > 1 ? engine.stack[1].real : 0.0
                    engine.statusMessage = "CALCULATING"
                    _ = engine.integrate(variable: varName, lower: lower, upper: upper, program: prog)
                    engine.statusMessage = nil
                    c47Mode = .none
                    c47Program = nil
                } else {
                    c47SelectedVar = varName
                }
            }
            needsDisplay = true
            return
        }
        
        if finalOp.stringValue == "C47_EXEC" {
            if c47Mode == .plot {
                engine.generatePlot(variable: c47SelectedVar, explicitMin: -10, explicitMax: 10)
                engine.requestPlot = true
            } else if c47Mode == .xeq, let prog = c47Program {
                engine.currentProgramLabel = prog.label
                _ = engine.evaluateProgram(prog, variables: engine.variables)
            }
            c47Mode = .none
            c47Program = nil
            needsDisplay = true
            return
        }
    }
    
    if finalOp == .shiftYellow {
        engine.setShift(1)
        return
    }
    if finalOp == .shiftBlue {
        engine.setShift(2)
        return
    }
    
    if engine.shiftState > 0 {
        for key in HP32KeyMap.standardGrid {
            if key.primaryAction == op {
                if engine.shiftState == 1, let yellow = key.yellowAction { finalOp = yellow }
                else if engine.shiftState == 2, let blue = key.blueAction { finalOp = blue }
                break
            }
        }
        engine.setShift(0)
    }
    
    if let pendingItem = waitingForMenuDigit {
        if let digit = parseUInt(finalOp.stringValue) {
            engine.executeMath("\(pendingItem.action) \(digit)")
        }
        waitingForMenuDigit = nil
        return
    }
    
    if let menu = activeMenu {
        if finalOp.stringValue.hasPrefix("LFU_") {
            let index = parseUInt(String(finalOp.stringValue.dropFirst(4))) ?? 0
            if index < menuItemsDisplayCache.count {
                let selected = menuItemsDisplayCache[index]
                
                if selected.requiresDigit {
                    waitingForMenuDigit = selected
                    activeMenu = nil
                } else {
                    engine.executeMath(selected.action)
                    lfuManager.recordUsage(of: selected.action)
                    activeMenu = nil
                }
            }
            return
        }
        
        if engine.isWaitingForAlpha {
            if finalOp.stringValue.count == 1 {
                menuAlphaQuery.append(finalOp.stringValue)
                menuItemsDisplayCache = MenuSystem.filter(menu: menu, query: menuAlphaQuery)
                return
            }
        }
        
        if finalOp == .backspace || finalOp == .clear || finalOp == .c {
            if !menuAlphaQuery.isEmpty {
                menuAlphaQuery.removeLast()
                menuItemsDisplayCache = MenuSystem.filter(menu: menu, query: menuAlphaQuery)
            } else {
                activeMenu = nil
            }
            return
        }
    }
    
    if let newMenu = CalculatorMenu(rawValue: finalOp.stringValue) {
        activeMenu = newMenu
        menuAlphaQuery = ""
        menuItemsDisplayCache = newMenu.items
    }
    else if finalOp.stringValue.hasPrefix("LFU_") {
        let index = parseUInt(String(finalOp.stringValue.dropFirst(4))) ?? 0
        if let funcName = lfuManager.slots[index] {
            engine.executeMath(funcName)
            lfuManager.recordUsage(of: funcName)
        }
    }
    else {
        if finalOp.stringValue.count == 1, let digit = parseUInt(finalOp.stringValue) {
            engine.digit(digit)
        } else if finalOp == .decimal {
            engine.decimal()
        } else if finalOp == .toggleSign {
            engine.toggleSign()
        } else if finalOp == .enter {
            engine.enter()
        } else if finalOp == .backspace || finalOp == .clear || finalOp == .c {
            engine.backspace()
        } else {
            engine.executeMath(finalOp.stringValue)
        }
    }
}


    static let engine = CalculatorEngine()
    static let lfuManager = LFUManager()
    static let renderer = Renderer()
    static let uartBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
    static var uartLen = 0
    static var needsDisplay = true
    static var lastActivityTime: UInt64 = 0
    static var isSleeping = false

    // UI States
    static var isShowingFullPrecision = false
    static var isShowingRegisters = false
    static var regsOffset = 0
    
    enum C47Mode {
        case none, solve, integrate, plot, xeq
    }
    static var c47Mode: C47Mode = .none
    static var c47Program: CalculatorEngine.Program? = nil
    static var c47SelectedVar: String = "X"

    @inline(never)
    static func loopIteration() {
        let now = hw_time_us()
        
        if !isSleeping && now - lastActivityTime > 60_000_000 {
            isSleeping = true
            needsDisplay = true
        }
        
        let ch = get_uart_char_c()
        if ch >= 0 {
            lastActivityTime = now
            if ch == 13 || ch == 10 {
                if uartLen > 0 {
                    dispatchUART(uartBuf, uartLen, engine, lfuManager)
                    uartLen = 0
                    needsDisplay = true
                }
                
                putchar_c(88); putchar_c(58); putchar_c(32) // "X: "
                engine.displayXBuffer.withUnsafeBufferPointer { ptr in
                    for i in 0..<engine.displayXLength {
                        putchar_c(Int32(ptr[i]))
                    }
                }
                putchar_c(10) // \n
                let yValue = engine.stack.count > 1 ? engine.stack[1].real : 0.0
                
                print("Y: ", terminator: "")
                for ch in engine.formatNumber(yValue).utf8 {
                    putchar_c(Int32(ch))
                }
                putchar_c(10) // \n
                
                for _ in 0..<32 { putchar_c(61) } // "================================"
                putchar_c(10) // \n
            } else if ch == 8 || ch == 127 {
                if uartLen > 0 {
                    uartLen -= 1
                    needsDisplay = true
                }
            } else {
                if uartLen < 31 {
                    uartBuf[uartLen] = UInt8(ch)
                    uartLen += 1
                    needsDisplay = true
                }
            }
        }
        if needsDisplay {
            renderer.clear()
            
            if isSleeping {
                var changed = false
                if let prev = renderer.previousBuffer {
                    for i in 0..<1024 {
                        if prev[i] != renderer.buffer[i] { changed = true; break }
                    }
                } else { changed = true }
                
                if changed {
                    renderer.buffer.withUnsafeBufferPointer { ptr in
                        display_send_buffer(ptr.baseAddress!)
                        if renderer.previousBuffer == nil { renderer.previousBuffer = [UInt8](repeating: 0, count: 1024) }
                        for i in 0..<1024 { renderer.previousBuffer![i] = ptr[i] }
                    }
                }
                needsDisplay = false
                return
            }
            

            let yBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 64)
            defer { yBuffer.deallocate() }
            
            if isShowingFullPrecision {
                let valStr = "\(engine.stack.first?.real ?? 0.0)"
                var lineY = 4
                var i = 0
                let maxChars = 14
                while i < valStr.count {
                    let start = valStr.index(valStr.startIndex, offsetBy: i)
                    let end = valStr.index(start, offsetBy: min(maxChars, valStr.count - i))
                    renderer.drawString(String(valStr[start..<end]), x: 2, y: lineY, size: .medium, color: true)
                    lineY += 12
                    i += maxChars
                }
                renderer.buffer.withUnsafeBufferPointer { ptr in display_send_buffer(ptr.baseAddress!) }
                needsDisplay = false
                return
            }
            
            if isShowingRegisters {
                let getRegVal: (Int) -> Double = { idx in
                    if idx < 4 {
                        return engine.stack.count > idx ? engine.stack[idx].real : 0.0
                    } else {
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
                
                for i in 0..<4 {
                    let regIdx = regsOffset + (3 - i)
                    let name = getRegName(regIdx)
                    let val = getRegVal(regIdx)
                    format_double_c(val, yBuffer, 64)
                    var len = 0
                    while len < 64 && yBuffer[len] != 0 { len += 1 }
                    let valStr = String(decoding: UnsafeBufferPointer(start: yBuffer, count: len), as: UTF8.self)
                    renderer.drawString("\(name) \(valStr)", x: 2, y: 4 + (i * 12), size: .small, color: true)
                }
                
                renderer.buffer.withUnsafeBufferPointer { ptr in display_send_buffer(ptr.baseAddress!) }
                needsDisplay = false
                return
            }
            
            let menuActive = activeMenu != nil || waitingForMenuDigit != nil || c47Mode != .none
            
            // 1. Draw Menu (bottom area y=53)
            if let menu = activeMenu {
                renderer.renderMenu(menu: menu, query: menuAlphaQuery)
            } else if c47Mode != .none {
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
                
                let segmentWidth = items.count > 0 ? 128 / min(6, items.count) : 128
                for i in 0..<min(6, items.count) {
                    let item = items[i]
                    let xOffset = i * segmentWidth
                    renderer.drawSoftkeyArrow(x: xOffset + (segmentWidth / 2) - 2, y: 50)
                    let textW = item.label.count * FontData.Tiny.charWidth
                    let textX = xOffset + (segmentWidth - textW) / 2
                    renderer.drawString(item.label, x: textX, y: 54, size: .tiny, color: true)
                }
            } else if let pending = waitingForMenuDigit {
                renderer.drawString("\(pending.action) _", x: 2, y: 53, size: .tiny, color: true)
            } else if !menuActive && !engine.isGeneratingPlot && !engine.isPlotLoading {
                renderer.renderLFU(manager: lfuManager)
            }
            
            // 2. Draw X register (dynamic font size)
            let displayFont: Renderer.FontSize = .small
            var startX = 2
            let charW = FontData.Small.charWidth
            
            let hasCursor = engine.isBuildingNumber || engine.prgmIsBuildingNumber || engine.isWaitingForAlpha
            let totalLen = engine.displayXLength + (hasCursor ? 1 : 0)
            let totalW = totalLen * charW
            var overflow = false
            
            if startX + totalW > 126 {
                startX = 126 - totalW
                overflow = true
            }
            
            engine.displayXBuffer.withUnsafeBufferPointer { ptr in
                renderer.drawString(ptr.baseAddress!, length: engine.displayXLength, x: startX, y: 28, size: displayFont, color: true)
            }
            if hasCursor {
                let cursorX = startX + (engine.displayXLength * charW)
                _ = renderer.drawChar(95, x: cursorX, y: 28, size: displayFont, color: true) // '_' is ASCII 95
            }
            if overflow {
                renderer.fillRect(x: 0, y: 28, w: charW, h: FontData.Small.charHeight, color: false)
                _ = renderer.drawChar(60, x: 0, y: 28, size: displayFont, color: true) // '<'
            }
            
            // 3. Draw Indicators
            var indX = 2
            let indY = 2
            if engine.shiftState == 1 {
                renderer.drawString("f", x: indX, y: indY, size: .small)
                indX += 12
            } else if engine.shiftState == 2 {
                renderer.drawString("g", x: indX, y: indY, size: .small)
                indX += 12
            }
            if engine.angleMode == .rad {
                renderer.drawString("RAD", x: indX, y: indY, size: .small)
                indX += 30
            }
            if engine.baseMode == .hex {
                renderer.drawString("HEX", x: indX, y: indY, size: .small)
                indX += 30
            } else if engine.baseMode == .oct {
                renderer.drawString("OCT", x: indX, y: indY, size: .small)
                indX += 30
            } else if engine.baseMode == .bin {
                renderer.drawString("BIN", x: indX, y: indY, size: .small)
                indX += 30
            }
            if engine.complexMode {
                renderer.drawString("CMPLX", x: indX, y: indY, size: .small)
                indX += 42
            }
            if engine.isHypPending {
                renderer.drawString("HYP", x: indX, y: indY, size: .small)
                indX += 30
            }
            if engine.isProgrammingMode {
                renderer.drawString("PRGM", x: indX, y: indY, size: .small)
                indX += 38
            }
            
            var changed = false
            if let prev = renderer.previousBuffer {
                for i in 0..<1024 {
                    if prev[i] != renderer.buffer[i] { changed = true; break }
                }
            } else { changed = true }
            
            if changed {
                renderer.buffer.withUnsafeBufferPointer { ptr in
                    display_send_buffer(ptr.baseAddress!)
                    if renderer.previousBuffer == nil { renderer.previousBuffer = [UInt8](repeating: 0, count: 1024) }
                    for i in 0..<1024 { renderer.previousBuffer![i] = ptr[i] }
                }
            }
            needsDisplay = false
        }
    }

    static func main() {
        print("Booted!")
        hw_init()
        
        while true {
            WatchCalcFirmware.loopIteration()
        }
    }
}
