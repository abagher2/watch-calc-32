public enum FirmwareView {
    public enum HStackAlignment { case top, center, bottom }
    public enum VStackAlignment { case leading, center, trailing }

    case textNode(String, Renderer.FontSize, Bool, Int)
    case spacerNode(Int, Int)
    indirect case hstackNode(HStackAlignment, Int, [FirmwareView])
    indirect case vstackNode(VStackAlignment, Int, [FirmwareView])
    indirect case paddingNode(Int, Int, Int, Int, FirmwareView)
    indirect case backgroundNode(Bool, FirmwareView)
    indirect case frameNode(Int?, Int?, FirmwareView.VStackAlignment, FirmwareView.HStackAlignment, FirmwareView)
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        switch self {
        case .textNode(let text, let font, _, let scale):
            let w = renderer.getStringWidth(text, size: font) * scale
            let h: Int
            switch font {
            case .tiny: h = FontData.Tiny.charHeight
            case .small: h = FontData.Small.charHeight
            case .display: h = FontData.Display.charHeight
            case .medium: h = FontData.Medium.charHeight
            case .large: h = FontData.Large.charHeight
            }
            return (w, h * scale)
        case .spacerNode(let w, let h):
            return (w, h)
        case .hstackNode(_, let spacing, let children):
            var w = 0
            var h = 0
            for child in children {
                let s = child.size(in: renderer)
                w += s.width
                h = max(h, s.height)
            }
            w += max(0, children.count - 1) * spacing
            return (w, h)
        case .vstackNode(_, let spacing, let children):
            var w = 0
            var h = 0
            for child in children {
                let s = child.size(in: renderer)
                w = max(w, s.width)
                h += s.height
            }
            h += max(0, children.count - 1) * spacing
            return (w, h)
        case .paddingNode(let top, let bottom, let leading, let trailing, let child):
            let s = child.size(in: renderer)
            return (s.width + leading + trailing, s.height + top + bottom)
        case .backgroundNode(_, let child):
            return child.size(in: renderer)
        case .frameNode(let w, let h, _, _, let child):
            let s = child.size(in: renderer)
            return (w ?? s.width, h ?? s.height)
        }
    }
    
    public func draw(in renderer: Renderer, x: Int, y: Int) {
        switch self {
        case .textNode(let text, let font, let color, let scale):
            renderer.drawString(text, x: x, y: y, size: font, color: color, scale: scale)
        case .spacerNode:
            break
        case .hstackNode(let alignment, let spacing, let children):
            var cursorX = x
            let totalHeight = self.size(in: renderer).height
            for child in children {
                let s = child.size(in: renderer)
                var drawY = y
                switch alignment {
                case .top: drawY = y
                case .center: drawY = y + (totalHeight - s.height) / 2
                case .bottom: drawY = y + totalHeight - s.height
                }
                child.draw(in: renderer, x: cursorX, y: drawY)
                cursorX += s.width + spacing
            }
        case .vstackNode(let alignment, let spacing, let children):
            var cursorY = y
            let totalWidth = self.size(in: renderer).width
            for child in children {
                let s = child.size(in: renderer)
                var drawX = x
                switch alignment {
                case .leading: drawX = x
                case .center: drawX = x + (totalWidth - s.width) / 2
                case .trailing: drawX = x + totalWidth - s.width
                }
                child.draw(in: renderer, x: drawX, y: cursorY)
                cursorY += s.height + spacing
            }
        case .paddingNode(let top, _, let leading, _, let child):
            child.draw(in: renderer, x: x + leading, y: y + top)
        case .backgroundNode(let color, let child):
            let s = self.size(in: renderer)
            renderer.fillRect(x: x, y: y, w: s.width, h: s.height, color: color)
            child.draw(in: renderer, x: x, y: y)
        case .frameNode(let targetW, let targetH, let hAlign, let vAlign, let child):
            let s = child.size(in: renderer)
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
            
            child.draw(in: renderer, x: drawX, y: drawY)
        }
    }
}

public func FirmwareText(_ text: String, font: Renderer.FontSize = .small, color: Bool = true, scale: Int = 1) -> FirmwareView {
    return .textNode(text, font, color, scale)
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
    return .paddingNode(top, bottom, leading, trailing, child)
}

public func FirmwareBackground(color: Bool, child: FirmwareView) -> FirmwareView {
    return .backgroundNode(color, child)
}

public func FirmwareRect(width: Int, height: Int, color: Bool = true) -> FirmwareView {
    return FirmwareBackground(color: color, child: FirmwareFrame(width: width, height: height, child: FirmwareSpacer()))
}

public func FirmwareFrame(width: Int? = nil, height: Int? = nil, alignment: FirmwareView.VStackAlignment = .center, vAlignment: FirmwareView.HStackAlignment = .center, child: FirmwareView) -> FirmwareView {
    return .frameNode(width, height, alignment, vAlignment, child)
}
