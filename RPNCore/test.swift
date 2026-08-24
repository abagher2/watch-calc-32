import Foundation

@testable import RPNCore

let engine = CalculatorEngine()
engine.isProgrammingMode = true
engine.programs.append(CalculatorEngine.Program(label: "X", steps: ["STO A", "RCL B"]))
engine.isProgrammingMode = false

let controller = RetroUIController(engine: engine)
controller.processAction(.solve)
controller.processAction(.lfu0)
print(controller.retroUI.softkeyProgram?.label ?? "nil")
