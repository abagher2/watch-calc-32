

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
    
    public enum SoftkeyMode { case none, solve, integrate, plot, xeq }
    public var softkeyMode: SoftkeyMode = .none
    public var softkeyProgram: CalculatorEngine.Program? = nil
    public var softkeySelectedVar: String = "X"
    
    public var doubleFormatter: ((Double, CalculatorEngine.DisplayMode) -> String)?
    
    public init(lfuManager: LFUManager) {
        self.lfuManager = lfuManager
    }
    
    public func render(engine: CalculatorEngine, renderer: Renderer) {
        // Evaluate the body content
        let screen = FirmwareVStack(alignment: .leading, spacing: 0) {
            FirmwareFrame(width: 132, height: 11, alignment: .leading, vAlignment: .top) {
                TopBarIndicatorsView()
            }
            
            RetroUIBodyView(retroUI: self)
            
            FirmwareFrame(width: 132, height: 11, alignment: .leading, vAlignment: .bottom) {
                RetroUIFooterView(retroUI: self)
            }
        }
        
        screen.draw(in: renderer, x: 0, y: 0, engine: engine)
    }
}

public struct RetroUIBodyView: FirmwareView {
    public let retroUI: RetroUI
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        return (132, 43)
    }
    
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
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
            let dataPoints = engine.plotData.enumerated().map { PlotDataPoint(id: $0.offset, x: $0.element.0, y: $0.element.1) }
            let scatterPoints = engine.statPoints.enumerated().map { PlotDataPoint(id: $0.offset, x: $0.element.x, y: $0.element.y) }
            
            var regressionPoints: [PlotDataPoint] = []
            if engine.isStatPlot && engine.statN > 1 {
                let num = engine.statSumXY - (engine.statSumX * engine.statSumY / engine.statN)
                let den = engine.statSumX2 - (engine.statSumX * engine.statSumX / engine.statN)
                let m = den == 0 ? 0 : num / den
                let b = (engine.statSumY - m * engine.statSumX) / engine.statN
                
                if let first = scatterPoints.first, let last = scatterPoints.last {
                    let startX = first.x - 10
                    let endX = last.x + 10
                    regressionPoints = [
                        PlotDataPoint(id: 0, x: startX, y: m * startX + b),
                        PlotDataPoint(id: 1, x: endX, y: m * endX + b)
                    ]
                }
            }
            
            var highlightedDataPoints: [PlotDataPoint] = []
            if let limits = engine.integrationLimits {
                let minL = min(limits.0, limits.1)
                let maxL = max(limits.0, limits.1)
                highlightedDataPoints = dataPoints.filter { $0.x >= minL && $0.x <= maxL }
            }
            
            var tangentPoints: [PlotDataPoint]? = nil
            if let first = dataPoints.first, let last = dataPoints.last, !engine.isStatPlot {
                let centerX = (first.x + last.x) / 2.0
                var closestP = dataPoints[0]
                var minDiff = Double.greatestFiniteMagnitude
                var closestIdx = 0
                for i in 0..<dataPoints.count {
                    let diff = abs(dataPoints[i].x - centerX)
                    if diff < minDiff {
                        minDiff = diff
                        closestP = dataPoints[i]
                        closestIdx = i
                    }
                }
                if closestIdx > 0 && closestIdx < dataPoints.count - 1 {
                    let p1 = dataPoints[closestIdx - 1]
                    let p2 = dataPoints[closestIdx + 1]
                    let m = (p2.y - p1.y) / (p2.x - p1.x)
                    
                    let startX = first.x
                    let startY = m * (startX - closestP.x) + closestP.y
                    let endX = last.x
                    let endY = m * (endX - closestP.x) + closestP.y
                    tangentPoints = [
                        PlotDataPoint(id: 0, x: startX, y: startY),
                        PlotDataPoint(id: 1, x: endX, y: endY)
                    ]
                }
            }
            
            let plotContent: [ChartNode] = 
                SharedPlotBuilder.buildAxesContent().nodes +
                SharedPlotBuilder.buildMainPlotContent(isStatPlot: engine.isStatPlot, dataPoints: dataPoints, scatterPoints: scatterPoints, regressionPoints: regressionPoints).nodes +
                SharedPlotBuilder.buildOverlayContent(scatterPoints: scatterPoints, tangentPoints: tangentPoints).nodes +
                SharedPlotBuilder.buildAreaContent(hasIntegrationLimits: engine.integrationLimits != nil, highlightedDataPoints: highlightedDataPoints).nodes
            
            FirmwareChart(content: plotContent, width: 132, height: 43).draw(in: renderer, x: x, y: y, engine: engine)
#endif
        } else {
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
            for i in 0..<6 {
                let segment = renderer.menuSegments[i]
                renderer.fillRect(x: segment.x, y: y, w: segment.w, h: 11, color: true)
                let lw = renderer.getStringWidth("+", size: .tiny)
                renderer.drawString("+", x: segment.x + (segment.w - lw) / 2, y: y + (11 - FontData.Tiny.charHeight)/2, size: .tiny, color: false, scale: 1)
            }
        } else if !engine.isGeneratingPlot && !engine.isPlotLoading {
            SoftkeyRowView().draw(in: renderer, x: x, y: y, engine: engine)
        }
    }
}
