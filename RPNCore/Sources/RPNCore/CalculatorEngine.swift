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

internal func parseDoubleSlice(_ slice: ArraySlice<UInt8>, exponent: String? = nil) -> Double {
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

internal func parseDouble(_ text: String) -> Double? {
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
        if fracPart < 0.0000001 {
            return String(intPart)
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
            return String(intPart) + "." + fracStr
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

internal func parseInt(_ text: String) -> Int? { return Int(text) }
internal func _substringToString(_ substring: Substring) -> String { return String(substring) }
internal func _formatDouble(_ value: Double) -> String { return "\(value)" }
internal func parseDouble(_ text: String) -> Double? { return Double(text) }
internal func parseInt64(_ text: String, radix: Int) -> Int64? { return Int64(text, radix: radix) }
internal func parseInt64(_ text: String) -> Int64? { return Int64(text) }

#endif

#if hasFeature(Embedded)
@_silgen_name("format_double_c")
func format_double_c(_ val: Double, _ buffer: UnsafeMutablePointer<UInt8>, _ max_len: Int32, _ mode: Int32, _ places: Int32)
#endif

#if !hasFeature(Embedded)
@Observable
#endif
public class CalculatorEngine {



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
    public var flags: [Bool] = Array(repeating: false, count: 12)
    public var skipNextInstruction: Bool = false
    
    // UI Events
    public var requestPlot: Bool = false
    public var requestPlotPrompt: Bool = false
    public var isPlotLoading: Bool = false
    public var plotData: [(Double, Double)] = []
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
    
    // Exam Mode
    public var isExamMode: Bool = false {
        didSet {
            toggleExamMode()
        }
    }
    private var stashedPrograms: [Program] = []
    private var stashedVariables: [String: CalculatorValue] = [:]
    
    // Shift State: 0=None, 1=Yellow(f), 2=Blue(g)
    public var shiftState: Int = 0 // 0: unshifted, 1: yellow, 2: blue
    public var isAssigning: Bool = false  // Unlimited Stack Array (For Overlay) - String representation

    public var stackStrings: [String] = []
    
    // Internal state - stack[0] is X, stack[1] is Y, etc.
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
    public struct Program: Codable, Identifiable {
        public var id: String { label }
        public var label: String
        public var steps: [String]
        
        public init(label: String, steps: [String]) {
            self.label = label
            self.steps = steps
        }
        
        public func extractVariables() -> [String] {
            var vars: [String] = []
            var seen = Set<String>()
            for step in steps {
                var v: String? = nil
                if step.count == 1 && "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(step) {
                    v = step
                } else if (step.hasPrefix("RCL ") || step.hasPrefix("STO ")) && step.count == 5 {
                    let char = String(step.last!)
                    if "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(char) {
                        v = char
                    }
                }
                
                if let v = v, seen.insert(v).inserted {
                    vars.append(v)
                }
            }
            return vars
        }
    }
    #else
    public struct Program: Identifiable {
        public var id: String { label }
        public var label: String
        public var steps: [String]
        
        public init(label: String, steps: [String]) {
            self.label = label
            self.steps = steps
        }
        
        public func extractVariables() -> [String] {
            var vars: [String] = []
            var seen = Set<String>()
            for step in steps {
                var v: String? = nil
                if step.count == 1 && "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(step) {
                    v = step
                } else if (step.hasPrefix("RCL ") || step.hasPrefix("STO ")) && step.count == 5 {
                    let char = String(step.last!)
                    if "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(char) {
                        v = char
                    }
                }
                
                if let v = v, seen.insert(v).inserted {
                    vars.append(v)
                }
            }
            return vars
        }
    }
    #endif
    public var programs: [Program] = [] {
        didSet {
            #if !hasFeature(Embedded)
            if let data = try? JSONEncoder().encode(programs) {
                UserDefaults.standard.set(data, forKey: "saved_programs")
            }
            #endif
        }
    }
    
    public init() {
        #if !hasFeature(Embedded)
        if let data = UserDefaults.standard.data(forKey: "saved_programs"),
           let savedPrograms = try? JSONDecoder().decode([Program].self, from: data) {
            self.programs = savedPrograms
        }
        #endif
        
        let normalPDF = Program(label: "NPDF", steps: ["X", "𝑥²", "2", "÷", "+/-", "𝑒ˣ", "2", "π", "×", "√𝑥", "÷"])
        if !programs.contains(where: { $0.label == "NPDF" }) {
            programs.append(normalPDF)
        }
        updateDisplay()
    }
    public var currentProgramLabel: String = ""
    public var currentProgramSteps: [String] = []
    public var currentProgramStepIndex: Int = 0
    public var currentEquation: String = ""
    public var currentEquationNumber: String = ""
    public var isEquationMode: Bool = false
    public var isProgrammingMode: Bool = false
    public var currentEquationIndex: Int = 0
    public var lastCrownValue: Double = 0.0
    
    public func scrollUp() {
        if isProgrammingMode {
            if currentProgramStepIndex > 0 {
                currentProgramStepIndex -= 1
                updateProgramDisplay()
            }
        } else if isEquationMode {
            if !programs.isEmpty {
                currentEquationIndex = max(0, currentEquationIndex - 1)
                currentEquation = programs[currentEquationIndex].steps.joined(separator: " ")
                updateDisplay()
            }
        }
    }
    
    public func scrollDown() {
        if isProgrammingMode {
            if currentProgramStepIndex < currentProgramSteps.count {
                currentProgramStepIndex += 1
                updateProgramDisplay()
            }
        } else if isEquationMode {
            if !programs.isEmpty {
                currentEquationIndex = min(programs.count - 1, currentEquationIndex + 1)
                currentEquation = programs[currentEquationIndex].steps.joined(separator: " ")
                updateDisplay()
            }
        }
    }
    
    private func appendToEquation(_ str: String, isDigit: Bool = false) {
        if currentEquation.isEmpty {
            currentEquation = str
        } else {
            if isDigit {
                let lastChar = currentEquation.last ?? " "
                let isNum = (lastChar >= "0" && lastChar <= "9")
                if isNum || lastChar == "." {
                    currentEquation += str
                } else {
                    currentEquation += " \(str)"
                }
            } else {
                currentEquation += " \(str)"
            }
        }
    }
    public var isWaitingForLabel: Bool = false
    public var complexMode: Bool = false
    public var isHypPending: Bool = false
    
    public func newEquation() {
        isWaitingForLabel = true
        promptString = "Select Label"
    }
    
    public func editEquation(_ program: Program) {
        isProgrammingMode = true
        currentProgramLabel = program.label
        currentProgramSteps = program.steps
        updateProgramDisplay()
    }
    
    // Modes
    public var isWaitingForAlpha: Bool = false
    public var alphaAction: AlphaAction = .none
    public var alphaPrompt: String = "Variable"
    public var pendingEquationVars: [String] = []
    public var currentEvaluatingProgram: Program? = nil
    
    public var angleMode: AngleMode = .deg
    public var displayMode: DisplayMode = .all
    public var activeTheme: Theme = .pioneer
    public var statusMessage: String? = nil
    
    public enum Theme { case pioneer, modern }
    public var baseMode: BaseMode = .dec
    public var isFractionMode: Bool = false
    public var maxDenominator: Double = 4095.0
    public var stackSizeLimit: Int = 4
    
    public enum AngleMode { case deg, rad, grd }
    
    public enum DisplayMode {
        case fix(Int)
        case sci(Int)
        case eng(Int)
        case all
    }
    
    public enum BaseMode { case dec, hex, oct, bin }
    
    public enum AlphaAction {
        case none, sto, stoAdd, stoSub, stoMul, stoDiv, rcl, evalEquation, promptVar, view, swapVar
    }
    
    public var usesContextualAlphaPad: Bool {
        return alphaAction == .sto || alphaAction == .stoAdd || alphaAction == .stoSub || alphaAction == .stoMul || alphaAction == .stoDiv || alphaAction == .rcl || alphaAction == .promptVar || alphaAction == .view || alphaAction == .swapVar
    }
    

    public func clearPrograms() {
        programs.removeAll()
        currentProgramSteps.removeAll()
        currentProgramLabel = ""
        currentEquation = ""
        isProgrammingMode = false
        isEquationMode = false
        updateDisplay()
    }
    
    private func saveProgram() {
        if let idx = programs.firstIndex(where: { $0.label == currentProgramLabel }) {
            programs[idx] = Program(label: currentProgramLabel, steps: currentProgramSteps)
        } else {
            programs.append(Program(label: currentProgramLabel, steps: currentProgramSteps))
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
        isEquationMode = false
        currentEquation = ""
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
            stashedPrograms = programs
            stashedVariables = variables
            
            programs.removeAll()
            variables.removeAll()
            
            // Clear all active state to prevent smuggling values
            stack = [CalculatorValue(), CalculatorValue(), CalculatorValue(), CalculatorValue()]
            lastX = CalculatorValue()
            clearStats()
            isProgrammingMode = false
            isEquationMode = false
            currentProgramSteps.removeAll()
            currentInputLength = 0
            isBuildingNumber = false
            shiftState = 0
            
            // Show a brief message
            errorMessage = "EXAM MODE ON"
        } else {
            // Turning OFF: Restore stashed data (wiping anything entered during the exam)
            programs = stashedPrograms
            variables = stashedVariables
            
            stashedPrograms.removeAll()
            stashedVariables.removeAll()
            
            errorMessage = "EXAM MODE OFF"
        }
        updateDisplay()
    }
    
    // MARK: - Input
    
    public var stackLiftEnabled: Bool = true
    public var prgmIsBuildingNumber: Bool = false
    
    public func digit(_ d: Int) {
        if isWaitingForLabel { return }
        errorMessage = nil
        
        if isEquationMode {
            appendToEquation("\(d)", isDigit: true)
            updateDisplay()
            return
        }
        
        if isProgrammingMode {
            if let last = currentProgramSteps.last, isProgramNumberStep(last) {
                currentProgramSteps[currentProgramSteps.count - 1] = last + "\(d)"
            } else {
                currentProgramSteps.append("\(d)")
            }
            prgmIsBuildingNumber = true
            updateProgramDisplay()
            return
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
        if isProgrammingMode {
            currentProgramSteps.append(l.uppercased())
            updateProgramDisplay()
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
        if isProgrammingMode {
            if let last = currentProgramSteps.last, isProgramNumberStep(last) {
                currentProgramSteps[currentProgramSteps.count - 1] = last + "E"
            } else {
                currentProgramSteps.append("1E")
            }
            prgmIsBuildingNumber = true
            updateProgramDisplay()
            return
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
        errorMessage = nil
        
        if isEquationMode {
            appendToEquation(".", isDigit: true)
            updateDisplay()
            return
        }
        
        if isProgrammingMode {
            if let last = currentProgramSteps.last, isProgramNumberStep(last) {
                currentProgramSteps[currentProgramSteps.count - 1] = last + "."
            } else {
                currentProgramSteps.append(".")
            }
            prgmIsBuildingNumber = true
            updateProgramDisplay()
            return
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
            // Allow multiple decimals
            appendInputByte(46)
            isFractionMode = true // Auto-enable fraction display
        }
        updateCurrentInputDisplay()
    }
    
    public func complexSeparator() {
        // Obsolete: HP32SII uses X and Y registers for complex entry
    }
    
    public func toggleSign() {
        errorMessage = nil
        if isProgrammingMode {
            if let last = currentProgramSteps.last, isProgramNumberStep(last) {
                if let eIndex = last.lastIndex(of: "E") {
                    let base = last[..<eIndex]
                    var exp = String(last[last.index(after: eIndex)...])
                    if exp.hasPrefix("-") {
                        exp.removeFirst()
                    } else {
                        exp = "-" + exp
                    }
                    currentProgramSteps[currentProgramSteps.count - 1] = base + "E" + exp
                } else {
                    if last.hasPrefix("-") {
                        currentProgramSteps[currentProgramSteps.count - 1] = String(last.dropFirst())
                    } else {
                        currentProgramSteps[currentProgramSteps.count - 1] = "-" + last
                    }
                }
            } else {
                currentProgramSteps.append("+/-")
            }
            prgmIsBuildingNumber = true
            updateProgramDisplay()
            return
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
    
    private func updateCurrentInputDisplay() {
        #if hasFeature(Embedded)
        displayXLength = currentInputLength
        for i in 0..<currentInputLength {
            displayXBuffer[i] = currentInputBuffer[i]
        }
        if isBuildingExponent {
            displayXBuffer[displayXLength] = 69 // 'E'
            displayXLength += 1
            for c in currentExponent.utf8 {
                if displayXLength >= 64 { break }
                displayXBuffer[displayXLength] = c
                displayXLength += 1
            }
        }
        #else
        var str = String(decoding: currentInputBuffer[0..<currentInputLength], as: UTF8.self)
        if isBuildingExponent {
            str += "E\(currentExponent.isEmpty ? "0" : currentExponent)"
        }
        displayX = str
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
            for i in 0..<currentInputLength {
                if currentInputBuffer[i] == 46 { decimalCount += 1 }
            }
            var val = 0.0
            
            if decimalCount == 2 {
                let valString = String(decoding: currentInputBuffer[0..<currentInputLength], as: UTF8.self)
                val = parseFractionString(valString)
            } else {
                if baseMode != .dec {
                    let valString = String(decoding: currentInputBuffer[0..<currentInputLength], as: UTF8.self)
                    let radix: Int
                    switch baseMode {
                    case .hex: radix = 16
                    case .oct: radix = 8
                    case .bin: radix = 2
                    default: radix = 10
                    }
                    if let parsedInt = Int64(valString, radix: radix) {
                        val = Double(parsedInt)
                    } else {
                        val = 0.0
                    }
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
        
        if isEquationMode {
            appendToEquation("ENTER")
            updateDisplay()
            return
        }
        
        if alphaAction == .promptVar {
            if isBuildingNumber { commitInput() }
            if let varName = pendingEquationVars.first {
                variables[varName] = stack.count > 0 ? stack[0] : CalculatorValue()
                pendingEquationVars.removeFirst()
                promptNextEquationVar()
            }
            return
        }

        if isProgrammingMode {
            if prgmIsBuildingNumber {
                prgmIsBuildingNumber = false
            } else {
                currentProgramSteps.append("ENTER")
            }
            updateProgramDisplay()
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
        if isProgrammingMode {
            currentProgramSteps.removeAll()
            updateProgramDisplay()
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

        if isProgrammingMode {
            if !currentProgramSteps.isEmpty {
                currentProgramSteps.removeLast()
                updateProgramDisplay()
            }
            return
        }
        if isEquationMode {
            if !currentEquation.isEmpty {
                currentEquation.removeLast()
                updateDisplay()
            }
            return
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
                    stackLiftEnabled = false
                    stack[0] = CalculatorValue()
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
        if stack.count > 1 {
            let last = stack.removeLast()
            pushToStack(last)
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
        if isEquationMode || isProgrammingMode {
            commitInput()
            pushToStack(CalculatorValue(real: result ? 1.0 : 0.0))
            stack.removeLast()
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

    public func executeMath(_ operation: String) {
        if isWaitingForLabel {
            if operation == "C" || operation == "CLEAR" || operation == "BACKSPACE" {
                cancelAlpha()
            }
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
        if isWaitingForLabel {
            if operation == "C" || operation == "CLEAR" || operation == "BACKSPACE" {
                cancelAlpha()
            }
            return
        }
        
        let hadError = errorMessage != nil
        errorMessage = nil
        
        if isEquationMode {
            let eqnBlacklist: Set<String> = [
                "STO", "XEQ", "GTO", "LBL", "RTN", "HEX", "DEC", "OCT", "BIN", "BASE",
                "FLAGS", "VIEW", "SHOW", "DISP", "MODES", "SETUP",
                "CMPLX", ">HMS", ">HR", ">POL", ">REC", "MEM", "VARS", "PRGM", "REGS", "CLALL", "CLREGS", "CLPRGM", "CLΣ"
            ]
            if eqnBlacklist.contains(operation) || 
               operation.hasPrefix("SF ") || operation.hasPrefix("CF ") || 
               operation.hasPrefix("FS? ") || operation.hasPrefix("FC? ") {
                errorMessage = "INVALID DATA"
                updateDisplay()
                return
            }
        }
        if hadError {
            stackLiftEnabled = false
            if (operation == "C" || operation == "CLEAR" || operation == "BACKSPACE" || operation == "CLX" || operation == "<-") {
                updateDisplay()
                return
            }
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
            if isEquationMode {
                isEquationMode = false
            }
            if isProgrammingMode {
                saveProgram()
                isProgrammingMode = false
                updateProgramDisplay()
                return
            }
            isProgrammingMode = true
            updateProgramDisplay()
            return
        }
        
        // Intercept inputs when building a program or equation
        if isProgrammingMode && !isWaitingForAlpha {
            if ["STO", "RCL", "LBL", "GTO", "XEQ", "VIEW"].contains(operation) {
                // Let these fall through to prompt for alpha
                prgmIsBuildingNumber = false
            } else if operation == "C" || operation == "CLEAR" {
                saveProgram()
                isProgrammingMode = false
                prgmIsBuildingNumber = false
                updateProgramDisplay()
                return
            } else if let p = parseInt(operation) {
                currentProgramSteps.append("\(p)")
                prgmIsBuildingNumber = true
                updateProgramDisplay()
                return
            } else if operation == "BACKSPACE" {
                if !currentProgramSteps.isEmpty {
                    currentProgramSteps.removeLast()
                }
                prgmIsBuildingNumber = false
                updateProgramDisplay()
                return
            } else if operation == "CLEAR" {
                currentProgramSteps.removeAll()
                prgmIsBuildingNumber = false
                updateProgramDisplay()
                return
            } else if operation == "RTN" {
                currentProgramSteps.append("RTN")
                saveProgram()
                isProgrammingMode = false
                isEquationMode = false
                isWaitingForLabel = false
                prgmIsBuildingNumber = false
                promptString = nil
                updateDisplay()
                return
            } else if operation == "ENTER" {
                if prgmIsBuildingNumber {
                    prgmIsBuildingNumber = false // Just terminate the number, don't append ENTER
                } else {
                    currentProgramSteps.append("ENTER")
                }
                updateProgramDisplay()
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
                currentProgramSteps.append(operation)
                prgmIsBuildingNumber = false
                updateProgramDisplay()
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
        
        if isEquationMode {
            if operation == "C" || operation == "CLEAR" {
                isEquationMode = false
                promptString = nil
                updateDisplay()
            } else if operation == "RCL" {
                startRcl()
            } else {
                appendToEquation(operation)
                updateDisplay()
            }
            return
        }
        
        if operation == "EQN" {
            isEquationMode = true
            updateDisplay()
            return
        }
        
        if operation == "XEQ" {
            isWaitingForLabel = true
            startAlpha()
            alphaPrompt = "XEQ _"
            return
        }
        
        if operation == "LBL" {
            isWaitingForLabel = true
            startAlpha()
            alphaPrompt = "LBL _"
            return
        }
        
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
                // Formatting to string and back to simulate RND to display precision
                let str = formatNumber(stack[0].real)
                if let rounded = parseDouble(str) {
                    stack[0].real = rounded
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
            let wasProgramming = isProgrammingMode
            isEquationMode = false
            isProgrammingMode = false
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
        case "CLPRGM":
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
            if isProgrammingMode {
                currentProgramSteps.append("RTN")
                updateProgramDisplay()
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
        case "x=y": if currentEvaluatingProgram != nil { binaryOp { CalculatorValue(real: $1.real == $0.real ? 1.0 : 0.0) } } else { performTest(stack[0].real == stack[1].real) }; return
        case "x!=y": if currentEvaluatingProgram != nil { binaryOp { CalculatorValue(real: $1.real != $0.real ? 1.0 : 0.0) } } else { performTest(stack[0].real != stack[1].real) }; return
        case "x>y": if currentEvaluatingProgram != nil { binaryOp { CalculatorValue(real: $1.real > $0.real ? 1.0 : 0.0) } } else { performTest(stack[0].real > stack[1].real) }; return
        case "x<y": if currentEvaluatingProgram != nil { binaryOp { CalculatorValue(real: $1.real < $0.real ? 1.0 : 0.0) } } else { performTest(stack[0].real < stack[1].real) }; return
        case "x<=y": if currentEvaluatingProgram != nil { binaryOp { CalculatorValue(real: $1.real <= $0.real ? 1.0 : 0.0) } } else { performTest(stack[0].real <= stack[1].real) }; return
        case "x=0": if currentEvaluatingProgram != nil { unaryOp { CalculatorValue(real: $0.real == 0 ? 1.0 : 0.0) } } else { performTest(stack[0].real == 0) }; return
        case "x!=0": if currentEvaluatingProgram != nil { unaryOp { CalculatorValue(real: $0.real != 0 ? 1.0 : 0.0) } } else { performTest(stack[0].real != 0) }; return
        case "x>0": if currentEvaluatingProgram != nil { unaryOp { CalculatorValue(real: $0.real > 0 ? 1.0 : 0.0) } } else { performTest(stack[0].real > 0) }; return
        case "x<0": if currentEvaluatingProgram != nil { unaryOp { CalculatorValue(real: $0.real < 0 ? 1.0 : 0.0) } } else { performTest(stack[0].real < 0) }; return
        case "x<=0": if currentEvaluatingProgram != nil { unaryOp { CalculatorValue(real: $0.real <= 0 ? 1.0 : 0.0) } } else { performTest(stack[0].real <= 0) }; return
        case "𝑥!", "n!": 
            if stack.count > 0 {
                if stack[0].real < 0 || stack[0].real != floor(stack[0].real) { errorMessage = "INVALID DATA"; return }
            }
            unaryOp { CalculatorValue(real: tgamma($0.real + 1)) }
        case "π": commitInput(); pushToStack(CalculatorValue(real: Double.pi))
        case "+/-": toggleSign(); return
        case "ENTER": commitInput(); pushToStack(stack[0]); stackLiftEnabled = false
        case ".": decimal(); return
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
        
        // Base logic
        case "AND": binaryOp { CalculatorValue(real: Double(Int64($1.real) & Int64($0.real))) }
        case "OR": binaryOp { CalculatorValue(real: Double(Int64($1.real) | Int64($0.real))) }
        case "XOR": binaryOp { CalculatorValue(real: Double(Int64($1.real) ^ Int64($0.real))) }
        case "NOT": unaryOp { CalculatorValue(real: Double(~Int64($0.real))) }
            
        case "R↓":
            if stack.count > 1 {
                let first = stack[0]
                for i in 0..<(stackSizeLimit - 1) { stack[i] = stack[i+1] }
                stack[stackSizeLimit - 1] = CalculatorValue()
                stack.append(first)
            }
        case "R↑":
            if stack.count > 1 {
                let last = stack.removeLast()
                pushToStack(last)
            }

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
        case "GRD": angleMode = .grd
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
            plotData.removeAll()
            plotMarkers.removeAll()
            
            let prog: Program?
            if let label = currentProgramLabel.isEmpty ? nil : currentProgramLabel,
               let p = programs.first(where: { $0.label == label }) {
                prog = p
            } else if let firstProgram = programs.first {
                prog = firstProgram
            } else {
                prog = nil
            }
            
            let evalFunc: (Double) -> Double? = { xVal in
                if let program = prog {
                    var vars = self.variables
                    vars[variable] = CalculatorValue(real: xVal)
                    return self.evaluateProgram(program, variables: vars)?.real
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
            // Plot data will just be an empty array, or we can use statPoints directly in the view
        }
        self.requestPlot = true
    }
    
    public func evaluateProgram(_ program: Program, variables: [String: CalculatorValue]) -> CalculatorValue? {
        // Save state
        let savedStack = self.stack
        let savedLastX = self.lastX
        let savedStackStrings = self.stackStrings
        let savedPrompt = self.promptString
        let savedDisplayX = self.displayX
        let savedProgMode = self.isProgrammingMode
        let savedEqMode = self.isEquationMode
        let savedInputBuffer = self.currentInputBuffer
        let savedInputLength = self.currentInputLength
        let savedIsBuildingNum = self.isBuildingNumber
        let savedShift = self.shiftState
        let savedLiftEnabled = self.stackLiftEnabled
        
        self.isProgrammingMode = false
        self.isEquationMode = false
        self.isBuildingNumber = false
        self.stackLiftEnabled = true
        self.currentEvaluatingProgram = program
        
        // Clear stack for the program
        self.stack = Array(repeating: CalculatorValue(), count: self.stackSizeLimit)
        
        if let emptyVar = variables[""] {
            self.push(emptyVar)
        }
        
        // Execute steps
        var i = 0
        while i < program.steps.count {
            let step = program.steps[i]
            if skipNextInstruction {
                skipNextInstruction = false
                i += 1
                continue
            }
            if isProgramNumberStep(step) {
                if !self.isBuildingNumber {
                    if self.stackLiftEnabled && !self.stack.isEmpty {
                        self.pushToStack(self.stack[0]) // Push stack
                    }
                    self.isBuildingNumber = true
                    self.currentInputLength = 0
                }
                let bytes = Array(step.utf8)
                let lengthToAdd = min(bytes.count, 64 - self.currentInputLength)
                for j in 0..<lengthToAdd {
                    self.currentInputBuffer[self.currentInputLength + j] = bytes[j]
                }
                self.currentInputLength += lengthToAdd
            } else if let val = variables[step] {
                self.push(val)
                self.stackLiftEnabled = true
            } else if step.hasPrefix("RCL ") {
                let varName = String(step.dropFirst(4))
                if let val = variables[varName] {
                    self.push(val)
                    self.stackLiftEnabled = true
                }
            } else if step.hasPrefix("STO ") {
                let varName = String(step.dropFirst(4))
                self.variables[varName] = self.stack.first ?? CalculatorValue()
            } else if ["SETUP", "DISP", "MODES", "STAT", "FN=", "EQN", "PRGM", "SOLVE", "∫", "SHOW", "PLOT", "VIEW", "CLEAR"].contains(step) {
                // Handled by action closure
            } else {
                self.executeMath(step)
            }
            i += 1
        }
        
        if self.isBuildingNumber { self.commitInput() }
        
        // Get result
        let result = self.stack.first
        
        // Restore state
        self.stack = savedStack
        self.lastX = savedLastX
        self.stackStrings = savedStackStrings
        self.promptString = savedPrompt
        self.displayX = savedDisplayX
        self.isProgrammingMode = savedProgMode
        self.isEquationMode = savedEqMode
        self.currentInputBuffer = savedInputBuffer
        self.currentInputLength = savedInputLength
        self.isBuildingNumber = savedIsBuildingNum
        self.shiftState = savedShift
        self.stackLiftEnabled = savedLiftEnabled
        self.currentEvaluatingProgram = nil
        
        self.updateDisplay()
        return result
    }

    private func isProgramNumberStep(_ step: String) -> Bool {
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
        
        if isProgrammingMode {
            let stepNum = currentProgramSteps.count + 1
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
        let key = str.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if key.isEmpty { 
            cancelAlpha()
            return 
        }
        
        let initialChar = key
        
        if baseMode == .hex && alphaAction == .none && !isEquationMode && !isProgrammingMode && !isWaitingForLabel && ["A", "B", "C", "D", "E", "F"].contains(initialChar) {
            letter(initialChar)
            return
        }
        
        if alphaAction == .promptVar {
            // User submitted a value for a variable in an equation
            if let val = parseDouble(key) {
                if let varName = pendingEquationVars.first {
                    variables[varName] = CalculatorValue(real: val)
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
                if isProgrammingMode {
                    let stepNum = currentProgramSteps.count + 1
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
            isProgrammingMode = true
            currentProgramLabel = initialChar
            if let existing = programs.first(where: { $0.label == currentProgramLabel }) {
                currentProgramSteps = existing.steps
            } else {
                currentProgramSteps = []
            }
            updateProgramDisplay()
        } else if alphaAction == .evalEquation {
            if let program = programs.first(where: { $0.label == initialChar }) {
                currentEvaluatingProgram = program
                let knownCommands: Set<String> = ["SETUP", "DISP", "MODES", "STAT", "FN=", "EQN", "PRGM", "SOLVE", "∫", "SHOW", "PLOT", "VIEW", "CLEAR", "ENTER", "BACKSPACE", "+", "-", "×", "÷", ".", "SIN", "COS", "TAN", "ASIN", "ACOS", "ATAN", "LOG", "LN", "ABS", "INTG", "FRAC", "RND", "LAST𝑥", "𝑥≷𝑦", "𝑥≷𝑦", "R↓", "R↑", "𝑦ˣ", "xVy", "1/𝑥", "𝑥!", "√𝑥", "𝑥²", "𝑒ˣ", "10ˣ", "%", "%CHG", "π", "LBL", "GTO", "XEQ", "RTN", "STO", "RCL", "MEM", "PROB", "PARTS", "SUMS", "BASE", "FLAGS", "CMPLX", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "SD", "𝑥?0", "𝑥?𝑦", "INT÷", "AND", "OR", "XOR", "NOT"]
                pendingEquationVars = program.steps.filter { step in
                    guard let first = step.first, first.isLetter else { return false }
                    return !knownCommands.contains(step)
                }
                // Remove duplicates while preserving order
                var seen = Set<String>()
                pendingEquationVars = pendingEquationVars.filter { seen.insert($0).inserted }
                
                promptNextEquationVar()
            }
        } else if isProgrammingMode {
            if alphaAction == .sto {
                currentProgramSteps.append("STO \(initialChar)")
            } else if alphaAction == .stoAdd {
                currentProgramSteps.append("STO + \(initialChar)")
            } else if alphaAction == .stoSub {
                currentProgramSteps.append("STO - \(initialChar)")
            } else if alphaAction == .stoMul {
                currentProgramSteps.append("STO × \(initialChar)")
            } else if alphaAction == .stoDiv {
                currentProgramSteps.append("STO ÷ \(initialChar)")
            } else if alphaAction == .rcl {
                currentProgramSteps.append("RCL \(initialChar)")
            } else if alphaAction == .evalEquation {
                currentProgramSteps.append("XEQ \(initialChar)")
            } else if alphaAction == .view {
                currentProgramSteps.append("VIEW \(initialChar)")
            } else {
                // If it's LBL, GTO, or just raw alpha fallback
                if isWaitingForLabel {
                    // Handled above usually, but fallback just in case
                } else {
                    currentProgramSteps.append(initialChar)
                }
            }
            updateProgramDisplay()
        } else if isEquationMode {
            appendToEquation(initialChar)
            updateDisplay()
        } else if alphaAction == .sto {
            variables[initialChar] = stack.count > 0 ? stack[0] : CalculatorValue()
        } else if alphaAction == .stoAdd {
            let existing = variables[initialChar] ?? CalculatorValue()
            variables[initialChar] = existing + (stack.count > 0 ? stack[0] : CalculatorValue())
        } else if alphaAction == .stoSub {
            let existing = variables[initialChar] ?? CalculatorValue()
            variables[initialChar] = existing - (stack.count > 0 ? stack[0] : CalculatorValue())
        } else if alphaAction == .stoMul {
            let existing = variables[initialChar] ?? CalculatorValue()
            variables[initialChar] = existing * (stack.count > 0 ? stack[0] : CalculatorValue())
        } else if alphaAction == .stoDiv {
            let existing = variables[initialChar] ?? CalculatorValue()
            if let top = stack.first, top.real != 0 {
                variables[initialChar] = existing / top
            } else {
                errorMessage = "DIVIDE BY 0"
            }
        } else if alphaAction == .swapVar {
            let varValue = variables[initialChar] ?? CalculatorValue()
            let xValue = stack.first ?? CalculatorValue()
            variables[initialChar] = xValue
            stack[0] = varValue
            stackLiftEnabled = true
        } else if alphaAction == .rcl {
            let val = variables[initialChar] ?? CalculatorValue()
            pushToStack(val)
            updateDisplay()
        } else if alphaAction == .view {
            let val = variables[initialChar] ?? CalculatorValue()
            let valStr = val.isComplex ? "\(formatNumber(val.real)) + \(formatNumber(val.imag))i" : formatNumber(val.real)
            transientMessage = "\(initialChar) = \(valStr)"
            updateDisplay()
        } else {
            // Push variable directly if in run mode
            let val = variables[initialChar] ?? CalculatorValue()
            push(val)
        }
        
        if alphaAction != .promptVar && alphaAction != .evalEquation {
            alphaAction = .none
        }
        isBuildingNumber = false
        isWaitingForAlpha = false
        if !isEquationMode && !isProgrammingMode {
            promptString = nil
            updateDisplay()
        }
    }
    
    public func promptNextEquationVar() {
        if let nextVar = pendingEquationVars.first {
            isWaitingForAlpha = false
            alphaAction = .promptVar
            alphaPrompt = "\(nextVar)?"
        } else if let program = currentEvaluatingProgram {
            // All variables bound, evaluate
            isWaitingForAlpha = false
            alphaAction = .none
            currentEvaluatingProgram = nil
            if let result = evaluateProgram(program, variables: variables) {
                push(result)
            }
            isEquationMode = false
            updateDisplay()
        }
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
                isProgrammingMode = true
                currentProgramLabel = "P" // default to P for testing
                if let existing = programs.first(where: { $0.label == currentProgramLabel }) {
                    currentProgramSteps = existing.steps
                } else {
                    currentProgramSteps = []
                }
                updateProgramDisplay()
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
            if isEquationMode && currentProgramSteps.isEmpty {
                isEquationMode = false
            } else if isProgrammingMode && currentProgramSteps.isEmpty {
                isProgrammingMode = false
            }
        }
        isWaitingForAlpha = false
        promptString = nil
        alphaAction = .none
        pendingEquationVars = []
        currentEvaluatingProgram = nil
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
    
    public func formatNumber(_ val: Double) -> String {
        if baseMode != .dec {
            let intVal = Int64(val)
            switch baseMode {
            case .hex: return String(intVal, radix: 16).uppercased() + "h"
            case .oct: return String(intVal, radix: 8) + "o"
            case .bin: return String(intVal, radix: 2) + "b"
            default: break
            }
        }
        
        if isFractionMode {
            let valAbs = abs(val)
            let whole = Int64(valAbs)
            let remainder = valAbs - Double(whole)
            let sign = val < 0 ? -1 : 1
            
            if remainder > 1e-6 {
                let num = Int64(round(remainder * 1_000_000))
                let den = Int64(1_000_000)
                let frac = Rational<Int64>(num, den).limitDenominator(to: Int64(maxDenominator))
                let fnum = frac.numerator
                let fden = frac.denominator
                
                if whole == 0 {
                    return sign < 0 ? "-\(fnum)/\(fden)" : "\(fnum)/\(fden)"
                } else {
                    return sign < 0 ? "-\(whole) \(fnum)/\(fden)" : "\(whole) \(fnum)/\(fden)"
                }
            }
        }
        
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false
        formatter.decimalSeparator = "."
        let maxLength = 12
        
        switch displayMode {
        case .fix(let places):
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = places
            formatter.maximumFractionDigits = places
            let result = formatter.string(from: NSNumber(value: val)) ?? "0"
            if val != 0 && (parseDouble(result) ?? 0.0) == 0.0 {
                return formatScientificToFit(val: val, maxLength: maxLength, maxFraction: places)
            }
            return result.count > maxLength ? formatScientificToFit(val: val, maxLength: maxLength, maxFraction: places) : result
        case .sci(let places):
            return formatScientificToFit(val: val, maxLength: maxLength, maxFraction: places)
        case .eng(let places):
            return formatScientificToFit(val: val, maxLength: maxLength, maxFraction: places)
        case .all:
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = maxLength - 1
            formatter.minimumFractionDigits = 0
            var result = formatter.string(from: NSNumber(value: val)) ?? "0"
            
            if result.count <= maxLength && (abs(val) >= 1e-4 || val == 0) {
                return result
            }
            
            if abs(val) >= 1e-4 && abs(val) < pow(10.0, Double(maxLength - 1)) {
                let intPartLen = String(Int64(abs(val))).count
                let signLen = val < 0 ? 1 : 0
                let allowedFraction = max(0, maxLength - intPartLen - signLen - 1)
                formatter.maximumFractionDigits = allowedFraction
                result = formatter.string(from: NSNumber(value: val)) ?? "0"
                if result.count <= maxLength {
                    return result
                }
            }
            
            return formatScientificToFit(val: val, maxLength: maxLength, maxFraction: maxLength - 1)
        }
    }
    
    private func formatScientificToFit(val: Double, maxLength: Int, maxFraction: Int) -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false
        formatter.numberStyle = .scientific
        formatter.decimalSeparator = "."
        formatter.exponentSymbol = "E"
        formatter.usesSignificantDigits = true
        
        for fractionDigits in (0...maxFraction).reversed() {
            formatter.maximumSignificantDigits = fractionDigits + 1
            formatter.minimumSignificantDigits = fractionDigits + 1
            if let str = formatter.string(from: NSNumber(value: val)), str.count <= maxLength {
                return str
            }
        }
        
        formatter.maximumSignificantDigits = 1
        formatter.minimumSignificantDigits = 1
        return formatter.string(from: NSNumber(value: val)) ?? "0"
    }
    
    public func updateProgramDisplay() {
        if currentProgramSteps.isEmpty {
            promptString = "00 LBL \(currentProgramLabel)"
        } else {
            let stepNum = "\(currentProgramSteps.count)"
            promptString = "\(stepNum) \(currentProgramSteps.last!)"
        }
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
                if isEquationMode {
            promptString = currentEquation.isEmpty ? "EQN=" : currentEquation
            displayX = promptString!
            #if hasFeature(Embedded)
            _populateBufferWithString(displayX)
            #endif
            return
        }
        if isProgrammingMode {
            displayX = promptString ?? "00 LBL \(currentProgramLabel)"
            #if hasFeature(Embedded)
            _populateBufferWithString(displayX)
            #endif
            return
        }
        if let prompt = promptString {
            displayX = prompt
            #if hasFeature(Embedded)
            _populateBufferWithString(prompt)
            #endif
            return
        }
        
        while stack.count < stackSizeLimit {
            stack.append(CalculatorValue())
        }
        if !isBuildingNumber {
                #if hasFeature(Embedded)
                if baseMode != .dec {
                    let strVal = formatNumber(stack[0].real)
                    _populateBufferWithString(strVal)
                } else {
                    var cMode: Int32 = 0
                    var cPlaces: Int32 = 0
                    switch displayMode {
                    case .fix(let p): cMode = 1; cPlaces = Int32(p)
                    case .sci(let p): cMode = 2; cPlaces = Int32(p)
                    case .eng(let p): cMode = 3; cPlaces = Int32(p)
                    case .all: cMode = 0; cPlaces = 0
                    }
                    displayXBuffer.withUnsafeMutableBufferPointer { ptr in
                        format_double_c(stack[0].real, ptr.baseAddress!, 13, cMode, cPlaces)
                    }
                    var len = 0
                    while len < 64 && displayXBuffer[len] != 0 { len += 1 }
                    displayXLength = len
                }
                #else
                displayX = formatNumber(stack[0].real)
                #endif
            }
        #if !hasFeature(Embedded)
        updateStackStrings()
        #endif
    }
    
    private func updateStackStrings() {
        #if !hasFeature(Embedded)
        let logicalStack = getLogicalStack()
        stackStrings = logicalStack.map { formatNumber($0.real) }
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
    
    public func integrate(variable: String, lower: Double, upper: Double, program: Program) -> Double {
        let n = 30 // Reduced to prevent main thread lockup
        let h = (upper - lower) / Double(n)
        var vars = variables
        var sum = 0.0
        
        self.plotData.removeAll()
        self.isStatPlot = false
        
        self.isSilent = true // Prevent UI updates during tight loop
        for i in 0...n {
            let x = lower + Double(i) * h
            vars[variable] = CalculatorValue(real: x)
            let f = evaluateProgram(program, variables: vars)?.real ?? 0.0
            
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

    public func derive(variable: String, at: Double, program: Program) -> Double? {
        let h = 1e-5
        var vars = variables
        vars[variable] = CalculatorValue(real: at + h)
        let fPlus = evaluateProgram(program, variables: vars)?.real ?? 0.0
        vars[variable] = CalculatorValue(real: at - h)
        let fMinus = evaluateProgram(program, variables: vars)?.real ?? 0.0
        
        let derivative = (fPlus - fMinus) / (2 * h)
        self.pushToStack(CalculatorValue(real: derivative))
        updateDisplay()
        return derivative
    }

    public func solve(for variable: String, program: Program, target: Double = 0.0) -> Double? {
        let maxIterations = 100
        let tolerance = 1e-7
        var x0 = variables[variable]?.real ?? 0.0
        var x1 = x0 + 0.1
        var vars = variables
        
        vars[variable] = CalculatorValue(real: x0)
        var f0 = (evaluateProgram(program, variables: vars)?.real ?? 0.0) - target
        
        vars[variable] = CalculatorValue(real: x1)
        var f1 = (evaluateProgram(program, variables: vars)?.real ?? 0.0) - target
        
        for _ in 0..<maxIterations {
            if abs(f1 - f0) < 1e-14 { break }
            let x2 = x1 - f1 * (x1 - x0) / (f1 - f0)
            if abs(x2 - x1) < tolerance {
                self.pushToStack(CalculatorValue(real: x2))
                updateDisplay()
                return x2
            }
            x0 = x1
            f0 = f1
            x1 = x2
            
            vars[variable] = CalculatorValue(real: x1)
            f1 = (evaluateProgram(program, variables: vars)?.real ?? 0.0) - target
        }
        
        return nil
    }
}

#if !hasFeature(Embedded)
extension CalculatorEngine: ObservableObject {}
#endif

