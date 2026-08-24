import Foundation
@testable import RPNCore

let engine = CalculatorEngine()
let controller = RetroUIController(engine: engine)
controller.processAction(.shiftYellow)
controller.processAction(.decimal)
print("FDISP State: \(engine.isFractionMode)")
