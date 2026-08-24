// MARK: - Shared key label → engine command mapping

public func mapOp(_ opToExecute: String) -> CalculatorOperation {
    switch opToExecute {
    case "<-":              return .backspace
    case "▸km":            return .toKm
    case "▸mi":            return .toMi
    case "▸kg":            return .toKg
    case "▸lb":            return .toLb
    case "▸°C":            return .toCelsius
    case "▸°F":            return .toFahrenheit
    case "▸cm":            return .toCm
    case "▸in":            return .toIn
    case "▸l":             return .toLiters
    case "▸gal":           return .toGal
    case "▸θ,𝑟":           return .toPolar
    case "▸𝑦,𝑥":          return .toRectangular
    case "▸HR":            return .toHr
    case "▸HMS":           return .toHms
    case "▸DEG":           return .toDeg
    case "▸RAD":           return .toRad
    case "↓":              return .rollDown
    case "↑":              return .rollUp
    case "𝑥?𝑦":           return .testXY
    case "𝑥?0":           return .testX0
    case "LAST𝑥":         return .lastx
    case "𝑥≷𝑦", "𝑥≷𝑦":  return .swapXY
    case "𝑥≷?", "𝑥≷?":  return .swapXYPrompt
    case "∫":              return .integrate
    case "Σ+":             return .statAdd
    case "Σ-":             return .statSub
    case "𝑥̄,𝑦̄":           return .statMean
    case "s,σ":            return .statStdDev
    case "L.R.":           return .lr
    case "SUMS":           return .sums
    case "𝑦ˣ":            return .power
    case "ˣ√𝑦":           return .xRootY
    case "𝑥,𝑦":           return .cmplx
    case "¹/𝑥":           return .reciprocal
    case "𝑥!":            return .factorial
    case "√𝑥":            return .sqrt
    case "𝑥²":            return .square
    case "𝑒ˣ":            return .exp
    case "10ˣ":            return .exp10
    case "+/-":            return .toggleSign
    case "÷R":             return .intDiv
    case "|x|":            return .abs
    default:
        // Try to find a matching stringValue
        if let op = CalculatorOperation.allCases.first(where: { $0.stringValue == opToExecute }) {
            return op
        }
        // Fallbacks
        if opToExecute == "." { return .decimal }
        if let _ = parseInteger(opToExecute) {
            // Find the digit
            return CalculatorOperation.allCases.first(where: { $0.stringValue == opToExecute }) ?? .decimal
        }
        return .enter
    }
}


// MARK: - Commands that open a menu rather than executing directly

/// The complete set of mapped operations that should be routed to the
/// platform menu handler rather than passed to engine.executeMath().
public let menuCommands: Set<CalculatorOperation> = [
    .disp, .modes, .lr, .sums, .fnEq, .eqn, .prgm,
    .solve, .integrate, .show, .plot, .view, .clear,
    .testXY, .testX0, .base, .flags, .xeq,
    .prob, .parts, .mem, .regs, .statMean, .statStdDev, .const,
    .lfu0, .lfu1, .lfu2, .lfu3, .lfu4, .lfu5
]

// MARK: - Core action dispatch

/// Executes the action for a resolved key command.
public func dispatchKey(
    _ command: CalculatorOperation,
    engine: CalculatorEngine,
    onMenuAction: ((CalculatorOperation) -> Void)?
) {
    if engine.isWaitingForAlpha {
        if command == .backspace {
            engine.submitAlpha("<-")
        } else if command == .enter {
            engine.submitAlpha("ENTER")
        } else {
            let alpha = alphaLabel(for: command) ?? command.stringValue
            engine.submitAlpha(alpha)
        }
    } else {
        if command == .backspace {
            engine.backspace()
        } else if command == .enter {
            engine.enter()
        } else if command == .toggleSign {
            engine.toggleSign()
        } else if command == .decimal {
            engine.decimal()
        } else if command == .e {
            engine.startExponent()
        } else if menuCommands.contains(command) {
            onMenuAction?(command)
        } else if command.stringValue.count == 1 && command.stringValue.first!.isNumber {
            engine.digit(parseInteger(command.stringValue)!)
        } else if command.stringValue.count == 1 && command.stringValue.first!.isASCII && command.stringValue.first!.isLetter && command.stringValue.uppercased() == command.stringValue && command != .c && command != .e {
            engine.submitAlpha(command.stringValue)
        } else {
            engine.execute(.operation(command))
        }
    }
}

public func parseInteger(_ str: String) -> Int? {
    var total = 0
    var isNegative = false
    var hasDigit = false
    for scalar in str.unicodeScalars {
        if scalar.value == 45 && !hasDigit { // '-'
            isNegative = true
        } else if scalar.value >= 48 && scalar.value <= 57 { // '0' - '9'
            total = total * 10 + Int(scalar.value - 48)
            hasDigit = true
        } else {
            return nil
        }
    }
    return hasDigit ? (isNegative ? -total : total) : nil
}
