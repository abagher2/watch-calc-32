
internal func engineGcd(_ a: Int64, _ b: Int64) -> Int64 {
    var a = abs(a)
    var b = abs(b)
    while b != 0 {
        let t = b
        b = a % b
        a = t
    }
    return a == 0 ? 1 : a
}

#if hasFeature(Embedded)
@_silgen_name("strtod")
func strtod(_ nptr: UnsafePointer<CChar>, _ endptr: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Double
#else
import Foundation
#endif

#if !hasFeature(Embedded)
import Foundation
import Observation
import RationalModule
#endif



public func parseDoubleSlice(_ slice: ArraySlice<UInt8>, exponent: String? = nil) -> Double {
    var val = 0.0
    var sign = 1.0
    var parsingFraction = false
    var fractionDivisor = 10.0
    
    for ch in slice {
        if ch == 45 { // '-'
            sign = -1.0
        } else if ch == 46 { // '.'
            parsingFraction = true
        } else if ch >= 48 && ch <= 57 { // '0' to '9'
            let digit = Double(ch - 48)
            if parsingFraction {
                val += digit / fractionDivisor
                fractionDivisor *= 10.0
            } else {
                val = val * 10.0 + digit
            }
        }
    }
    
    var finalVal = val * sign
    
    if let expStr = exponent, let expVal = parseInt(expStr) {
        finalVal *= _pow(10.0, Double(expVal))
    }
    
    return finalVal
}

#if hasFeature(Embedded)
public enum DummyCharacterSet { case whitespacesAndNewlines }
extension String {
    public func trimmingCharacters(in set: DummyCharacterSet) -> String {
        return self
    }
}
public class CommandLine {
    public static var arguments: [String] = []
}
public func srand48(_ seed: Int) {}
internal func _sin(_ x: Double) -> Double { return sin(x) }
internal func _cos(_ x: Double) -> Double { return cos(x) }
internal func _tan(_ x: Double) -> Double { return tan(x) }
internal func _exp(_ x: Double) -> Double { return exp(x) }
internal func _log(_ x: Double) -> Double { return log(x) }
internal func _log10(_ x: Double) -> Double { return log10(x) }
internal func _pow(_ x: Double, _ y: Double) -> Double { return pow(x, y) }
internal func _sinh(_ x: Double) -> Double { return sinh(x) }
internal func _cosh(_ x: Double) -> Double { return cosh(x) }
internal func _atanh(_ x: Double) -> Double { return atanh(x) }
internal func _asinh(_ x: Double) -> Double { return asinh(x) }
internal func _acosh(_ x: Double) -> Double { return acosh(x) }
internal func _atan2(_ y: Double, _ x: Double) -> Double { return atan2(y, x) }
internal func _sqrt(_ x: Double) -> Double { return x.squareRoot() }
@_silgen_name("c_floor")
func c_floor(_ x: Double) -> Double
@_silgen_name("c_abs")
func c_abs(_ x: Double) -> Double

internal func _floor(_ x: Double) -> Double { return c_floor(x) }
internal func _abs(_ x: Double) -> Double { return c_abs(x) }


public typealias IndexSet = [Int]

#if hasFeature(Embedded)


internal func parseInt(_ text: String) -> Int? {
    var val = 0
    var sign = 1
    var hasDigits = false
    for ch in text.utf8 {
        if ch == 45 { sign = -1 }
        else if ch >= 48 && ch <= 57 {
            val = val * 10 + Int(ch - 48)
            hasDigits = true
        }
    }
    return hasDigits ? val * sign : nil
}
internal func _substringToString(_ substring: Substring) -> String {
    var s = ""
    for c in substring { s.append(c) }
    return s
}
internal func _formatDouble(_ value: Double) -> String { return "\(value)" }

public func parseDouble(_ text: String) -> Double? {
    var val = 0.0
    var sign = 1.0
    var parsingFraction = false
    var fractionDivisor = 10.0
    
    for ch in text.utf8 {
        if ch == 45 { // '-'
            sign = -1.0
        } else if ch == 46 { // '.'
            parsingFraction = true
        } else if ch >= 48 && ch <= 57 { // '0' to '9'
            let digit = Double(ch - 48)
            if parsingFraction {
                val += digit / fractionDivisor
                fractionDivisor *= 10.0
            } else {
                val = val * 10.0 + digit
            }
        }
    }
    return val * sign
}
internal func parseInt64(_ text: String, radix: Int) -> Int64? {
    var val: Int64 = 0
    var sign: Int64 = 1
    for ch in text.utf8 {
        if ch == 45 { sign = -1 }
        else if ch >= 48 && ch <= 57 { val = val * Int64(radix) + Int64(ch - 48) }
        else if ch >= 65 && ch <= 70 { val = val * Int64(radix) + Int64(ch - 65 + 10) }
        else if ch >= 97 && ch <= 102 { val = val * Int64(radix) + Int64(ch - 97 + 10) }
    }
    return val * sign
}
internal func parseInt64(_ text: String) -> Int64? {
    return parseInt64(text, radix: 10)
}
#else
// This block intentionally removed.
#endif

public class DispatchQueue {
    public static let main = DispatchQueue()
    public func asyncAfter(deadline: Double, execute: @escaping () -> Void) { execute() }
}
public extension Double {
    static func now() -> Double { return 0.0 }
}

public extension Int64 {
    init?(_ text: String, radix: Int) { self = 0 }
}

public extension String {
    init<T>(reflecting value: T) {
        self = "\(value)"
    }
}
public extension FixedWidthInteger {

    init?(_ text: String) { self = 0 }
    init?(_ text: Substring) { self = 0 }
}

public class NumberFormatter {
    public enum Style { case decimal, scientific }
    public var usesGroupingSeparator = false
    public var decimalSeparator = "."
    public var numberStyle: Style = .decimal
    public var minimumFractionDigits = 0
    public var maximumFractionDigits = 0
    public var maximumSignificantDigits = 0
    public var minimumSignificantDigits = 0
    public var usesSignificantDigits = false
    public var exponentSymbol = "E"
    public init() {}
    public func string(from num: NSNumber) -> String? { 
        let val = num.value
        let intPart = Int64(val)
        let fracPart = val < 0 ? Double(intPart) - val : val - Double(intPart)

        var intStr = String(abs(intPart))
        if usesGroupingSeparator && intStr.count > 3 {
            var res = ""
            for (i, ch) in intStr.reversed().enumerated() {
                if i > 0 && i % 3 == 0 { res.append(decimalSeparator == "," ? "." : ",") }
                res.append(ch)
            }
            intStr = String(res.reversed())
        }
        let sign = intPart < 0 ? "-" : ""
        let finalIntPart = sign + intStr

        if fracPart < 0.0000001 {
            return finalIntPart
        } else {
            var fracInt = Int64(fracPart * 100000.0)
            // Remove trailing zeros
            while fracInt > 0 && fracInt % 10 == 0 {
                fracInt /= 10
            }
            var fracStr = String(fracInt)
            // Pad with leading zeros if needed
            let expectedLen = String(Int64(fracPart * 100000.0)).count
            while fracStr.count < expectedLen {
                fracStr = "0" + fracStr
            }
            return finalIntPart + decimalSeparator + fracStr
        }
    }
}
public class NSNumber {
    public let value: Double
    public init(value: Double) { self.value = value }
}

#else
internal func _sin(_ x: Double) -> Double { return Foundation.sin(x) }
internal func _cos(_ x: Double) -> Double { return Foundation.cos(x) }
internal func _tan(_ x: Double) -> Double { return Foundation.tan(x) }
internal func _exp(_ x: Double) -> Double { return Foundation.exp(x) }
internal func _log(_ x: Double) -> Double { return Foundation.log(x) }
internal func _log10(_ x: Double) -> Double { return Foundation.log10(x) }
internal func _pow(_ x: Double, _ y: Double) -> Double { return Foundation.pow(x, y) }
internal func _sinh(_ x: Double) -> Double { return Foundation.sinh(x) }
internal func _cosh(_ x: Double) -> Double { return Foundation.cosh(x) }
internal func _atanh(_ x: Double) -> Double { return Foundation.atanh(x) }
internal func _asinh(_ x: Double) -> Double { return Foundation.asinh(x) }
internal func _acosh(_ x: Double) -> Double { return Foundation.acosh(x) }
internal func _atan2(_ y: Double, _ x: Double) -> Double { return Foundation.atan2(y, x) }
internal func _sqrt(_ x: Double) -> Double { return Foundation.sqrt(x) }
internal func _floor(_ x: Double) -> Double { return floor(x) }
internal func _abs(_ x: Double) -> Double { return Swift.abs(x) }






internal func parseInt(_ text: String) -> Int? { return Int(text) }
internal func _substringToString(_ substring: Substring) -> String { return String(substring) }
internal func _formatDouble(_ value: Double) -> String { return "\(value)" }
public func parseDouble(_ text: String) -> Double? { return Double(text) }
internal func parseInt64(_ text: String, radix: Int) -> Int64? { return Int64(text, radix: radix) }
internal func parseInt64(_ text: String) -> Int64? { return Int64(text) }

#endif

@_silgen_name("format_double_c")
func format_double_c(_ val: Double, _ buffer: UnsafeMutablePointer<UInt8>, _ max_len: Int32, _ mode: Int32, _ places: Int32, _ use_comma: Int32)


#if !hasFeature(Embedded)
@Observable
#endif
public class CalculatorEngine {

    private func computeFractionToFit(valAbs: Double, sign: Double) -> (whole: Int64, num: Int64, den: Int64)? {
        var whole = Int64(valAbs)
        let remainder = valAbs - Double(whole)
        if remainder <= 1e-6 { return (whole, 0, 1) }
        
        let signLen = (sign < 0) ? 1 : 0
        let wholeLen = (whole == 0) ? 0 : String(whole).count
        let spaceLen = (whole == 0) ? 0 : 1
        let available = 12 - signLen - wholeLen - spaceLen - 1
        
        if available < 2 { return nil }
        
        if flags[8] {
            let targetDen = Int64(maxDenominator)
            let targetNum = Int64(round(remainder * Double(targetDen)))
            var fn = targetNum; var fd = targetDen
            if !flags[9] { let d = engineGcd(targetNum, targetDen); fn = targetNum / d; fd = targetDen / d }
            if fn == fd && fd > 0 { fn = 0; whole += 1 }
            if fn == 0 { return (whole, 0, 1) }
            if String(fn).count + String(fd).count <= available { return (whole, fn, fd) }
            return nil
        }
        
        let num = Int64(round(remainder * 1_000_000))
        let den = Int64(1_000_000)
        var currentMaxDenom = Int64(maxDenominator)
        
        while currentMaxDenom >= 2 {
            let frac = Rational<Int64>(num, den).limitDenominator(to: currentMaxDenom)
            var fn = frac.numerator; var fd = frac.denominator
            if fn == fd && fd > 0 { fn = 0; whole += 1 }
            if fn == 0 { return (whole, 0, 1) }
            if String(fn).count + String(fd).count <= available { return (whole, fn, fd) }
            currentMaxDenom = fd - 1
        }
        return nil
    }






    public let lfuManager = LFUManager()
    
    // Standard Display State
    public var displayXBuffer: [UInt8] = Array(repeating: 0, count: 64)
    public var displayXLength: Int = 1
    
    public var displayX: String {
        get { return String(decoding: displayXBuffer[0..<displayXLength], as: UTF8.self) }
        set {
            displayXLength = 0
            for c in newValue.utf8 {
                if displayXLength >= 64 { break }
                displayXBuffer[displayXLength] = c
                displayXLength += 1
            }
        }
    }
    public var promptString: String? = nil
    
    // Stack status
    public var hasStackData: Bool {
        return stack.count > 1 && stack.dropFirst().contains { $0.real != 0.0 || $0.imag != 0.0 }
    }
    
    public var errorMessage: String? = nil
    public var transientMessage: String? = nil
    public var isInterrupted: (() -> Bool)? = nil
    public var isWaitingForFlag: Bool = false
    public var flagAction: String = ""
    public var flagDotPressed: Bool = false
    public var flags: [Bool] = Array(repeating: false, count: 12)
    public var useCommaForDecimal: Bool = false
    public var skipNextInstruction: Bool = false
    
    // UI Events
    public var requestPlot: Bool = false
    public var requestPlotPrompt: Bool = false
    public var selectedPlotX: Double? = nil
    public var requestThemeChange: Bool = false
    /// Set true by handleCommand; the UI observes via onChange and resets to false.
    public var requestEqn: Bool = false
    public var requestFnEq: Bool = false
    public var requestSolve: Bool = false
    public var requestIntegrate: Bool = false
    public var requestXEQ: Bool = false
    public var requestShow: Bool = false
    public var isPlotLoading: Bool = false
    public var plotData: [(Double, Double)] = []
    public var firmwarePlotNodes: [ChartNode] = []

    public var plotMarkers: [(Double, Double)] = []
    public var selectedPlotMarkerIndex: Int? = nil
    public var isStatPlot: Bool = false
    public var isTestMode: Bool = false
    public var isPlotSRequested: Bool = false
    public var autoReturnToMainPad: Bool = true
    public var lastDispDigits: Int = 4
    public var isSilent: Bool = false
    public var integrationLimits: (Double, Double)? = nil
    public var stickyMode: Bool = false
    public var isGeneratingPlot: Bool = false

    /// The currently active calculator menu, shared across all platforms.
    /// - Firmware: `RetroUI.render()` reads this to draw pixel softkeys.
    /// - iOS / watchOS: `CalculatorMenuPresenter` observes this to present a sheet.
    /// Set to `nil` to dismiss the active menu on any platform.
    public var activeMenu: CalculatorMenu? = nil

    // Exam Mode
    public var isExamMode: Bool = false {
        didSet {
            toggleExamMode()
        }
    }
    private var stashedPrograms: [Equation] = []
    private var stashedVariables: [String: CalculatorValue] = [:]
    
    // Shift State: 0=None, 1=Yellow(f), 2=Blue(g)
    public var shiftState: Int = 0 // 0: unshifted, 1: yellow, 2: blue
    public var isAssigning: Bool = false  // Unlimited Stack Array (For Overlay) - String representation

    public var stackStrings: [String] = []
    
    // Internal state - stack[0] is X, stack[1] is Y, etc.
    private var plotSavedStack: [CalculatorValue] = Array(repeating: CalculatorValue(), count: 10)
    private var plotSavedInputBuffer: [UInt8] = Array(repeating: 0, count: 50)
    private var plotSavedStackStrings: [String] = Array(repeating: "", count: 10)
    private var plotSavedDisplayXBuffer: [UInt8] = Array(repeating: 0, count: 50)
    public var stack: [CalculatorValue] = [CalculatorValue()]
    public var isBuildingNumber: Bool = false
    private var hasDecimal: Bool = false
    private var isBuildingExponent: Bool = false
    public var currentInputBuffer: [UInt8] = Array(repeating: 0, count: 64)
    public var currentInputLength: Int = 1
    private func appendInputByte(_ b: UInt8) {
        if currentInputLength < 64 {
            currentInputBuffer[currentInputLength] = b
            currentInputLength += 1
        }
    }


    private var currentExponent: String = ""
    
    // Last X
    public var lastX: CalculatorValue = CalculatorValue()
    
    // Statistics Registers
    public var statN: Double = 0.0
    public var statSumX: Double = 0.0
    public var statSumX2: Double = 0.0
    public var statSumY: Double = 0.0
    public var statSumY2: Double = 0.0
    public var statSumXY: Double = 0.0
    
    #if !hasFeature(Embedded)
    public struct StatPoint: Codable, Equatable {
        public let x: Double
        public let y: Double
    }
    #else
    public struct StatPoint: Equatable {
        public let x: Double
        public let y: Double
    }
    #endif
    public var statPoints: [StatPoint] = []
    
    // Variables & Equations
    public var variables: [String: CalculatorValue] = [:]
    
    #if !hasFeature(Embedded)
    public struct Equation: Codable, Identifiable {
        public var id: String { label }
        public var label: String
        public var steps: [Instruction]
        
        public init(label: String, steps: [Instruction]) {
            self.label = label
            self.steps = steps
        }
        
        private enum CodingKeys: String, CodingKey {
            case label, steps
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.label = try container.decode(String.self, forKey: .label)
            let stringSteps = try container.decode([String].self, forKey: .steps)
            self.steps = stringSteps.compactMap { Instruction(fromString: $0) }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(label, forKey: .label)
            let stringSteps = steps.map { $0.stringValue }
            try container.encode(stringSteps, forKey: .steps)
        }
        
        public func extractVariables() -> [String] {
            var vars: [String] = []
            var seen = Set<String>()
            for step in steps {
                var v: String? = nil
                switch step {
                case .operation(let op):
                    if op.stringValue.count == 1 && "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(op.stringValue) {
                        v = op.stringValue
                    }
                case .sto(let s), .rcl(let s):
                    v = s
                case .custom(let s):
                    if s.count == 1 && "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(s) {
                        v = s
                    } else if (s.hasPrefix("RCL ") || s.hasPrefix("STO ")) && s.count == 5 {
                        let char = String(s.last!)
                        if "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(char) {
                            v = char
                        }
                    }
                default: break
                }
                
                if let v = v, seen.insert(v).inserted {
                    vars.append(v)
                }
            }
            return vars
        }
    }
    #else
    public struct Equation: Identifiable {
        public var id: String { label }
        public var label: String
        public var steps: [Instruction]
        
        public init(label: String, steps: [Instruction]) {
            self.label = label
            self.steps = steps
        }
        
        public func extractVariables() -> [String] {
            var vars: [String] = []
            var seen = Set<String>()
            for step in steps {
                var v: String? = nil
                switch step {
                case .operation(let op):
                    if op.stringValue.count == 1 && "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(op.stringValue) {
                        v = op.stringValue
                    }
                case .sto(let s), .rcl(let s):
                    v = s
                case .custom(let s):
                    if s.count == 1 && "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(s) {
                        v = s
                    } else if (s.hasPrefix("RCL ") || s.hasPrefix("STO ")) && s.count == 5 {
                        let char = String(s.last!)
                        if "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(char) {
                            v = char
                        }
                    }
                default: break
                }
                
                if let v = v, seen.insert(v).inserted {
                    vars.append(v)
                }
            }
            return vars
        }
    }
    #endif
    public var equations: [Equation] = [] {
        didSet {
            #if !hasFeature(Embedded)
            if let data = try? JSONEncoder().encode(equations) {
                UserDefaults.standard.set(data, forKey: "saved_programs")
            }
            #endif
        }
    }
    
    public init() {
        #if !hasFeature(Embedded)
        if let data = UserDefaults.standard.data(forKey: "saved_programs"),
           let savedPrograms = try? JSONDecoder().decode([Equation].self, from: data) {
            self.equations = savedPrograms
        }
        #endif
        
        let pdfSteps = ["X", "𝑥²", "2", "÷", "+/-", "𝑒ˣ", "2", "π", "×", "√𝑥", "÷"]
        let normalPDF = Equation(label: "NPDF", steps: pdfSteps.compactMap { Instruction(fromString: $0) })
        if !equations.contains(where: { $0.label == "NPDF" }) {
            equations.append(normalPDF)
        }
        updateDisplay()
    }
    public var currentEquationLabel: String = ""
    public var currentEquationSteps: [String] = []
    public var currentEquationStepIndex: Int = 0
    public var isEquationEditMode: Bool = false
    public var isEquationListMode: Bool = false
    public var currentEquationListIndex: Int = 0
    public var lastCrownValue: Double = 0.0
    
    public func scrollUp() {
        if isEquationListMode {
            if !equations.isEmpty {
                currentEquationListIndex = max(0, currentEquationListIndex - 1)
                updateDisplay()
            }
        } else if isEquationEditMode {
            if currentEquationStepIndex > 0 {
                currentEquationStepIndex -= 1
                updateEquationDisplay()
            }
        }
    }
    
    public func scrollDown() {
        if isEquationListMode {
            if !equations.isEmpty {
                currentEquationListIndex = min(equations.count - 1, currentEquationListIndex + 1)
                updateDisplay()
            }
        } else if isEquationEditMode {
            if currentEquationStepIndex < currentEquationSteps.count {
                currentEquationStepIndex += 1
                updateEquationDisplay()
            }
        }
    }
    
    public var isWaitingForLabel: Bool = false
    public var complexMode: Bool = false
    public var isHypPending: Bool = false
    
    public func newEquation() {
        isWaitingForLabel = true
        startAlpha()
        alphaPrompt = "LBL _"
        promptString = "LBL "
    }
    
    public func editEquation(_ equation: Equation) {
        isEquationEditMode = true
        currentEquationLabel = equation.label
        currentEquationSteps = equation.steps.map { $0.stringValue }
        updateEquationDisplay()
    }
    
    // Modes
    public var isWaitingForAlpha: Bool = false
    public var alphaAction: AlphaAction = .none
    public var alphaPrompt: String = "Variable"
    public var pendingEquationVars: [String] = []
    public var currentEvaluatingEquation: Equation? = nil
    
    public var angleMode: AngleMode = .deg
    public var displayMode: DisplayMode = .all
    public var activeTheme: Theme = .pioneer
    public var statusMessage: String? = nil
    
    public enum Theme { case pioneer, modern }
    public var baseMode: BaseMode = .dec
    public var isFractionMode: Bool = false { didSet { flags[7] = isFractionMode } }
    public var maxDenominator: Double = 4095.0
    public var stackSizeLimit: Int = 4
    
    public enum AngleMode: Equatable { case deg, rad, grd }

    public enum DisplayMode: Equatable {
        case fix(Int)
        case sci(Int)
        case eng(Int)
        case all
    }

    public enum BaseMode: Equatable { case dec, hex, oct, bin }
    
    public enum AlphaAction {
        case none, sto, stoAdd, stoSub, stoMul, stoDiv, rcl, evalEquation, promptVar, view, swapVar, solve, integrate, fnEq
    }
    
    public enum ResumeAction {
        case none
        case eval(Equation)
        case solve(variable: String, equation: Equation)
        case integrate(variable: String, lower: Double, upper: Double, equation: Equation, requestPlotAfter: Bool = false)
        case plot(variable: String, lower: Double, upper: Double, equation: Equation)
    }
    public var currentResumeAction: ResumeAction = .none
    
    public var usesContextualAlphaPad: Bool {
        return alphaAction == .sto || alphaAction == .stoAdd || alphaAction == .stoSub || alphaAction == .stoMul || alphaAction == .stoDiv || alphaAction == .rcl || alphaAction == .promptVar || alphaAction == .view || alphaAction == .swapVar || alphaAction == .solve || alphaAction == .integrate || alphaAction == .fnEq
    }
    

    public func clearPrograms() {
        equations.removeAll()
        currentEquationSteps.removeAll()
        currentEquationLabel = ""
        isEquationEditMode = false
        isEquationListMode = false
        updateDisplay()
    }
    
    private func saveEquation() {
        if let idx = equations.firstIndex(where: { $0.label == currentEquationLabel }) {
            equations[idx] = Equation(label: currentEquationLabel, steps: currentEquationSteps.compactMap { Instruction(fromString: $0) })
        } else {
            equations.append(Equation(label: currentEquationLabel, steps: currentEquationSteps.compactMap { Instruction(fromString: $0) }))
        }
    }
    
    public func clearStats() {
        statN = 0.0
        statSumX = 0.0
        statSumX2 = 0.0
        statSumY = 0.0
        statSumY2 = 0.0
        statSumXY = 0.0
        statPoints.removeAll()
        updateDisplay()
    }
    
    public func clearVars() {
        variables.removeAll()
        updateDisplay()
    }
    
    public func clearStack() {
        stack = Array(repeating: CalculatorValue(), count: stackSizeLimit)
        lastX = CalculatorValue()
        isBuildingNumber = false
        currentInputLength = 0
        updateDisplay()
    }
    
    public func clearAll() {
        stack = [CalculatorValue(), CalculatorValue(), CalculatorValue(), CalculatorValue()]
        lastX = CalculatorValue()
        clearStats()
        clearVars()
        clearPrograms()
        isFractionMode = false
        displayMode = .all
        shiftState = 0
        isBuildingNumber = false
        isEquationListMode = false
        currentInputLength = 0
        promptString = nil
        isWaitingForAlpha = false
        alphaAction = .none
        isWaitingForLabel = false
        pendingEquationVars = []
        updateDisplay()
    }
    
    private func toggleExamMode() {
        if isExamMode {
            // Turning ON: Stash data and clear active memory
            stashedPrograms = equations
            stashedVariables = variables
            
            equations.removeAll()
            variables.removeAll()
            
            // Clear all active state to prevent smuggling values
            stack = [CalculatorValue(), CalculatorValue(), CalculatorValue(), CalculatorValue()]
            lastX = CalculatorValue()
            clearStats()
            isEquationEditMode = false
                currentEquationSteps.removeAll()
            currentInputLength = 0
            isBuildingNumber = false
            shiftState = 0
            
            // Show a brief message
            errorMessage = "EXAM MODE ON"
        } else {
            // Turning OFF: Restore stashed data (wiping anything entered during the exam)
            equations = stashedPrograms
            variables = stashedVariables
            
            stashedPrograms.removeAll()
            stashedVariables.removeAll()
            
            errorMessage = "EXAM MODE OFF"
        }
        updateDisplay()
    }
    
    // MARK: - Input
    
    public var stackLiftEnabled: Bool = true
    public var eqnIsBuildingNumber: Bool = false
    
    public func digit(_ d: Int) {
        if isWaitingForLabel { return }
        if transientMessage != nil { transientMessage = nil; updateDisplay() }
        if errorMessage != nil { clearError(); return }
        
        if alphaAction != .promptVar {
            if isEquationEditMode {
                if let last = currentEquationSteps.last, isEquationNumberStep(last) {
                    currentEquationSteps[currentEquationSteps.count - 1] = last + "\(d)"
                } else {
                    currentEquationSteps.append("\(d)")
                }
                eqnIsBuildingNumber = true
                updateEquationDisplay()
                return
            }
        }
        
        // Base constraints
        if baseMode == .bin && d > 1 { return }
        if baseMode == .oct && d > 7 { return }
        
        if isBuildingExponent {
            if currentExponent.count < 3 {
                if currentExponent == "0" {
                    currentExponent = "\(d)"
                } else if currentExponent == "-0" {
                    currentExponent = "-\(d)"
                } else {
                    currentExponent += "\(d)"
                }
            }
        } else {
            if !isBuildingNumber {
                if stackLiftEnabled && !stack.isEmpty {
                    pushToStack(stack[0]) // Push stack
                }
                isBuildingNumber = true
                currentInputBuffer[0] = UInt8(d + 48); currentInputLength = 1
                hasDecimal = false
                isBuildingExponent = false
            } else {
                if currentInputLength == 1 && currentInputBuffer[0] == 48 && d == 0 { return }
                
                if currentInputLength == 1 && currentInputBuffer[0] == 48 {
                    currentInputBuffer[0] = UInt8(d + 48); currentInputLength = 1
                } else {
                    appendInputByte(UInt8(d + 48))
                }
            }
        }
        updateCurrentInputDisplay()
    }
    
    public func letter(_ l: String) {
        if isEquationEditMode {
            currentEquationSteps.append(l.uppercased())
            updateEquationDisplay()
        } else if baseMode == .hex {
            if !isBuildingNumber {
                isBuildingNumber = true
                currentInputBuffer[0] = l.utf8.first!; currentInputLength = 1
            } else {
                appendInputByte(l.utf8.first!)
            }
            updateCurrentInputDisplay()
        }
    }
    
    public func startExponent() {
        if errorMessage != nil { clearError(); return }
        if alphaAction != .promptVar {
            if isEquationEditMode {
                if let last = currentEquationSteps.last, isEquationNumberStep(last) {
                    currentEquationSteps[currentEquationSteps.count - 1] = last + "E"
                } else {
                    currentEquationSteps.append("1E")
                }
                eqnIsBuildingNumber = true
                updateEquationDisplay()
                return
            }
        }
        if !isBuildingNumber {
            isBuildingNumber = true
            currentInputBuffer[0] = 49; currentInputLength = 1
        }
        isBuildingExponent = true
        currentExponent = "0"
        updateCurrentInputDisplay()
    }
    
    public func decimal() {
        if errorMessage != nil { clearError(); return }
        
        if alphaAction != .promptVar {
            if isEquationEditMode {
                if let last = currentEquationSteps.last, isEquationNumberStep(last) {
                    currentEquationSteps[currentEquationSteps.count - 1] = last + "."
                } else {
                    currentEquationSteps.append(".")
                }
                eqnIsBuildingNumber = true
                updateEquationDisplay()
                return
            }
        }

        if baseMode != .dec { return } // No decimals in bases
        if isBuildingExponent { return }
        if !isBuildingNumber {
            if stackLiftEnabled && !stack.isEmpty {
                pushToStack(stack[0])
            }
            isBuildingNumber = true
            currentInputBuffer[0] = 48; currentInputBuffer[1] = 46; currentInputLength = 2
            hasDecimal = true
        } else if !hasDecimal {
            appendInputByte(46)
            hasDecimal = true
        } else {
            // Support HP 32sii fraction input (e.g. 1.2.3 for 1 2/3)
            // Allow up to 2 decimals total
            var dotCount = 0
            for i in 0..<currentInputLength {
                if currentInputBuffer[i] == 46 { dotCount += 1 }
            }
            if dotCount < 2 {
                appendInputByte(46)
                if dotCount == 1 {
                    isFractionMode = true // Auto-enable fraction display on second decimal
                }
            } else {
                return // Disallow more than 2 decimals
            }
        }
        updateCurrentInputDisplay()
    }
    
    public func complexSeparator() {
        // Obsolete: HP32SII uses X and Y registers for complex entry
    }
    
    public func toggleSign() {
        if errorMessage != nil { clearError(); return }
        if alphaAction != .promptVar {
            if isEquationEditMode {
                if let last = currentEquationSteps.last, isEquationNumberStep(last) {
                    if let eIndex = last.lastIndex(of: "E") {
                        let base = last[..<eIndex]
                        var exp = String(last[last.index(after: eIndex)...])
                        if exp.hasPrefix("-") {
                            exp.removeFirst()
                        } else {
                            exp = "-" + exp
                        }
                        currentEquationSteps[currentEquationSteps.count - 1] = base + "E" + exp
                    } else {
                        if last.hasPrefix("-") {
                            currentEquationSteps[currentEquationSteps.count - 1] = String(last.dropFirst())
                        } else {
                            currentEquationSteps[currentEquationSteps.count - 1] = "-" + last
                        }
                    }
                } else {
                    currentEquationSteps.append("+/-")
                }
                eqnIsBuildingNumber = true
                updateEquationDisplay()
                return
            }
        }

        if isBuildingNumber {
            if isBuildingExponent {
                if currentExponent.hasPrefix("-") {
                    currentExponent.removeFirst()
                } else {
                    currentExponent = "-" + currentExponent
                }
            } else {
                                if currentInputLength > 0 && currentInputBuffer[0] == 45 {
                    for i in 1..<currentInputLength { currentInputBuffer[i-1] = currentInputBuffer[i] }
                    currentInputLength -= 1
                } else {
                    if !(currentInputLength == 1 && currentInputBuffer[0] == 48) {
                        for i in (0..<currentInputLength).reversed() { currentInputBuffer[i+1] = currentInputBuffer[i] }
                        currentInputBuffer[0] = 45
                        currentInputLength += 1
                    }
                }
            }
            updateCurrentInputDisplay()
        } else {
            if !stack.isEmpty {
                lastX = stack[0]
                stack[0] = CalculatorValue(real: -stack[0].real)
                updateDisplay()
            }
        }
    }
    
    @_silgen_name("format_input_buffer_c")
    func format_input_buffer_c(_ inBuf: UnsafePointer<UInt8>, _ inLen: Int32, _ expBuf: UnsafePointer<UInt8>?, _ expLen: Int32, _ outBuf: UnsafeMutablePointer<UInt8>, _ maxOut: Int32, _ useComma: Int32) -> Int32

    private func updateCurrentInputDisplay() {
        var expBytes: [UInt8] = []
        if isBuildingExponent {
            expBytes = currentExponent.isEmpty ? [48] : Array(currentExponent.utf8) // 48 is '0'
        }
        
        #if hasFeature(Embedded)
        let inPtr = currentInputBuffer.withUnsafeBufferPointer { $0.baseAddress! }
        let outPtr = displayXBuffer.withUnsafeMutableBufferPointer { $0.baseAddress! }
        
        if expBytes.isEmpty {
            displayXLength = Int(format_input_buffer_c(inPtr, Int32(currentInputLength), nil, 0, outPtr, 64, useCommaForDecimal ? 1 : 0))
        } else {
            expBytes.withUnsafeBufferPointer { expPtr in
                displayXLength = Int(format_input_buffer_c(inPtr, Int32(currentInputLength), expPtr.baseAddress!, Int32(expBytes.count), outPtr, 64, useCommaForDecimal ? 1 : 0))
            }
        }
        #else
        var outBytes = [UInt8](repeating: 0, count: 64)
        let inLen = Int32(currentInputLength)
        let expLen = Int32(expBytes.count)
        
        let outLen: Int32 = currentInputBuffer.withUnsafeBufferPointer { inPtr in
            outBytes.withUnsafeMutableBufferPointer { outPtr in
                if expLen == 0 {
                    return format_input_buffer_c(inPtr.baseAddress!, inLen, nil, 0, outPtr.baseAddress!, 64, useCommaForDecimal ? 1 : 0)
                } else {
                    return expBytes.withUnsafeBufferPointer { expPtr in
                        return format_input_buffer_c(inPtr.baseAddress!, inLen, expPtr.baseAddress!, expLen, outPtr.baseAddress!, 64, useCommaForDecimal ? 1 : 0)
                    }
                }
            }
        }
        
        displayX = String(decoding: outBytes[0..<Int(outLen)], as: UTF8.self)
        updateStackStrings()
        #endif
    }
    
    private func parseFractionString(_ input: String) -> Double {
        // Parse "1.2.3" -> 1 + 2/3
        // Parse "0.1.2" -> 0 + 1/2
        // Parse "1.2" -> 1.2 (standard float)
        let parts = input.split(separator: Character(".")).map { String($0) }
        if parts.count == 3 {
            let whole = parseDouble(parts[0]) ?? 0.0
            let num = parseDouble(parts[1]) ?? 0.0
            let den = parseDouble(parts[2]) ?? 1.0
            let sign = whole < 0 || input.hasPrefix("-") ? -1.0 : 1.0
            if den == 0 { return 0.0 } // Prevent division by zero
            return sign * ((whole < 0 ? -whole : whole) + (num / den))
        } else {
            return parseDouble(input) ?? 0.0
        }
    }
    
    public func commitInput() {
        if isBuildingNumber {
            var decimalCount = 0
            var decimalPos = -1
            var hasExponent = false
            for i in 0..<currentInputLength {
                if currentInputBuffer[i] == 46 { 
                    decimalCount += 1 
                    decimalPos = i
                }
                if currentInputBuffer[i] == 69 { hasExponent = true }
            }
            var val = 0.0
            
            if decimalCount == 2 {
                // To avoid String allocations in Embedded Swift, parse the fraction slice directly
                // format: integer.numerator.denominator
                var part0: Double = 0.0
                var part1: Double = 0.0
                var part2: Double = 0.0
                var currentPart: Double = 0.0
                var partIndex = 0
                var emptyPart1 = false
                var emptyPart0 = false
                var charsInPart = 0
                var isNegativeFraction = false
                
                for i in 0..<currentInputLength {
                    let c = currentInputBuffer[i]
                    if c == 46 { // '.'
                        if partIndex == 0 { 
                            part0 = currentPart
                            if charsInPart == 0 { emptyPart0 = true }
                        }
                        else if partIndex == 1 { 
                            part1 = currentPart
                            if charsInPart == 0 { emptyPart1 = true }
                        }
                        else if partIndex == 2 { part2 = currentPart }
                        currentPart = 0.0
                        charsInPart = 0
                        partIndex += 1
                    } else if c >= 48 && c <= 57 {
                        currentPart = currentPart * 10.0 + Double(c - 48)
                        charsInPart += 1
                    } else if c == 45 { // '-'
                        isNegativeFraction = true
                    }
                }
                if partIndex == 0 { part0 = currentPart }
                else if partIndex == 1 { part1 = currentPart }
                else if partIndex == 2 { part2 = currentPart }
                
                if partIndex >= 2 && part2 != 0 {
                    if emptyPart1 {
                        // b..c form (e.g. 1..2 -> 1/2)
                        val = part0 / part2
                    } else {
                        // a.b.c or .b.c form
                        val = part0 + (part1 / part2)
                    }
                } else {
                    val = part0
                }
                
                if isNegativeFraction {
                    val = -val
                }
            } else {
                if baseMode != .dec {
                    let radix: Int64
                    switch baseMode {
                    case .hex: radix = 16
                    case .oct: radix = 8
                    case .bin: radix = 2
                    default: radix = 10
                    }
                    var parsedInt: Int64 = 0
                    var valid = false
                    for i in 0..<currentInputLength {
                        let c = currentInputBuffer[i]
                        var digit: Int64 = -1
                        if c >= 48 && c <= 57 { digit = Int64(c - 48) }
                        else if c >= 65 && c <= 70 { digit = Int64(c - 65 + 10) }
                        else if c >= 97 && c <= 102 { digit = Int64(c - 97 + 10) }
                        if digit >= 0 && digit < radix {
                            parsedInt = parsedInt * radix + digit
                            valid = true
                        }
                    }
                    val = valid ? Double(parsedInt) : 0.0
                } else {
                    val = parseDoubleSlice(currentInputBuffer[0..<currentInputLength], exponent: isBuildingExponent ? currentExponent : nil)
                }
            }
            
            if stack.isEmpty {
                stack.append(CalculatorValue(real: val))
            } else {
                stack[0] = CalculatorValue(real: val)
            }
            isBuildingNumber = false
            isBuildingExponent = false
        }
    }
    
    // MARK: - Stack Operations
    
    public func removeStackItem(at index: Int) {
        let arrayIndex = stack.count - 1 - index
        if arrayIndex >= 0 && arrayIndex < stack.count {
            stack.remove(at: arrayIndex)
            updateDisplay()
        }
    }
    
    public func moveStackItem(fromOffsets source: IndexSet, toOffset destination: Int) {
        var reversedArray = Array(stack.reversed())
        // Standard array move
        let itemsToMove = source.map { reversedArray[$0] }
        var dest = destination
        for idx in source.sorted(by: >) {
            reversedArray.remove(at: idx)
            if idx < dest {
                dest -= 1
            }
        }
        reversedArray.insert(contentsOf: itemsToMove, at: dest)
        stack = Array(reversedArray.reversed())
        updateDisplay()
    }
    
    public func enter() {
        errorMessage = nil
        
        if isEquationListMode {
            isEquationListMode = false
            updateDisplay()
            return
        }
        
        if alphaAction == .promptVar {
            if isBuildingNumber { commitInput() }
            if let varName = pendingEquationVars.first {
                print("ENTER VAR: \(varName) VALUE: \(stack.first?.real ?? 0)")
                self.variables[varName] = stack.count > 0 ? stack[0] : CalculatorValue()
                pendingEquationVars.removeFirst()
                promptNextEquationVar()
            }
            return
        }
        
        if isEquationEditMode {
            if eqnIsBuildingNumber {
                eqnIsBuildingNumber = false
            } else {
                currentEquationSteps.append("ENTER")
            }
            updateEquationDisplay()
            return
        }
        
        if isBuildingNumber {
            commitInput()
            pushToStack(stack[0])
        } else {
            if !stack.isEmpty {
                pushToStack(stack[0])
            }
        }
        stackLiftEnabled = false
        updateDisplay()
    }
    
    @discardableResult
    public func clearError() -> Bool {
        if errorMessage != nil {
            errorMessage = nil
            stackLiftEnabled = false
            updateDisplay()
            return true
        }
        return false
    }
    
    public func clearX() {
        if clearError() { return }
        if isEquationEditMode {
            currentEquationSteps.removeAll()
            updateEquationDisplay()
            return
        }
        if !stack.isEmpty {
            stack[0] = CalculatorValue()
        }
        currentInputBuffer[0] = 48; currentInputLength = 1
        isBuildingNumber = false
        hasDecimal = false
        isBuildingExponent = false
        stackLiftEnabled = false
        updateDisplay()
    }
    
    public func backspace() {
        if clearError() { return }

        if alphaAction != .promptVar {
            if isEquationEditMode {
                if !currentEquationSteps.isEmpty {
                    currentEquationSteps.removeLast()
                    updateEquationDisplay()
                }
                return
            }
        }
        
        if isBuildingNumber {
            if isBuildingExponent {
                if !currentExponent.isEmpty && currentExponent != "-" {
                    currentExponent.removeLast()
                    if currentExponent.isEmpty || currentExponent == "-" {
                        currentExponent = ""
                    }
                } else {
                    isBuildingExponent = false
                    currentExponent = ""
                }
            } else {
                if currentInputLength > 1 {
                    let last = currentInputBuffer[currentInputLength - 1]
                    currentInputLength -= 1
                    if last == 46 { hasDecimal = false }
                    
                    if currentInputLength == 1 && currentInputBuffer[0] == 45 {
                        currentInputBuffer[0] = 48
                    }
                } else {
                    currentInputBuffer[0] = 48
                    currentInputLength = 1
                    isBuildingNumber = false
                    
                    // HP32SII Parity: When you completely cancel a number entry
                    // by backspacing the last character, the stack should drop
                    // to reverse the stack lift that occurred when you started typing.
                    if stackLiftEnabled == true {
                        // We must have pushed the stack when we started building.
                        // Undo the push (drop the stack).
                        for i in 0..<(stackSizeLimit - 1) {
                            stack[i] = stack[i+1]
                        }
                        stack[stackSizeLimit - 1] = CalculatorValue()
                    } else {
                        stack[0] = CalculatorValue()
                    }
                    stackLiftEnabled = false
                }
            }
            if isBuildingNumber {
                updateCurrentInputDisplay()
            } else {
                updateDisplay()
            }
        } else {
            stack[0] = CalculatorValue()
            stackLiftEnabled = false
            updateDisplay()
        }
    }
    
    public func rollDown() {
        commitInput()
        if stack.count > 1 {
            let x = stack[0]
            for i in 0..<(stackSizeLimit - 1) {
                stack[i] = stack[i+1]
            }
            stack[stackSizeLimit - 1] = x
        }
        stackLiftEnabled = true
        updateDisplay()
    }
    
    public func rollUp() {
        commitInput()
        if stack.count == stackSizeLimit {
            let last = stack[stackSizeLimit - 1]
            for i in (1..<stackSizeLimit).reversed() {
                stack[i] = stack[i-1]
            }
            stack[0] = last
        }
        stackLiftEnabled = true
        updateDisplay()
    }
    
    public func swapXY() {
        commitInput()
        if stack.count >= 2 {
            let temp = stack[0]
            stack[0] = stack[1]
            stack[1] = temp
        } else if stack.count == 1 {
            stack.append(CalculatorValue())
            let temp = stack[0]
            stack[0] = stack[1]
            stack[1] = temp
        }
        stackLiftEnabled = false
        updateDisplay()
    }
    // MARK: - Math Operations
    
    private func performTest(_ result: Bool) {
        if isEquationEditMode {
            commitInput()
            pushToStack(CalculatorValue(real: result ? 1.0 : 0.0))
            updateDisplay()
        } else {
            transientMessage = result ? "YES" : "NO"
            #if !hasFeature(Embedded)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if self.transientMessage == "YES" || self.transientMessage == "NO" {
                    self.transientMessage = nil
                }
            }
            #endif
        }
    }

    public func executeOp(_ operation: CalculatorOperation, param: String? = nil) {
        if operation == .shiftYellow {
            shiftState = (shiftState == 1) ? 0 : 1
            return
        }
        if operation == .shiftBlue {
            shiftState = (shiftState == 2) ? 0 : 2
            return
        }
        
        let opString = param != nil ? "\(operation.stringValue) \(param!)" : operation.stringValue
        executeMath(opString)
    }

    public func execute(_ instruction: Instruction) {
        if isWaitingForLabel {
            if instruction == .operation(.clear) || instruction == .operation(.backspace) {
                cancelAlpha()
            }
            return
        }
        
        switch instruction {
        case .operation(let op):
            let raw = op.rawValue
            if raw >= CalculatorOperation.digit0.rawValue && raw <= CalculatorOperation.digit9.rawValue {
                digit(raw - CalculatorOperation.digit0.rawValue)
                return
            }
        default:
            break
        }
        
        // Forward all remaining logic directly via the stringValue to the existing handleCommand block.
        // This is safe since we eliminated strings from the *Equation* evaluator!
        handleCommand(instruction.stringValue)
    }
    
    
    public func executeMath(_ operation: String) {

        if transientMessage != nil {
            transientMessage = nil
            updateDisplay()
            if operation != "VIEW" {
                // If they typed something else, it just clears the view and proceeds.
            }
        }
        
        if isWaitingForLabel {
            if operation == "C" || operation == "CLEAR" || operation == "BACKSPACE" {
                cancelAlpha()
            }
            return
        }
        
        if operation == "↑" {
            scrollUp()
            return
        }
        if operation == "↓" {
            scrollDown()
            return
        }

        if isWaitingForFlag {
            handleCommand(operation)
            return
        }
        
        if operation.count == 1 {
            let char = operation.first!
            if char >= "0" && char <= "9" {
                if let ascii = char.asciiValue {
                    let d = Int(ascii - 48)
                    digit(d)
                    return
                }
            }
        }
        
        handleCommand(operation)
    }
    
    public func handleCommand(_ operation: String) {
        if operation == "SF" || operation == "CF" || operation == "FS?" {
            if isBuildingNumber { commitInput() }
            isWaitingForFlag = true
            flagAction = operation
            flagDotPressed = false
            promptString = "\(operation) _"
            updateDisplay()
            return
        }

        if transientMessage != nil {
            transientMessage = nil
            updateDisplay()
            if operation != "VIEW" {
                // If they typed something else, it just clears the view and proceeds.
            }
        }
        
        if isWaitingForLabel {
            if operation == "C" || operation == "CLEAR" || operation == "BACKSPACE" {
                cancelAlpha()
            }
            return
        }
        
        if operation == "↑" {
            scrollUp()
            return
        }
        if operation == "↓" {
            scrollDown()
            return
        }

        if isWaitingForFlag {
            if operation == "C" || operation == "CLEAR" || operation == "BACKSPACE" {
                isWaitingForFlag = false
                promptString = nil
                updateDisplay()
                return
            }
            if operation == "." {
                flagDotPressed = true
                promptString = "\(flagAction) ._"
                updateDisplay()
                return
            }
            if operation.count == 1, let char = operation.first, char >= "0" && char <= "9" {
                var flagNum = Int(char.asciiValue! - 48)
                if flagDotPressed {
                    if flagNum == 0 { flagNum = 10 }
                    else if flagNum == 1 { flagNum = 11 }
                    else { flagNum = -1 }
                }
                if flagNum >= 0 && flagNum <= 11 {
                    if flagAction == "SF" {
                        flags[flagNum] = true
                        if flagNum == 7 { isFractionMode = true }
                    } else if flagAction == "CF" {
                        flags[flagNum] = false
                        if flagNum == 7 { isFractionMode = false }
                    } else if flagAction == "FS?" {
                        errorMessage = flags[flagNum] ? "YES" : "NO"
                        isWaitingForFlag = false
                        promptString = nil
                        updateDisplay()
                        return
                    }
                    
                }
                isWaitingForFlag = false
                promptString = nil
                updateDisplay()
                return
            }
            return
        }
        
        if alphaAction == .promptVar {
            if operation == "ENTER" || operation == "R/S" {
                if isBuildingNumber { commitInput() }
                if let varName = pendingEquationVars.first {
                    self.variables[varName] = stack.count > 0 ? stack[0] : CalculatorValue()
                    pendingEquationVars.removeFirst()
                    promptNextEquationVar()
                }
                return
            } else if operation == "C" || operation == "CLEAR" {
                cancelAlpha()
                return
            }
        }
        
        if errorMessage != nil {
            clearError()
            return
        }

        if isAssigning {
            isAssigning = false
            if operation == "CLEAR" {
                // Unassign something? User said: "Unassign by clicking Assign and then 'C'"
                // If they click C (CLEAR), clear all manual assignments
                for (slot, _) in lfuManager.pinnedSlots {
                    lfuManager.clearAssignment(at: slot)
                }
            } else if !["ASGN", "SETUP", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "ENTER", "+", "-", "×", "÷"].contains(operation) {
                // Find first unpinned slot to assign to
                var slotToAssign = 0
                for i in 0..<16 {
                    if lfuManager.pinnedSlots[i] == nil {
                        slotToAssign = i
                        break
                    }
                }
                lfuManager.assign(operation, to: slotToAssign)
            }
            updateDisplay()
            return
        }
        
        lfuManager.recordUsage(of: operation)
        func parseFlag(_ s: Substring) -> Int? {
            switch String(s) {
            case "0": return 0; case "1": return 1; case "2": return 2; case "3": return 3;
            case "4": return 4; case "5": return 5; case "6": return 6; case "7": return 7;
            case "8": return 8; case "9": return 9; case "10": return 10; case "11": return 11;
            default: return nil
            }
        }
        
        if operation.hasPrefix("SF ") {
            if let f = parseFlag(operation.dropFirst(3)), f >= 0 && f < 12 { flags[f] = true }
            return
        }
        if operation.hasPrefix("CF ") {
            if let f = parseFlag(operation.dropFirst(3)), f >= 0 && f < 12 { flags[f] = false }
            return
        }
        if operation.hasPrefix("FS? ") {
            if let f = parseFlag(operation.dropFirst(4)), f >= 0 && f < 12 { performTest(flags[f]) }
            return
        }
        if operation.hasPrefix("FC? ") {
            if let f = parseFlag(operation.dropFirst(4)), f >= 0 && f < 12 { performTest(!flags[f]) }
            return
        }
        
        if operation == "PRGM" {
            if isEquationEditMode {
                saveEquation()
                isEquationEditMode = false
                isWaitingForLabel = false
                eqnIsBuildingNumber = false
                promptString = nil
                updateDisplay()
                return
            }
            isEquationEditMode = true
            updateEquationDisplay()
            return
        }
        
        // Intercept inputs when building a equation or equation
        if isEquationEditMode && !isWaitingForAlpha {
            if ["STO", "RCL", "LBL", "GTO", "XEQ", "VIEW"].contains(operation) {
                // Let these fall through to prompt for alpha
                eqnIsBuildingNumber = false
            } else if operation == "C" || operation == "CLEAR" {
                saveEquation()
                isEquationEditMode = false
                isWaitingForLabel = false
                eqnIsBuildingNumber = false
                promptString = nil
                updateDisplay()
                return
            } else if let p = parseInt(operation) {
                currentEquationSteps.append("\(p)")
                eqnIsBuildingNumber = true
                updateEquationDisplay()
                return
            } else if operation == "BACKSPACE" {
                if !currentEquationSteps.isEmpty {
                    currentEquationSteps.removeLast()
                }
                eqnIsBuildingNumber = false
                updateEquationDisplay()
                return
            } else if operation == "CLEAR" {
                currentEquationSteps.removeAll()
                eqnIsBuildingNumber = false
                updateEquationDisplay()
                return
            } else if operation == "RTN" {
                currentEquationSteps.append("RTN")
                saveEquation()
                isEquationEditMode = false
                        isWaitingForLabel = false
                eqnIsBuildingNumber = false
                promptString = nil
                updateDisplay()
                return
            } else if operation == "ENTER" {
                if eqnIsBuildingNumber {
                    eqnIsBuildingNumber = false // Just terminate the number, don't append ENTER
                } else {
                    currentEquationSteps.append("ENTER")
                }
                updateEquationDisplay()
                return
            } else if operation == "↑" {
                scrollUp()
                return
            } else if operation == "↓" {
                scrollDown()
                return
            } else if operation == "STO" {
                startAlpha()
                alphaPrompt = "STO _"
                alphaAction = .sto
                return
            } else if operation == "RCL" {
                startAlpha()
                alphaPrompt = "RCL _"
                alphaAction = .rcl
                return
            } else if operation == "GTO" {
                isWaitingForLabel = true
                startAlpha()
                alphaPrompt = "GTO _"
                return
            } else {
                currentEquationSteps.append(operation)
                eqnIsBuildingNumber = false
                updateEquationDisplay()
                return
            }
        }
        
        if operation == "STO" {
            startSto()
            return
        }
        
        if operation == "VIEW" {
            startView()
            return
        }
        if operation == "RCL" {
            startRcl()
            return
        }
        
        if operation == "x↔?" {
            startSwapVar()
            return
        }
        

        
        if operation == "EQN" {
            if isEquationEditMode {
                saveEquation()
                isEquationEditMode = false
                isWaitingForLabel = false
                eqnIsBuildingNumber = false
                promptString = nil
                updateDisplay()
                return
            }
            requestEqn = true
            isEquationListMode = true
            currentEquationListIndex = 0
            updateDisplay()
            return
        }
        
        if operation == "EQN_NEW" {
            isEquationListMode = false
            newEquation()
            updateDisplay()
            return
        }
        
        if operation.hasPrefix("EQN_EDIT_") {
            isEquationListMode = false
            let lbl = String(operation.dropFirst(9))
            if let existing = equations.first(where: { $0.label == lbl }) {
                editEquation(existing)
            }
            updateDisplay()
            return
        }
        
        if operation == "EQN_EDIT" {
            isEquationListMode = false
            if !equations.isEmpty && currentEquationListIndex < equations.count {
                editEquation(equations[currentEquationListIndex])
            }
            updateDisplay()
            return
        }
        
        if operation == "FN=" {
            startAlpha()
            alphaAction = .fnEq
            alphaPrompt = "FN= _"
            requestFnEq = true
            return
        }
        
        if operation == "SOLVE" {
            if equations.isEmpty {
                errorMessage = "NO EQN"
                updateDisplay()
                return
            }
            startAlpha()
            alphaAction = .solve
            alphaPrompt = "SOLVE _"
            requestSolve = true
            return
        }
        
        if operation == "∫" {
            if equations.isEmpty {
                errorMessage = "NO EQN"
                updateDisplay()
                return
            }
            startAlpha()
            alphaAction = .integrate
            alphaPrompt = "∫ _"
            requestIntegrate = true
            return
        }
        
        if operation == "XEQ" {
            print("DEBUG: XEQ handled, setting requestXEQ=true")
            isWaitingForLabel = true
            startAlpha()
            alphaPrompt = "XEQ _"
            requestXEQ = true
            return
        }
        
        if operation == "LBL" {
            isWaitingForLabel = true
            startAlpha()
            alphaPrompt = "LBL _"
            return
        }
        
        if operation == "SHOW" { requestShow = true; return }
        if operation == "." { decimal(); return }
        if operation == "E" || operation == "EEX" { startExponent(); return }
        if operation == "+/-" { toggleSign(); return }
        if operation == "<-" || operation == "BACKSPACE" { backspace(); return }
        if operation == "C" || operation == "CLEAR" || operation == "CLX" { clearX(); return }
        
        commitInput()
        stackLiftEnabled = true
        
        if operation == "CMPLX" {
            complexMode = true
            updateDisplay()
            return
        }
        
        if operation.hasPrefix("FIX ") {
            if let p = parseInt(_substringToString(operation.dropFirst(4))) { displayMode = .fix(p) }
            isFractionMode = false
            updateDisplay()
            return
        }
        if operation.hasPrefix("SCI ") {
            if let p = parseInt(_substringToString(operation.dropFirst(4))) { displayMode = .sci(p) }
            isFractionMode = false
            updateDisplay()
            return
        }
        if operation.hasPrefix("ENG ") {
            if let p = parseInt(_substringToString(operation.dropFirst(4))) { displayMode = .eng(p) }
            isFractionMode = false
            updateDisplay()
            return
        }
        
        if operation == "ALL" {
            displayMode = .all
            isFractionMode = false
            updateDisplay()
            return
        }
        
        if operation == "HYP" {
            isHypPending.toggle()
            updateDisplay()
            return
        }
        
        if complexMode {
            complexMode = false
            let handled = handleComplexMath(operation)
            if handled { 
                isBuildingNumber = false
                updateDisplay()
                return 
            }
        }
        
        switch operation {
        case "e": push(CalculatorValue(real: 2.718281828459045))
        case "c": push(CalculatorValue(real: 299792458))
        case "h": push(CalculatorValue(real: 6.62607015e-34))
        case "k": push(CalculatorValue(real: 1.380649e-23))
        case "G": push(CalculatorValue(real: 6.67430e-11))
        case "Na": push(CalculatorValue(real: 6.02214076e23))
        case "R": push(CalculatorValue(real: 8.314462618))
        case ">DEG":
            if stack.count > 0 { stack[0].real = stack[0].real * 180.0 / .pi }
        case ">RAD":
            if stack.count > 0 { stack[0].real = stack[0].real * .pi / 180.0 }
        case ">HR":
            if stack.count > 0 {
                let val = stack[0].real
                let sign = val < 0 ? -1.0 : 1.0
                let absVal = abs(val)
                let hours = floor(absVal)
                let minutes = floor((absVal - hours) * 100)
                let seconds = (absVal - hours - minutes / 100) * 10000
                stack[0].real = sign * (hours + minutes / 60.0 + seconds / 3600.0)
            }
        case ">HMS":
            if stack.count > 0 {
                let val = stack[0].real
                let sign = val < 0 ? -1.0 : 1.0
                let absVal = abs(val)
                let hours = floor(absVal)
                let minutes = floor((absVal - hours) * 60)
                let seconds = (absVal - hours - minutes / 60.0) * 3600
                stack[0].real = sign * (hours + minutes / 100.0 + seconds / 10000.0)
            }
        case ">θ,r":
            if stack.count > 1 {
                let x = stack[0].real
                let y = stack[1].real
                let r = hypot(x, y)
                var theta = atan2(y, x)
                if angleMode == .deg { theta *= 180.0 / .pi }
                else if angleMode == .grd { theta *= 200.0 / .pi }
                stack[0].real = r
                stack[1].real = theta
            }
        case ">y,x":
            if stack.count > 1 {
                let r = stack[0].real
                var theta = stack[1].real
                if angleMode == .deg { theta *= .pi / 180.0 }
                else if angleMode == .grd { theta *= .pi / 200.0 }
                let x = r * cos(theta)
                let y = r * sin(theta)
                stack[0].real = x
                stack[1].real = y
            }
        case "RND":
            if stack.count > 0 {
                if isFractionMode {
                    let val = stack[0].real
                    let sign = val < 0 ? -1.0 : 1.0
                    if let f = computeFractionToFit(valAbs: abs(val), sign: sign) {
                        stack[0].real = (Double(f.whole) + Double(f.num) / Double(f.den)) * sign
                    } else {
                        let str = formatNumber(stack[0].real, ignoreFractionMode: true)
                        if let rounded = parseDouble(str) { stack[0].real = rounded }
                    }
                } else {
                    let str = formatNumber(stack[0].real, ignoreFractionMode: true)
                    if let rounded = parseDouble(str) {
                        stack[0].real = rounded
                    }
                }
            }
        case "HEX":
            if stack.count > 0 && abs(stack[0].real) > 34359738367 { errorMessage = "TOO BIG"; return }
            baseMode = .hex
        case "DEC": baseMode = .dec
        case "OCT": 
            if stack.count > 0 && abs(stack[0].real) > 34359738367 { errorMessage = "TOO BIG"; return }
            baseMode = .oct
        case "BIN": 
            if stack.count > 0 && abs(stack[0].real) > 34359738367 { errorMessage = "TOO BIG"; return }
            baseMode = .bin

        case "C":
            let wasProgramming = isEquationEditMode
            isEquationEditMode = false
            isEquationListMode = false
            isWaitingForLabel = false
            alphaAction = .none
            promptString = nil
            if wasProgramming {
                // Do not clear input or stack, just exit programming mode
            } else {
                if isBuildingNumber {
                    currentInputBuffer[0] = 48; currentInputLength = 1
                    isBuildingNumber = false 
                }
                if stack.count > 0 { stack[0] = CalculatorValue() }
                stackLiftEnabled = false
            }
        case "CLEAR":
            if stack.count > 0 {
                stack[0] = CalculatorValue()
            }
            currentInputLength = 0
            isBuildingNumber = false
            stackLiftEnabled = false
        case "CLALL":
            clearAll()
            return
        case "CLREGS", "CLVARS":
            clearVars()
            return
        case "CLSTK":
            clearStack()
            return
        case "CLEQN":
            clearPrograms()
            return
        case "CLΣ":
            clearStats()
            return
        case "TEST":
            isTestMode.toggle()
            updateDisplay()
            return
        case "RTN":
            if isEquationEditMode {
                currentEquationSteps.append("RTN")
                updateEquationDisplay()
            }
            return
        case "SCRL":
            // Scroll logic handled by UI, no-op for engine
            return
        case "𝑥≷𝑦", "x↔y":
            swapXY()
            return
        case "ASGN": isAssigning = true; return
        case "SETUP": return // Not implemented
        case "+": binaryOp { $1 + $0 }
        case "-": binaryOp { $1 - $0 }
        case "×": binaryOp { $1 * $0 }
        case "÷":
            if stack.count > 0 && stack[0].real == 0 { errorMessage = "DIVIDE BY 0"; return }
            binaryOp { $1 / $0 }
        case "1/𝑥":
            if stack.count > 0 && stack[0].real == 0 { errorMessage = "DIVIDE BY 0"; return }
            unaryOp { CalculatorValue(real: 1.0 / $0.real) }
        case "√𝑥": 
            if stack.count > 0 && stack[0].real < 0 { errorMessage = "INVALID DATA"; return }
            unaryOp { CalculatorValue(real: _sqrt($0.real)) }
        case "𝑥²": unaryOp { CalculatorValue(real: $0.real * $0.real) }
        case "𝑦ˣ": binaryOp { CalculatorValue(real: _pow($1.real, $0.real)) }
        case "xVy":
            if stack.count > 0 && stack[0].real == 0 { errorMessage = "DIVIDE BY 0"; return }
            binaryOp { CalculatorValue(real: _pow($1.real, 1.0 / $0.real)) }
        case "%": percentOp { CalculatorValue(real: $1.real * ($0.real / 100.0)) }
        case "%CHG": percentOp { CalculatorValue(real: $1.real == 0 ? 0 : (($0.real - $1.real) / $1.real) * 100.0) }
        case "LN": 
            if stack.count > 0 {
                if stack[0].real == 0 { errorMessage = "DIVIDE BY 0"; return }
                if stack[0].real < 0 { errorMessage = "INVALID DATA"; return }
            }
            unaryOp { CalculatorValue(real: _log($0.real)) }
        case "𝑒ˣ": unaryOp { CalculatorValue(real: _exp($0.real)) }
        case "LOG": 
            if stack.count > 0 {
                if stack[0].real == 0 { errorMessage = "DIVIDE BY 0"; return }
                if stack[0].real < 0 { errorMessage = "INVALID DATA"; return }
            }
            unaryOp { CalculatorValue(real: _log10($0.real)) }
        case "10ˣ": unaryOp { CalculatorValue(real: _pow(10.0, $0.real)) }
        case "x=y": if currentEvaluatingEquation != nil { binaryOp { CalculatorValue(real: $1.real == $0.real ? 1.0 : 0.0) } } else { performTest(stack[0].real == stack[1].real) }; return
        case "x≠y", "x!=y": if currentEvaluatingEquation != nil { binaryOp { CalculatorValue(real: $1.real != $0.real ? 1.0 : 0.0) } } else { performTest(stack[0].real != stack[1].real) }; return
        case "x>y": if currentEvaluatingEquation != nil { binaryOp { CalculatorValue(real: $1.real > $0.real ? 1.0 : 0.0) } } else { performTest(stack[0].real > stack[1].real) }; return
        case "x<y": if currentEvaluatingEquation != nil { binaryOp { CalculatorValue(real: $1.real < $0.real ? 1.0 : 0.0) } } else { performTest(stack[0].real < stack[1].real) }; return
        case "x≥y", "x>=y": if currentEvaluatingEquation != nil { binaryOp { CalculatorValue(real: $1.real >= $0.real ? 1.0 : 0.0) } } else { performTest(stack[0].real >= stack[1].real) }; return
        case "x≤y", "x<=y": if currentEvaluatingEquation != nil { binaryOp { CalculatorValue(real: $1.real <= $0.real ? 1.0 : 0.0) } } else { performTest(stack[0].real <= stack[1].real) }; return
        case "x=0": if currentEvaluatingEquation != nil { unaryOp { CalculatorValue(real: $0.real == 0 ? 1.0 : 0.0) } } else { performTest(stack[0].real == 0) }; return
        case "x≠0", "x!=0": if currentEvaluatingEquation != nil { unaryOp { CalculatorValue(real: $0.real != 0 ? 1.0 : 0.0) } } else { performTest(stack[0].real != 0) }; return
        case "x>0": if currentEvaluatingEquation != nil { unaryOp { CalculatorValue(real: $0.real > 0 ? 1.0 : 0.0) } } else { performTest(stack[0].real > 0) }; return
        case "x<0": if currentEvaluatingEquation != nil { unaryOp { CalculatorValue(real: $0.real < 0 ? 1.0 : 0.0) } } else { performTest(stack[0].real < 0) }; return
        case "x≥0", "x>=0": if currentEvaluatingEquation != nil { unaryOp { CalculatorValue(real: $0.real >= 0 ? 1.0 : 0.0) } } else { performTest(stack[0].real >= 0) }; return
        case "x≤0", "x<=0": if currentEvaluatingEquation != nil { unaryOp { CalculatorValue(real: $0.real <= 0 ? 1.0 : 0.0) } } else { performTest(stack[0].real <= 0) }; return
        case "𝑥!", "n!": 
            if stack.count > 0 {
                if stack[0].real < 0 && stack[0].real == floor(stack[0].real) { errorMessage = "INVALID DATA"; return }
            }
            unaryOp { CalculatorValue(real: tgamma($0.real + 1)) }
        case "π": commitInput(); pushToStack(CalculatorValue(real: Double.pi))
        case "ENTER": commitInput(); pushToStack(stack[0]); stackLiftEnabled = false
        case "FRAC": unaryOp { CalculatorValue(real: $0.real - floor($0.real)) }
        case "SIN": 
            if isHypPending {
                isHypPending = false
                unaryOp { CalculatorValue.sinh($0) }
            } else {
                unaryOp { CalculatorValue.sin(CalculatorValue(real: toRad($0.real), imag: toRad($0.imag))) }
            }
        case "COS": 
            if isHypPending {
                isHypPending = false
                unaryOp { CalculatorValue.cosh($0) }
            } else {
                unaryOp { CalculatorValue.cos(CalculatorValue(real: toRad($0.real), imag: toRad($0.imag))) }
            }
        case "TAN":
            if isHypPending {
                isHypPending = false
                unaryOp { CalculatorValue.tanh($0) }
            } else {
                unaryOp { 
                    let radV = CalculatorValue(real: toRad($0.real), imag: toRad($0.imag))
                    return CalculatorValue.sin(radV) / CalculatorValue.cos(radV)
                }
            }
        case "ASIN": 
            if isHypPending {
                isHypPending = false
                unaryOp { CalculatorValue(real: _asinh($0.real)) }
            } else {
                unaryOp { CalculatorValue(real: fromRad(asin($0.real))) } // Naive real
            }
        case "ACOS": 
            if isHypPending {
                isHypPending = false
                unaryOp { CalculatorValue(real: _acosh($0.real)) }
            } else {
                unaryOp { CalculatorValue(real: fromRad(acos($0.real))) } // Naive real
            }
        case "ATAN": 
            if isHypPending {
                isHypPending = false
                unaryOp { CalculatorValue(real: _atanh($0.real)) }
            } else {
                unaryOp { CalculatorValue(real: fromRad(atan($0.real))) } // Naive real
            }
        case "LAST𝑥": commitInput(); push(lastX)
        case "ABS": unaryOp { CalculatorValue(real: $0.magnitude) }
        case "INTG": unaryOp { CalculatorValue(real: floor($0.real)) }
        case "SGN": unaryOp { CalculatorValue(real: $0.real > 0 ? 1.0 : ($0.real < 0 ? -1.0 : 0.0)) }
        case "CLx": commitInput(); stack[0] = CalculatorValue(); stackLiftEnabled = false; updateDisplay(); return
        
        // Base logic
        case "AND": binaryOp { CalculatorValue(real: Double(Int64($1.real) & Int64($0.real))) }
        case "OR": binaryOp { CalculatorValue(real: Double(Int64($1.real) | Int64($0.real))) }
        case "XOR": binaryOp { CalculatorValue(real: Double(Int64($1.real) ^ Int64($0.real))) }
        case "NOT": unaryOp { CalculatorValue(real: Double(~Int64($0.real))) }
            
        case "R↓":
            rollDown()
            return
        case "R↑":
            rollUp()
            return

        case "Σ+": addStat()
        case "Σ-": removeStat()
        case "x-bar": calculateMean()
        case "y-bar": calculateMean(y: true)
        case "xw": calculateWeightedMean()
        case "s": calculateStdDev(sample: true)
        case "sy": calculateStdDev(sample: true, y: true)
        case "σ": calculateStdDev(sample: false)
        case "σy": calculateStdDev(sample: false, y: true)
        case "n": commitInput(); push(CalculatorValue(real: Double(statN)))
        case "Σx": commitInput(); push(CalculatorValue(real: statSumX))
        case "Σy": commitInput(); push(CalculatorValue(real: statSumY))
        case "Σx²": commitInput(); push(CalculatorValue(real: statSumX2))
        case "Σy²": commitInput(); push(CalculatorValue(real: statSumY2))
        case "Σxy": commitInput(); push(CalculatorValue(real: statSumXY))
        case "->kg", "→kg": unaryOp { CalculatorValue(real: $0.real * 0.45359237) }
        case "->lb", "→lb": unaryOp { CalculatorValue(real: $0.real / 0.45359237) }
        case "->°C", "→°C": unaryOp { CalculatorValue(real: ($0.real - 32) * 5/9) }
        case "->°F", "→°F": unaryOp { CalculatorValue(real: $0.real * 9/5 + 32) }
        case "->cm", "→cm": unaryOp { CalculatorValue(real: $0.real * 2.54) }
        case "->in", "→in": unaryOp { CalculatorValue(real: $0.real / 2.54) }
        case "->l", "→l": unaryOp { CalculatorValue(real: $0.real * 3.785411784) }
        case "->gal", "→gal": unaryOp { CalculatorValue(real: $0.real / 3.785411784) }
        case "->km", "→km": unaryOp { CalculatorValue(real: $0.real * 1.609344) }
        case "->mi", "→mi": unaryOp { CalculatorValue(real: $0.real / 1.609344) }
        
        // Advanced Math (HP-32SII Parity)
        case "Pn,r", "nPr": 
            if stack.count > 1 {
                let y = stack[1].real
                let x = stack[0].real
                if y < 0 || x < 0 || y < x || y != floor(y) || x != floor(x) { 
                    errorMessage = "INVALID DATA"
                    return 
                }
            }
            binaryOp { CalculatorValue(real: tgamma($1.real + 1) / tgamma($1.real - $0.real + 1)) }
        case "Cn,r", "nCr": 
            if stack.count > 1 {
                let y = stack[1].real
                let x = stack[0].real
                if y < 0 || x < 0 || y < x || y != floor(y) || x != floor(x) { 
                    errorMessage = "INVALID DATA"
                    return 
                }
            }
            binaryOp { CalculatorValue(real: tgamma($1.real + 1) / (tgamma($0.real + 1) * tgamma($1.real - $0.real + 1))) }
            
        case "MOD":
            if stack.count > 0 && stack[0].real == 0 { errorMessage = "DIVIDE BY 0"; return }
            binaryOp { CalculatorValue(real: $1.real - $0.real * floor($1.real / $0.real)) }
            
        case "INT÷":
            if stack.count > 0 && stack[0].real == 0 { errorMessage = "DIVIDE BY 0"; return }
            let x = stack[0].real
            let y = stack[1].real
            lastX = stack[0]
            let q = trunc(y / x)
            let r = y.truncatingRemainder(dividingBy: x)
            stack[0] = CalculatorValue(real: q)
            stack[1] = CalculatorValue(real: r)
            stackLiftEnabled = true
            updateDisplay()
            
        case "RAND", "R#": commitInput(); pushToStack(CalculatorValue(real: Double.random(in: 0..<1)))
        case "SEED", "SD":
            if stack.count > 0 { srand48(Int(stack[0].real)); drop() }
        
        case "m": calculateSlope()
        case "b": calculateYIntercept()
        case "ŷ,r": calculateCorrelation()
        case "x̂": calculateLinearEstimation()
        
        case "PLOT": generatePlot()
        case "STK4":
            stackSizeLimit = 4
            if stack.count > 4 { stack = Array(stack.prefix(4)) }
            updateDisplay()
        case "STK8":
            stackSizeLimit = 8
            updateDisplay()
        case "STKINF":
            stackSizeLimit = 999
            updateDisplay()
        case "RAD": angleMode = .rad
        case "DEG": angleMode = .deg
        case "GRD", "GRAD": angleMode = .grd
        case ".": useCommaForDecimal = false; updateDisplay()
        case ",": useCommaForDecimal = true; updateDisplay()
        case "FIX": // Handled by prefix check above if has argument
            break
        case "SCI", "ENG", "ALL":
            if operation == "ALL" { displayMode = .all }
            isFractionMode = false
            break
        case "FDISP":
            isFractionMode.toggle()
            break
        case "/c":
            if stack.count > 0 {
                maxDenominator = abs(stack[0].real)
                if maxDenominator < 1 { maxDenominator = 4095.0 }
                drop()
                isFractionMode = true
            }
            break
        default: break
        }
        
        isBuildingNumber = false
        updateDisplay()
    }
    
    private func percentOp(_ op: (CalculatorValue, CalculatorValue) -> CalculatorValue) {
        let x = stack.count > 0 ? stack[0] : CalculatorValue()
        let y = stack.count > 1 ? stack[1] : CalculatorValue()
        lastX = x
        let result = op(x, y)
        
        if result.real.isInfinite {
            errorMessage = "OVERFLOW"
            return
        }
        if result.real.isNaN {
            errorMessage = "INVALID DATA"
            return
        }
        
        if stack.count > 0 {
            stack[0] = result
        } else {
            stack.append(result)
        }
        
        stackLiftEnabled = true
    }

    @inline(__always)
    private func binaryOp(_ op: (CalculatorValue, CalculatorValue) -> CalculatorValue) {
        let x = stack.count > 0 ? stack[0] : CalculatorValue()
        let y = stack.count > 1 ? stack[1] : CalculatorValue()
        lastX = x
        let result = op(x, y)
        
        if result.real.isInfinite {
            errorMessage = "OVERFLOW"
            return
        }
        if result.real.isNaN {
            errorMessage = "INVALID DATA"
            return
        }
        
        if !complexMode && result.imag != 0 {
            errorMessage = "INVALID DATA"
            return
        }
        
        drop()
        if stack.count > 0 {
            stack[0] = result
        } else {
            stack.append(result)
        }
        
        stackLiftEnabled = true
        
        if stack.isEmpty {
            stack.append(CalculatorValue())
        }
    }
    
    private func handleComplexMath(_ operation: String) -> Bool {
        switch operation {
        case "+": complexBinaryOp { $1 + $0 }
        case "-": complexBinaryOp { $1 - $0 }
        case "×": complexBinaryOp { $1 * $0 }
        case "÷": complexBinaryOp { $1 / $0 }
        case "1/𝑥": complexUnaryOp { CalculatorValue(real: 1.0) / $0 }
        case "√𝑥": complexUnaryOp { CalculatorValue.sqrt($0) }
        case "𝑥²": complexUnaryOp { $0 * $0 }
        case "𝑦ˣ": complexBinaryOp { CalculatorValue.pow($1, $0) }
        case "xVy":
            if stack.count > 0 && stack[0].real == 0 && stack[0].imag == 0 { errorMessage = "DIVIDE BY 0"; return true }
            complexBinaryOp { CalculatorValue.pow($1, CalculatorValue(real: 1.0) / $0) }
        case "LN": complexUnaryOp { CalculatorValue.ln($0) }
        case "𝑒ˣ": complexUnaryOp { CalculatorValue.exp($0) }
        case "LOG": complexUnaryOp { CalculatorValue.ln($0) / CalculatorValue(real: _log(10)) }
        case "10ˣ": complexUnaryOp { CalculatorValue.pow(CalculatorValue(real: 10), $0) }
        case "SIN": complexUnaryOp { CalculatorValue.sin($0) }
        case "COS": complexUnaryOp { CalculatorValue.cos($0) }
        case "+/-": complexUnaryOp { CalculatorValue(real: -$0.real, imag: -$0.imag) }
        default: return false
        }
        
        isBuildingNumber = false
        updateDisplay()
        return true
    }
    
    @inline(__always)
    private func complexUnaryOp(_ op: (CalculatorValue) -> CalculatorValue) {
        let xi = stack.count > 0 ? stack[0].real : 0.0
        let yr = stack.count > 1 ? stack[1].real : 0.0
        
        let c = CalculatorValue(real: yr, imag: xi)
        lastX = CalculatorValue(real: xi)
        
        let result = op(c)
        drop()
        drop()
        stack[1] = CalculatorValue(real: result.real)
        stack[0] = CalculatorValue(real: result.imag)
        
        stackLiftEnabled = true
    }
    
    @inline(__always)
    private func complexBinaryOp(_ op: (CalculatorValue, CalculatorValue) -> CalculatorValue) {
        let x1i = stack.count > 0 ? stack[0].real : 0.0
        let y1r = stack.count > 1 ? stack[1].real : 0.0
        let z2i = stack.count > 2 ? stack[2].real : 0.0
        let t2r = stack.count > 3 ? stack[3].real : 0.0
        
        let c1 = CalculatorValue(real: y1r, imag: x1i)
        let c2 = CalculatorValue(real: t2r, imag: z2i)
        
        lastX = CalculatorValue(real: x1i)
        
        let result = op(c2, c1)
        
        drop()
        drop()
        drop()
        drop()
        stack[1] = CalculatorValue(real: result.real)
        stack[0] = CalculatorValue(real: result.imag)
        
        if stack.count < 4 {
            for _ in 0..<(4 - stack.count) {
                stack.append(CalculatorValue())
            }
        }
        
        stackLiftEnabled = true
    }
    
    public func generatePlot(variable: String? = nil, explicitMin: Double? = nil, explicitMax: Double? = nil) {
        if isBuildingNumber { commitInput() }
        print("DEBUG: generatePlot called!")
        if let variable = variable {
            // Plot Equation
            isStatPlot = false
            let x2 = explicitMax ?? (stack.count > 0 ? stack[0].real : 3.0)
            let x1 = explicitMin ?? (stack.count > 1 ? stack[1].real : -3.0)
            
            var xmin = min(x1, x2)
            var xmax = max(x1, x2)
            
            if xmin == xmax { 
                xmin = -3.0
                xmax = 3.0
            }
            
            // plotData.removeAll()
            plotData.removeAll(keepingCapacity: true)
            plotMarkers.removeAll(keepingCapacity: true)
            plotData.reserveCapacity(110)
            plotMarkers.reserveCapacity(10)
            self.isSilent = true
            
            let prog: Equation?
            if let label = currentEquationLabel.isEmpty ? nil : currentEquationLabel,
               let p = equations.first(where: { $0.label == label }) {
                prog = p
            } else if let firstProgram = equations.first {
                prog = firstProgram
            } else {
                prog = nil
            }
            
            let evalFunc: (Double) -> Double? = { xVal in
                if let equation = prog {
                    let oldVal = self.variables[variable]
                    self.variables[variable] = CalculatorValue(real: xVal)
                    let result = self.evaluateEquation(equation)?.real
                    self.variables[variable] = oldVal // Restore directly to avoid dictionary copies
                    return result
                } else {
                    return (1.0 / sqrt(2.0 * Double.pi)) * exp(-pow(xVal, 2) / 2.0)
                }
            }
            
            // Senary Search for Roots
            let senarySegments = 6
            let senaryStep = (xmax - xmin) / Double(senarySegments)
            var prevX = xmin
            var prevY = evalFunc(prevX)
            
            if let pY = prevY, abs(pY) < 1e-10 {
                plotMarkers.append((prevX, pY))
            }
            
            for i in 1...senarySegments {
                let currX = xmin + Double(i) * senaryStep
                let currY = evalFunc(currX)
                
                if let pY = prevY, let cY = currY {
                    if pY * cY < 0 {
                        // Sign change -> Binary Search
                        var low = prevX
                        var high = currX
                        var rootY = 0.0
                        var rootX = (low + high) / 2.0
                        for _ in 0..<30 { // up to 30 iterations for precision
                            rootX = (low + high) / 2.0
                            if let midY = evalFunc(rootX) {
                                rootY = midY
                                if abs(midY) < 1e-10 { break }
                                if pY * midY < 0 {
                                    high = rootX
                                } else {
                                    low = rootX
                                    prevY = midY // Update prevY logic contextually for bounds
                                }
                            } else {
                                break
                            }
                        }
                        plotMarkers.append((rootX, rootY))
                    } else if abs(cY) < 1e-10 {
                        plotMarkers.append((currX, cY))
                    }
                }
                prevX = currX
                prevY = currY
            }
            
            let steps = 100
            let stepSize = (xmax - xmin) / Double(steps)
            
            for i in 0...steps {
                let x = xmin + Double(i) * stepSize
                if let y = evalFunc(x) {
                    plotData.append((x, y))
                }
            }
        } else {
            // Scatter Plot
            isStatPlot = true
            plotData.removeAll(keepingCapacity: true)
        self.plotData.reserveCapacity(110)
            plotMarkers.removeAll()
        }
        self.isSilent = false
        self.requestPlot = true
        print("DEBUG: requestPlot SET TO TRUE by generatePlot")
    }
    
    
    private func getVar(_ name: String) -> CalculatorValue {
        let resolved = resolveTargetName(name)
        if resolved == "Σn" { return CalculatorValue(real: Double(statN)) }
        if resolved == "Σx" { return CalculatorValue(real: statSumX) }
        if resolved == "Σy" { return CalculatorValue(real: statSumY) }
        if resolved == "Σx²" { return CalculatorValue(real: statSumX2) }
        if resolved == "Σy²" { return CalculatorValue(real: statSumY2) }
        if resolved == "Σxy" { return CalculatorValue(real: statSumXY) }
        return variables[resolved] ?? CalculatorValue()
    }
    
    private func setVar(_ name: String, _ value: CalculatorValue) {
        let resolved = resolveTargetName(name)
        if resolved == "Σn" { statN = value.real; return }
        if resolved == "Σx" { statSumX = value.real; return }
        if resolved == "Σy" { statSumY = value.real; return }
        if resolved == "Σx²" { statSumX2 = value.real; return }
        if resolved == "Σy²" { statSumY2 = value.real; return }
        if resolved == "Σxy" { statSumXY = value.real; return }
        if !resolved.isEmpty { variables[resolved] = value }
    }

    private func resolveTargetName(_ name: String) -> String {
        if name == "(i)" {
            let idxVal = self.variables["i"]?.real ?? 0.0
            let idx = Int(idxVal)
            if idx >= 1 && idx <= 26 {
                let ascii = UInt8(64 + idx)
                return String(Character(UnicodeScalar(ascii)))
            } else if idx == 27 {
                return "i"
            } else if idx >= 28 && idx <= 33 {
                let stats = ["Σn", "Σx", "Σy", "Σx²", "Σy²", "Σxy"]
                return stats[idx - 28]
            }
            return ""
        }
        return name
    }

    public func evaluateEquation(_ equation: Equation, clearStack: Bool = true) -> CalculatorValue? {
        // Save state
        var savedStack = Array(repeating: CalculatorValue(), count: self.stackSizeLimit)
        for i in 0..<self.stack.count { savedStack[i] = self.stack[i] }
        var savedLastX = self.lastX
        var savedStackStrings = self.isSilent ? [] : self.stackStrings
        var savedPrompt = self.isSilent ? nil : self.promptString
        var savedDisplayXBuffer = self.isSilent ? [] : self.displayXBuffer
        var savedDisplayXLength = self.displayXLength
        var savedProgMode = self.isEquationEditMode
        var savedInputBuffer = self.isSilent ? [] : self.currentInputBuffer
        var savedInputLength = self.currentInputLength
        var savedIsBuildingNum = self.isBuildingNumber
        var savedShift = self.shiftState
        var savedLiftEnabled = self.stackLiftEnabled
                
        if !clearStack {
            savedStack = []
            savedStackStrings = []
                    }
        
                self.isEquationEditMode = false
        self.isBuildingNumber = false
        self.stackLiftEnabled = true
        self.currentEvaluatingEquation = equation
        
        // Clear stack for the equation
        // Reuse existing stack array to prevent memory allocation in loops
        if clearStack {
            if self.stack.count != self.stackSizeLimit {
                self.stack = Array(repeating: CalculatorValue(), count: self.stackSizeLimit)
            } else {
                for j in 0..<self.stack.count { self.stack[j] = CalculatorValue() }
            }
        }
        
        if let emptyVar = variables[""] {
            self.push(emptyVar)
        }
        
        // Execute steps
        var i = 0
        var cycleCount = 0
        while i < equation.steps.count {
            if let check = isInterrupted, check() {
                errorMessage = "INTERRUPTED"
                break
            }
            cycleCount += 1
            if cycleCount > 100000 {
                errorMessage = "TIMEOUT"
                break
            }
            let step = equation.steps[i]
            if skipNextInstruction {
                skipNextInstruction = false
                i += 1
                continue
            }
            
            if case .operation(let op) = step, op == .rtn {
                break
            }
            if case .custom(let str) = step, str == "RTN" {
                break
            }
            
            switch step {
            case .operation(let op):
                let raw = op.rawValue
                if raw >= CalculatorOperation.digit0.rawValue && raw <= CalculatorOperation.digit9.rawValue {
                    let d = raw - CalculatorOperation.digit0.rawValue
                    if !self.isBuildingNumber {
                        if self.stackLiftEnabled && !self.stack.isEmpty {
                            self.pushToStack(self.stack[0]) // Push stack
                        }
                        self.isBuildingNumber = true
                        self.currentInputLength = 0
                    }
                    if self.currentInputLength < 64 {
                        self.currentInputBuffer[self.currentInputLength] = UInt8(48 + d)
                        self.currentInputLength += 1
                    }
                } else if op == .decimal {
                    if !self.isBuildingNumber {
                        if self.stackLiftEnabled && !self.stack.isEmpty {
                            self.pushToStack(self.stack[0])
                        }
                        self.isBuildingNumber = true
                        self.currentInputLength = 0
                    }
                    if self.currentInputLength < 64 {
                        self.currentInputBuffer[self.currentInputLength] = 46 // '.'
                        self.currentInputLength += 1
                    }
                } else if op == .toggleSign && self.isBuildingNumber {
                    // Handled if we need to implement +/- inside numbers natively
                    // Let executeMath handle it for simplicity for now, wait, toggleSign is parsed as math
                    self.execute(step)
                } else {
                    self.execute(step)
                }
                
            case .rcl(let varName):
                let targetName = resolveTargetName(varName)
                if let val = variables[targetName] {
                    self.push(val)
                    self.stackLiftEnabled = true
                }
            case .xeq(let label):
                var subProgram: Equation? = nil
                for p in equations {
                    if p.label == label { subProgram = p; break }
                }
                if let sub = subProgram {
                    if let res = evaluateEquation(sub, clearStack: false) {
                        // For subprograms, it operates on the live stack now. No need to push.
                        self.stackLiftEnabled = true
                    }
                }
            case .sto(let varName):
                self.setVar(varName, self.stack.first ?? CalculatorValue())
            case .custom(let str):
                if let val = self.variables[str] {
                    self.push(val)
                    self.stackLiftEnabled = true
                } else if str.hasPrefix("RCL ") {
                    let varName = String(str.dropFirst(4))
                    if let val = self.variables[varName] {
                        self.push(val)
                        self.stackLiftEnabled = true
                    }
                } else if str.hasPrefix("STO ") {
                    let varName = String(str.dropFirst(4))
                    self.self.variables[varName] = self.stack.first ?? CalculatorValue()
                } else if ["SETUP", "DISP", "MODES", "STAT", "FN=", "EQN", "PRGM", "SOLVE", "∫", "SHOW", "PLOT", "VIEW", "CLEAR"].contains(str) {
                    // Handled by action closure
                } else {
                    self.execute(step)
                }
            default:
                self.execute(step)
            }
            i += 1
        }
        
        if self.isBuildingNumber { self.commitInput() }
        
        // Get result
        let result = self.stack.first
        
        // Restore state
        if clearStack {
            for i in 0..<self.stack.count { self.stack[i] = savedStack[i] }
            self.lastX = savedLastX
            if !self.isSilent {
                for j in 0..<self.stackStrings.count { self.stackStrings[j] = self.plotSavedStackStrings[j] }
                self.promptString = savedPrompt
                for j in 0..<savedDisplayXLength {
                    self.displayXBuffer[j] = savedDisplayXBuffer[j]
                }
            }
            self.displayXLength = savedDisplayXLength
                    }
        
        self.isEquationEditMode = savedProgMode
        self.currentInputLength = savedInputLength
        if !self.isSilent {
            for j in 0..<savedInputLength {
                self.currentInputBuffer[j] = self.plotSavedInputBuffer[j]
            }
        }
        self.isBuildingNumber = savedIsBuildingNum
        self.shiftState = savedShift
        self.stackLiftEnabled = savedLiftEnabled
        self.currentEvaluatingEquation = nil
        self.updateDisplay()
        
        return result
    }
    
    private func isEquationNumberStep(_ step: String) -> Bool {
        if step == "-" { return false }
        if step == "E" { return false }
        let allowedCharacters = "0123456789.-E"
        for char in step {
            if !allowedCharacters.contains(char) {
                return false
            }
        }
        return true
    }

    private func testConditional(_ condition: Bool) {
        transientMessage = condition ? "YES" : "NO"
        if !condition {
            skipNextInstruction = true
        }
    }
    
    @inline(__always)
    private func unaryOp(_ op: (CalculatorValue) -> CalculatorValue) {
        let x = stack.count > 0 ? stack[0] : CalculatorValue()
        lastX = x
        let result = op(x)
        
        if result.real.isInfinite {
            errorMessage = "OVERFLOW"
            return
        }
        if result.real.isNaN {
            errorMessage = "INVALID DATA"
            return
        }
        
        if !complexMode && result.imag != 0 {
            errorMessage = "INVALID DATA"
            return
        }
        
        if stack.count > 0 {
            stack[0] = result
        } else {
            stack.append(result)
        }
        
        stackLiftEnabled = true
    }
    
    // MARK: - Statistics
    
    private func addStat() {
        let x = stack.count > 0 ? stack[0].real : 0.0
        let y = stack.count > 1 ? stack[1].real : 0.0
        statN += 1
        statSumX += x
        statSumX2 += x * x
        statSumY += y
        statSumY2 += y * y
        statSumXY += x * y
        statPoints.append(StatPoint(x: x, y: y))
        stack[0] = CalculatorValue(real: statN)
        stackLiftEnabled = false
    }
    
    private func removeStat() {
        let x = stack.count > 0 ? stack[0].real : 0.0
        let y = stack.count > 1 ? stack[1].real : 0.0
        if statN > 0 {
            statN -= 1
            statSumX -= x
            statSumX2 -= x * x
            statSumY -= y
            statSumY2 -= y * y
            statSumXY -= x * y
            if let index = statPoints.lastIndex(where: { $0.x == x && $0.y == y }) {
                statPoints.remove(at: index)
            }
        }
        stack[0] = CalculatorValue(real: statN)
        stackLiftEnabled = false
    }
    
    private func calculateMean(y: Bool = false) {
        if statN == 0 { errorMessage = "STAT ERROR"; return }
        let meanX = statSumX / statN
        let meanY = statSumY / statN
        
        if y {
            commitInput()
            pushToStack(CalculatorValue(real: meanY))
        } else {
            commitInput()
            pushToStack(CalculatorValue(real: meanY))
            pushToStack(CalculatorValue(real: meanX))
        }
    }
    
    private func calculateWeightedMean() {
        if statSumY == 0 { errorMessage = "STAT ERROR"; return }
        let xw = statSumXY / statSumY
        commitInput()
        pushToStack(CalculatorValue(real: xw))
    }
    
    private func calculateStdDev(sample: Bool, y: Bool = false) {
        if statN <= (sample ? 1 : 0) { errorMessage = "STAT ERROR"; return }
        let div = sample ? (statN - 1) : statN
        let varX = (statSumX2 - (statSumX * statSumX / statN)) / div
        let varY = (statSumY2 - (statSumY * statSumY / statN)) / div
        
        if y {
            commitInput()
            pushToStack(CalculatorValue(real: sqrt(varY > 0 ? varY : 0)))
        } else {
            commitInput()
            pushToStack(CalculatorValue(real: sqrt(varY > 0 ? varY : 0)))
            pushToStack(CalculatorValue(real: sqrt(varX > 0 ? varX : 0)))
        }
    }
    
    private func calculateSlope() {
        if statN <= 1 { errorMessage = "STAT ERROR"; return }
        let num = statSumXY - (statSumX * statSumY / statN)
        let den = statSumX2 - (statSumX * statSumX / statN)
        if den == 0 { errorMessage = "STAT ERROR"; return }
        let m = num / den
        commitInput()
        pushToStack(CalculatorValue(real: m))
    }
    
    private func calculateYIntercept() {
        if statN <= 1 { errorMessage = "STAT ERROR"; return }
        let num = statSumXY - (statSumX * statSumY / statN)
        let den = statSumX2 - (statSumX * statSumX / statN)
        if den == 0 { errorMessage = "STAT ERROR"; return }
        let m = num / den
        let b = (statSumY - m * statSumX) / statN
        commitInput()
        pushToStack(CalculatorValue(real: b))
    }
    
    private func calculateCorrelation() {
        if statN <= 1 { errorMessage = "STAT ERROR"; return }
        let num = statSumXY - (statSumX * statSumY / statN)
        let denX = statSumX2 - (statSumX * statSumX / statN)
        let denY = statSumY2 - (statSumY * statSumY / statN)
        if denX == 0 || denY == 0 { errorMessage = "STAT ERROR"; return }
        let r = num / sqrt(denX * denY)
        
        // ŷ,r command calculates both
        let x = stack.count > 0 ? stack[0].real : 0.0
        let m = num / denX
        let b = (statSumY - m * statSumX) / statN
        let yHat = m * x + b
        commitInput()
        pushToStack(CalculatorValue(real: r))
        pushToStack(CalculatorValue(real: yHat))
    }
    
    private func calculateLinearEstimation() {
        if statN <= 1 { errorMessage = "STAT ERROR"; return }
        let y = stack.count > 0 ? stack[0].real : 0.0
        let num = statSumXY - (statSumX * statSumY / statN)
        let den = statSumX2 - (statSumX * statSumX / statN)
        if den == 0 { errorMessage = "STAT ERROR"; return }
        let m = num / den
        let b = (statSumY - m * statSumX) / statN
        
        if m == 0 { errorMessage = "STAT ERROR"; return }
        let xHat = (y - b) / m
        
        commitInput()
        pushToStack(CalculatorValue(real: xHat))
    }
    
    // MARK: - Angles
    
    private func toRad(_ value: Double) -> Double {
        switch angleMode {
        case .deg: return value * .pi / 180.0
        case .rad: return value
        case .grd: return value * .pi / 200.0
        }
    }
    
    private func fromRad(_ value: Double) -> Double {
        switch angleMode {
        case .deg: return value * 180.0 / .pi
        case .rad: return value
        case .grd: return value * 200.0 / .pi
        }
    }
    
    // MARK: - Variables
    
    private func startAlphaPrompt(action: AlphaAction, promptBase: String) {
        commitInput()
        isWaitingForAlpha = true
        alphaAction = action
        
        if isEquationEditMode {
            let stepNum = currentEquationSteps.count + 1
            let paddedStep = stepNum < 10 ? "0\(stepNum)" : "\(stepNum)"
            promptString = "\(paddedStep) \(promptBase)"
        } else {
            promptString = promptBase
        }
        updateDisplay()
    }
    
    public func startSto() {
        startAlphaPrompt(action: .sto, promptBase: "STO")
    }
    
    public func startSwapVar() {
        startAlphaPrompt(action: .swapVar, promptBase: "x↔")
    }
    
    public func startView() {
        startAlphaPrompt(action: .view, promptBase: "VIEW")
    }
    
    public func startRcl() {
        startAlphaPrompt(action: .rcl, promptBase: "RCL")
    }
    
    public func submitAlpha(_ str: String) {
        if transientMessage != nil { transientMessage = nil; updateDisplay() }
        print("DEBUG: submitAlpha \(str), isWaitingForLabel: \(isWaitingForLabel), requestXEQ: \(requestXEQ)")
        let key = str.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if key.isEmpty { 
            cancelAlpha()
            return 
        }
        
        let initialChar = key
        
        if baseMode == .hex && alphaAction == .none && !isEquationEditMode && !isWaitingForLabel && ["A", "B", "C", "D", "E", "F"].contains(initialChar) {
            letter(initialChar)
            return
        }
        
        if alphaAction == .promptVar {
            // User submitted a value for a variable in an equation
            if let val = parseDouble(key) {
                if let varName = pendingEquationVars.first {
                    self.variables[varName] = CalculatorValue(real: val)
                    pendingEquationVars.removeFirst()
                    promptNextEquationVar()
                }
            } else {
                // If invalid number, cancel evaluation
                cancelAlpha()
            }
            return
        }
        
        if alphaAction == .sto {
            if ["+", "-", "×", "÷"].contains(initialChar) {
                switch initialChar {
                case "+": alphaAction = .stoAdd
                case "-": alphaAction = .stoSub
                case "×": alphaAction = .stoMul
                case "÷": alphaAction = .stoDiv
                default: break
                }
                if isEquationEditMode {
                    let stepNum = currentEquationSteps.count + 1
                    let paddedStep = stepNum < 10 ? "0\(stepNum)" : "\(stepNum)"
                    promptString = "\(paddedStep) STO \(initialChar)"
                } else {
                    promptString = "STO \(initialChar)"
                }
                updateDisplay()
                return // Still waiting for the variable letter
            }
        }
        
        isWaitingForAlpha = false
        promptString = nil
        
        if isWaitingForLabel {
            isWaitingForLabel = false
            
            if requestXEQ {
                print("DEBUG: Inside requestXEQ block in submitAlpha")
                requestXEQ = false
                if isEquationEditMode {
                    currentEquationSteps.append("XEQ \(initialChar)")
                    updateEquationDisplay()
                    return
                } else {
                    isEquationEditMode = false
                    if let equation = equations.first(where: { $0.label == initialChar }) {
                        currentResumeAction = .eval(equation)
                        pendingEquationVars = equation.extractVariables()
                        promptNextEquationVar()
                    }
                }
            } else {
                isEquationEditMode = true
                currentEquationLabel = initialChar
                if let existing = equations.first(where: { $0.label == currentEquationLabel }) {
                    currentEquationSteps = existing.steps.map { $0.stringValue }
                } else {
                    currentEquationSteps = []
                }
                updateEquationDisplay()
            }
        } else if alphaAction == .evalEquation {
            isEquationListMode = false
            requestEqn = false
            if let equation = equations.first(where: { $0.label == initialChar }) {
                currentResumeAction = .eval(equation)
                pendingEquationVars = equation.extractVariables()
                
                promptNextEquationVar()
            }
        } else if alphaAction == .solve {
            if let equation = currentEvaluatingEquation {
                currentResumeAction = .solve(variable: initialChar, equation: equation)
                pendingEquationVars = equation.extractVariables().filter { $0 != initialChar && variables[$0] == nil }
                promptNextEquationVar()
            }
        } else if alphaAction == .integrate {
            if let equation = currentEvaluatingEquation {
                let lower = stack.count > 1 ? stack[1].real : 0.0
                let upper = stack.count > 0 ? stack[0].real : 0.0
                currentResumeAction = .integrate(variable: initialChar, lower: lower, upper: upper, equation: equation, requestPlotAfter: true)
                pendingEquationVars = equation.extractVariables().filter { $0 != initialChar && variables[$0] == nil }
                promptNextEquationVar()
            }
        } else if alphaAction == .fnEq {
            if let equation = equations.first(where: { $0.label == initialChar }) {
                currentEvaluatingEquation = equation
                currentEquationLabel = initialChar
            }
            alphaAction = .none
            updateDisplay()
        } else if isEquationEditMode {
            if alphaAction == .sto {
                currentEquationSteps.append("STO \(initialChar)")
            } else if alphaAction == .stoAdd {
                currentEquationSteps.append("STO + \(initialChar)")
            } else if alphaAction == .stoSub {
                currentEquationSteps.append("STO - \(initialChar)")
            } else if alphaAction == .stoMul {
                currentEquationSteps.append("STO × \(initialChar)")
            } else if alphaAction == .stoDiv {
                currentEquationSteps.append("STO ÷ \(initialChar)")
            } else if alphaAction == .rcl {
                currentEquationSteps.append("RCL \(initialChar)")
            } else if alphaAction == .evalEquation {
                currentEquationSteps.append("XEQ \(initialChar)")
            } else if alphaAction == .view {
                currentEquationSteps.append("VIEW \(initialChar)")
            } else {
                // If it's LBL, GTO, or just raw alpha fallback
                if isWaitingForLabel {
                    // Handled above usually, but fallback just in case
                } else {
                    currentEquationSteps.append(initialChar)
                }
            }
            updateEquationDisplay()
        } else if alphaAction == .sto {
            setVar(initialChar, stack.count > 0 ? stack[0] : CalculatorValue())
        } else if alphaAction == .stoAdd {
            let existing = getVar(initialChar)
            setVar(initialChar, existing + (stack.count > 0 ? stack[0] : CalculatorValue()))
        } else if alphaAction == .stoSub {
            let existing = getVar(initialChar)
            setVar(initialChar, existing - (stack.count > 0 ? stack[0] : CalculatorValue()))
        } else if alphaAction == .stoMul {
            let existing = getVar(initialChar)
            setVar(initialChar, existing * (stack.count > 0 ? stack[0] : CalculatorValue()))
        } else if alphaAction == .stoDiv {
            let existing = getVar(initialChar)
            if let top = stack.first, top.real != 0 {
                setVar(initialChar, existing / top)
            } else {
                errorMessage = "DIVIDE BY 0"
            }
        } else if alphaAction == .swapVar {
            let varValue = getVar(initialChar)
            let xValue = stack.first ?? CalculatorValue()
            setVar(initialChar, xValue)
            stack[0] = varValue
            stackLiftEnabled = true
        } else if alphaAction == .rcl {
            let val = getVar(initialChar)
            pushToStack(val)
            updateDisplay()
        } else if alphaAction == .view {
            let val = getVar(initialChar)
            let valStr = val.isComplex ? "\(formatNumber(val.real)) + \(formatNumber(val.imag))i" : formatNumber(val.real)
            transientMessage = "\(initialChar) = \(valStr)"
            updateDisplay()
        } else {
            // Push variable directly if in run mode
            let val = getVar(initialChar)
            push(val)
        }
        
        if alphaAction != .promptVar && alphaAction != .evalEquation {
            alphaAction = .none
        }
        isBuildingNumber = false
        isWaitingForAlpha = false
        if !isEquationEditMode {
            promptString = nil
        }
        updateDisplay()
    }
    
    public func startPlot(variable: String, lower: Double, upper: Double) {
        if isBuildingNumber { commitInput() }
        if let equation = equations.first(where: { $0.label == currentEquationLabel }) {
            currentResumeAction = .plot(variable: variable, lower: lower, upper: upper, equation: equation)
            pendingEquationVars = equation.extractVariables().filter { $0 != variable && variables[$0] == nil }
            promptNextEquationVar()
        }
    }
    
    public func startIntegrate(variable: String, lower: Double, upper: Double, requestPlotAfter: Bool = false) {
        if isBuildingNumber { commitInput() }
        if let equation = equations.first(where: { $0.label == currentEquationLabel }) {
            currentResumeAction = .integrate(variable: variable, lower: lower, upper: upper, equation: equation, requestPlotAfter: requestPlotAfter)
            pendingEquationVars = equation.extractVariables().filter { $0 != variable && variables[$0] == nil }
            promptNextEquationVar()
        }
    }

    public func promptNextEquationVar() {
        while let nextVar = pendingEquationVars.first {
            if variables[nextVar] != nil {
                pendingEquationVars.removeFirst()
            } else {
                isWaitingForAlpha = true
                alphaAction = .promptVar
                alphaPrompt = "\(nextVar)?"
                updateDisplay()
                return
            }
        }
        
        // All variables bound, evaluate
        isWaitingForAlpha = false
        alphaAction = .none
        currentEvaluatingEquation = nil
        
        switch currentResumeAction {
        case .eval(let equation):
            if let result = evaluateEquation(equation) {
                push(result)
            }
        case .solve(let variable, let equation):
            if let ans = solve(for: variable, equation: equation) {
                pushToStack(CalculatorValue(real: ans))
            }
        case .integrate(let variable, let lower, let upper, let equation, let requestPlotAfter):
            let ans = integrate(variable: variable, lower: lower, upper: upper, equation: equation)
            pushToStack(CalculatorValue(real: ans))
            if requestPlotAfter {
                self.isPlotSRequested = false
                self.requestPlot = true
        print("DEBUG: requestPlot SET TO TRUE by generatePlot")
            }
        case .plot(let variable, let lower, let upper, let equation):
            self.generatePlot(variable: variable, explicitMin: lower, explicitMax: upper)
        case .none:
            break
        }
        currentResumeAction = .none
        updateDisplay()
    }
    
    public func push(_ val: CalculatorValue) {
        commitInput()
        pushToStack(val)
        // Do NOT disable stackLift — pushed constants behave like π: the next
        // digit entered lifts the stack rather than replacing the constant.
        // e.g.  CONST(h)  2  ×  →  2 * h   (no ENTER needed)
        updateDisplay()
    }
    

    public func drop() {
        if !stack.isEmpty {
            let topValue = stack[stackSizeLimit - 1]
            for i in 0..<(stackSizeLimit - 1) { stack[i] = stack[i+1] }
            stack[stackSizeLimit - 1] = topValue
        }
    }

    public func pushToStack(_ value: CalculatorValue) {
        for i in (1..<stackSizeLimit).reversed() {
            stack[i] = stack[i-1]
        }
        stack[0] = value
    }

    public func startAlpha() {
        if CommandLine.arguments.contains("-UITesting") {
            // Bypass alpha entry in UI tests to avoid watchOS keyboard issues
            if isWaitingForLabel {
                isWaitingForLabel = false
                isEquationEditMode = true
                currentEquationLabel = "P" // default to P for testing
                if let existing = equations.first(where: { $0.label == currentEquationLabel }) {
                    currentEquationSteps = existing.steps.map { $0.stringValue }
                } else {
                    currentEquationSteps = []
                }
                updateEquationDisplay()
            } else if alphaAction == .evalEquation {
                submitAlpha("P")
            } else if alphaAction == .promptVar {
                submitAlpha("X") // defaults to X if testing vars
            }
            alphaAction = .none
            isWaitingForAlpha = false
            return
        }
        
        isWaitingForAlpha = true
        alphaPrompt = "Variable"
        promptString = nil
        updateDisplay()
    }
    
    public func cancelAlpha() {
        if isWaitingForLabel {
            isWaitingForLabel = false
            if isEquationEditMode && currentEquationSteps.isEmpty {
                isEquationEditMode = false
            }
        }
        isWaitingForAlpha = false
        promptString = nil
        alphaAction = .none
        pendingEquationVars = []
        currentEvaluatingEquation = nil
        updateDisplay()
    }
    
    // MARK: - Shift state
    
    public func setShift(_ state: Int) {
        if shiftState == state {
            shiftState = 0
        } else {
            shiftState = state
        }
    }
    
    // MARK: - Update Display
    
    
    private func intToBuffer(_ val: Int64, buffer: inout [UInt8], offset: Int) -> Int {
        var v = abs(val)
        var length = 0
        if v == 0 {
            buffer[offset] = 48
            return 1
        }
        var temp = [UInt8](repeating: 0, count: 20)
        while v > 0 {
            temp[length] = UInt8(v % 10) + 48
            v /= 10
            length += 1
        }
        if val < 0 {
            temp[length] = 45 // '-'
            length += 1
        }
        for i in 0..<length {
            buffer[offset + i] = temp[length - 1 - i]
        }
        return length
    }
    
    private func intToRadixBuffer(_ val: Int64, radix: Int64, suffix: UInt8, buffer: inout [UInt8], offset: Int) -> Int {
        var v = val // For base conversions, usually treat as bit pattern, but let's just do positive
        if v < 0 { v = Int64(bitPattern: UInt64(bitPattern: v)) }
        var length = 0
        if v == 0 {
            buffer[offset] = 48
            buffer[offset+1] = suffix
            return 2
        }
        var temp = [UInt8](repeating: 0, count: 64)
        while v > 0 {
            let rem = UInt8(v % radix)
            temp[length] = rem < 10 ? rem + 48 : rem - 10 + 65 // 'A'
            v /= radix
            length += 1
        }
        for i in 0..<length {
            buffer[offset + i] = temp[length - 1 - i]
        }
        buffer[offset + length] = suffix
        return length + 1
    }

    public func formatNumberToBuffer(_ val: Double, buffer: inout [UInt8]) -> Int {
        if baseMode != .dec {
            let intVal = Int64(val)
            switch baseMode {
            case .hex: return intToRadixBuffer(intVal, radix: 16, suffix: 104, buffer: &buffer, offset: 0) // 'h'
            case .oct: return intToRadixBuffer(intVal, radix: 8, suffix: 111, buffer: &buffer, offset: 0) // 'o'
            case .bin: return intToRadixBuffer(intVal, radix: 2, suffix: 98, buffer: &buffer, offset: 0) // 'b'
            default: break
            }
        }
        
        if isFractionMode {
            let sign = val < 0 ? -1.0 : 1.0
            if let f = computeFractionToFit(valAbs: abs(val), sign: sign) {
                let whole = f.whole
                let fnum = f.num
                let fden = f.den
                
                if fnum == 0 {
                    return intToBuffer(val < 0 ? -whole : whole, buffer: &buffer, offset: 0)
                } else if whole == 0 {
                    var off = 0
                    if val < 0 { buffer[off] = 45; off += 1 }
                    off += intToBuffer(fnum, buffer: &buffer, offset: off)
                    buffer[off] = 47; off += 1 // '/'
                    off += intToBuffer(fden, buffer: &buffer, offset: off)
                    return off
                } else {
                    var off = 0
                    if val < 0 { buffer[off] = 45; off += 1 }
                    off += intToBuffer(whole, buffer: &buffer, offset: off)
                    buffer[off] = 32; off += 1 // ' '
                    off += intToBuffer(fnum, buffer: &buffer, offset: off)
                    buffer[off] = 47; off += 1 // '/'
                    off += intToBuffer(fden, buffer: &buffer, offset: off)
                    return off
                }
            }
        }
        
        var cMode: Int32 = 0
        var cPlaces: Int32 = 0
        switch displayMode {
        case .fix(let p): cMode = 1; cPlaces = Int32(p)
        case .sci(let p): cMode = 2; cPlaces = Int32(p)
        case .eng(let p): cMode = 3; cPlaces = Int32(p)
        case .all: cMode = 0; cPlaces = 0
        }
        
        var len = 0
        buffer.withUnsafeMutableBufferPointer { ptr in
            format_double_c(val, ptr.baseAddress!, 13, cMode, cPlaces, useCommaForDecimal ? 1 : 0)
        }
        while len < 64 && buffer[len] != 0 { len += 1 }
        return len
    }

    
    public func formatValue(_ cv: CalculatorValue) -> String {
        let val = cv.real

        return formatNumber(val)
    }

    public func formatNumber(_ val: Double, ignoreFractionMode: Bool = false) -> String {
        if baseMode != .dec {
            let intVal = Int64(val)
            switch baseMode {
            case .hex: return String(intVal, radix: 16).uppercased() + "h"
            case .oct: return String(intVal, radix: 8) + "o"
            case .bin: return String(intVal, radix: 2) + "b"
            default: break
            }
        }
        
        if isFractionMode && !ignoreFractionMode {
            let sign = val < 0 ? -1.0 : 1.0
            if let f = computeFractionToFit(valAbs: abs(val), sign: sign) {
                let whole = f.whole
                let fnum = f.num
                let fden = f.den
                
                if fnum == 0 {
                    return val < 0 ? "-\(whole)" : "\(whole)"
                } else if whole == 0 {
                    return val < 0 ? "-\(fnum)/\(fden)" : "\(fnum)/\(fden)"
                } else {
                    return val < 0 ? "-\(whole) \(fnum)/\(fden)" : "\(whole) \(fnum)/\(fden)"
                }
            }
        }
        
        var cMode: Int32 = 0
        var cPlaces: Int32 = 0
        switch displayMode {
        case .fix(let p): cMode = 1; cPlaces = Int32(p)
        case .sci(let p): cMode = 2; cPlaces = Int32(p)
        case .eng(let p): cMode = 3; cPlaces = Int32(p)
        case .all: cMode = 0; cPlaces = 0
        }
        
        let bufLen = 64
        var buffer = [UInt8](repeating: 0, count: bufLen)
        buffer.withUnsafeMutableBufferPointer { ptr in
            // max_len = 13 strictly enforces a maximum string length of 12 characters.
            // This prevents ANY ellipsis or wrapping on the physical UI constraints.
            format_double_c(val, ptr.baseAddress!, 13, cMode, cPlaces, useCommaForDecimal ? 1 : 0)
        }
        
        var len = 0
        while len < bufLen && buffer[len] != 0 { len += 1 }
        return String(decoding: buffer[0..<len], as: UTF8.self)
    }
    
    public func updateEquationDisplay() {
        if currentEquationSteps.isEmpty {
            promptString = "00 LBL \(currentEquationLabel)"
        } else {
            let stepNum = currentEquationSteps.count < 10 ? "0\(currentEquationSteps.count)" : "\(currentEquationSteps.count)"
            promptString = "\(stepNum) \(currentEquationSteps.last!)"
        }
        updateDisplay()
    }
    
    
    private func _populateBufferWithString(_ str: String) {
        var len = 0
        for char in str.utf8 {
            if len < 63 {
                displayXBuffer[len] = char
                len += 1
            }
        }
        displayXBuffer[len] = 0
        displayXLength = len
    }

    public func updateDisplay() {
        if isSilent { return }
        if let err = errorMessage {
            // Do NOT poison displayX or promptString with the error.
            // UI components explicitly check engine.errorMessage.
            // Just return so we don't overwrite the underlying buffer while the error is showing.
            return
        }
        if isEquationListMode {
            if equations.isEmpty {
                displayX = "NO EQN"
                promptString = "NO EQN"
            } else {
                let prog = equations[currentEquationListIndex]
                displayX = "\(prog.label): \(prog.steps.map { $0.stringValue }.joined(separator: " "))"
                promptString = displayX
            }
            _populateBufferWithString(displayX)
            return
        }
        if isEquationEditMode {
            displayX = promptString ?? "00 LBL \(currentEquationLabel)"
            _populateBufferWithString(displayX)
            return
        }
        if let prompt = promptString {
            displayX = prompt
            _populateBufferWithString(prompt)
            return
        }
        
        while stack.count < stackSizeLimit {
            stack.append(CalculatorValue())
        }
        if !isBuildingNumber {
            #if hasFeature(Embedded)
            let strVal = formatValue(stack[0])
            _populateBufferWithString(strVal)
            #else
            displayX = formatValue(stack[0])
            _populateBufferWithString(displayX)
            #endif
        }
        #if !hasFeature(Embedded)
        updateStackStrings()
        #endif
    }
    
    private func updateStackStrings() {
        #if !hasFeature(Embedded)
        let logicalStack = getLogicalStack()
        stackStrings = logicalStack.map { formatValue($0) }
        #endif
    }

    public func getLogicalStack() -> [CalculatorValue] {
        var logicalStack = stack
        if isBuildingNumber, let value = parseDouble(displayX) {
            if !stackLiftEnabled && !logicalStack.isEmpty {
                logicalStack[0] = CalculatorValue(real: value)
            } else {
                logicalStack.insert(CalculatorValue(real: value), at: 0)
            }
        }
        while logicalStack.count < stackSizeLimit {
            logicalStack.append(CalculatorValue())
        }
        return logicalStack
    }

    
    // MARK: - Calculus and Advanced Math
    
    public func integrate(variable: String, lower: Double, upper: Double, equation: Equation) -> Double {
        // HP-32SII nuance: Integration accuracy dynamically adjusts based on current display mode
        var n = 30
        switch displayMode {
        case .fix(let places): n = 30 + (places * 20)
        case .sci(let places): n = 30 + (places * 10)
        case .eng(let places): n = 30 + (places * 10)
        case .all: n = 100

        }
        // Cap to prevent excessive lag on devices
        n = min(n, 200)
        // Ensure n is a multiple of 3 for Simpson's 3/8 Rule
        n = ((n + 2) / 3) * 3

        let h = (upper - lower) / Double(n)
        
        var sum = 0.0
        
        self.plotData.removeAll(keepingCapacity: true)
        self.plotData.reserveCapacity(110)
        self.isStatPlot = false
        
        self.isSilent = true // Prevent UI updates during tight loop
        for i in 0...n {
            if let check = isInterrupted, check() {
                errorMessage = "INTERRUPTED"
                break
            }
            let x = lower + Double(i) * h
            
            let oldVal = self.variables[variable]
            self.variables[variable] = CalculatorValue(real: x)
            let f = evaluateEquation(equation)?.real ?? 0.0
            self.variables[variable] = oldVal
            
            self.plotData.append((x, f))
            
            // Simpson's 3/8 Rule
            let weight: Double = (i == 0 || i == n) ? 1.0 : (i % 3 == 0 ? 2.0 : 3.0)
            sum += weight * f
        }
        self.isSilent = false // Restore UI updates
        let result = (3.0 * h / 8.0) * sum
        self.push(CalculatorValue(real: result))
        self.integrationLimits = (lower, upper)
        self.isPlotSRequested = true
        updateDisplay()
        return result
    }

    public func derive(variable: String, at: Double, equation: Equation) -> Double? {
        let h = 1e-5
        var vars = variables
        
        vars[variable] = CalculatorValue(real: at + h)
        self.variables = vars; let fPlus = evaluateEquation(equation)?.real ?? 0.0
        vars[variable] = CalculatorValue(real: at - h)
        self.variables = vars; let fMinus = evaluateEquation(equation)?.real ?? 0.0
        
        let derivative = (fPlus - fMinus) / (2 * h)
        self.pushToStack(CalculatorValue(real: derivative))
        updateDisplay()
        return derivative
    }

    public func solve(for variable: String, equation: Equation, target: Double = 0.0) -> Double? {
        let maxIterations = 100
        let tolerance = 1e-7
        var x0 = variables[variable]?.real ?? 0.0
        var x1 = x0 + 0.1
        
        let oldVal = self.variables[variable]
        
        self.variables[variable] = CalculatorValue(real: x0)
        var f0 = (evaluateEquation(equation)?.real ?? 0.0) - target
        
        self.variables[variable] = CalculatorValue(real: x1)
        var f1 = (evaluateEquation(equation)?.real ?? 0.0) - target
        
        for _ in 0..<maxIterations {
            if let check = isInterrupted, check() {
                errorMessage = "INTERRUPTED"
                break
            }
            if abs(f1 - f0) < 1e-14 { break }
            let x2 = x1 - f1 * (x1 - x0) / (f1 - f0)
            if abs(x2 - x1) < tolerance {
                self.variables[variable] = oldVal
                self.pushToStack(CalculatorValue(real: x2))
                updateDisplay()
                return x2
            }
            x0 = x1
            f0 = f1
            x1 = x2
            
            self.variables[variable] = CalculatorValue(real: x1)
            f1 = (evaluateEquation(equation)?.real ?? 0.0) - target
        }
        
        self.variables[variable] = oldVal
        return nil
    }
}

#if !hasFeature(Embedded)
extension CalculatorEngine: ObservableObject {}
#endif


extension CalculatorEngine {
    public var plotDataPoints: [PlotDataPoint] {
        plotData.enumerated().map { PlotDataPoint(id: $0.offset, x: $0.element.0, y: $0.element.1) }
    }
    
    public var scatterPlotDataPoints: [PlotDataPoint] {
        statPoints.enumerated().map { PlotDataPoint(id: $0.offset, x: $0.element.x, y: $0.element.y) }
    }
    
    public var regressionPlotDataPoints: [PlotDataPoint] {
        guard isStatPlot, statN > 1 else { return [] }
        let num = statSumXY - (statSumX * statSumY / Double(statN))
        let den = statSumX2 - (statSumX * statSumX / Double(statN))
        let m = den == 0 ? 0 : num / den
        let b = (statSumY - m * statSumX) / Double(statN)
        
        let minX = statPoints.map { $0.x }.min() ?? -10.0
        let maxX = statPoints.map { $0.x }.max() ?? 10.0
        
        let padding = (maxX - minX) * 0.1
        let startX = minX - padding
        let endX = maxX + padding
        
        return [
            PlotDataPoint(id: 0, x: startX, y: m * startX + b),
            PlotDataPoint(id: 1, x: endX, y: m * endX + b)
        ]
    }
    
    public var highlightedPlotDataPoints: [PlotDataPoint] {
        guard let limits = integrationLimits else { return [] }
        let minL = min(limits.0, limits.1)
        let maxL = max(limits.0, limits.1)
        return plotData.enumerated().compactMap { (i, pt) in
            if pt.0 >= minL && pt.0 <= maxL {
                return PlotDataPoint(id: i, x: pt.0, y: pt.1)
            }
            return nil
        }
    }
    
    public func findYForPlot(x: Double) -> Double? {
        let pts = plotData.sorted { $0.0 < $1.0 }
        guard let first = pts.first, let last = pts.last else { return nil }
        if x <= first.0 { return first.1 }
        if x >= last.0 { return last.1 }
        
        for i in 0..<pts.count - 1 {
            let p1 = pts[i]
            let p2 = pts[i+1]
            if x >= p1.0 && x <= p2.0 {
                let dx = p2.0 - p1.0
                if dx == 0 { return nil }
                let t = (x - p1.0) / dx
                return p1.1 + t * (p2.1 - p1.1)
            }
        }
        return nil
    }
    
    public func tangentSlopeForPlot(x: Double) -> Double? {
        let pts = plotData.sorted { $0.0 < $1.0 }
        guard let first = pts.first, let last = pts.last else { return nil }
        if x <= first.0 || x >= last.0 { return nil }
        
        for i in 0..<pts.count - 1 {
            let p1 = pts[i]
            let p2 = pts[i+1]
            if x >= p1.0 && x <= p2.0 {
                let dx = p2.0 - p1.0
                if dx == 0 { return nil }
                return (p2.1 - p1.1) / dx
            }
        }
        return nil
    }
    
    public func tangentPlotDataPoints(at x: Double) -> [PlotDataPoint]? {
        guard let y = findYForPlot(x: x),
              let m = tangentSlopeForPlot(x: x),
              let first = plotData.first, let last = plotData.last else { return nil }
              
        let startX = first.0
        let startY = m * (startX - x) + y
        let endX = last.0
        let endY = m * (endX - x) + y
        return [PlotDataPoint(id: 0, x: startX, y: startY), PlotDataPoint(id: 1, x: endX, y: endY)]
    }
}
