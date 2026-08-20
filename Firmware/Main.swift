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

    static func processAction(_ action: String, engine: CalculatorEngine, lfuManager: LFUManager) {
        var finalAction = action
        
        if finalAction == "SHIFT_YELLOW" {
            engine.setShift(1)
            return
        }
        if finalAction == "SHIFT_BLUE" {
            engine.setShift(2)
            return
        }
        
        if engine.shiftState > 0 {
            for key in HP32KeyMap.standardGrid {
                if key.action == action {
                    if engine.shiftState == 1 { finalAction = key.yellowLabel }
                    else if engine.shiftState == 2 { finalAction = key.blueLabel }
                    break
                }
            }
            engine.setShift(0) // Consume shift
        }
        
        if finalAction.isEmpty { return }
        
        // 1. Check if we are waiting for a numeric parameter (e.g. FIX 4)
        if let pendingItem = waitingForMenuDigit {
            if let digit = parseUInt(finalAction) {
                engine.executeMath("\(pendingItem.action) \(digit)")
            }
            waitingForMenuDigit = nil
            return
        }
        
        // 2. Check if a Menu is active
        if let menu = activeMenu {
            if finalAction.hasPrefix("LFU_") {
                let index = parseUInt(String(finalAction.dropFirst(4))) ?? 0
                if index < menuItemsDisplayCache.count {
                    let selected = menuItemsDisplayCache[index]
                    
                    if selected.requiresDigit {
                        waitingForMenuDigit = selected
                        activeMenu = nil
                    } else {
                        engine.executeMath(selected.action)
                        activeMenu = nil
                    }
                }
                return
            }
            
            // Handle Alpha typing for menu search
            if engine.isWaitingForAlpha {
                if finalAction.count == 1 { // crude alpha check
                    menuAlphaQuery.append(finalAction)
                    menuItemsDisplayCache = MenuSystem.filter(menu: menu, query: menuAlphaQuery)
                    return
                }
            }
            
            if finalAction == "<-" || finalAction == "CLEAR" || finalAction == "C" {
                if !menuAlphaQuery.isEmpty {
                    menuAlphaQuery.removeLast()
                    menuItemsDisplayCache = MenuSystem.filter(menu: menu, query: menuAlphaQuery)
                } else {
                    activeMenu = nil // Dismiss
                }
                return
            }
        }
        
        // 3. Intercept Menu Activation
        if let newMenu = CalculatorMenu(rawValue: finalAction) {
            activeMenu = newMenu
            menuAlphaQuery = ""
            menuItemsDisplayCache = newMenu.items
        }
        // 4. Handle standard LFU Execution
        else if finalAction.hasPrefix("LFU_") {
            let index = parseUInt(String(finalAction.dropFirst(4))) ?? 0
            if let funcName = lfuManager.slots[index] {
                engine.executeMath(funcName)
                lfuManager.recordUsage(of: funcName)
            }
        }
        // 5. Dispatch to RPNCore
        else if let digit = parseUInt(finalAction) {
            engine.digit(digit)
        } else if finalAction == "." {
            engine.decimal()
        } else if finalAction == "+/-" {
            engine.toggleSign()
        } else if finalAction == "ENTER" {
            engine.enter()
        } else if finalAction == "<-" || finalAction == "CLEAR" || finalAction == "C" {
            engine.backspace()
        } else {
            engine.executeMath(finalAction)
        }
    }
    
    
    

@inline(never)
static func dispatchUART(_ buf: UnsafePointer<UInt8>, _ len: Int, _ engine: CalculatorEngine, _ lfu: LFUManager) {
    var str = ""
    str.reserveCapacity(len)
    var i = 0
    while i < len {
        let c = buf[i]
        if c < 0x80 {
            str.append(Character(UnicodeScalar(c)))
            i += 1
        } else if c >= 0xC0 && c < 0xE0 {
            if i + 1 < len {
                let code = ((UInt32(c) & 0x1F) << 6) | (UInt32(buf[i+1]) & 0x3F)
                if let scalar = UnicodeScalar(code) { str.append(Character(scalar)) }
                i += 2
            } else { i += 1 }
        } else if c >= 0xE0 && c < 0xF0 {
            if i + 2 < len {
                let code = ((UInt32(c) & 0x0F) << 12) | ((UInt32(buf[i+1]) & 0x3F) << 6) | (UInt32(buf[i+2]) & 0x3F)
                if let scalar = UnicodeScalar(code) { str.append(Character(scalar)) }
                i += 3
            } else { i += 1 }
        } else {
            i += 1
        }
    }
    
    if str == "C" {
        WatchCalcFirmware.isSleeping = false
    }
    
    if WatchCalcFirmware.isSleeping {
        return
    }
    
    if str == "OFF" {
        WatchCalcFirmware.isSleeping = true
        return
    }
    
    if str.hasPrefix("SET_FLAG_") {
        let parts = str.split(separator: "_")
        if parts.count == 4, let flagIdx = parseUInt(String(parts[2])), let flagVal = parseUInt(String(parts[3])) {
            if flagIdx >= 0 && flagIdx < 12 {
                engine.flags[flagIdx] = (flagVal == 1)
            }
        }
        return
    }
    
    if str.hasPrefix("SET_STACK_") {
        if let stackVal = parseUInt(String(str.dropFirst("SET_STACK_".count))) {
            engine.stackSizeLimit = max(4, stackVal)
        }
        return
    }
    
    if str.hasPrefix("SET_EXAM_") {
        if let examVal = parseUInt(String(str.dropFirst("SET_EXAM_".count))) {
            engine.isExamMode = (examVal == 1)
        }
        return
    }
    
    WatchCalcFirmware.processAction(str, engine: engine, lfuManager: lfu)
}

    static let engine = CalculatorEngine()
    static let lfuManager = LFUManager()
    static let renderer = Renderer()
    static let uartBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
    static var uartLen = 0
    static var needsDisplay = true
    static var lastActivityTime: UInt64 = 0
    static var isSleeping = false

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
                
                print("X: ", terminator: "")
                for ch in engine.displayX.utf8 {
                    putchar_c(Int32(ch))
                }
                putchar_c(10) // \n
                
                let yValue = engine.stack.count > 1 ? engine.stack[1].real : 0.0
                print("Y: ", terminator: "")
                for ch in engine.formatNumber(yValue).utf8 {
                    putchar_c(Int32(ch))
                }
                putchar_c(10) // \n
                
                print("================================")
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
                renderer.buffer.withUnsafeBufferPointer { ptr in
                    display_send_buffer(ptr.baseAddress!)
                }
                needsDisplay = false
                return
            }
            
            let menuActive = activeMenu != nil || waitingForMenuDigit != nil
            
            // 1. Draw Menu (bottom area)
            if let menu = activeMenu {
                renderer.renderMenu(menu: menu, query: menuAlphaQuery)
            } else if let pending = waitingForMenuDigit {
                renderer.drawString("\(pending.action) _", x: 2, y: 52, size: .small, color: true)
            } else if !menuActive && !engine.isGeneratingPlot && !engine.isPlotLoading {
                renderer.renderLFU(manager: lfuManager)
            }
            
            // 2. Draw X register (dynamic font size)
            let displayFont: Renderer.FontSize = .small
            let startX = 2
            
            // Centered vertically always, even when menu is active
            engine.displayXBuffer.withUnsafeBufferPointer { ptr in
                renderer.drawString(ptr.baseAddress!, length: engine.displayXLength, x: startX, y: 28, size: displayFont, color: true)
            }
            if engine.isBuildingNumber || engine.prgmIsBuildingNumber || engine.isWaitingForAlpha {
                let cursorX = startX + (engine.displayXLength * FontData.Small.charWidth)
                renderer.drawChar(Character(UnicodeScalar(95)!), x: cursorX, y: 28, size: displayFont, color: true) // '_' is ASCII 95
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
            if engine.isHypPending {
                renderer.drawString("HYP", x: indX, y: indY, size: .small)
                indX += 30
            }
            if engine.isProgrammingMode {
                renderer.drawString("PRGM", x: indX, y: indY, size: .small)
                indX += 38
            }
            
            renderer.buffer.withUnsafeBufferPointer { ptr in
                display_send_buffer(ptr.baseAddress!)
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
