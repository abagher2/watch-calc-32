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
        // 1. Check if we are waiting for a numeric parameter (e.g. FIX 4)
        if let pendingItem = waitingForMenuDigit {
            if let digit = parseUInt(action) {
                engine.executeMath("\(pendingItem.action) \(digit)")
            }
            waitingForMenuDigit = nil
            return
        }
        
        // 2. Check if a Menu is active
        if let menu = activeMenu {
            if action.hasPrefix("LFU_") {
                let index = parseUInt(String(action.dropFirst(4))) ?? 0
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
                if action.count == 1 { // crude alpha check
                    menuAlphaQuery.append(action)
                    menuItemsDisplayCache = MenuSystem.filter(menu: menu, query: menuAlphaQuery)
                    return
                }
            }
            
            if action == "<-" || action == "CLEAR" || action == "C" {
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
        if let newMenu = CalculatorMenu(rawValue: action) {
            activeMenu = newMenu
            menuAlphaQuery = ""
            menuItemsDisplayCache = newMenu.items
        }
        // 4. Handle standard LFU Execution
        else if action.hasPrefix("LFU_") {
            let index = parseUInt(String(action.dropFirst(4))) ?? 0
            if let funcName = lfuManager.slots[index] {
                engine.executeMath(funcName)
                lfuManager.recordUsage(of: funcName)
            }
        }
        // 5. Dispatch to RPNCore
        else if let digit = parseUInt(action) {
            engine.digit(digit)
        } else if action == "." {
            engine.decimal()
        } else if action == "+/-" {
            engine.toggleSign()
        } else if action == "ENTER" {
            engine.enter()
        } else if action == "<-" || action == "CLEAR" || action == "C" {
            engine.backspace()
        } else {
            engine.executeMath(action)
        }
    }
    
    
    

@inline(never)
static func dispatchUART(_ buf: UnsafePointer<UInt8>, _ len: Int, _ engine: CalculatorEngine, _ lfu: LFUManager) {
    var str = ""
    for i in 0..<len {
        str.append(Character(UnicodeScalar(buf[i])))
    }
    WatchCalcFirmware.processAction(str, engine: engine, lfuManager: lfu)
}

    static let engine = CalculatorEngine()
    static let lfuManager = LFUManager()
    static let renderer = Renderer()
    static let uartBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
    static var uartLen = 0
    static var needsDisplay = true

    @inline(never)
    static func loopIteration() {
        let ch = get_uart_char_c()
        if ch >= 0 {
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
            renderer.drawString("X: ", x: 2, y: 20, size: .large)
            renderer.drawString(engine.displayX, x: 30, y: 20, size: .large)
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
