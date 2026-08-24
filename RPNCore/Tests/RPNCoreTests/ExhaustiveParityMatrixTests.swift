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
            XCTAssertEqual(controller.retroUI.activeMenu, menu, "Failed to open menu \(menu.rawValue)")
            
            // Assert display rendering
            controller.render()
            XCTAssertFalse(controller.renderer.buffer.allSatisfy { $0 == 0 })
            
            // Test softkeys for the menu
            let items = menu.items
            for (i, item) in items.enumerated() {
                if i >= 6 { break } // Only test first page for simplicity in matrix
                let lfuOp = CalculatorOperation.lfu(index: i)
                controller.processAction(lfuOp)
                
                if item.requiresDigit {
                    XCTAssertEqual(controller.retroUI.waitingForMenuDigit, item, "Menu item \(item.label) failed to wait for digit")
                    controller.processAction(.digit5)
                }
                
                // Active menu should be closed after selection
                XCTAssertNil(controller.retroUI.activeMenu, "Menu \(menu.rawValue) did not close after selecting \(item.label)")
                
                // Reset for next item
                controller.processAction(.clear)
                controller.processAction(op)
            }
        }
    }
    
    func testFNEquationMenuPaginationAndAlpha() {
        let engine = CalculatorEngine()
        let controller = RetroUIController(engine: engine)
        
        // Populate 10 equations
        for i in 0..<10 {
            engine.isProgrammingMode = true
            engine.currentProgramLabel = "A\(i)"
            engine.programs.append(CalculatorEngine.Program(label: "A\(i)", steps: ["1", "+", "2"]))
        }
        engine.isProgrammingMode = false
        
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
        
        XCTAssertEqual(engine.currentEvaluatingProgram?.label, "A5")
        XCTAssertEqual(engine.currentProgramLabel, "A5")
        XCTAssertFalse(engine.isWaitingForAlpha)
        XCTAssertEqual(engine.alphaAction, .none)
    }
    
    func testAdvancedC47Modes() {
        let modes: [(op: CalculatorOperation, mode: RetroUI.C47Mode)] = [
            (.solve, .solve),
            (.integrate, .integrate),
            (.plot, .plot),
            (.xeq, .xeq)
        ]
        
        for config in modes {
            let engine = CalculatorEngine()
            let controller = RetroUIController(engine: engine)
            
            controller.processAction(config.op)
            XCTAssertEqual(controller.retroUI.c47Mode, config.mode)
            
            // Create a dummy program
            engine.isProgrammingMode = true
            engine.programs.append(CalculatorEngine.Program(label: "X", steps: ["STO A", "RCL B"]))
            engine.isProgrammingMode = false
            
            // Simulate LFU press for Program X (which is the first one, index 0)
            let lfu0 = CalculatorOperation.lfu0
            controller.processAction(lfu0) // Selects C47_PRG_X
            
            XCTAssertEqual(controller.retroUI.c47Program?.label, "X")
            
            // Now the menu should show variables A and B
            // LFU 0 should be @A or  A, LFU 1 should be @B or  B
            controller.processAction(lfu0) // Selects A
            
            if config.mode == .solve || config.mode == .integrate {
                XCTAssertEqual(controller.retroUI.c47Mode, .none, "Mode should exit after calculating")
            } else {
                XCTAssertEqual(controller.retroUI.c47SelectedVar, "A")
            }
        }
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
