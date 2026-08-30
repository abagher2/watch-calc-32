    public var currentEquationIndex: Int = 0
    
    public func scrollUp() {
        if isEquationEditMode {
            if currentEquationStepIndex > 0 {
                currentEquationStepIndex -= 1
                updateEquationDisplay()
            }
        } else if isEquationMode {
            if !equations.isEmpty {
                currentEquationIndex = max(0, currentEquationIndex - 1)
                currentEquation = equations[currentEquationIndex].steps.joined(separator: " ")
                updateDisplay()
            }
        }
    }
    
    public func scrollDown() {
        if isEquationEditMode {
            if currentEquationStepIndex < currentEquationSteps.count {
                currentEquationStepIndex += 1
                updateEquationDisplay()
            }
        } else if isEquationMode {
            if !equations.isEmpty {
                currentEquationIndex = min(equations.count - 1, currentEquationIndex + 1)
                currentEquation = equations[currentEquationIndex].steps.joined(separator: " ")
                updateDisplay()
            }
        }
    }
