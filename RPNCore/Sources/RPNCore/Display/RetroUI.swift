

#if canImport(SwiftUI) && canImport(Charts)
import SwiftUI
import Charts
#endif

public class RetroUI {
    public var lfuManager: LFUManager
    public var waitingForMenuDigit: MenuItem?
    public var menuAlphaQuery: String = ""
    public var menuOffset: Int = 0
    public var isShowingFullPrecision: Bool = false
    public var isShowingRegisters: Bool = false
    public var regsOffset: Int = 0
    
    public enum SoftkeyMode { case none, solve, integrate, plot, xeq, plotOptions }
    public var softkeyMode: SoftkeyMode = .none
    public var softkeyProgram: CalculatorEngine.Program? = nil
    public var softkeySelectedVar: String = "X"
    
    public var doubleFormatter: ((Double, CalculatorEngine.DisplayMode) -> String)?
    public var plotMinXString: String = ""
    public var plotMinYString: String = ""
    public var plotMaxYString: String = ""
    public var plotMaxXString: String = ""
    public var plotCenterXString: String = ""
    
    public init(lfuManager: LFUManager) {
        self.lfuManager = lfuManager
    }
    
    public func render(engine: CalculatorEngine, renderer: Renderer) {
        // Evaluate the body content
        let screen = FirmwareVStack(alignment: .leading, spacing: 0) {
            if !engine.requestPlot {
                FirmwareFrame(width: 132, height: 11, alignment: .leading, vAlignment: .top) {
                    TopBarIndicatorsView()
                }
            }
            
            RetroUIBodyView(retroUI: self, isPlotting: engine.requestPlot)
            
            FirmwareFrame(width: 132, height: 11, alignment: .leading, vAlignment: .bottom) {
                RetroUIFooterView(retroUI: self)
            }
        }
        
        screen.draw(in: renderer, x: 0, y: 0, engine: engine)
    }
}

public struct RetroUIBodyView: FirmwareView {
    public let retroUI: RetroUI
    public var isPlotting: Bool = false
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        return (132, isPlotting ? 54 : 43)
    }
    
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        print("DEBUG: RetroUIBodyView.draw - reqPlot=\(engine.requestPlot ? 1 : 0) isEq=\(engine.isEquationListMode ? 1 : 0) err=\(engine.errorMessage != nil ? 1 : 0)")
        if let msg = engine.errorMessage ?? engine.transientMessage {
            let view = FirmwarePadding(leading: 6) {
                FirmwareText(msg, font: .medium, color: true)
            }
            view.draw(in: renderer, x: x, y: y, engine: engine)
            
        } else if retroUI.isShowingRegisters {
            let regs: [(String, Double)] = [
                ("T", engine.stack.count > 3 ? engine.stack[3].real : 0),
                ("Z", engine.stack.count > 2 ? engine.stack[2].real : 0),
                ("Y", engine.stack.count > 1 ? engine.stack[1].real : 0),
                ("X", engine.stack.count > 0 ? engine.stack[0].real : 0)
            ]
            let maxChars = 64
            var startY = y
            for (name, val) in regs {
                let valStr = retroUI.doubleFormatter?(val, engine.displayMode) ?? "\(val)"
                var i = 0
                while i < valStr.count {
                    let start = valStr.index(valStr.startIndex, offsetBy: i)
                    let end = valStr.index(start, offsetBy: min(maxChars, valStr.count - i))
                    let chunk = String(valStr[start..<end])
                    
                    let view = FirmwarePadding(leading: 6) {
                        FirmwareHStack(alignment: .bottom, spacing: 6) {
                            FirmwareText("\(name):", font: .medium, color: true)
                            FirmwareText(chunk, font: .medium, color: true)
                        }
                    }
                    view.draw(in: renderer, x: x, y: startY, engine: engine)
                    startY += 24
                    i += maxChars
                }
            }
            
        } else if engine.isBuildingNumber || engine.isWaitingForAlpha {
            print("DEBUG: MainDisplayNumberView.draw! reqPlot=\(engine.requestPlot ? 1 : 0)")
            MainDisplayNumberView().draw(in: renderer, x: x, y: y + 13, engine: engine)
            
        } else if engine.isEquationListMode {
            var startY = y
            for i in 0..<engine.programs.count {
                let prog = engine.programs[i]
                let summary = prog.steps.map { $0.stringValue }.joined(separator: " ")
                
                let view = FirmwarePadding(leading: 6) {
                    FirmwareHStack(alignment: .bottom, spacing: 6) {
                        FirmwareText(prog.label, font: .medium, color: true)
                        FirmwareText(summary.prefix(32).description, font: .small, color: true)
                    }
                }
                view.draw(in: renderer, x: x, y: startY, engine: engine)
                startY += 24
            }
            
        } else if engine.requestPlot {
#if !canImport(SwiftUI)
            let isStatPlot = engine.isStatPlot
            var dataPoints: [PlotDataPoint] = []
            dataPoints.reserveCapacity(engine.plotData.count)
            if !isStatPlot {
                for (i, pt) in engine.plotData.enumerated() {
                    dataPoints.append(PlotDataPoint(id: i, x: pt.0, y: pt.1))
                }
            }
            var scatterPoints: [PlotDataPoint] = []
            if isStatPlot {
                for (i, pt) in engine.statPoints.enumerated() {
                    scatterPoints.append(PlotDataPoint(id: i, x: pt.x, y: pt.y))
                }
            }
            var highlightedPoints: [PlotDataPoint] = []
            if let lim = engine.integrationLimits {
                for pt in engine.plotData {
                    if pt.0 >= lim.0 && pt.0 <= lim.1 {
                        highlightedPoints.append(PlotDataPoint(id: highlightedPoints.count, x: pt.0, y: pt.1))
                    }
                }
            }
            
            var tangentPoints: [PlotDataPoint]? = nil
            if let rootX = engine.selectedPlotX {
                var rootY = 0.0
                var m = 0.0
                if dataPoints.count > 1 {
                    for i in 0..<dataPoints.count-1 {
                        let p1 = dataPoints[i]
                        let p2 = dataPoints[i+1]
                        if rootX >= p1.x && rootX <= p2.x {
                            m = (p2.y - p1.y) / (p2.x - p1.x)
                            let t = (rootX - p1.x) / (p2.x - p1.x)
                            rootY = p1.y + t * (p2.y - p1.y)
                            break
                        }
                    }
                }
                
                if let first = dataPoints.first, let last = dataPoints.last {
                    let startY = m * (first.x - rootX) + rootY
                    let endY = m * (last.x - rootX) + rootY
                    tangentPoints = [
                        PlotDataPoint(id: 0, x: first.x, y: startY),
                        PlotDataPoint(id: 1, x: last.x, y: endY)
                    ]
                }
            }
            
            engine.firmwarePlotNodes.removeAll(keepingCapacity: true)
            engine.firmwarePlotNodes.reserveCapacity(dataPoints.count + scatterPoints.count + (tangentPoints?.count ?? 0) + highlightedPoints.count + 5)
            SharedPlotBuilder.buildMainPlotContent(isStatPlot: isStatPlot, dataPoints: dataPoints, scatterPoints: scatterPoints, regressionPoints: [], into: &engine.firmwarePlotNodes)
            SharedPlotBuilder.buildAxesContent(into: &engine.firmwarePlotNodes)
            SharedPlotBuilder.buildAreaContent(hasIntegrationLimits: engine.integrationLimits != nil, highlightedDataPoints: highlightedPoints, into: &engine.firmwarePlotNodes)
            SharedPlotBuilder.buildOverlayContent(scatterPoints: scatterPoints, tangentPoints: tangentPoints, into: &engine.firmwarePlotNodes)
            
            var minX = Double.greatestFiniteMagnitude
            var maxX = -Double.greatestFiniteMagnitude
            var minY = Double.greatestFiniteMagnitude
            var maxY = -Double.greatestFiniteMagnitude
            let allPoints = dataPoints + scatterPoints + (tangentPoints ?? [])
            for pt in allPoints {
                if pt.x < minX { minX = pt.x }
                if pt.x > maxX { maxX = pt.x }
                if pt.y < minY { minY = pt.y }
                if pt.y > maxY { maxY = pt.y }
            }
            if minX > 1e100 { minX = -10; maxX = 10; minY = -10; maxY = 10 }
            
            let padX = (maxX - minX) * 0.1
            let trueMin = minX - padX
            let trueMax = maxX + padX
            let center = (trueMin + trueMax) / 2.0
            
            let padY = (maxY - minY) * 0.1
            let trueMinY = minY - padY
            let trueMaxY = maxY + padY
            
            var minStr = retroUI.doubleFormatter?(trueMin, .fix(1)) ?? "\(trueMin)"
            var maxStr = retroUI.doubleFormatter?(trueMax, .fix(1)) ?? "\(trueMax)"
            var centerStr = retroUI.doubleFormatter?(center, .fix(2)) ?? "\(center)"
            var minYStr = retroUI.doubleFormatter?(trueMinY, .fix(2)) ?? "\(trueMinY)"
            var maxYStr = retroUI.doubleFormatter?(trueMaxY, .fix(2)) ?? "\(trueMaxY)"
            
            while minStr.hasPrefix(" ") { minStr = String(minStr.dropFirst()) }
            while maxStr.hasPrefix(" ") { maxStr = String(maxStr.dropFirst()) }
            while centerStr.hasPrefix(" ") { centerStr = String(centerStr.dropFirst()) }
            while minYStr.hasPrefix(" ") { minYStr = String(minYStr.dropFirst()) }
            while maxYStr.hasPrefix(" ") { maxYStr = String(maxYStr.dropFirst()) }
            
            retroUI.plotMinXString = minStr
            retroUI.plotMaxXString = maxStr
            retroUI.plotMinYString = minYStr
            retroUI.plotMaxYString = maxYStr
            retroUI.plotCenterXString = centerStr
            
            for m in engine.plotMarkers {
                engine.firmwarePlotNodes.append(.rule(x: m.0, y: nil))
                engine.firmwarePlotNodes.append(.point(x: m.0, y: m.1))
            }
            engine.firmwarePlotNodes.append(.rule(x: center, y: nil))
            
            print("DEBUG: Inside FirmwareChart block! reqPlot=\(engine.requestPlot ? 1 : 0) nodes=\(engine.firmwarePlotNodes.count)")
            FirmwareChart(content: engine.firmwarePlotNodes, width: 132, height: isPlotting ? 54 : 43, minXString: nil, maxXString: nil).draw(in: renderer, x: x, y: y, engine: engine)
            
            // Draw X center at top left (Annunciator location)
            let xStr = centerStr
            renderer.fillRect(x: x, y: y, w: renderer.getStringWidth(xStr, size: .tiny) + 2, h: 10, color: false)
            renderer.drawString(xStr, x: x + 1, y: y, size: .tiny, color: true)
            
            // Draw Y limits at top right
            let yStr = "[" + minYStr + "," + maxYStr + "]"
            let yStrW = renderer.getStringWidth(yStr, size: .tiny)
            renderer.fillRect(x: x + 132 - yStrW - 2, y: y, w: yStrW + 2, h: 10, color: false)
            renderer.drawString(yStr, x: x + 132 - yStrW - 1, y: y, size: .tiny, color: true)
            
            if let status = engine.statusMessage ?? (engine.isPlotLoading ? "CALCULATING..." : nil) {
                let w = renderer.getStringWidth(status, size: .small)
                let sx = max(0, (132 - w) / 2)
                let sy = y + (isPlotting ? 54 : 43) / 2 - 4
                renderer.fillRect(x: sx - 2, y: sy - 1, w: w + 4, h: 9, color: false)
                renderer.drawString(status, x: sx, y: sy, size: .small, color: true)
            }
#endif
        } else {
            print("DEBUG: MainDisplayNumberView.draw! reqPlot=\(engine.requestPlot ? 1 : 0)")
            MainDisplayNumberView().draw(in: renderer, x: x, y: y + 13, engine: engine)
        }
    }
}

public struct RetroUIFooterView: FirmwareView {
    public let retroUI: RetroUI
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        return (132, 11)
    }
    
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        print("DEBUG: RetroUIBodyView.draw - reqPlot=\(engine.requestPlot ? 1 : 0) isEq=\(engine.isEquationListMode ? 1 : 0) err=\(engine.errorMessage != nil ? 1 : 0)")
        if engine.errorMessage != nil || engine.transientMessage != nil || retroUI.isShowingRegisters || retroUI.isShowingFullPrecision {
            return
        }
        
        let menuActive = engine.activeMenu != nil || retroUI.waitingForMenuDigit != nil || retroUI.softkeyMode != .none || engine.alphaAction == .fnEq || engine.isEquationListMode
        if menuActive {
            if let menu = engine.activeMenu {
                #if !hasFeature(Embedded)
                let items = MenuSystem.filter(menu: menu, query: retroUI.menuAlphaQuery, engine: engine).filter { !$0.isSoftwareOnly }
                #else
                let items = MenuSystem.filter(menu: menu, query: retroUI.menuAlphaQuery, engine: engine)
                #endif
                MenuSoftkeyRowView(items: items, offset: retroUI.menuOffset).draw(in: renderer, x: x, y: y, engine: engine)
                
            } else if retroUI.softkeyMode != .none {
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
                MenuSoftkeyRowView(items: items, offset: retroUI.menuOffset).draw(in: renderer, x: x, y: y, engine: engine)
                
            } else if engine.alphaAction == .fnEq {
                var items: [MenuItem] = []
                for prog in engine.programs {
                    items.append(MenuItem(label: prog.label, action: prog.label))
                }
                MenuSoftkeyRowView(items: items, offset: retroUI.menuOffset).draw(in: renderer, x: x, y: y, engine: engine)
                
            } else if engine.isEquationListMode {
                var items: [MenuItem] = []
                items.append(MenuItem(label: "NEW", action: "EQN_NEW"))
                if !engine.programs.isEmpty {
                    items.append(MenuItem(label: "EDIT", action: "EQN_EDIT"))
                }
                MenuSoftkeyRowView(items: items, offset: retroUI.menuOffset).draw(in: renderer, x: x, y: y, engine: engine)
            }
        } else if engine.requestPlot {
            if retroUI.softkeyMode == .plotOptions {
                let items: [MenuItem] = [
                    MenuItem(label: "MARK", action: "PLOT_MARK"),
                    MenuItem(label: "CLEAR", action: "PLOT_CLEAR"),
                    MenuItem(label: "STORE", action: "PLOT_STORE"),
                    MenuItem(label: "∫ f(x)", action: "PLOT_INTEGRATE")
                ]
                MenuSoftkeyRowView(items: items, offset: retroUI.menuOffset).draw(in: renderer, x: x, y: y, engine: engine)
            } else {
                let labels = [
                    "<",
                    "|<-",
                    "OUT",
                    "IN",
                    "->|",
                    ">"
                ]
                for i in 0..<6 {
                    let segment = renderer.menuSegments[i]
                    renderer.fillRect(x: segment.x, y: y, w: segment.w, h: 11, color: true)
                    let label = labels[i]
                    let lw = renderer.getStringWidth(label, size: .tiny)
                    let textX = max(segment.x, segment.x + (segment.w - lw) / 2)
                    renderer.drawString(label, x: textX, y: y + (11 - FontData.Tiny.charHeight)/2, size: .tiny, color: false, scale: 1)
                }
                
                // X=... moved to top left per user request
            }
        } else if !engine.isGeneratingPlot && !engine.isPlotLoading {
            SoftkeyRowView().draw(in: renderer, x: x, y: y, engine: engine)
        }
    }
}
