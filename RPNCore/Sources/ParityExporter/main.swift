import Foundation
import RPNCore

let saveDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "/tmp"
print("Saving buffers to \(saveDir)")

let engine = CalculatorEngine()
let c = RetroUIController(engine: engine)

func saveBuffer(name: String) {
    let _ = c.render()
    let hex = c.renderer.buffer.map { String(format: "%02x", $0) }.joined()
    let url = URL(fileURLWithPath: saveDir).appendingPathComponent(name + ".txt")
    try! hex.write(to: url, atomically: true, encoding: .utf8)
    print("Saved \(name)")
}

func clear_all() {
    c.engine.clearAll()
    c.engine.activeMenu = nil
}

// 1. Complex Equation
clear_all()
c.processAction(.eqn) // EQN
c.processAction(.sin); c.processAction(.digit1); c.processAction(.add)
c.processAction(.exp); c.processAction(.enter)
saveBuffer(name: "parity_complex_eqn")

// 2. Multi-line Scroll
clear_all()
c.processAction(.eqn) // EQN
c.processAction(.sqrt); c.processAction(.add); c.processAction(.exp); c.processAction(.add)
c.processAction(.digit1); c.processAction(.add); c.processAction(.digit2); c.processAction(.add); c.processAction(.digit3)
saveBuffer(name: "parity_multiline_1")
c.processAction(.shiftYellow); c.processAction(.digit8) // UP ARROW
saveBuffer(name: "parity_multiline_2")

// 3. Base Modes
clear_all()
c.processAction(.digit1); c.processAction(.digit2); c.processAction(.enter)
c.processAction(.base) // BASE
c.processAction(.lfu0) // HEX
saveBuffer(name: "parity_base_mode")
c.processAction(.base) // BASE
c.processAction(.lfu1) // DEC

// 4. Softkey LFU
clear_all()
c.processAction(.const) // CNST
saveBuffer(name: "parity_softkey_1")
c.processAction(.lfu5) // MORE
saveBuffer(name: "parity_softkey_2")
c.processAction(.c)

// 5. Scientific
clear_all()
c.processAction(.disp) // DISP
c.processAction(.lfu1) // SCI
c.processAction(.digit4)
c.processAction(.digit1); c.processAction(.decimal); c.processAction(.digit2); c.processAction(.digit3)
c.processAction(.e); c.processAction(.digit5)
c.processAction(.enter)
saveBuffer(name: "parity_scientific")

// 6. Math Symbols
clear_all()
c.engine.isEquationMode = true
c.engine.currentEquation = "∫(√(X)+e^(Y)+1/X)"
c.engine.updateDisplay()
saveBuffer(name: "parity_math_symbols")
