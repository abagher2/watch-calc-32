public enum View {
    public enum HStackAlignment { case top, center, bottom }
    public enum VStackAlignment { case leading, center, trailing }

    case textNode(String, Renderer.FontSize, Bool)
    case spacerNode(Int, Int)
    indirect case hstackNode(HStackAlignment, Int, [View])
    indirect case vstackNode(VStackAlignment, Int, [View])
    indirect case paddingNode(Int, Int, Int, Int, View)
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        switch self {
        case .textNode(let text, let font, _):
            let w = renderer.getStringWidth(text, size: font)
            let h: Int
            switch font {
            case .tiny: h = FontData.Tiny.charHeight
            case .small: h = FontData.Small.charHeight
            case .display: h = FontData.Display.charHeight
            case .medium: h = FontData.Medium.charHeight
            case .large: h = FontData.Large.charHeight
            }
            return (w, h)
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
        }
    }
    
    public func draw(in renderer: Renderer, x: Int, y: Int) {
        switch self {
        case .textNode(let text, let font, let color):
            renderer.drawString(text, x: x, y: y, size: font, color: color)
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
        case .paddingNode(let top, let bottom, let leading, let trailing, let child):
            child.draw(in: renderer, x: x + leading, y: y + top)
        }
    }
}

public func Text(_ text: String, font: Renderer.FontSize = .small, color: Bool = true) -> View {
    return .textNode(text, font, color)
}

public func Spacer(minWidth: Int = 0, minHeight: Int = 0) -> View {
    return .spacerNode(minWidth, minHeight)
}

public func HStack(alignment: View.HStackAlignment = .center, spacing: Int = 0, children: [View]) -> View {
    return .hstackNode(alignment, spacing, children)
}

public func VStack(alignment: View.VStackAlignment = .leading, spacing: Int = 0, children: [View]) -> View {
    return .vstackNode(alignment, spacing, children)
}

public func Padding(top: Int = 0, bottom: Int = 0, leading: Int = 0, trailing: Int = 0, child: View) -> View {
    return .paddingNode(top, bottom, leading, trailing, child)
}
