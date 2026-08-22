func parseUInt(_ str: String) -> Int? {
    var result = 0
    var hasDigits = false
    for c in str.utf8 {
        if c >= 48 && c <= 57 {
            result = result * 10 + Int(c - 48)
            hasDigits = true
        } else if c == 45 {
            return nil
        } else {
            return nil
        }
    }
    return hasDigits ? result : nil
}

func parseUIntBytes(_ buf: UnsafePointer<UInt8>, _ start: Int, _ end: Int) -> Int? {
    if start == end { return nil }
    var result = 0
    var hasDigits = false
    for i in start..<end {
        let c = buf[i]
        if c == 32 || c == 10 || c == 13 { continue }
        if c >= 48 && c <= 57 {
            result = result * 10 + Int(c - 48)
            hasDigits = true
        } else if c == 45 {
            return nil
        } else {
            return nil
        }
    }
    return hasDigits ? result : nil
}

func matchOpBytes(_ buf: UnsafePointer<UInt8>, _ len: Int) -> CalculatorOperation? {
    var start = 0
    var end = len
    while start < end && buf[start] <= 32 { start += 1 }
    while end > start && buf[end - 1] <= 32 { end -= 1 }
    let trimmedLen = end - start
    if trimmedLen == 0 { return nil }
    
    for op in CalculatorOperation.allCases {
        let utf8 = op.stringValue.utf8
        if utf8.count == trimmedLen {
            var match = true
            var i = 0
            for byte in utf8 {
                if byte != buf[start + i] {
                    match = false
                    break
                }
                i += 1
            }
            if match { return op }
        }
    }
    return nil
}

func isCommand(_ buf: UnsafePointer<UInt8>, _ len: Int, _ cmd: StaticString) -> Bool {
    var start = 0
    var end = len
    while start < end && buf[start] <= 32 { start += 1 }
    while end > start && buf[end - 1] <= 32 { end -= 1 }
    let trimmedLen = end - start
    
    return cmd.withUTF8Buffer { utf8 in
        if utf8.count != trimmedLen { return false }
        for i in 0..<trimmedLen {
            if utf8[i] != buf[start + i] { return false }
        }
        return true
    }
}

@main
struct WatchCalcFirmware {
    static var activeMenu: CalculatorMenu? = nil
    static var menuOffset = 0
    static var menuAlphaQuery: String = ""
    static var waitingForMenuDigit: MenuItem? = nil
    static var programScrollOffset = 0
    static var menuItemsDisplayCache: [MenuItem] = []


@inline(never)
static func dispatchUART(_ buf: UnsafePointer<UInt8>, _ len: Int, _ engine: CalculatorEngine, _ lfu: LFUManager) {
    if isCommand(buf, len, "50") { // "C"
        WatchCalcFirmware.isSleeping = false
    }
    
    if WatchCalcFirmware.isSleeping {
        return
    }
    
    if engine.isWaitingForLabel {
        if isCommand(buf, len, "<-") || isCommand(buf, len, "BACKSPACE") {
            engine.submitAlpha("<-")
        } else if isCommand(buf, len, "ENTER") {
            engine.submitAlpha("ENTER")
        } else {
            // Very rare case for waitingForLabel, convert to String as fallback
            let str = String(decoding: UnsafeBufferPointer(start: buf, count: len), as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            engine.submitAlpha(str)
        }
        needsDisplay = true
        return
    }
    
    if let op = matchOpBytes(buf, len) {
        processAction(op, engine: engine, lfuManager: lfu)
    } else if let id = parseUIntBytes(buf, 0, len), let op = CalculatorOperation(rawValue: id) {
        processAction(op, engine: engine, lfuManager: lfu)
    } else if isCommand(buf, len, "CLEAR_ALL") {
        engine.clearAll()
        isShowingRegisters = false
        isShowingFullPrecision = false
        regsOffset = 0
        needsDisplay = true
    } else {
        let str = String(decoding: UnsafeBufferPointer(start: buf, count: len), as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    if engine.isProgrammingMode || engine.isEquationMode {
        if engine.shiftState == 1 && finalOp == .digit8 { // Up arrow
            programScrollOffset += 1
            engine.shiftState = 0
            needsDisplay = true
            return
        }
        if engine.shiftState == 1 && finalOp == .digit7 { // Down arrow
            programScrollOffset = max(0, programScrollOffset - 1)
            engine.shiftState = 0
            needsDisplay = true
            return
        }
    }
    
    if finalOp == .regs {
        isShowingRegisters = true
        regsOffset = 0
        activeMenu = nil
        menuOffset = 0
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
        menuOffset = 0
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
    
    if finalOp == .off {
        WatchCalcFirmware.isSleeping = true
        needsDisplay = true
        return
    }
    
        if engine.isWaitingForAlpha {
            if finalOp.stringValue.count == 1 {
                if let menu = activeMenu {
                    menuAlphaQuery.append(finalOp.stringValue)
                    menuItemsDisplayCache = MenuSystem.filter(menu: menu, query: menuAlphaQuery)
                } else {
            engine.executeMath(finalOp.stringValue)
            lfuManager.recordUsage(of: finalOp.stringValue)
        }
                return
            }
        }
    
    if let pendingItem = waitingForMenuDigit {
        if let digit = parseUInt(finalOp.stringValue) {
            engine.executeMath("\(pendingItem.action) \(digit)")
        }
        waitingForMenuDigit = nil
        activeMenu = nil
        return
    }
    
    if let menu = activeMenu {
        if finalOp.stringValue.hasPrefix("LFU_") {
            let index = parseUInt(String(finalOp.stringValue.dropFirst(4))) ?? 0
            
            // Check for MORE button
            if index == 5 && menuItemsDisplayCache.count - menuOffset > 6 {
                menuOffset += 5
                needsDisplay = true
                return
            }
            
            // Adjust index based on spacing mapping
            let visibleCount = menuItemsDisplayCache.count - menuOffset
            let isMore = visibleCount > 6
            var actualIndex = index
            if !isMore {
                let count = visibleCount
                if count == 4 {
                    if index == 0 || index == 1 { actualIndex = index }
                    else if index == 4 { actualIndex = 2 }
                    else if index == 5 { actualIndex = 3 }
                    else { return }
                } else if count == 5 {
                    if index == 0 || index == 1 || index == 2 { actualIndex = index }
                    else if index == 4 { actualIndex = 3 }
                    else if index == 5 { actualIndex = 4 }
                    else { return }
                }
            }
            actualIndex += menuOffset
            
            if actualIndex < menuItemsDisplayCache.count {
                let selected = menuItemsDisplayCache[actualIndex]
                if selected.requiresDigit {
                    waitingForMenuDigit = selected
                    activeMenu = nil
                    menuOffset = 0
                } else {
                    if selected.action == "REGS" {
                        isShowingRegisters = true
                        regsOffset = 0
                        needsDisplay = true
                    } else {
                        engine.executeMath(selected.action)
                        lfuManager.recordUsage(of: selected.action)
                    }
                    activeMenu = nil
                    menuOffset = 0
                }
            }
            return
        }
        

        
        if finalOp == .backspace || finalOp == .clear || finalOp == .c {
            if !menuAlphaQuery.isEmpty {
                menuAlphaQuery.removeLast()
                menuItemsDisplayCache = MenuSystem.filter(menu: menu, query: menuAlphaQuery)
            } else {
                activeMenu = nil
                menuOffset = 0
            }
            return
        }
    }
    
    if let newMenu = CalculatorMenu(rawValue: finalOp.stringValue) {
        activeMenu = newMenu
        menuAlphaQuery = ""
        menuOffset = 0
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
        } else if finalOp == .regs {
            isShowingRegisters = true
            regsOffset = 0
            needsDisplay = true
        } else if finalOp == .backspace || finalOp == .clear || finalOp == .c {
            engine.backspace()
        } else if finalOp == .e {
            engine.startExponent()
        } else {
            engine.executeMath(finalOp.stringValue)
            lfuManager.recordUsage(of: finalOp.stringValue)
        }
    }
}


    static let engine = CalculatorEngine()
    static let lfuManager = LFUManager()
    static let renderer = Renderer()
    static let retroUI = RetroUI(lfuManager: lfuManager)
    static let uartBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
    static let formatBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: 64)
    static let txBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
    static var txHead = 0
    static var txTail = 0
    
    @inline(__always)
    static func pushTx(_ val: UInt8) {
        let next = (txHead + 1) % 1024
        if next != txTail {
            txBuf[txHead] = val
            txHead = next
        }
    }
    
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

    static let rxRingBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: 256)
    static var rxHead = 0
    static var rxTail = 0
    
    static let lineBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
    static var lineLen = 0

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
            let next = (rxHead + 1) % 256
            if next != rxTail {
                rxRingBuf[rxHead] = UInt8(ch)
                rxHead = next
            }
        }
        
        while rxTail != rxHead {
            let b = rxRingBuf[rxTail]
            rxTail = (rxTail + 1) % 256
            
            if b == 13 || b == 10 {
                if lineLen > 0 {
                    if isSleeping {
                        if isCommand(lineBuf, lineLen, "C") || isCommand(lineBuf, lineLen, "50") || isCommand(lineBuf, lineLen, "CLEAR") {
                            isSleeping = false
                            needsDisplay = true
                        }
                    }
                    
                    if !isSleeping {
                        dispatchUART(lineBuf, lineLen, engine, lfuManager)
                        needsDisplay = true
                    }
                    lineLen = 0
                }
                
                // Dump Screen Data to UART
                pushTx(88); pushTx(58); pushTx(32) // "X: "
                engine.displayXBuffer.withUnsafeBufferPointer { ptr in
                    for i in 0..<engine.displayXLength {
                        pushTx(ptr[i])
                    }
                }
                pushTx(10) // \n
                let yValue = engine.stack.count > 1 ? engine.stack[1].real : 0.0
                
                pushTx(89); pushTx(58); pushTx(32) // "Y: "
                format_double_c(yValue, WatchCalcFirmware.formatBuf, 64, 0, 0)
                var fmtLen = 0
                while fmtLen < 64 && WatchCalcFirmware.formatBuf[fmtLen] != 0 { fmtLen += 1 }
                for i in 0..<fmtLen { pushTx(WatchCalcFirmware.formatBuf[i]) }
                pushTx(10) // \n
                
                for _ in 0..<32 { pushTx(61) } // "================================"
                pushTx(10) // \n
            } else if b == 8 || b == 127 {
                if lineLen > 0 {
                    lineLen -= 1
                    needsDisplay = true
                }
            } else {
                if lineLen < 31 {
                    lineBuf[lineLen] = b
                    lineLen += 1
                }
            }
        }
        
        if txHead != txTail {
            putchar_c(Int32(txBuf[txTail]))
            txTail = (txTail + 1) % 1024
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
            

            // Sync state
            retroUI.activeMenu = activeMenu
            retroUI.waitingForMenuDigit = waitingForMenuDigit
            retroUI.menuAlphaQuery = menuAlphaQuery
            retroUI.menuOffset = menuOffset
            retroUI.programScrollOffset = programScrollOffset
            switch c47Mode {
            case .none: retroUI.c47Mode = .none
            case .solve: retroUI.c47Mode = .solve
            case .integrate: retroUI.c47Mode = .integrate
            case .plot: retroUI.c47Mode = .plot
            case .xeq: retroUI.c47Mode = .xeq
            }
            retroUI.c47Program = c47Program

            // Formatter injected in main()
            
            retroUI.isShowingFullPrecision = isShowingFullPrecision
            retroUI.isShowingRegisters = isShowingRegisters
            retroUI.regsOffset = regsOffset
            
            // Render standard retro UI
            retroUI.render(engine: engine, renderer: renderer)
            
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
        
        retroUI.doubleFormatter = { (val, mode) in
            let yBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 64)
            defer { yBuffer.deallocate() }
            var cMode: Int32 = 0
            var cPlaces: Int32 = 0
            switch mode {
            case .fix(let p): cMode = 1; cPlaces = Int32(p)
            case .sci(let p): cMode = 2; cPlaces = Int32(p)
            case .eng(let p): cMode = 3; cPlaces = Int32(p)
            case .all: cMode = 0; cPlaces = 0
            }
            format_double_c(val, yBuffer, 64, cMode, cPlaces)
            var len = 0
            while len < 64 && yBuffer[len] != 0 { len += 1 }
            return String(decoding: UnsafeBufferPointer(start: yBuffer, count: len), as: UTF8.self)
        }
        
        while true {
            WatchCalcFirmware.loopIteration()
        }
    }
}
