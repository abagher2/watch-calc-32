import Foundation

@testable import RPNCore

let engine = CalculatorEngine()
engine.isEquationEditMode = true
engine.equations.append(CalculatorEngine.Equation(label: "X", steps: ["STO A", "RCL B"]))
engine.isEquationEditMode = false

let controller = RetroUIController(engine: engine)
controller.processAction(.solve)
controller.processAction(.lfu0)
print(controller.retroUI.softkeyProgram?.label ?? "nil")
