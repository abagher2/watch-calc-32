    public var currentEquationIndex: Int = 0
    
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
