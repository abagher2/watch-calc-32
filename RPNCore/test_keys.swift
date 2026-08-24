import Foundation
@testable import RPNCore

let engine = CalculatorEngine()
let controller = RetroUIController(engine: engine)

for key in HP32KeyMap.standardGrid {
    print("Testing key: \(key.label) at row \(key.row), col \(key.col)")
    
    if let primary = key.primaryAction {
        print("  Primary: \(primary)")
        engine.shiftState = 0
        controller.processAction(primary)
        controller.processAction(.clear)
    }
    
    if let yellow = key.yellowAction {
        print("  Yellow: \(yellow)")
        engine.shiftState = 0
        controller.processAction(.shiftYellow)
        if let primary = key.primaryAction {
            controller.processAction(primary)
        }
        controller.processAction(.clear)
    }
    
    if let blue = key.blueAction {
        print("  Blue: \(blue)")
        engine.shiftState = 0
        controller.processAction(.shiftBlue)
        if let primary = key.primaryAction {
            controller.processAction(primary)
        }
        controller.processAction(.clear)
    }
}
print("Done!")
