#if !hasFeature(Embedded)
import Foundation
import Observation
import RationalModule
#endif

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
internal func parseInt(_ text: String) -> Int? { return 0 }
internal func _substringToString(_ substring: Substring) -> String { return "" }
internal func _formatDouble(_ value: Double) -> String { return "0.0" }
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


#if !hasFeature(Embedded)
@Observable
#endif
public class CalculatorEngine {
    public let lfuManager = LFUManager()
    
    // Standard Display State
    public var displayX: String = "0"
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
    public var isStatPlot: Bool = false
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
    public var currentInput: String = "0"
    private var currentExponent: String = ""
    private var isBuildingImaginary: Bool = false
    
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
        
        let normalPDF = Program(label: "NPDF", steps: ["X", "x^2", "2", "÷", "+/-", "e^x", "2", "π", "×", "√x", "÷"])
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
                if lastChar.isNumber || lastChar == "." {
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
    
    public enum Theme { case pioneer, dm32 }
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
        case none, sto, rcl, evalEquation, promptVar
    }
    
    public var usesContextualAlphaPad: Bool {
        return alphaAction == .sto || alphaAction == .rcl || alphaAction == .promptVar
    }
    

    public func clearPrograms() {
        programs.removeAll()
        currentProgramSteps.removeAll()
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
        currentInput = ""
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
            currentInput = ""
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
                currentInput = "\(d)"
                hasDecimal = false
                isBuildingExponent = false
            } else {
                if currentInput == "0" && d == 0 { return }
                
                if currentInput == "0" {
                    currentInput = "\(d)"
                } else {
                    currentInput += "\(d)"
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
                currentInput = l
            } else {
                currentInput += l
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
            currentInput = "1"
        }
        isBuildingExponent = true
        currentExponent = "0"
        updateCurrentInputDisplay()
    }
    
    public func decimal() {
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
            isBuildingNumber = true
            currentInput = "0."
            hasDecimal = true
        } else if !hasDecimal {
            currentInput += "."
            hasDecimal = true
        } else {
            // Support HP 32sii fraction input (e.g. 1.2.3 for 1 2/3)
            // Allow multiple decimals
            currentInput += "."
            isFractionMode = true // Auto-enable fraction display
        }
        updateCurrentInputDisplay()
    }
    
    public func complexSeparator() {
        // (i) input
        if isBuildingNumber {
            commitInput()
        }
        isBuildingImaginary = true
        // Start building imaginary part
        isBuildingNumber = true
        currentInput = "0"
        hasDecimal = false
        isBuildingExponent = false
        currentExponent = ""
        updateCurrentInputDisplay()
    }
    
    public func toggleSign() {
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
                if currentInput.hasPrefix("-") {
                    currentInput.removeFirst()
                } else {
                    if currentInput != "0" {
                        currentInput = "-" + currentInput
                    }
                }
            }
            updateCurrentInputDisplay()
        } else {
            if !stack.isEmpty {
                lastX = stack[0]
                stack[0] = CalculatorValue(real: -stack[0].real, imag: -stack[0].imag)
                updateDisplay()
            }
        }
    }
    
    private func updateCurrentInputDisplay() {
        var str = currentInput
        if isBuildingExponent {
            str += "E\(currentExponent.isEmpty ? "0" : currentExponent)"
        }
        if isBuildingImaginary {
            displayX = "\(formatNumber(stack[0].real)) + \(str)i"
        } else {
            displayX = str
        }
        updateStackStrings()
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
            var valString = currentInput
            var val = 0.0
            if valString.split(separator: Character(".")).map({ String($0) }).count == 3 {
                 val = parseFractionString(valString)
            } else {
                if baseMode != .dec {
                    let radix: Int
                    switch baseMode {
                    case .hex: radix = 16
                    case .oct: radix = 8
                    case .bin: radix = 2
                    default: radix = 10
                    }
                    if let parsedInt = parseInt64(valString, radix: radix) {
                        val = Double(parsedInt)
                    } else {
                        val = 0.0
                    }
                } else {
                    if isBuildingExponent {
                        valString += "e\(currentExponent)"
                    }
                    val = parseDouble(valString) ?? 0.0
                }
            }
            
            if isBuildingImaginary {
                stack[0].imag = val
                isBuildingImaginary = false
            } else {
                if stack.isEmpty {
                    stack.append(CalculatorValue(real: val))
                } else {
                    stack[0] = CalculatorValue(real: val)
                }
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
    
    public func clearX() {
        if isProgrammingMode {
            currentProgramSteps.removeAll()
            updateProgramDisplay()
            return
        }
        if !stack.isEmpty {
            stack[0] = CalculatorValue()
        }
        currentInput = "0"
        isBuildingNumber = false
        hasDecimal = false
        isBuildingImaginary = false
        stackLiftEnabled = false
        updateDisplay()
    }
    
    public func backspace() {
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
                if currentInput.count > 1 {
                    let last = currentInput.removeLast()
                    if last == "." { hasDecimal = false }
                    if currentInput == "-" {
                        currentInput = "0"
                        isBuildingNumber = false
                    }
                } else {
                    currentInput = "0"
                    isBuildingNumber = false
                }
            }
            updateCurrentInputDisplay()
        } else {
            for i in 0..<(stackSizeLimit - 1) {
                stack[i] = stack[i+1]
            }
            stack[stackSizeLimit - 1] = CalculatorValue()
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
        updateDisplay()
    }
    
    public func rollUp() {
        commitInput()
        if stack.count > 1 {
            let last = stack.removeLast()
            pushToStack(last)
        }
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

    public func executeMath(_ operation: String) {
        if isWaitingForLabel {
            if operation == "C" || operation == "CLEAR" || operation == "BACKSPACE" {
                cancelAlpha()
            }
            return
        }
        
        errorMessage = nil
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
            if ["STO", "RCL", "LBL", "GTO", "XEQ"].contains(operation) {
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
        if operation == "RCL" {
            startRcl()
            return
        }
        
        if isEquationMode {
            if operation == "C" || operation == "CLEAR" {
                isEquationMode = false
                promptString = nil
                updateDisplay()
            } else if operation == "RCL" {
                startRcl()
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
            } else if isBuildingNumber { 
                currentInput = "0"
                isBuildingNumber = false 
            } else {
                if stack.count > 0 { stack[0] = CalculatorValue() }
            }
        case "CLEAR":
            stack = [CalculatorValue(), CalculatorValue(), CalculatorValue(), CalculatorValue()]
            currentInput = ""
            isBuildingNumber = false
        case "x<>y", "𝑥><𝑦":
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
        case "1/x":
            if stack.count > 0 && stack[0].real == 0 { errorMessage = "DIVIDE BY 0"; return }
            unaryOp { CalculatorValue(real: 1.0 / $0.real) }
        case "√x": 
            if stack.count > 0 && stack[0].real < 0 { errorMessage = "SQRT(NEG)"; return }
            unaryOp { CalculatorValue(real: _sqrt($0.real)) }
        case "x^2": unaryOp { CalculatorValue(real: $0.real * $0.real) }
        case "y^x": binaryOp { CalculatorValue(real: _pow($1.real, $0.real)) }
        case "%": percentOp { CalculatorValue(real: $1.real * ($0.real / 100.0)) }
        case "%CHG": percentOp { CalculatorValue(real: $1.real == 0 ? 0 : (($0.real - $1.real) / $1.real) * 100.0) }
        case "LN": 
            if stack.count > 0 {
                if stack[0].real == 0 { errorMessage = "LOG(0)"; return }
                if stack[0].real < 0 { errorMessage = "LOG(NEG)"; return }
            }
            unaryOp { CalculatorValue(real: _log($0.real)) }
        case "e^x": unaryOp { CalculatorValue(real: _exp($0.real)) }
        case "LOG": 
            if stack.count > 0 {
                if stack[0].real == 0 { errorMessage = "LOG(0)"; return }
                if stack[0].real < 0 { errorMessage = "LOG(NEG)"; return }
            }
            unaryOp { CalculatorValue(real: _log10($0.real)) }
        case "10^x": unaryOp { CalculatorValue(real: _pow(10.0, $0.real)) }
        case "x=y": performTest(stack[0].real == stack[1].real); return
        case "x!=y": performTest(stack[0].real != stack[1].real); return
        case "x>y": performTest(stack[0].real > stack[1].real); return
        case "x<y": performTest(stack[0].real < stack[1].real); return
        case "x<=y": performTest(stack[0].real <= stack[1].real); return
        case "x=0": performTest(stack[0].real == 0); return
        case "x!=0": performTest(stack[0].real != 0); return
        case "x>0": performTest(stack[0].real > 0); return
        case "x<0": performTest(stack[0].real < 0); return
        case "x<=0": performTest(stack[0].real <= 0); return
        case "𝑥!", "x!", "n!": 
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
        case "LASTx": commitInput(); push(lastX)
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
        case "n": commitInput(); push(CalculatorValue(real: statN))
        case "Σx": commitInput(); push(CalculatorValue(real: statSumX))
        case "Σy": commitInput(); push(CalculatorValue(real: statSumY))
        case "Σx²": commitInput(); push(CalculatorValue(real: statSumX2))
        case "Σy²": commitInput(); push(CalculatorValue(real: statSumY2))
        case "Σxy": commitInput(); push(CalculatorValue(real: statSumXY))
        case "CLΣ": clearStats()
        case "->kg": unaryOp { CalculatorValue(real: $0.real * 0.45359237) }
        case "->lb": unaryOp { CalculatorValue(real: $0.real / 0.45359237) }
        case "->°C": unaryOp { CalculatorValue(real: ($0.real - 32) * 5/9) }
        case "->°F": unaryOp { CalculatorValue(real: $0.real * 9/5 + 32) }
        case "->cm": unaryOp { CalculatorValue(real: $0.real * 2.54) }
        case "->in": unaryOp { CalculatorValue(real: $0.real / 2.54) }
        case "->l": unaryOp { CalculatorValue(real: $0.real * 3.785411784) }
        case "->gal": unaryOp { CalculatorValue(real: $0.real / 3.785411784) }
        case "->km": unaryOp { CalculatorValue(real: $0.real * 1.609344) }
        case "->mi": unaryOp { CalculatorValue(real: $0.real / 1.609344) }
        
        // Advanced Math (HP-32SII Parity)
        case "Pn,r": 
            if stack.count > 1 {
                if stack[0].real < 0 || stack[1].real < 0 || stack[0].real != floor(stack[0].real) || stack[1].real != floor(stack[1].real) { errorMessage = "INVALID DATA"; return }
            }
            binaryOp { CalculatorValue(real: tgamma($1.real + 1) / tgamma($1.real - $0.real + 1)) }
        case "Cn,r": 
            if stack.count > 1 {
                if stack[0].real < 0 || stack[1].real < 0 || stack[0].real != floor(stack[0].real) || stack[1].real != floor(stack[1].real) { errorMessage = "INVALID DATA"; return }
            }
            binaryOp { CalculatorValue(real: tgamma($1.real + 1) / (tgamma($0.real + 1) * tgamma($1.real - $0.real + 1))) }
            
        case "MOD":
            if stack.count > 0 && stack[0].real == 0 { errorMessage = "DIVIDE BY 0"; return }
            binaryOp { CalculatorValue(real: $1.real.truncatingRemainder(dividingBy: $0.real)) }
            
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
            
        case "R#": commitInput(); pushToStack(CalculatorValue(real: Double.random(in: 0..<1)))
        case "SD":
            if stack.count > 0 { srand48(Int(stack[0].real)); drop() }
        
        case "m": calculateSlope()
        case "b": calculateYIntercept()
        case "ŷ,r": calculateCorrelation()
        case "x̂": calculateLinearEstimation()
        
        case "PLOT": generatePlot()
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
        case "1/x": complexUnaryOp { CalculatorValue(real: 1.0) / $0 }
        case "√x": complexUnaryOp { CalculatorValue.sqrt($0) }
        case "x^2": complexUnaryOp { $0 * $0 }
        case "y^x": complexBinaryOp { CalculatorValue.pow($1, $0) }
        case "LN": complexUnaryOp { CalculatorValue.ln($0) }
        case "e^x": complexUnaryOp { CalculatorValue.exp($0) }
        case "LOG": complexUnaryOp { CalculatorValue.ln($0) / CalculatorValue(real: _log(10)) }
        case "10^x": complexUnaryOp { CalculatorValue.pow(CalculatorValue(real: 10), $0) }
        case "SIN": complexUnaryOp { CalculatorValue.sin($0) }
        case "COS": complexUnaryOp { CalculatorValue.cos($0) }
        case "+/-": complexUnaryOp { CalculatorValue(real: -$0.real, imag: -$0.imag) }
        default: return false
        }
        
        isBuildingNumber = false
        updateDisplay()
        return true
    }
    
    private func complexUnaryOp(_ op: (CalculatorValue) -> CalculatorValue) {
        let xr = stack.count > 0 ? stack[0].real : 0.0
        let yi = stack.count > 1 ? stack[1].real : 0.0
        
        let c = CalculatorValue(real: xr, imag: yi)
        lastX = CalculatorValue(real: xr) // naive
        
        let result = op(c)
        drop()
        drop()
        stack[0] = CalculatorValue(real: result.real)
        stack[1] = CalculatorValue(real: result.imag)
    }
    
    private func complexBinaryOp(_ op: (CalculatorValue, CalculatorValue) -> CalculatorValue) {
        let x1r = stack.count > 0 ? stack[0].real : 0.0
        let y1i = stack.count > 1 ? stack[1].real : 0.0
        let z2r = stack.count > 2 ? stack[2].real : 0.0
        let t2i = stack.count > 3 ? stack[3].real : 0.0
        
        let c1 = CalculatorValue(real: x1r, imag: y1i)
        let c2 = CalculatorValue(real: z2r, imag: t2i)
        
        lastX = CalculatorValue(real: x1r)
        
        let result = op(c2, c1)
        
        drop()
        drop()
        drop()
        drop()
        stack[0] = CalculatorValue(real: result.real)
        stack[1] = CalculatorValue(real: result.imag)
        
        if stack.count < 4 {
            for _ in 0..<(4 - stack.count) {
                stack.append(CalculatorValue())
            }
        }
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
            
            let steps = 100
            let stepSize = (xmax - xmin) / Double(steps)
            
            for i in 0...steps {
                let x = xmin + Double(i) * stepSize
                var vars = variables
                vars[variable] = CalculatorValue(real: x)
                
                let prog: Program?
                if let label = currentProgramLabel.isEmpty ? nil : currentProgramLabel,
                   let p = programs.first(where: { $0.label == label }) {
                    prog = p
                } else if let firstProgram = programs.first {
                    prog = firstProgram
                } else {
                    prog = nil
                }
                
                if let program = prog {
                    if let result = self.evaluateProgram(program, variables: vars) {
                        plotData.append((x, result.real))
                    }
                } else {
                    // Demo fallback: Normal PDF
                    let y = (1.0 / sqrt(2.0 * Double.pi)) * exp(-pow(x, 2) / 2.0)
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
        let savedInput = self.currentInput
        let savedIsBuildingNum = self.isBuildingNumber
        let savedShift = self.shiftState
        let savedLiftEnabled = self.stackLiftEnabled
        
        self.isProgrammingMode = false
        self.isEquationMode = false
        self.isBuildingNumber = false
        self.stackLiftEnabled = true
        
        // Clear stack for the program
        self.stack.removeAll()
        
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
                }
                self.currentInput = step
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
        self.currentInput = savedInput
        self.isBuildingNumber = savedIsBuildingNum
        self.shiftState = savedShift
        self.stackLiftEnabled = savedLiftEnabled
        
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
    }
    
    // MARK: - Statistics
    
    private func addStat() {
        let x = stack.count > 0 ? stack[0].real : 0.0
        let y = stack.count > 1 ? stack[1].real : 0.0
        lastX = stack.count > 0 ? stack[0] : CalculatorValue()
        statN += 1
        statSumX += x
        statSumX2 += x * x
        statSumY += y
        statSumY2 += y * y
        statSumXY += x * y
        statPoints.append(StatPoint(x: x, y: y))
        stack[0] = CalculatorValue(real: statN)
    }
    
    private func removeStat() {
        let x = stack.count > 0 ? stack[0].real : 0.0
        let y = stack.count > 1 ? stack[1].real : 0.0
        lastX = stack.count > 0 ? stack[0] : CalculatorValue()
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
    
    public func startSto() {
        commitInput()
        isWaitingForAlpha = true
        alphaAction = .sto
        
        if isProgrammingMode {
            let stepNum = currentProgramSteps.count + 1
            let paddedStep = stepNum < 10 ? "0\(stepNum)" : "\(stepNum)"
            promptString = "\(paddedStep) STO"
        } else {
            promptString = "STO"
        }
        updateDisplay()
    }
    
    public func startRcl() {
        commitInput()
        isWaitingForAlpha = true
        alphaAction = .rcl
        
        if isProgrammingMode {
            let stepNum = currentProgramSteps.count + 1
            let paddedStep = stepNum < 10 ? "0\(stepNum)" : "\(stepNum)"
            promptString = "\(paddedStep) RCL"
        } else {
            promptString = "RCL"
        }
        updateDisplay()
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
                let knownCommands: Set<String> = ["SETUP", "DISP", "MODES", "STAT", "FN=", "EQN", "PRGM", "SOLVE", "∫", "SHOW", "PLOT", "VIEW", "CLEAR", "ENTER", "BACKSPACE", "+", "-", "×", "÷", ".", "SIN", "COS", "TAN", "ASIN", "ACOS", "ATAN", "LOG", "LN", "ABS", "INTG", "FRAC", "RND", "LASTx", "x<>y", "𝑥><𝑦", "R↓", "R↑", "y^x", "xVy", "1/x", "x!", "√x", "x^2", "e^x", "10^x", "%", "%CHG", "π", "LBL", "GTO", "XEQ", "RTN", "STO", "RCL", "MEM", "PROB", "PARTS", "SUMS", "BASE", "FLAGS", "CMPLX", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "SD", "x?0", "x?y", "INT÷", "AND", "OR", "XOR", "NOT"]
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
            } else if alphaAction == .rcl {
                currentProgramSteps.append("RCL \(initialChar)")
            } else if alphaAction == .evalEquation {
                currentProgramSteps.append("XEQ \(initialChar)")
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
        } else if alphaAction == .rcl {
            let val = variables[initialChar] ?? CalculatorValue()
            pushToStack(val)
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
            for i in 0..<(stackSizeLimit - 1) { stack[i] = stack[i+1] }
            stack[stackSizeLimit - 1] = CalculatorValue()
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
            case .hex: return String(intVal, radix: 16, uppercase: true)
            case .oct: return String(intVal, radix: 8)
            case .bin: return String(intVal, radix: 2)
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
    
    public func updateDisplay() {
        if isSilent { return }
        
        if isEquationMode {
            promptString = currentEquation.isEmpty ? "EQN=" : currentEquation
            displayX = promptString!
            return
        }
        if isProgrammingMode {
            displayX = promptString ?? "00 LBL \(currentProgramLabel)"
            return
        }
        
        while stack.count < stackSizeLimit {
            stack.append(CalculatorValue())
        }
        if !isBuildingNumber {
            if stack[0].isComplex {
                displayX = "\(formatNumber(stack[0].real)) + \(formatNumber(stack[0].imag))i"
            } else {
                displayX = formatNumber(stack[0].real)
            }
        }
        updateStackStrings()
    }
    
    private func updateStackStrings() {
        let logicalStack = getLogicalStack()
        stackStrings = logicalStack.map { $0.isComplex ? "\(formatNumber($0.real)) + \(formatNumber($0.imag))i" : formatNumber($0.real) }
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

    public func solve(for variable: String, program: Program) -> Double? {
        let maxIterations = 100
        let tolerance = 1e-7
        var x0 = variables[variable]?.real ?? 0.0
        var x1 = x0 + 0.1
        var vars = variables
        
        vars[variable] = CalculatorValue(real: x0)
        var f0 = evaluateProgram(program, variables: vars)?.real ?? 0.0
        
        vars[variable] = CalculatorValue(real: x1)
        var f1 = evaluateProgram(program, variables: vars)?.real ?? 0.0
        
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
            f1 = evaluateProgram(program, variables: vars)?.real ?? 0.0
        }
        
        return nil
    }
}
