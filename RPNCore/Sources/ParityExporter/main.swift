import Foundation
import RPNCore

let engine = CalculatorEngine()
let c = RetroUIController(engine: engine)

print("--- Initial ---")
print("Active Menu: \(String(describing: engine.activeMenu))")

print("\n--- Press PLOT ---")
c.processAction(.plot)
let _ = c.render()
print("Active Menu: \(String(describing: engine.activeMenu))")
print("Annunciators: \(engine.activeAnnunciators)")
print("ErrorMessage: \(String(describing: engine.errorMessage))")
