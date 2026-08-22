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
    static let engine = CalculatorEngine()
    static let lfuManager = LFUManager()
    static let uiController = RetroUIController(engine: engine, lfuManager: lfuManager)
    static let renderer = Renderer()


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
        if op == .off {
            WatchCalcFirmware.isSleeping = true
            needsDisplay = true
            return
        }
        uiController.processAction(op)
    } else if let id = parseUIntBytes(buf, 0, len), let op = CalculatorOperation(rawValue: id) {
        if op == .off {
            WatchCalcFirmware.isSleeping = true
            needsDisplay = true
            return
        }
        uiController.processAction(op)
    } else if isCommand(buf, len, "CLEAR_ALL") {
        engine.clearAll()
        uiController.retroUI.isShowingRegisters = false
        uiController.retroUI.isShowingFullPrecision = false
        uiController.retroUI.regsOffset = 0
        needsDisplay = true
    } else {
        let str = String(decoding: UnsafeBufferPointer(start: buf, count: len), as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        engine.executeMath(str)
    }
}

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

    static let rxRingBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: 256)
    static var rxHead = 0
    static var rxTail = 0
    
    static let lineBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
    static var lineLen = 0

    static var lastMatrixState: UInt64 = 0
    static var debounceCounter: Int = 0

    @inline(never)
    static func loopIteration() {
        let now = hw_time_us()
        
        if !isSleeping && now - lastActivityTime > 60_000_000 {
            isSleeping = true
            needsDisplay = true
        }
        
#if EMULATOR
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
#endif
        
        let matrixState = matrix_scan()
        if matrixState != lastMatrixState {
            debounceCounter += 1
            if debounceCounter > 2 { // Stable for roughly 20-30ms
                let pressed = matrixState & ~lastMatrixState
                if pressed != 0 {
                    if isSleeping {
                        isSleeping = false
                        needsDisplay = true
                    }
                    lastActivityTime = now
                    
                    for r in 0..<8 {
                        for c in 0..<6 {
                            let bit = UInt64(1) << ((r * 6) + c)
                            if (pressed & bit) != 0 {
                                if let key = HP32KeyMap.standardGrid.first(where: { $0.row == r && $0.col == c }) {
                                    if let op = key.primaryAction {
                                        uiController.processAction(op)
                                        needsDisplay = true
                                    }
                                }
                            }
                        }
                    }
                }
                lastMatrixState = matrixState
                debounceCounter = 0
            }
        } else {
            debounceCounter = 0
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
            
            // Render standard retro UI
            uiController.retroUI.render(engine: engine, renderer: renderer)
            
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
        
        if isSleeping {
            sleep_ms_c(100)
        } else {
            sleep_ms_c(10)
        }
    }

    static func main() {
        print("Booted!")
        hw_init()
        
        uiController.retroUI.doubleFormatter = { (val, mode) in
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
