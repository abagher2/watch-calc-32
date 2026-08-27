import Foundation
@testable import RPNCore
let engine = CalculatorEngine()
engine.executeMath("PRGM")
engine.executeMath("LBL")
engine.submitAlpha("N")
engine.executeMath("RCL")
engine.submitAlpha("X")
engine.executeMath("RCL")
engine.submitAlpha("M")
print(engine.programs.first?.steps.map { $0.stringValue } ?? [])
