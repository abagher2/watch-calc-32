import SwiftUI
import RPNCore

// MARK: - Shared key label → engine command mapping

/// Translates key face labels (▸ prefix, unicode math, arrow symbols) into
/// the canonical engine operation strings used by CalculatorEngine.executeMath().
///
/// Identical mapping table used by both the watchOS CalcButton and the iOS
/// HapticNumpadView — single source of truth.
public func mapOp(_ opToExecute: String) -> String {
    switch opToExecute {

    // ── Backspace ──────────────────────────────────────────────────────────
    case "<-":              return "BACKSPACE"

    // ── Unit conversions (▸ prefix) ────────────────────────────────────────
    case "▸km":            return "->km"
    case "▸mi":            return "->mi"
    case "▸kg":            return "->kg"
    case "▸lb":            return "->lb"
    case "▸°C":            return "->°C"
    case "▸°F":            return "->°F"
    case "▸cm":            return "->cm"
    case "▸in":            return "->in"
    case "▸l":             return "->l"
    case "▸gal":           return "->gal"

    // ── Polar / rectangular conversion ─────────────────────────────────────
    case "▸θ,r":           return ">θ,r"
    case "▸𝑦,𝑥":          return ">y,x"

    // ── Time conversion ────────────────────────────────────────────────────
    case "▸HR":            return ">HR"
    case "▸HMS":           return ">HMS"

    // ── Angle-mode conversion ──────────────────────────────────────────────
    case "▸DEG":           return ">DEG"
    case "▸RAD":           return ">RAD"

    // ── Stack-roll arrow keys (Voyager layout) ─────────────────────────────
    case "↓":              return "R↓"
    case "↑":              return "R↑"

    // ── Conditional tests (italic unicode → ascii) ─────────────────────────
    case "𝑥?𝑦":           return "x?y"
    case "𝑥?0":           return "x?0"

    // ── Stack / last-x ─────────────────────────────────────────────────────
    case "LAST𝑥":         return "LASTx"
    case "𝑥⟷𝑦":          return "x<>y"
    case "𝑥⟷?":          return "x<>?"
    case "𝑥><𝑦":         return "x<>y"    // alternate glyph on some key maps
    case "𝑥><?":          return "x<>?"

    // ── Integral shorthand (unicode → engine tag) ──────────────────────────
    case "∫":              return "∫FN"

    // ── Statistics symbols (pass-through, kept for clarity) ───────────────
    case "Σ+":             return "Σ+"
    case "Σ-":             return "Σ-"
    case "x̄,ȳ":           return "x̄,ȳ"
    case "s,σ":            return "s,σ"
    case "L.R.":           return "L.R."
    case "SUMS":           return "SUMS"

    // ── Math unicode → ASCII engine keys ──────────────────────────────────
    case "𝑦ˣ":            return "y^x"
    case "ˣ√𝑦":           return "xVy"
    case "𝑥,𝑦":           return "x,y"
    case "¹/𝑥":           return "1/x"
    case "𝑥!":            return "x!"
    case "√𝑥":            return "√x"
    case "𝑥²":            return "x^2"
    case "𝑒ˣ":            return "e^x"
    case "10ˣ":            return "10^x"

    default:               return opToExecute
    }
}

// MARK: - Commands that open a menu rather than executing directly

/// The complete set of mapped operation strings that should be routed to the
/// platform menu handler rather than passed to engine.executeMath().
/// Used by both CalcButton (watchOS) and HapticNumpadView (iOS).
public let menuCommands: Set<String> = [
    "DISP", "MODES", "L.R.", "SUMS", "FN=", "EQN", "PRGM",
    "SOLVE", "∫FN", "SHOW", "PLOT", "VIEW", "CLEAR",
    "x?y", "x?0", "BASE", "FLAGS", "XEQ",
    "PROB", "PARTS", "MEM", "REGS", "x̄,ȳ", "s,σ", "CONST",
]

// MARK: - Core action dispatch

/// Executes the action for a resolved (already mapOp-translated) key command.
///
/// - Parameters:
///   - command:       The engine command string, already passed through `mapOp()`.
///   - engine:        The shared `CalculatorEngine` instance.
///   - onMenuAction:  Platform-specific callback invoked for menu-triggering commands
///                    (e.g. opens a sheet on iOS, sets a @State binding on watchOS).
///                    When `nil`, menu commands are silently ignored.
public func dispatchKey(
    _ command: String,
    engine: CalculatorEngine,
    onMenuAction: ((String) -> Void)?
) {
    if engine.isWaitingForAlpha {
        if command == "BACKSPACE" {
            engine.submitAlpha("<-")
        } else if command == "ENTER" {
            engine.submitAlpha("ENTER")
        } else {
            let alpha = alphaLabel(for: command) ?? command
            engine.submitAlpha(alpha)
        }
    } else {
        if command == "BACKSPACE" {
            engine.backspace()
        } else if command == "ENTER" {
            engine.enter()
        } else if command == "+/-" {
            engine.toggleSign()
        } else if command == "." {
            engine.decimal()
        } else if command == "E" {
            engine.startExponent()
        } else if menuCommands.contains(command) {
            onMenuAction?(command)
        } else if let d = Int(command) {
            engine.digit(d)
        } else if command.count == 1 && command.first!.isASCII && command.first!.isLetter && command.uppercased() == command {
            engine.submitAlpha(command)
        } else {
            engine.executeMath(command)
        }
    }
}
