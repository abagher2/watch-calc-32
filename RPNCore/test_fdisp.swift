import Foundation
@testable import RPNCore

let engine = CalculatorEngine()
let controller = RetroUIController(engine: engine)

engine.executeMath("5")
engine.executeMath(".")
engine.executeMath("2")
engine.executeMath("5")
engine.executeMath("ENTER")

print("Value: \(engine.getFormattedValue())")
controller.processAction(.fdisp)
print("FDISP value: \(engine.getFormattedValue())")

controller.processAction(.slashc)
print("After /c: \(engine.getFormattedValue())")

