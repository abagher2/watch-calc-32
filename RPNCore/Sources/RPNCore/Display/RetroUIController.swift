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
            if finalOp == .integrate { // Up arrow
                retroUI.regsOffset = max(0, retroUI.regsOffset - 2)
                engine.shiftState = 0
                return
            }
            if finalOp == .solve { // Down arrow
                retroUI.regsOffset += 2
                engine.shiftState = 0
                return
            }
            if finalOp == .c || finalOp == .clear || finalOp == .backspace || finalOp == .enter {
                retroUI.isShowingRegisters = false
                return
            }
            retroUI.isShowingRegisters = false
        }
        
        // Removed unused programScrollOffset interception
        if finalOp == .regs {
            retroUI.isShowingRegisters = true
            retroUI.regsOffset = 0
            engine.activeMenu = nil
            return
        }
        
        // Advanced Modes
        if finalOp == .solve || finalOp == .integrate || finalOp == .plot || finalOp == .xeq {
            if finalOp == .solve { retroUI.softkeyMode = .solve }
            if finalOp == .integrate { retroUI.softkeyMode = .integrate }
            if finalOp == .plot { retroUI.softkeyMode = .plot }
            if finalOp == .xeq { retroUI.softkeyMode = .xeq }
            retroUI.softkeyProgram = nil
            engine.activeMenu = nil
            return
        }
        
        if retroUI.softkeyMode != .none {
            if finalOp == .c || finalOp == .clear || finalOp == .backspace {
                retroUI.softkeyMode = .none
                retroUI.softkeyProgram = nil
                return
            }
            
            var softkeyActionStr = finalOp.stringValue
            if finalOp.stringValue.hasPrefix("LFU_") {
                let suffix = String(finalOp.stringValue.dropFirst(4))
                let index = parseInteger(suffix) ?? 0
                
                var items: [MenuItem] = []
                if retroUI.softkeyProgram == nil {
                    for prog in engine.programs {
                        items.append(MenuItem(label: prog.label, action: "SOFTKEY_PRG_\(prog.label)"))
                    }
                } else {
                    let vars = retroUI.softkeyProgram!.extractVariables()
                    for v in vars.sorted() {
                        let hasVal = (engine.variables[v]?.real ?? 0.0) != 0.0
                        let label = hasVal ? "@\(v)" : " \(v)"
                        items.append(MenuItem(label: label, action: "SOFTKEY_VAR_\(v)"))
                    }
                    if retroUI.softkeyMode == .plot || retroUI.softkeyMode == .xeq {
                        items.append(MenuItem(label: "EXEC", action: "SOFTKEY_EXEC"))
                    }
                }
                
                if index < items.count {
                    softkeyActionStr = items[index].action
                }
            }
            
            if softkeyActionStr.hasPrefix("SOFTKEY_PRG_") {
                let progLabel = String(softkeyActionStr.dropFirst(12))
                retroUI.softkeyProgram = engine.programs.first(where: { $0.label == progLabel })
                return
            }
            
            if softkeyActionStr.hasPrefix("SOFTKEY_VAR_") {
                let varName = String(softkeyActionStr.dropFirst(12))
                if engine.isBuildingNumber {
                    engine.commitInput()
                    engine.variables[varName] = engine.stack.first ?? CalculatorValue()
                } else {
                    if retroUI.softkeyMode == .solve, let prog = retroUI.softkeyProgram {
                        let target = engine.stack.first?.real ?? 0.0
                        engine.statusMessage = "CALCULATING"
                        _ = engine.solve(for: varName, program: prog, target: target)
                        engine.statusMessage = nil
                        retroUI.softkeyMode = .none
                        retroUI.softkeyProgram = nil
                    } else if retroUI.softkeyMode == .integrate, let prog = retroUI.softkeyProgram {
                        let upper = engine.stack.count > 0 ? engine.stack[0].real : 0.0
                        let lower = engine.stack.count > 1 ? engine.stack[1].real : 0.0
                        engine.statusMessage = "CALCULATING"
                        _ = engine.integrate(variable: varName, lower: lower, upper: upper, program: prog)
                        engine.statusMessage = nil
                        retroUI.softkeyMode = .none
                        retroUI.softkeyProgram = nil
                    } else {
                        retroUI.softkeySelectedVar = varName
                    }
                }
                return
            }
            
            if softkeyActionStr == "SOFTKEY_EXEC" {
                if retroUI.softkeyMode == .plot {
                    engine.generatePlot(variable: retroUI.softkeySelectedVar, explicitMin: -10, explicitMax: 10)
                    engine.requestPlot = true
                } else if retroUI.softkeyMode == .xeq, let prog = retroUI.softkeyProgram {
                    engine.currentProgramLabel = prog.label
                    _ = engine.evaluateProgram(prog, variables: engine.variables)
                }
                retroUI.softkeyMode = .none
                retroUI.softkeyProgram = nil
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
            var shiftedOp = finalOp
            for key in HP32KeyMap.standardGrid {
                if key.primaryAction == op {
                    if engine.shiftState == 1, let yellow = key.yellowAction { shiftedOp = yellow }
                    else if engine.shiftState == 2, let blue = key.blueAction { shiftedOp = blue }
                    break
                }
            }
            engine.setShift(0)
            
            if shiftedOp != finalOp {
                processAction(shiftedOp)
                return
            }
        }

        
        if (engine.isEquationMode || engine.alphaAction == .fnEq), finalOp.stringValue.hasPrefix("LFU_") {
            let suffix = String(finalOp.stringValue.dropFirst(4))
            let index = parseInteger(suffix) ?? 0
            
            var items: [MenuItem] = [
                MenuItem(label: "NEW", action: "EQN_NEW")
            ]
            for prog in engine.programs {
                items.append(MenuItem(label: prog.label.isEmpty ? "EQN" : prog.label, action: "EQN_EDIT_\(prog.label)"))
            }
            
            if index == 5 && items.count - retroUI.menuOffset > 6 {
                retroUI.menuOffset += 5
                return
            }
            
            let visibleItems = Array(items.dropFirst(retroUI.menuOffset))
            if index < visibleItems.count {
                let selected = visibleItems[index]
                if selected.action == "EQN_NEW" {
                    engine.isWaitingForLabel = true
                    engine.startAlpha()
                    engine.alphaPrompt = "LBL _"
                    engine.promptString = "LBL "
                } else if selected.action.hasPrefix("EQN_EDIT_") {
                    let lbl = String(selected.action.dropFirst(9))
                    if let existing = engine.programs.first(where: { $0.label == lbl }) {
                        engine.editEquation(existing)
                    }
                } else {
                    engine.submitAlpha(selected.label)
                }
                retroUI.menuOffset = 0
            }
            return
        }
        
        if engine.isWaitingForAlpha {

            if finalOp == .backspace || finalOp == .clear || finalOp == .c {
                engine.submitAlpha("<-")
            } else if finalOp == .enter {
                engine.submitAlpha("ENTER")
            } else if let alpha = finalOp.alphaLabel ?? (finalOp.stringValue.count == 1 ? finalOp.stringValue : nil) {
                if let menu = engine.activeMenu {
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
            if let digit = parseInteger(finalOp.stringValue) {
                engine.executeMath("\(pendingItem.action) \(digit)")
            }
            retroUI.waitingForMenuDigit = nil
            engine.activeMenu = nil
            return
        }
        
        if let menu = engine.activeMenu {
            let items = MenuSystem.filter(menu: menu, query: retroUI.menuAlphaQuery)
            
            if finalOp.stringValue.hasPrefix("LFU_") {
                let suffix = String(finalOp.stringValue.dropFirst(4))
                let index = parseInteger(suffix) ?? 0
                
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
                        engine.activeMenu = nil
                        retroUI.menuOffset = 0
                    } else {
                        // Sub-menu navigation actions open a child menu rather than
                        // executing a math op. Mirrors GenericMenuPresenterView.subMenuMap.
                        let subMenuMap: [String: CalculatorMenu] = [
                            "STATMEAN":   .statMean,
                            "STATSTDDEV": .statStdDev,
                            "STATLR":     .lr,
                            "STATSUMS":   .sums,
                        ]
                        if selected.action == "REGS" {
                            retroUI.isShowingRegisters = true
                            retroUI.regsOffset = 0
                            engine.activeMenu = nil
                            retroUI.menuOffset = 0
                        } else if let subMenu = subMenuMap[selected.action] {
                            // Transition to sub-menu — stays in menu state
                            engine.activeMenu = subMenu
                            retroUI.menuAlphaQuery = ""
                            retroUI.menuOffset = 0
                            menuItemsDisplayCache = subMenu.items
                        } else {
                            engine.executeMath(selected.action)
                            lfuManager.recordUsage(of: selected.action)
                            engine.activeMenu = nil
                            retroUI.menuOffset = 0
                        }
                    }
                }
                return
            }
            
            if finalOp == .backspace || finalOp == .clear || finalOp == .c {
                if !retroUI.menuAlphaQuery.isEmpty {
                    retroUI.menuAlphaQuery.removeLast()
                    menuItemsDisplayCache = MenuSystem.filter(menu: menu, query: retroUI.menuAlphaQuery)
                } else {
                    engine.activeMenu = nil
                    retroUI.menuOffset = 0
                }
                return
            }
        }

        
        if let newMenu = CalculatorMenu(rawValue: finalOp.stringValue) {
            engine.activeMenu = newMenu
            retroUI.menuAlphaQuery = ""
            retroUI.menuOffset = 0
            menuItemsDisplayCache = newMenu.items
        }
        else if finalOp.stringValue.hasPrefix("LFU_") {
            let suffix = String(finalOp.stringValue.dropFirst(4))
            let index = parseInteger(suffix) ?? 0
            if let funcName = lfuManager.slots[index] {
                engine.executeMath(funcName)
                lfuManager.recordUsage(of: funcName)
            }
        }
        else {
            if finalOp.stringValue.count == 1, let digit = parseInteger(finalOp.stringValue) {
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
        let captureEngine = self.engine
        retroUI.doubleFormatter = { val, mode in
            return captureEngine.formatNumber(val)
        }
        renderer.clear()
        retroUI.render(engine: engine, renderer: renderer)
    }
}
