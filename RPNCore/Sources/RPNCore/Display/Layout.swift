

#if canImport(SwiftUI) && canImport(Charts)
import SwiftUI
import Charts
#endif

public enum FirmwareView {
    case textNode(String, Renderer.FontSize, Bool, Int)
    case charNode(UInt8, Renderer.FontSize, Bool, Int) // text, font, color, scale
    case spacerNode(Int, Int) // minWidth, minHeight
    case hstackNode(HStackAlignment, Int, [FirmwareView]) // alignment, spacing, children
    case vstackNode(VStackAlignment, Int, [FirmwareView]) // alignment, spacing, children
    case paddingNode(Int, Int, Int, Int, [FirmwareView]) // top, bottom, leading, trailing, child
    case backgroundNode(Bool, [FirmwareView]) // color, child
    case frameNode(Int?, Int?, VStackAlignment, HStackAlignment, [FirmwareView]) // width, height, alignment, valignment, child
    case chartNode([ChartNode], Int, Int) // content, width, height
    
    public enum HStackAlignment { case top, center, bottom }
    public enum VStackAlignment { case leading, center, trailing }
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        switch self {
        case .textNode(let text, let font, _, let scale):
            let w = renderer.getStringWidth(text, size: font) * scale
            let h = (font == .small ? 8 : (font == .display ? 32 : 12)) * scale
            return (w, h)
        case .charNode(let ch, let font, _, let scale):
            let w = renderer.getCharWidth(UInt32(ch), size: font) * scale
            let h = (font == .small ? 8 : (font == .display ? 32 : 12)) * scale
            return (w, h)
        case .spacerNode(let w, let h):
            return (w, h)
        case .hstackNode(_, let spacing, let children):
            var w = 0, h = 0
            for child in children {
                let s = child.size(in: renderer)
                w += s.width
                h = max(h, s.height)
            }
            if children.count > 1 { w += spacing * (children.count - 1) }
            return (w, h)
        case .vstackNode(_, let spacing, let children):
            var w = 0, h = 0
            for child in children {
                let s = child.size(in: renderer)
                h += s.height
                w = max(w, s.width)
            }
            if children.count > 1 { h += spacing * (children.count - 1) }
            return (w, h)
        case .paddingNode(let top, let bottom, let leading, let trailing, let child):
            let s = child[0].size(in: renderer)
            return (s.width + leading + trailing, s.height + top + bottom)
        case .backgroundNode(_, let child):
            return child[0].size(in: renderer)
        case .frameNode(let width, let height, _, _, let child):
            let s = child[0].size(in: renderer)
            return (width ?? s.width, height ?? s.height)
        case .chartNode(_, let cw, let ch):
            return (cw, ch)
        }
    }
    
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine? = nil) {
        switch self {
        case .textNode(let text, let font, let color, let scale):
            renderer.drawString(text, x: x, y: y, size: font, color: color, scale: scale)
        case .charNode(let ch, let font, let color, let scale):
            _ = renderer.drawChar(UInt32(ch), x: x, y: y, size: font, color: color, scale: scale)
        case .spacerNode:
            break
        case .hstackNode(let align, let spacing, let children):
            var dx = x
            for child in children {
                let s = child.size(in: renderer)
                var dy = y
                if align == .center { dy += (self.size(in: renderer).height - s.height) / 2 }
                else if align == .bottom { dy += (self.size(in: renderer).height - s.height) }
                child.draw(in: renderer, x: dx, y: dy, engine: engine)
                dx += s.width + spacing
            }
        case .vstackNode(let align, let spacing, let children):
            var dy = y
            for child in children {
                let s = child.size(in: renderer)
                var dx = x
                if align == .center { dx += (self.size(in: renderer).width - s.width) / 2 }
                else if align == .trailing { dx += (self.size(in: renderer).width - s.width) }
                child.draw(in: renderer, x: dx, y: dy, engine: engine)
                dy += s.height + spacing
            }
        case .paddingNode(let top, _, let leading, _, let child):
            child[0].draw(in: renderer, x: x + leading, y: y + top, engine: engine)
        case .backgroundNode(let color, let child):
            let s = self.size(in: renderer)
            renderer.fillRect(x: x, y: y, w: s.width, h: s.height, color: color)
            child[0].draw(in: renderer, x: x, y: y, engine: engine)
        case .frameNode(let targetW, let targetH, let hAlign, let vAlign, let child):
            let s = child[0].size(in: renderer)
            let finalW = targetW ?? s.width
            let finalH = targetH ?? s.height
            var drawX = x
            switch hAlign {
            case .leading: drawX = x
            case .center: drawX = x + (finalW - s.width) / 2
            case .trailing: drawX = x + finalW - s.width
            }
            var drawY = y
            switch vAlign {
            case .top: drawY = y
            case .center: drawY = y + (finalH - s.height) / 2
            case .bottom: drawY = y + finalH - s.height
            }
            child[0].draw(in: renderer, x: drawX, y: drawY, engine: engine)
            
        case .chartNode(let content, let width, let height):
#if !canImport(SwiftUI)
            var minX = Double.greatestFiniteMagnitude
            var maxX = -Double.greatestFiniteMagnitude
            var minY = Double.greatestFiniteMagnitude
            var maxY = -Double.greatestFiniteMagnitude
            
            var lineMarks: [(x: Double, y: Double, dash: [Int])] = []
            var areaMarks: [(x: Double, yStart: Double, yEnd: Double)] = []
            var ruleMarks: [(x: Double?, y: Double?)] = []
            var pointMarks: [(x: Double, y: Double)] = []
            
            for item in content {
                switch item {
                case .line(let x, let y, let dash):
                    lineMarks.append((x: x, y: y, dash: dash))
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                case .area(let x, let yStart, let yEnd):
                    areaMarks.append((x: x, yStart: yStart, yEnd: yEnd))
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if yStart < minY { minY = yStart }
                    if yStart > maxY { maxY = yStart }
                    if yEnd < minY { minY = yEnd }
                    if yEnd > maxY { maxY = yEnd }
                case .point(let x, let y):
                    pointMarks.append((x: x, y: y))
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                case .rule(let x, let y):
                    ruleMarks.append((x: x, y: y))
                }
            }
            guard minX != Double.greatestFiniteMagnitude else { return }
            
            if minX == maxX { minX -= 1; maxX += 1 }
            if minY == maxY { minY -= 1; maxY += 1 }
            
            let padX = (maxX - minX) * 0.05
            let padY = (maxY - minY) * 0.05
            minX -= padX; maxX += padX
            minY -= padY; maxY += padY
            
            func toScreen(_ px: Double, _ py: Double) -> (Int, Int) {
                let sx = Int(((px - minX) / (maxX - minX)) * Double(width))
                let sy = Int(Double(height) - ((py - minY) / (maxY - minY)) * Double(height))
                return (x + sx, y + sy)
            }
            
            // 6-region Grid
            let numGridLines = 6
            for i in 1..<numGridLines {
                let gy = y + (height * i) / numGridLines
                for gx in stride(from: x, to: x + width, by: 4) { renderer.setPixel(x: gx, y: gy, color: true) }
                let gx = x + (width * i) / numGridLines
                for gy2 in stride(from: y, to: y + height, by: 4) { renderer.setPixel(x: gx, y: gy2, color: true) }
            }
            
            // Axes from RuleMarks
            for rule in ruleMarks {
                if let rx = rule.x {
                    let sc = toScreen(rx, 0)
                    if sc.0 >= x && sc.0 <= x + width { renderer.drawRect(x: sc.0, y: y, w: 1, h: height, color: true) }
                }
                if let ry = rule.y {
                    let sc = toScreen(0, ry)
                    if sc.1 >= y && sc.1 <= y + height { renderer.drawRect(x: x, y: sc.1, w: width, h: 1, color: true) }
                }
            }
            
            // Area Marks (Integration)
            for area in areaMarks {
                let sc = toScreen(area.x, area.yEnd)
                let zeroSc = toScreen(area.x, area.yStart)
                let startY = min(sc.1, zeroSc.1)
                let endY = max(sc.1, zeroSc.1)
                for fillY in startY...endY {
                    if (sc.0 + fillY) % 2 == 0 {
                        renderer.setPixel(x: sc.0, y: fillY, color: true)
                    }
                }
            }
            
            // Line Marks (Curve and Tangents)
            var prevCurve: (Int, Int)? = nil
            var prevTangent: (Int, Int)? = nil
            for line in lineMarks {
                let sc = toScreen(line.x, line.y)
                let isTangent = line.dash.count > 0 // || line.series == "Tangent" (ignoring series for now)
                
                if isTangent {
                    if let prev = prevTangent { renderer.drawLine(x0: prev.0, y0: prev.1, x1: sc.0, y1: sc.1, color: true) }
                    prevTangent = sc
                } else {
                    if let prev = prevCurve { renderer.drawLine(x0: prev.0, y0: prev.1, x1: sc.0, y1: sc.1, color: true) }
                    prevCurve = sc
                }
            }
            
            // Point Marks (Scatter)
            for point in pointMarks {
                let sc = toScreen(point.x, point.y)
                renderer.drawRect(x: sc.0 - 1, y: sc.1 - 1, w: 3, h: 3, color: true)
            }
            
            // Bounds Label
            var minStr = "\(minX + padX)"
            var maxStr = "\(maxX - padX)"
            if minStr.count > 6 { minStr = String(minStr.prefix(6)) }
            if maxStr.count > 6 { maxStr = String(maxStr.prefix(6)) }
            renderer.drawString("[\(minStr), \(maxStr)]", x: x + 2, y: y + 2, size: .small, color: true)

#endif
        }
    }
}

public func FirmwareText(_ text: String, font: Renderer.FontSize = .small, color: Bool = true, scale: Int = 1) -> FirmwareView {
    return .textNode(text, font, color, scale)
}

public func FirmwareChar(_ ch: UInt8, font: Renderer.FontSize = .small, color: Bool = true, scale: Int = 1) -> FirmwareView {
    return .charNode(ch, font, color, scale)
}

public func FirmwareSpacer(minWidth: Int = 0, minHeight: Int = 0) -> FirmwareView {
    return .spacerNode(minWidth, minHeight)
}

public func FirmwareHStack(alignment: FirmwareView.HStackAlignment = .center, spacing: Int = 0, children: [FirmwareView]) -> FirmwareView {
    return .hstackNode(alignment, spacing, children)
}

public func FirmwareVStack(alignment: FirmwareView.VStackAlignment = .leading, spacing: Int = 0, children: [FirmwareView]) -> FirmwareView {
    return .vstackNode(alignment, spacing, children)
}

public func FirmwarePadding(top: Int = 0, bottom: Int = 0, leading: Int = 0, trailing: Int = 0, child: FirmwareView) -> FirmwareView {
    return .paddingNode(top, bottom, leading, trailing, [child])
}

public func FirmwareBackground(color: Bool, child: FirmwareView) -> FirmwareView {
    return .backgroundNode(color, [child])
}

public func FirmwareRect(width: Int, height: Int, color: Bool = true) -> FirmwareView {
    return .backgroundNode(color, [.spacerNode(width, height)])
}

public func FirmwareFrame(width: Int? = nil, height: Int? = nil, alignment: FirmwareView.VStackAlignment = .center, vAlignment: FirmwareView.HStackAlignment = .center, child: FirmwareView) -> FirmwareView {
    return .frameNode(width, height, alignment, vAlignment, [child])
}

public func FirmwareChart(content: [ChartNode], width: Int, height: Int) -> FirmwareView {
    return .chartNode(content, width, height)
}
