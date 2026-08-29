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
    
    return fastMatchOp(buf + start, trimmedLen)
}

func fastMatchOp(_ buf: UnsafePointer<UInt8>, _ len: Int) -> CalculatorOperation? {
    if len == 0 { return nil }
    let b0 = buf[0]
    let b1 = len > 1 ? buf[1] : 0
    let b2 = len > 2 ? buf[2] : 0
    let b3 = len > 3 ? buf[3] : 0
    let b4 = len > 4 ? buf[4] : 0
    let b5 = len > 5 ? buf[5] : 0
    let b6 = len > 6 ? buf[6] : 0
    let b7 = len > 7 ? buf[7] : 0
    let b8 = len > 8 ? buf[8] : 0
    let b9 = len > 9 ? buf[9] : 0
    let b10 = len > 10 ? buf[10] : 0
    let b11 = len > 11 ? buf[11] : 0
    let b12 = len > 12 ? buf[12] : 0
    let b13 = len > 13 ? buf[13] : 0
    if len == 5 && b0 == 226 && b1 == 134 && b2 == 146 && b3 == 99 && b4 == 109 { return .toCm }
    if len == 6 && b0 == 226 && b1 == 134 && b2 == 146 && b3 == 103 && b4 == 97 && b5 == 108 { return .toGal }
    if len == 5 && b0 == 226 && b1 == 134 && b2 == 146 && b3 == 105 && b4 == 110 { return .toIn }
    if len == 5 && b0 == 226 && b1 == 134 && b2 == 146 && b3 == 107 && b4 == 103 { return .toKg }
    if len == 5 && b0 == 226 && b1 == 134 && b2 == 146 && b3 == 107 && b4 == 109 { return .toKm }
    if len == 4 && b0 == 226 && b1 == 134 && b2 == 146 && b3 == 108 { return .toLiters }
    if len == 5 && b0 == 226 && b1 == 134 && b2 == 146 && b3 == 108 && b4 == 98 { return .toLb }
    if len == 5 && b0 == 226 && b1 == 134 && b2 == 146 && b3 == 109 && b4 == 105 { return .toMi }
    if len == 6 && b0 == 226 && b1 == 134 && b2 == 146 && b3 == 194 && b4 == 176 && b5 == 67 { return .toCelsius }
    if len == 6 && b0 == 226 && b1 == 134 && b2 == 146 && b3 == 194 && b4 == 176 && b5 == 70 { return .toFahrenheit }
    if len == 1 && b0 == 48 { return .digit0 }
    if len == 1 && b0 == 49 { return .digit1 }
    if len == 1 && b0 == 50 { return .digit2 }
    if len == 1 && b0 == 51 { return .digit3 }
    if len == 1 && b0 == 52 { return .digit4 }
    if len == 1 && b0 == 53 { return .digit5 }
    if len == 1 && b0 == 54 { return .digit6 }
    if len == 1 && b0 == 55 { return .digit7 }
    if len == 1 && b0 == 56 { return .digit8 }
    if len == 1 && b0 == 57 { return .digit9 }
    if len == 1 && b0 == 43 { return .add }
    if len == 1 && b0 == 45 { return .subtract }
    if len == 2 && b0 == 195 && b1 == 151 { return .multiply }
    if len == 2 && b0 == 195 && b1 == 183 { return .divide }
    if len == 1 && b0 == 46 { return .decimal }
    if len == 5 && b0 == 69 && b1 == 78 && b2 == 84 && b3 == 69 && b4 == 82 { return .enter }
    if len == 3 && b0 == 43 && b1 == 47 && b2 == 45 { return .toggleSign }
    if len == 6 && b0 == 49 && b1 == 47 && b2 == 240 && b3 == 157 && b4 == 145 && b5 == 165 { return .reciprocal }
    if len == 4 && b0 == 49 && b1 == 48 && b2 == 203 && b3 == 163 { return .exp10 }
    if len == 6 && b0 == 240 && b1 == 157 && b2 == 145 && b3 == 146 && b4 == 203 && b5 == 163 { return .exp }
    if len == 6 && b0 == 240 && b1 == 157 && b2 == 145 && b3 == 166 && b4 == 203 && b5 == 163 { return .power }
    if len == 3 && b0 == 120 && b1 == 86 && b2 == 121 { return .xRootY }
    if len == 6 && b0 == 240 && b1 == 157 && b2 == 145 && b3 == 165 && b4 == 194 && b5 == 178 { return .square }
    if len == 7 && b0 == 226 && b1 == 136 && b2 == 154 && b3 == 240 && b4 == 157 && b5 == 145 && b6 == 165 { return .sqrt }
    if len == 5 && b0 == 240 && b1 == 157 && b2 == 145 && b3 == 165 && b4 == 33 { return .factorial }
    if len == 4 && b0 == 62 && b1 == 68 && b2 == 69 && b3 == 71 { return .toDeg }
    if len == 4 && b0 == 62 && b1 == 72 && b2 == 77 && b3 == 83 { return .toHms }
    if len == 3 && b0 == 62 && b1 == 72 && b2 == 82 { return .toHr }
    if len == 4 && b0 == 62 && b1 == 82 && b2 == 65 && b3 == 68 { return .toRad }
    if len == 4 && b0 == 62 && b1 == 121 && b2 == 44 && b3 == 120 { return .toRectangular }
    if len == 5 && b0 == 62 && b1 == 206 && b2 == 184 && b3 == 44 && b4 == 114 { return .toPolar }
    if len == 3 && b0 == 65 && b1 == 66 && b2 == 83 { return .abs }
    if len == 4 && b0 == 65 && b1 == 67 && b2 == 79 && b3 == 83 { return .acos }
    if len == 3 && b0 == 65 && b1 == 78 && b2 == 68 { return .and }
    if len == 4 && b0 == 65 && b1 == 83 && b2 == 73 && b3 == 78 { return .asin }
    if len == 4 && b0 == 65 && b1 == 84 && b2 == 65 && b3 == 78 { return .atan }
    if len == 3 && b0 == 226 && b1 == 134 && b2 == 144 { return .backspace }
    if len == 4 && b0 == 66 && b1 == 65 && b2 == 83 && b3 == 69 { return .base }
    if len == 3 && b0 == 66 && b1 == 73 && b2 == 78 { return .bin }
    if len == 1 && b0 == 67 { return .c }
    if len == 5 && b0 == 67 && b1 == 76 && b2 == 69 && b3 == 65 && b4 == 82 { return .clear }
    if len == 5 && b0 == 67 && b1 == 77 && b2 == 80 && b3 == 76 && b4 == 88 { return .cmplx }
    if len == 5 && b0 == 67 && b1 == 79 && b2 == 78 && b3 == 83 && b4 == 84 { return .const }
    if len == 3 && b0 == 67 && b1 == 79 && b2 == 83 { return .cos }
    if len == 3 && b0 == 68 && b1 == 69 && b2 == 67 { return .dec }
    if len == 4 && b0 == 68 && b1 == 73 && b2 == 83 && b3 == 80 { return .disp }
    if len == 1 && b0 == 69 { return .e }
    if len == 3 && b0 == 69 && b1 == 78 && b2 == 71 { return .eng }
    if len == 3 && b0 == 69 && b1 == 81 && b2 == 78 { return .eqn }
    if len == 3 && b0 == 70 && b1 == 73 && b2 == 88 { return .fix }
    if len == 5 && b0 == 70 && b1 == 76 && b2 == 65 && b3 == 71 && b4 == 83 { return .flags }
    if len == 3 && b0 == 70 && b1 == 78 && b2 == 61 { return .fnEq }
    if len == 4 && b0 == 70 && b1 == 82 && b2 == 65 && b3 == 67 { return .frac }
    if len == 3 && b0 == 71 && b1 == 84 && b2 == 79 { return .gto }
    if len == 3 && b0 == 72 && b1 == 69 && b2 == 88 { return .hex }
    if len == 3 && b0 == 72 && b1 == 89 && b2 == 80 { return .hyp }
    if len == 4 && b0 == 73 && b1 == 78 && b2 == 84 && b3 == 71 { return .intg }
    if len == 5 && b0 == 73 && b1 == 78 && b2 == 84 && b3 == 195 && b4 == 183 { return .intDiv }
    if len == 4 && b0 == 76 && b1 == 46 && b2 == 82 && b3 == 46 { return .lr }
    if len == 8 && b0 == 76 && b1 == 65 && b2 == 83 && b3 == 84 && b4 == 240 && b5 == 157 && b6 == 145 && b7 == 165 { return .lastx }
    if len == 3 && b0 == 76 && b1 == 66 && b2 == 76 { return .lbl }
    if len == 5 && b0 == 76 && b1 == 70 && b2 == 85 && b3 == 95 && b4 == 48 { return .lfu0 }
    if len == 5 && b0 == 76 && b1 == 70 && b2 == 85 && b3 == 95 && b4 == 49 { return .lfu1 }
    if len == 5 && b0 == 76 && b1 == 70 && b2 == 85 && b3 == 95 && b4 == 50 { return .lfu2 }
    if len == 5 && b0 == 76 && b1 == 70 && b2 == 85 && b3 == 95 && b4 == 51 { return .lfu3 }
    if len == 5 && b0 == 76 && b1 == 70 && b2 == 85 && b3 == 95 && b4 == 52 { return .lfu4 }
    if len == 5 && b0 == 76 && b1 == 70 && b2 == 85 && b3 == 95 && b4 == 53 { return .lfu5 }
    if len == 2 && b0 == 76 && b1 == 78 { return .ln }
    if len == 3 && b0 == 76 && b1 == 79 && b2 == 71 { return .log }
    if len == 3 && b0 == 77 && b1 == 69 && b2 == 77 { return .mem }
    if len == 5 && b0 == 77 && b1 == 79 && b2 == 68 && b3 == 69 && b4 == 83 { return .modes }
    if len == 3 && b0 == 78 && b1 == 79 && b2 == 84 { return .not }
    if len == 3 && b0 == 79 && b1 == 67 && b2 == 84 { return .oct }
    if len == 3 && b0 == 79 && b1 == 70 && b2 == 70 { return .off }
    if len == 2 && b0 == 79 && b1 == 82 { return .or }
    if len == 5 && b0 == 80 && b1 == 65 && b2 == 82 && b3 == 84 && b4 == 83 { return .parts }
    if len == 4 && b0 == 80 && b1 == 76 && b2 == 79 && b3 == 84 { return .plot }
    if len == 4 && b0 == 80 && b1 == 82 && b2 == 71 && b3 == 77 { return .prgm }
    if len == 4 && b0 == 80 && b1 == 82 && b2 == 79 && b3 == 66 { return .prob }
    if len == 3 && b0 == 110 && b1 == 80 && b2 == 114 { return .nPr }
    if len == 3 && b0 == 110 && b1 == 67 && b2 == 114 { return .nCr }
    if len == 4 && b0 == 82 && b1 == 65 && b2 == 78 && b3 == 68 { return .rand }
    if len == 3 && b0 == 82 && b1 == 67 && b2 == 76 { return .rcl }
    if len == 4 && b0 == 82 && b1 == 69 && b2 == 71 && b3 == 83 { return .regs }
    if len == 3 && b0 == 82 && b1 == 78 && b2 == 68 { return .rnd }
    if len == 4 && b0 == 82 && b1 == 226 && b2 == 134 && b3 == 145 { return .rollUp }
    if len == 4 && b0 == 82 && b1 == 226 && b2 == 134 && b3 == 147 { return .rollDown }
    if len == 3 && b0 == 83 && b1 == 67 && b2 == 73 { return .sci }
    if len == 8 && b0 == 83 && b1 == 69 && b2 == 84 && b3 == 95 && b4 == 69 && b5 == 88 && b6 == 65 && b7 == 77 { return .setExam }
    if len == 9 && b0 == 83 && b1 == 69 && b2 == 84 && b3 == 95 && b4 == 83 && b5 == 84 && b6 == 65 && b7 == 67 && b8 == 75 { return .setStack }
    if len == 4 && b0 == 83 && b1 == 72 && b2 == 79 && b3 == 87 { return .show }
    if len == 3 && b0 == 83 && b1 == 73 && b2 == 78 { return .sin }
    if len == 5 && b0 == 83 && b1 == 79 && b2 == 76 && b3 == 86 && b4 == 69 { return .solve }
    if len == 3 && b0 == 83 && b1 == 84 && b2 == 79 { return .sto }
    if len == 4 && b0 == 83 && b1 == 85 && b2 == 77 && b3 == 83 { return .sums }
    if len == 3 && b0 == 84 && b1 == 65 && b2 == 78 { return .tan }
    if len == 4 && b0 == 86 && b1 == 73 && b2 == 69 && b3 == 87 { return .view }
    if len == 3 && b0 == 88 && b1 == 69 && b2 == 81 { return .xeq }
    if len == 3 && b0 == 88 && b1 == 79 && b2 == 82 { return .xor }
    if len == 4 && b0 == 115 && b1 == 44 && b2 == 207 && b3 == 131 { return .statStdDev }
    if len == 13 && b0 == 240 && b1 == 157 && b2 == 145 && b3 == 165 && b4 == 204 && b5 == 132 && b6 == 44 && b7 == 240 && b8 == 157 && b9 == 145 && b10 == 166 && b11 == 204 && b12 == 132 { return .statMean }
    if len == 3 && b0 == 206 && b1 == 163 && b2 == 43 { return .statAdd }
    if len == 3 && b0 == 206 && b1 == 163 && b2 == 45 { return .statSub }
    if len == 4 && b0 == 120 && b1 == 33 && b2 == 61 && b3 == 48 { return .testNeq0 }
    if len == 4 && b0 == 120 && b1 == 33 && b2 == 61 && b3 == 121 { return .testNeq }
    if len == 3 && b0 == 120 && b1 == 60 && b2 == 48 { return .testLt0 }
    if len == 4 && b0 == 120 && b1 == 60 && b2 == 61 && b3 == 48 { return .testLte0 }
    if len == 4 && b0 == 120 && b1 == 60 && b2 == 61 && b3 == 121 { return .testLte }
    if len == 3 && b0 == 120 && b1 == 60 && b2 == 121 { return .testLt }
    if len == 3 && b0 == 120 && b1 == 61 && b2 == 48 { return .testEq0 }
    if len == 3 && b0 == 120 && b1 == 61 && b2 == 121 { return .testEq }
    if len == 3 && b0 == 120 && b1 == 62 && b2 == 48 { return .testGt0 }
    if len == 3 && b0 == 120 && b1 == 62 && b2 == 121 { return .testGt }
    if len == 6 && b0 == 240 && b1 == 157 && b2 == 145 && b3 == 165 && b4 == 63 && b5 == 48 { return .testX0 }
    if len == 9 && b0 == 240 && b1 == 157 && b2 == 145 && b3 == 165 && b4 == 63 && b5 == 240 && b6 == 157 && b7 == 145 && b8 == 166 { return .testXY }
    if len == 5 && b0 == 120 && b1 == 226 && b2 == 134 && b3 == 148 && b4 == 63 { return .swapXYPrompt }
    if len == 5 && b0 == 120 && b1 == 226 && b2 == 134 && b3 == 148 && b4 == 121 { return .swapXY }
    if len == 5 && b0 == 226 && b1 == 136 && b2 == 171 && b3 == 70 && b4 == 78 { return .integrate }
    if len == 1 && b0 == 37 { return .percent }
    if len == 4 && b0 == 37 && b1 == 67 && b2 == 72 && b3 == 71 { return .percentChange }
    if len == 3 && b0 == 77 && b1 == 79 && b2 == 68 { return .modulo }
    if len == 3 && b0 == 82 && b1 == 84 && b2 == 78 { return .rtn }
    if len == 4 && b0 == 83 && b1 == 67 && b2 == 82 && b3 == 76 { return .scrl }
    if len == 2 && b0 == 207 && b1 == 128 { return .pi }
    if len == 12 && b0 == 83 && b1 == 72 && b2 == 73 && b3 == 70 && b4 == 84 && b5 == 95 && b6 == 89 && b7 == 69 && b8 == 76 && b9 == 76 && b10 == 79 && b11 == 87 { return .shiftYellow }
    if len == 10 && b0 == 83 && b1 == 72 && b2 == 73 && b3 == 70 && b4 == 84 && b5 == 95 && b6 == 66 && b7 == 76 && b8 == 85 && b9 == 69 { return .shiftBlue }
    if len == 5 && b0 == 70 && b1 == 68 && b2 == 73 && b3 == 83 && b4 == 80 { return .fdisp }
    if len == 2 && b0 == 47 && b1 == 99 { return .slashc }
    if len == 3 && b0 == 226 && b1 == 134 && b2 == 145 { return .scrollUp }
    if len == 3 && b0 == 226 && b1 == 134 && b2 == 147 { return .scrollDown }
    if len == 1 && b0 == 65 { return .sqrt }
    if len == 1 && b0 == 66 { return .exp }
    if len == 1 && b0 == 67 { return .ln }
    if len == 1 && b0 == 68 { return .power }
    if len == 1 && b0 == 69 { return .reciprocal }
    if len == 1 && b0 == 70 { return .statAdd }
    if len == 1 && b0 == 71 { return .sto }
    if len == 1 && b0 == 72 { return .rcl }
    if len == 1 && b0 == 73 { return .rollDown }
    if len == 1 && b0 == 74 { return .sin }
    if len == 1 && b0 == 75 { return .cos }
    if len == 1 && b0 == 76 { return .tan }
    if len == 1 && b0 == 77 { return .enter }
    if len == 1 && b0 == 78 { return .swapXY }
    if len == 1 && b0 == 79 { return .toggleSign }
    if len == 1 && b0 == 80 { return .e }
    if len == 1 && b0 == 81 { return .digit7 }
    if len == 1 && b0 == 82 { return .digit8 }
    if len == 1 && b0 == 83 { return .digit9 }
    if len == 1 && b0 == 84 { return .digit4 }
    if len == 1 && b0 == 85 { return .digit5 }
    if len == 1 && b0 == 86 { return .digit6 }
    if len == 1 && b0 == 87 { return .digit1 }
    if len == 1 && b0 == 88 { return .digit2 }
    if len == 1 && b0 == 89 { return .digit3 }
    if len == 1 && b0 == 90 { return .digit0 }
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
    
    if engine.isWaitingForLabel || engine.isWaitingForAlpha {
        if matchOpBytes(buf, len)?.stringValue.hasPrefix("LFU_") == true || (parseUIntBytes(buf, 0, len).flatMap { CalculatorOperation(rawValue: $0) })?.stringValue.hasPrefix("LFU_") == true {
            // Do not intercept LFU commands as alpha input
        } else if isCommand(buf, len, "<-") || isCommand(buf, len, "BACKSPACE") {
            engine.submitAlpha("<-")
        } else if isCommand(buf, len, "ENTER") {
            engine.submitAlpha("ENTER")
        } else {
            var s = 0
            var e = len
            while s < e && buf[s] <= 32 { s += 1 }
            while e > s && buf[e - 1] <= 32 { e -= 1 }
            let trimmedLen = e - s
            let str = trimmedLen > 0 ? String(decoding: UnsafeBufferPointer(start: buf + s, count: trimmedLen), as: UTF8.self) : ""
            // print("SUBMIT ALPHA: \(str), isWaitingForLabel: \(engine.isWaitingForLabel)")
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
        var s = 0
        var e = len
        while s < e && buf[s] <= 32 { s += 1 }
        while e > s && buf[e - 1] <= 32 { e -= 1 }
        let trimmedLen = e - s
        let str = trimmedLen > 0 ? String(decoding: UnsafeBufferPointer(start: buf + s, count: trimmedLen), as: UTF8.self) : ""
        if str.hasPrefix("PLOTX ") {
            let valStr = String(str.dropFirst(6))
            if let val = parseDouble(valStr) {
                engine.selectedPlotX = val
                engine.updateDisplay()
            }
        } else {
            engine.executeMath(str)
            engine.updateDisplay()
        }
    }
}

    static let uartBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
    static let formatBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: 64)
    static let txBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: 4096)
    static var txHead = 0
    static var txTail = 0
    
    @inline(__always)
    static func pushTx(_ val: UInt8) {
        let next = (txHead + 1) % 4096
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
        var ch = get_uart_char_c()
        while ch >= 0 {
            lastActivityTime = now
            let next = (rxHead + 1) % 256
            if next != rxTail {
                rxRingBuf[rxHead] = UInt8(ch)
                rxHead = next
            }
            ch = get_uart_char_c()
        }
        
        while rxTail != rxHead {
            let b = rxRingBuf[rxTail]
            rxTail = (rxTail + 1) % 256
            
            if b == 13 || b == 10 {
                if lineLen > 0 {
                    if isSleeping {
                        if isCommand(lineBuf, lineLen, "C") || isCommand(lineBuf, lineLen, "50") || isCommand(lineBuf, lineLen, "CLEAR") {
                            hw_display_wake_c()
                            isSleeping = false
                            needsDisplay = true
                            lastActivityTime = hw_time_us()
                        }
                    }
                    
                    if !isSleeping {
                        dispatchUART(lineBuf, lineLen, engine, lfuManager)
                        needsDisplay = true
                        lastActivityTime = hw_time_us()
                    }
                    lineLen = 0
                }
                
                // Dump Screen Data to UART
                pushTx(88); pushTx(58); pushTx(32) // "X: "
                if let err = engine.errorMessage {
                    for b in err.utf8 { pushTx(b) }
                } else if let tr = engine.transientMessage {
                    for b in tr.utf8 { pushTx(b) }
                } else {
                    engine.displayXBuffer.withUnsafeBufferPointer { ptr in
                        for i in 0..<engine.displayXLength {
                            pushTx(ptr[i])
                        }
                    }
                }
                pushTx(10) // \n
                let yValue = engine.stack.count > 1 ? engine.stack[1].real : 0.0
                let zValue = engine.stack.count > 2 ? engine.stack[2].real : 0.0
                let tValue = engine.stack.count > 3 ? engine.stack[3].real : 0.0
                let lValue = engine.lastX.real
                
                func printVal(_ nameBytes: [UInt8], _ val: Double) {
                    for b in nameBytes { pushTx(b) }
                    format_double_c(val, WatchCalcFirmware.formatBuf, 64, 0, 0, engine.useCommaForDecimal ? 1 : 0)
                    var fmtLen = 0
                    while fmtLen < 64 && WatchCalcFirmware.formatBuf[fmtLen] != 0 { fmtLen += 1 }
                    for i in 0..<fmtLen { pushTx(WatchCalcFirmware.formatBuf[i]) }
                    pushTx(10)
                }
                
                printVal([89, 58, 32], yValue) // Y: 
                printVal([90, 58, 32], zValue) // Z: 
                printVal([84, 58, 32], tValue) // T: 
                printVal([76, 58, 32], lValue) // L: 
                
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
                        hw_display_wake_c()
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
        
        while txHead != txTail {
            putchar_c(Int32(txBuf[txTail]))
            txTail = (txTail + 1) % 4096
        }
        if needsDisplay {
            renderer.clear()
            
            if isSleeping {
                var changed = false
                if let prev = renderer.previousBuffer {
                    for i in 0..<renderer.buffer.count {
                        if prev[i] != renderer.buffer[i] { changed = true; break }
                    }
                } else { changed = true }
                
                if changed {
                    renderer.buffer.withUnsafeBufferPointer { ptr in
                        display_send_buffer(ptr.baseAddress!)
                        if renderer.previousBuffer == nil { renderer.previousBuffer = [UInt8](repeating: 0, count: renderer.buffer.count) }
                        for i in 0..<renderer.buffer.count { renderer.previousBuffer![i] = ptr[i] }
                    }
                }
                hw_display_sleep_c()
                needsDisplay = false
                return
            }
            
            // Render standard retro UI
            uiController.retroUI.render(engine: engine, renderer: renderer)
            // print("DEBUG: requestPlot=\(engine.requestPlot ? "1" : "0") isEq=\(engine.isEquationListMode ? "1" : "0")")
            
            var changed = false
            if let prev = renderer.previousBuffer {
                for i in 0..<renderer.buffer.count {
                    if prev[i] != renderer.buffer[i] { changed = true; break }
                }
            } else { changed = true }
            
            if changed {
                renderer.buffer.withUnsafeBufferPointer { ptr in
                    display_send_buffer(ptr.baseAddress!)
                    if renderer.previousBuffer == nil { renderer.previousBuffer = [UInt8](repeating: 0, count: renderer.buffer.count) }
                    for i in 0..<renderer.buffer.count { renderer.previousBuffer![i] = ptr[i] }
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
        // print("Booted!")
        hw_init()
        
        // True hardware/firmware level interrupt polling for C and OFF
        engine.isInterrupted = {
            let m = matrix_scan()
            for r in 0..<8 {
                for c in 0..<6 {
                    let bit = UInt64(1) << ((r * 6) + c)
                    if (m & bit) != 0 {
                        if let key = HP32KeyMap.standardGrid.first(where: { $0.row == r && $0.col == c }) {
                            if key.primaryAction == .c {
                                lastMatrixState = m // Update to prevent double-trigger when returning to loop
                                return true
                            }
                        }
                    }
                }
            }
            return false
        }
        
        uiController.retroUI.doubleFormatter = { (val, mode) in
            var cMode: Int32 = 0
            var cPlaces: Int32 = 0
            switch mode {
            case .fix(let p): cMode = 1; cPlaces = Int32(p)
            case .sci(let p): cMode = 2; cPlaces = Int32(p)
            case .eng(let p): cMode = 3; cPlaces = Int32(p)
            case .all: cMode = 0; cPlaces = 0
            case .sig(let p): cMode = 4; cPlaces = Int32(p)
            }
            format_double_c(val, WatchCalcFirmware.formatBuf, 64, cMode, cPlaces, engine.useCommaForDecimal ? 1 : 0)
            var len = 0
            while len < 64 && WatchCalcFirmware.formatBuf[len] != 0 { len += 1 }
            return String(decoding: UnsafeBufferPointer(start: WatchCalcFirmware.formatBuf, count: len), as: UTF8.self)
        }
        
        while true {
            WatchCalcFirmware.loopIteration()
        }
    }
}
