#if !hasFeature(Embedded)

import Foundation

public class RetroUIController {

    public let engine: CalculatorEngine
    public let lfuManager: LFUManager
    public let renderer: Renderer
    public let retroUI: RetroUI
    
    public var menuItemsDisplayCache: [MenuItem] = []
    
    public init(engine: CalculatorEngine = CalculatorEngine(), lfuManager: LFUManager = LFUManager()) {
        self.engine = engine
        self.lfuManager = lfuManager
        self.renderer = Renderer()
        self.retroUI = RetroUI(lfuManager: lfuManager)
    }
    
    public func processAction(_ op: CalculatorOperation) {
        let finalOp = op
        
        // HP-32SII Error Message Reset Handling:
        // When an error is displayed, pressing any key clears the error message
        // and restores the normal display without executing the key.
        if engine.errorMessage != nil {
            engine.clearError()
            render()
            return
        }
        
        if engine.isTestMode {
            if finalOp == .c || finalOp == .clear || finalOp == .backspace {
                engine.isTestMode = false
            }
            return
        }
        
        if engine.requestPlot {
            if finalOp == .c || finalOp == .clear || finalOp == .backspace {
                engine.requestPlot = false
                engine.selectedPlotMarkerIndex = nil
                return
            }
            if finalOp == .lfu0 || finalOp.stringValue == "LFU_0" { engine.selectedPlotMarkerIndex = 0; return }
            if finalOp == .lfu1 || finalOp.stringValue == "LFU_1" { engine.selectedPlotMarkerIndex = 1; return }
            if finalOp == .lfu2 || finalOp.stringValue == "LFU_2" { engine.selectedPlotMarkerIndex = 2; return }
            if finalOp == .lfu3 || finalOp.stringValue == "LFU_3" { engine.selectedPlotMarkerIndex = 3; return }
            if finalOp == .lfu4 || finalOp.stringValue == "LFU_4" { engine.selectedPlotMarkerIndex = 4; return }
            if finalOp == .lfu5 || finalOp.stringValue == "LFU_5" { engine.selectedPlotMarkerIndex = 5; return }
        }
        
        if finalOp == .show {

            retroUI.isShowingFullPrecision = true
            return
        }
        
        if retroUI.isShowingFullPrecision {
            if finalOp == .c || finalOp == .clear || finalOp == .backspace {
                retroUI.isShowingFullPrecision = false
            }
            return
        }

        if retroUI.isShowingRegisters {
            if engine.shiftState == 1 && finalOp == .digit8 { // Up arrow
                retroUI.regsOffset = max(0, retroUI.regsOffset - 1)
                engine.shiftState = 0
                return
            }
            if engine.shiftState == 1 && finalOp == .digit7 { // Down arrow
                retroUI.regsOffset += 1
                engine.shiftState = 0
                return
            }
            if finalOp == .c || finalOp == .clear || finalOp == .backspace || finalOp == .enter {
                retroUI.isShowingRegisters = false
                return
            }
            retroUI.isShowingRegisters = false
        }
        
        if engine.isProgrammingMode || engine.isEquationMode {
            if engine.shiftState == 1 && finalOp == .digit8 { // Up arrow
                retroUI.programScrollOffset += 1
                engine.shiftState = 0
                return
            }
            if engine.shiftState == 1 && finalOp == .digit7 { // Down arrow
                retroUI.programScrollOffset = max(0, retroUI.programScrollOffset - 1)
                engine.shiftState = 0
                return
            }
        }
        
        if finalOp == .regs {
            retroUI.isShowingRegisters = true
            retroUI.regsOffset = 0
            retroUI.activeMenu = nil
            return
        }
        
        // C47 Modes
        if finalOp == .solve || finalOp == .integrate || finalOp == .plot || finalOp == .xeq {
            if finalOp == .solve { retroUI.c47Mode = .solve }
            if finalOp == .integrate { retroUI.c47Mode = .integrate }
            if finalOp == .plot { retroUI.c47Mode = .plot }
            if finalOp == .xeq { retroUI.c47Mode = .xeq }
            retroUI.c47Program = nil
            retroUI.activeMenu = nil
            return
        }
        
        if retroUI.c47Mode != .none {
            if finalOp == .c || finalOp == .clear || finalOp == .backspace {
                retroUI.c47Mode = .none
                retroUI.c47Program = nil
                return
            }
            
            if finalOp.stringValue.hasPrefix("C47_PRG_") {
                let progLabel = String(finalOp.stringValue.dropFirst(8))
                retroUI.c47Program = engine.programs.first(where: { $0.label == progLabel })
                return
            }
            
            if finalOp.stringValue.hasPrefix("C47_VAR_") {
                let varName = String(finalOp.stringValue.dropFirst(8))
                if engine.isBuildingNumber {
                    engine.commitInput()
                    engine.variables[varName] = engine.stack.first ?? CalculatorValue()
                } else {
                    if retroUI.c47Mode == .solve, let prog = retroUI.c47Program {
                        let target = engine.stack.first?.real ?? 0.0
                        engine.statusMessage = "CALCULATING"
                        _ = engine.solve(for: varName, program: prog, target: target)
                        engine.statusMessage = nil
                        retroUI.c47Mode = .none
                        retroUI.c47Program = nil
                    } else if retroUI.c47Mode == .integrate, let prog = retroUI.c47Program {
                        let upper = engine.stack.count > 0 ? engine.stack[0].real : 0.0
                        let lower = engine.stack.count > 1 ? engine.stack[1].real : 0.0
                        engine.statusMessage = "CALCULATING"
                        _ = engine.integrate(variable: varName, lower: lower, upper: upper, program: prog)
                        engine.statusMessage = nil
                        retroUI.c47Mode = .none
                        retroUI.c47Program = nil
                    }
                }
                return
            }
            
            if finalOp.stringValue == "C47_EXEC" {
                if retroUI.c47Mode == .plot {
                    engine.generatePlot(variable: "X", explicitMin: -10, explicitMax: 10)
                    engine.requestPlot = true
                } else if retroUI.c47Mode == .xeq, let prog = retroUI.c47Program {
                    engine.currentProgramLabel = prog.label
                    _ = engine.evaluateProgram(prog, variables: engine.variables)
                }
                retroUI.c47Mode = .none
                retroUI.c47Program = nil
                return
            }
        }
        
        if finalOp == .shiftYellow {
            engine.setShift(1)
            return
        }
        if finalOp == .shiftBlue {
            engine.setShift(2)
            return
        }
        
        if engine.shiftState > 0 {
            engine.setShift(0)
        }

        
        if engine.isWaitingForAlpha {
            if finalOp == .backspace || finalOp == .clear || finalOp == .c {
                engine.submitAlpha("<-")
            } else if finalOp == .enter {
                engine.submitAlpha("ENTER")
            } else if let alpha = finalOp.alphaLabel ?? (finalOp.stringValue.count == 1 ? finalOp.stringValue : nil) {
                if let menu = retroUI.activeMenu {
                    retroUI.menuAlphaQuery.append(alpha)
                    menuItemsDisplayCache = MenuSystem.filter(menu: menu, query: retroUI.menuAlphaQuery)
                } else {
                    engine.submitAlpha(alpha)
                    lfuManager.recordUsage(of: alpha)
                }
            }
            return
        }
        
        if let pendingItem = retroUI.waitingForMenuDigit {
            if let digit = Int(finalOp.stringValue) {
                engine.executeMath("\(pendingItem.action) \(digit)")
            }
            retroUI.waitingForMenuDigit = nil
            retroUI.activeMenu = nil
            return
        }
        
        if let menu = retroUI.activeMenu {
            let items = MenuSystem.filter(menu: menu, query: retroUI.menuAlphaQuery)
            
            if finalOp.stringValue.hasPrefix("LFU_") {
                let index = Int(String(finalOp.stringValue.dropFirst(4))) ?? 0
                
                // Check for MORE button
                if index == 5 && items.count - retroUI.menuOffset > 6 {
                    retroUI.menuOffset += 5
                    return
                }
                
                // Adjust index based on spacing mapping
                let visibleCount = items.count - retroUI.menuOffset
                let isMore = visibleCount > 6
                var actualIndex = index
                if !isMore {
                    let count = visibleCount
                    if count == 4 {
                        if index == 0 || index == 1 { actualIndex = index }
                        else if index == 4 { actualIndex = 2 }
                        else if index == 5 { actualIndex = 3 }
                        else { return }
                    } else if count == 5 {
                        if index == 0 || index == 1 || index == 2 { actualIndex = index }
                        else if index == 4 { actualIndex = 3 }
                        else if index == 5 { actualIndex = 4 }
                        else { return }
                    }
                }
                actualIndex += retroUI.menuOffset
                
                if actualIndex < items.count {
                    let selected = items[actualIndex]
                    if selected.requiresDigit {
                        retroUI.waitingForMenuDigit = selected
                        retroUI.activeMenu = nil
                    } else {
                        if selected.action == "REGS" {
                            retroUI.isShowingRegisters = true
                            retroUI.regsOffset = 0
                        } else {
                            engine.executeMath(selected.action)
                            lfuManager.recordUsage(of: selected.action)
                        }
                        retroUI.activeMenu = nil
                    }
                }
                return
            }
            
            if finalOp == .backspace || finalOp == .clear || finalOp == .c {
                if !retroUI.menuAlphaQuery.isEmpty {
                    retroUI.menuAlphaQuery.removeLast()
                } else {
                    retroUI.activeMenu = nil
                }
                return
            }
        }

        
        if let newMenu = CalculatorMenu(rawValue: finalOp.stringValue) {
            retroUI.activeMenu = newMenu
            retroUI.menuAlphaQuery = ""
            retroUI.menuOffset = 0
            menuItemsDisplayCache = newMenu.items
        }
        else if finalOp.stringValue.hasPrefix("LFU_") {
            let index = Int(String(finalOp.stringValue.dropFirst(4))) ?? 0
            if let funcName = lfuManager.slots[index] {
                engine.executeMath(funcName)
                lfuManager.recordUsage(of: funcName)
            }
        }
        else {
            if finalOp.stringValue.count == 1, let digit = Int(finalOp.stringValue) {
                engine.digit(digit)
            } else if finalOp == .e {
                engine.startExponent()
            } else if finalOp == .decimal {
                engine.decimal()
            } else if finalOp == .toggleSign {
                engine.toggleSign()
            } else if finalOp == .enter {
                engine.enter()
            } else if finalOp == .regs {
                retroUI.isShowingRegisters = true
                retroUI.regsOffset = 0
            } else if finalOp == .backspace {
                engine.backspace()
            } else if finalOp == .clear || finalOp == .c {
                engine.executeMath(finalOp.stringValue)
            } else {
                engine.executeMath(finalOp.stringValue)
                lfuManager.recordUsage(of: finalOp.stringValue)
            }
        }
    }
    
    public func render() {
        retroUI.doubleFormatter = { [weak engine] val, mode in
            return engine?.formatNumber(val) ?? "\(val)"
        }
        renderer.clear()
        retroUI.render(engine: engine, renderer: renderer)
    }
}
#endif
