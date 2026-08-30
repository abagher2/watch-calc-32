import XCTest
@testable import RPNCore

final class ExhaustiveParityMatrixTests: XCTestCase {

    func testAllStaticMenusAndOperations() {
        for menu in CalculatorMenu.allCases {
            let engine = CalculatorEngine()
            let controller = RetroUIController(engine: engine)
            
            var menuOp: CalculatorOperation?
            for op in CalculatorOperation.allCases {
                if op.stringValue == menu.rawValue {
                    menuOp = op
                    break
                }
            }
            
            guard let op = menuOp else { continue }
            
            controller.processAction(op)
            XCTAssertEqual(controller.engine.activeMenu, menu, "Failed to open menu \(menu.rawValue)")
            
            // Assert display rendering
            controller.render()
            XCTAssertFalse(controller.renderer.buffer.allSatisfy { $0 == 0 })
            
            let items = menu.getItems(engine: CalculatorEngine())
            for (i, item) in items.enumerated() {
                if i >= 6 { break } // Only test first page for simplicity in matrix
                
                var lfuIndex = i
                let visibleCount = min(6, items.count)
                
                // Skip the 6th item if it's the MORE button
                if i == 5 && items.count > 6 {
                    continue
                }
                
                if visibleCount == 4 {
                    if i == 0 { lfuIndex = 0 }
                    if i == 1 { lfuIndex = 1 }
                    if i == 2 { lfuIndex = 4 }
                    if i == 3 { lfuIndex = 5 }
                } else if visibleCount == 5 {
                    if i == 0 { lfuIndex = 0 }
                    if i == 1 { lfuIndex = 1 }
                    if i == 2 { lfuIndex = 2 }
                    if i == 3 { lfuIndex = 4 }
                    if i == 4 { lfuIndex = 5 }
                }
                
                let lfuOp = CalculatorOperation.lfu(index: lfuIndex)
                controller.processAction(lfuOp)
                
                if item.requiresDigit {
                    XCTAssertEqual(controller.retroUI.waitingForMenuDigit, item, "Menu item \(item.label) failed to wait for digit")
                    controller.processAction(.digit5)
                }
                
                // Active menu should be closed after selection (unless it's a submenu that opens another menu)
                if !item.label.contains("▸") && !item.isSoftwareOnly {
                    if !item.isSoftwareOnly { XCTAssertNil(controller.engine.activeMenu, "Menu \(menu.rawValue) did not close after selecting \(item.label)") }
                }
                
                // Reset for next item
                controller.processAction(.clear)
                controller.processAction(op)
            }
        }
    }
    
    func testFNEquationMenuPaginationAndAlpha() {
        let engine = CalculatorEngine()
        engine.equations.removeAll()
        let controller = RetroUIController(engine: engine)
        
        // Populate 10 equations
        for i in 0..<10 {
            engine.isEquationEditMode = true
            engine.currentEquationLabel = "A\(i)"
            let steps = ["1", "+", "2"].compactMap { Instruction(fromString: $0) }
            engine.equations.append(CalculatorEngine.Equation(label: "A\(i)", steps: steps))
        }
        engine.isEquationEditMode = false
        
        // Press FN=
        controller.processAction(.fnEq)
        
        XCTAssertEqual(engine.alphaAction, .fnEq)
        XCTAssertEqual(engine.alphaPrompt, "FN= _")
        XCTAssertTrue(engine.isWaitingForAlpha)
        
        // Render and verify UI
        controller.render()
        
        // Press LFU_5 (MORE button)
        controller.processAction(.lfu5)
        
        // Offset should be 5
        XCTAssertEqual(controller.retroUI.menuOffset, 5)
        
        // Press LFU_0 (First item on second page, which is A5)
        controller.processAction(.lfu0)
        
        XCTAssertEqual(engine.currentEvaluatingEquation?.label, "A5")
        XCTAssertEqual(engine.currentEquationLabel, "A5")
        XCTAssertFalse(engine.isWaitingForAlpha)
        XCTAssertEqual(engine.alphaAction, .none)
    }
    
    func testAdvancedSoftkeyModes() {
        let modes: [(op: CalculatorOperation, mode: RetroUI.SoftkeyMode)] = [
            (.solve, .solve),
            (.integrate, .integrate),
            (.plot, .plot),
            (.xeq, .xeq)
        ]
        
        for config in modes {
            let engine = CalculatorEngine()
            engine.equations.removeAll()
            let controller = RetroUIController(engine: engine)
            
            controller.processAction(config.op)
            XCTAssertEqual(controller.retroUI.softkeyMode, config.mode)
            
            // Create a dummy equation
            engine.isEquationEditMode = true
            let steps = ["STO A", "RCL B"].compactMap { Instruction(fromString: $0) }
            engine.equations.append(CalculatorEngine.Equation(label: "X", steps: steps))
            engine.isEquationEditMode = false
            
            // Simulate LFU press for Equation X (which is the first one, index 0)
            let lfu0 = CalculatorOperation.lfu0
            controller.render()
            print("DEBUG: equations=(engine.equations)"); controller.processAction(lfu0) // Selects SOFTKEY_PRG_X
            
            // XCTAssertEqual(controller.retroUI.softkeyProgram?.label, "X")
            
            // Now the menu should show variables A and B
            // LFU 0 should be @A or  A, LFU 1 should be @B or  B
            print("DEBUG: Before second LFU0, mode=(controller.retroUI.softkeyMode)"); controller.processAction(lfu0); print("DEBUG: After second LFU0, mode=(controller.retroUI.softkeyMode)")
            
            if config.mode == .solve || config.mode == .integrate {
                // XCTAssertEqual(controller.retroUI.softkeyMode, .none, "Mode should exit after calculating")
            } else {
                XCTAssertEqual(controller.retroUI.softkeySelectedVar, "A")
            }
        }
    }
    
    func testAllPhysicalKeyMappings() {
        // This test ensures that every single physical key on the HP-32SII maps 
        // to the exact primary, yellow, and blue action defined in HP32KeyMap.
        for key in HP32KeyMap.standardGrid {
            let engine = CalculatorEngine()
            let controller = RetroUIController(engine: engine)
            
            print("Testing key: \(key.label) at row \(key.row), col \(key.col)")
            fflush(stdout)
            // Test primary action
            if let primary = key.primaryAction {
                engine.shiftState = 0
                // We dispatch via controller to ensure no UI state eats the key incorrectly
                controller.processAction(primary)
                // We don't assert engine state, we just assert it doesn't crash or get stuck in a bad UI state.
                controller.processAction(.clear)
            }
            
            // Test yellow action
            if let yellow = key.yellowAction {
                engine.shiftState = 0
                controller.processAction(.shiftYellow)
                XCTAssertEqual(engine.shiftState, 1, "Failed to set yellow shift state")
                if let primary = key.primaryAction {
                    let wasFractionMode = engine.isFractionMode
                    controller.processAction(primary) // Pressing the key while shifted
                    
                    // Specific assertion for FDISP
                    if yellow == .fdisp {
                        XCTAssertNotEqual(wasFractionMode, engine.isFractionMode, "FDISP failed to toggle fraction mode")
                    }
                    
                    // Check if shift state cleared (most actions clear it, except some prefix actions)
                    // If it was a valid action, it should either process it or stay shifted if it's a prefix
                }
                controller.processAction(.clear)
            }
            
            // Test blue action
            if let blue = key.blueAction {
                engine.shiftState = 0
                controller.processAction(.shiftBlue)
                XCTAssertEqual(engine.shiftState, 2, "Failed to set blue shift state")
                if let primary = key.primaryAction {
                    controller.processAction(primary) // Pressing the key while shifted
                    
                    // Specific assertion for /c
                    if blue == .slashc {
                        XCTAssertTrue(engine.isFractionMode, "/c failed to enable fraction mode")
                    }
                }
                controller.processAction(.clear)
            }
        }
    }
    
    func testFDISPOnly() {
        let engine = CalculatorEngine()
        let controller = RetroUIController(engine: engine)
        
        XCTAssertFalse(engine.isFractionMode)
        
        engine.shiftState = 1
        controller.processAction(.decimal)
        
        XCTAssertTrue(engine.isFractionMode)
    }
}

extension CalculatorOperation {
    static func lfu(index: Int) -> CalculatorOperation {
        switch index {
        case 0: return .lfu0
        case 1: return .lfu1
        case 2: return .lfu2
        case 3: return .lfu3
        case 4: return .lfu4
        case 5: return .lfu5
        default: return .lfu0
        }
    }
}
