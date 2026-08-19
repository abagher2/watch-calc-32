import Foundation

struct CalculatorValue { var real = 0.0; var imag = 0.0; var isComplex = false }

var stack = [CalculatorValue(), CalculatorValue(), CalculatorValue(), CalculatorValue()]
var isBuildingNumber = false
var stackLiftEnabled = true
var currentInput = ""
var displayX = "0"
var stackStrings = [String]()

func formatNumber(_ d: Double) -> String { return "\(d)" }

func updateStackStrings() {
    var logicalStack = stack
    if isBuildingNumber, let value = Double(displayX) {
        if !stackLiftEnabled && !logicalStack.isEmpty {
            logicalStack[0] = CalculatorValue(real: value)
        } else {
            logicalStack.insert(CalculatorValue(real: value), at: 0)
        }
    }
    stackStrings = logicalStack.map { formatNumber($0.real) }
}

func commitInput() {
    if isBuildingNumber {
        let val = Double(currentInput) ?? 0.0
        if stack.isEmpty {
            stack.append(CalculatorValue(real: val))
        } else {
            stack[0] = CalculatorValue(real: val)
        }
        isBuildingNumber = false
    }
}

func digit(_ d: Int) {
    if !isBuildingNumber {
        if stackLiftEnabled && !stack.isEmpty {
            stack.insert(stack[0], at: 0)
        }
        isBuildingNumber = true
        currentInput = "\(d)"
    } else {
        currentInput += "\(d)"
    }
    displayX = currentInput
    updateStackStrings()
}

func enter() {
    if isBuildingNumber {
        commitInput()
        stack.insert(stack[0], at: 0)
    } else {
        if !stack.isEmpty {
            stack.insert(stack[0], at: 0)
        }
    }
    stackLiftEnabled = false
    updateStackStrings()
}

digit(1)
enter()
digit(2)
enter()
digit(3)
enter()
digit(4)
enter()
digit(5)
enter()
digit(6)
enter()
digit(7)
enter()
digit(8)

print(stackStrings)

