
public class RetroUI {
    public var isShowingRegisters: Bool = false
    public var isShowingFullPrecision: Bool = false
    public var regsOffset: Int = 0
    public var softkeySelectedVar: String = "X"
    
    public enum SoftkeyMode {
        case none, integrate, solve, plot, xeq
    }
    public var softkeyMode: SoftkeyMode = .none
    public var softkeyProgram: CalculatorEngine.Program? = nil
    
    public var waitingForMenuDigit: MenuItem? = nil
    public var menuOffset: Int = 0
    public var menuAlphaQuery: String = ""
    
    private var lfuManager: LFUManager
    
    public init(lfuManager: LFUManager) {
        self.lfuManager = lfuManager
    }
    
    public var doubleFormatter: ((Double, CalculatorEngine.DisplayMode) -> String)? = nil
    
    public func render(engine: CalculatorEngine, renderer: Renderer) {
        // --- 1. Top Bar Area ---
        var indX = 6
        let indY = 6
        if engine.shiftState == 1 {
            let w = renderer.drawChar(8624, x: indX, y: indY, size: .display, color: true, scale: 1)
            indX += w + 2
        }
        if engine.shiftState == 2 {
            let w = renderer.drawChar(8625, x: indX, y: indY, size: .display, color: true, scale: 1)
            indX += w + 2
        }
        if engine.alphaAction == .evalEquation {
            let w = renderer.getStringWidth("=", size: .display)
            renderer.drawString("=", x: indX, y: indY, size: .display, color: true, scale: 1)
            indX += w + 2
        } else if engine.isWaitingForAlpha {
            let w = renderer.getStringWidth("A..Z", size: .display)
            renderer.drawString("A..Z", x: indX, y: indY, size: .display, color: true, scale: 1)
            indX += w + 2
        }
        if engine.isHypPending {
            let w = renderer.getStringWidth("HYP", size: .display)
            renderer.drawString("HYP", x: indX, y: indY, size: .display, color: true, scale: 1)
            indX += w + 2
        }
        if engine.isStatPlot {
            let w = renderer.getStringWidth("STAT", size: .display)
            renderer.drawString("STAT", x: indX, y: indY, size: .display, color: true, scale: 1)
            indX += w + 2
        }
        
        var rightX = 400 - 6
        if true {
            let w = renderer.getStringWidth("BAT", size: .display)
            renderer.drawString("BAT", x: rightX - w, y: indY, size: .display, color: true, scale: 1)
            rightX -= w + 4
        }
        if engine.angleMode == .rad {
            let w = renderer.getStringWidth("RAD", size: .display)
            renderer.drawString("RAD", x: rightX - w, y: indY, size: .display, color: true, scale: 1)
            rightX -= w + 4
        } else if false {
            // grad
        }
        if engine.complexMode {
            let w = renderer.getStringWidth("C", size: .display)
            renderer.drawString("C", x: rightX - w, y: indY, size: .display, color: true, scale: 1)
            rightX -= w + 4
        }
        if engine.isProgrammingMode {
            let w = renderer.getStringWidth("PRGM", size: .display)
            renderer.drawString("PRGM", x: rightX - w, y: indY, size: .display, color: true, scale: 1)
            rightX -= w + 4
        }
        
        // --- 2. Main Content Area ---
        if engine.isTestMode {
            renderer.fillRect(x: 30, y: 80, w: 340, h: 80, color: false)
            let txtW = renderer.getStringWidth("HP-32SII TEST OK", size: .display)
            renderer.drawString("HP-32SII TEST OK", x: 30 + (340 - txtW) / 2, y: 80 + (80 - FontData.Display.charHeight) / 2, size: .display, color: true, scale: 1)
        } else if isShowingRegisters {
            let regNames = ["X", "Y", "Z", "T"]
            for i in 0..<4 {
                let regIdx = regsOffset + (3 - i)
                var name = "?"
                if regIdx < 4 { name = regNames[regIdx] }
                else if regIdx - 4 < 26 {
                    let ascii = 65 + regIdx - 4
                    name = String(Character(UnicodeScalar(ascii)!))
                }
                let val = engine.stack.count > regIdx ? engine.stack[regIdx].real : 0.0
                let valStr = doubleFormatter?(val, engine.displayMode) ?? "\(val)"
                let txt = "\(name): \(valStr)"
                renderer.drawString(txt, x: 6, y: 40 + i * 22, size: .small, color: true, scale: 1)
            }
        } else if isShowingFullPrecision {
            let valStr = "\(engine.stack.first?.real ?? 0.0)"
            var i = 0
            let maxChars = 12
            var lineY = 40
            while i < valStr.count {
                let start = valStr.index(valStr.startIndex, offsetBy: i)
                let end = valStr.index(start, offsetBy: min(maxChars, valStr.count - i))
                renderer.drawString(String(valStr[start..<end]), x: 6, y: lineY, size: .medium, color: true, scale: 1)
                lineY += FontData.Medium.charHeight - 12
                i += maxChars
            }
        } else {
            var textW = 0
            #if hasFeature(Embedded)
            if let status = engine.statusMessage {
                textW = renderer.getStringWidth(status, size: .medium)
                renderer.drawString(status, x: 6, y: 40, size: .medium, color: true, scale: 1)
            } else if let error = engine.errorMessage {
                textW = renderer.getStringWidth(error, size: .medium)
                renderer.drawString(error, x: 6, y: 40, size: .medium, color: true, scale: 1)
            } else if let transient = engine.transientMessage {
                textW = renderer.getStringWidth(transient, size: .medium)
                renderer.drawString(transient, x: 6, y: 40, size: .medium, color: true, scale: 1)
            } else if let prompt = engine.promptString {
                textW = renderer.getStringWidth(prompt, size: .display)
                renderer.drawString(prompt, x: 6, y: 40, size: .display, color: true, scale: 1)
            } else {
                if engine.isBuildingNumber || engine.isWaitingForAlpha {
                    var curX = 6
                    let len = min(engine.displayXLength, 64)
                    engine.displayXBuffer.withUnsafeBufferPointer { ptr in
                        for i in 0..<len {
                            let cw = renderer.drawChar(UInt32(ptr[i]), x: curX, y: 40, size: .display, color: true, scale: 1)
                            curX += cw + 1
                        }
                    }
                    if engine.isWaitingForAlpha {
                        renderer.drawString("?", x: curX, y: 40 + FontData.Tiny.charHeight, size: .display, color: true, scale: 1)
                    }
                    textW = curX - 6
                    renderer.fillRect(x: 6, y: 40 + FontData.Display.charHeight + 2, w: textW, h: 4, color: true)
                } else {
                    engine.displayXBuffer.withUnsafeBufferPointer { ptr in
                        let len = min(engine.displayXLength, 64)
                        var curX = 6
                        for i in 0..<len {
                            let cw = renderer.drawChar(UInt32(ptr[i]), x: curX, y: 40, size: .display, color: true, scale: 1)
                            curX += cw + 1
                        }
                    }
                }
            }
            #else
            let valStr = engine.statusMessage ?? engine.errorMessage ?? engine.transientMessage ?? engine.promptString ?? engine.displayX
            let isTextMsg = (engine.statusMessage ?? engine.errorMessage ?? engine.transientMessage ?? engine.promptString) != nil
            let fontToUse: Renderer.FontSize = isTextMsg ? .medium : .display
            textW = renderer.getStringWidth(valStr, size: fontToUse)
            if textW > 390 {
                renderer.drawString("<", x: 6, y: 40, size: fontToUse, color: true, scale: 1)
                renderer.drawString(valStr, x: 400 - textW, y: 40, size: fontToUse, color: true, scale: 1)
            } else {
                renderer.drawString(valStr, x: 400 - 6 - textW, y: 40, size: fontToUse, color: true, scale: 1)
            }
            #endif
        }
        
        let footerY = 240 - 40
        if engine.isTestMode || engine.isProgrammingMode || engine.requestPlot || engine.isEquationListMode || engine.activeMenu != nil || engine.isGeneratingPlot || engine.isPlotLoading {
            for i in 0..<6 {
                let segment = renderer.menuSegments[i]
                renderer.fillRect(x: segment.x, y: footerY, w: segment.w, h: 36, color: true)
            }
        } else {
            for i in 0..<6 {
                let segment = renderer.menuSegments[i]
                let funcName = engine.lfuManager.slots[i] ?? ""
                let label = renderer.fitSoftkeyLabel(funcName)
                renderer.fillRect(x: segment.x, y: footerY + 4, w: segment.w, h: 32, color: true)
                let lw = renderer.getStringWidth(label, size: .tiny)
                renderer.drawString(label, x: segment.x + (segment.w - lw) / 2, y: footerY + 4 + (32 - FontData.Tiny.charHeight)/2, size: .tiny, color: false, scale: 1)
            }
        }
    }
}
