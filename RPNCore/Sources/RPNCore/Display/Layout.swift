#if canImport(SwiftUI) && canImport(Charts)
import SwiftUI
import Charts
#endif

public protocol FirmwareView {
    func size(in renderer: Renderer) -> (width: Int, height: Int)
    func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine)
    func hstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int)
    func hstackDraw(renderer: Renderer, x: Int, y: Int, alignment: HStackAlignment, spacing: Int, engine: CalculatorEngine)
    func vstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int)
    func vstackDraw(renderer: Renderer, x: Int, y: Int, alignment: VStackAlignment, spacing: Int, engine: CalculatorEngine)
}

public struct EmptyFirmwareView: FirmwareView {
    public init() {}
    public func size(in renderer: Renderer) -> (width: Int, height: Int) { return (0, 0) }
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {}
}

public struct TupleFirmwareView2<A: FirmwareView, B: FirmwareView>: FirmwareView {
    public let a: A
    public let b: B
    public init(_ a: A, _ b: B) { self.a = a; self.b = b }
    public func size(in renderer: Renderer) -> (width: Int, height: Int) { return (0, 0) } // Handled by stacks
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {}
}

public struct TupleFirmwareView3<A: FirmwareView, B: FirmwareView, C: FirmwareView>: FirmwareView {
    public let a: A, b: B, c: C
    public init(_ a: A, _ b: B, _ c: C) { self.a = a; self.b = b; self.c = c }
    public func size(in renderer: Renderer) -> (width: Int, height: Int) { return (0, 0) }
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {}
}

public struct TupleFirmwareView4<A: FirmwareView, B: FirmwareView, C: FirmwareView, D: FirmwareView>: FirmwareView {
    public let a: A, b: B, c: C, d: D
    public init(_ a: A, _ b: B, _ c: C, _ d: D) { self.a = a; self.b = b; self.c = c; self.d = d }
    public func size(in renderer: Renderer) -> (width: Int, height: Int) { return (0, 0) }
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {}
}

public struct TupleFirmwareView5<A: FirmwareView, B: FirmwareView, C: FirmwareView, D: FirmwareView, E: FirmwareView>: FirmwareView {
    public let a: A, b: B, c: C, d: D, e: E
    public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) { self.a = a; self.b = b; self.c = c; self.d = d; self.e = e }
    public func size(in renderer: Renderer) -> (width: Int, height: Int) { return (0, 0) }
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {}
}

public struct TupleFirmwareView6<A: FirmwareView, B: FirmwareView, C: FirmwareView, D: FirmwareView, E: FirmwareView, F: FirmwareView>: FirmwareView {
    public let a: A, b: B, c: C, d: D, e: E, f: F
    public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) { self.a = a; self.b = b; self.c = c; self.d = d; self.e = e; self.f = f }
    public func size(in renderer: Renderer) -> (width: Int, height: Int) { return (0, 0) }
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {}
}

public struct OptionalFirmwareView<A: FirmwareView>: FirmwareView {
    public let content: A?
    public init(_ content: A?) { self.content = content }
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        return content?.size(in: renderer) ?? (0, 0)
    }
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        content?.draw(in: renderer, x: x, y: y, engine: engine)
    }
}

public struct EitherFirmwareView<A: FirmwareView, B: FirmwareView>: FirmwareView {
    public let a: A?
    public let b: B?
    public init(a: A?, b: B?) { self.a = a; self.b = b }
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        if let a = a { return a.size(in: renderer) }
        if let b = b { return b.size(in: renderer) }
        return (0, 0)
    }
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        if let a = a { a.draw(in: renderer, x: x, y: y, engine: engine) }
        if let b = b { b.draw(in: renderer, x: x, y: y, engine: engine) }
    }
}

@resultBuilder
public struct FirmwareBuilder {
    public static func buildBlock() -> EmptyFirmwareView { EmptyFirmwareView() }
    public static func buildBlock<A: FirmwareView>(_ a: A) -> A { a }
    public static func buildBlock<A: FirmwareView, B: FirmwareView>(_ a: A, _ b: B) -> TupleFirmwareView2<A, B> { TupleFirmwareView2(a, b) }
    public static func buildBlock<A: FirmwareView, B: FirmwareView, C: FirmwareView>(_ a: A, _ b: B, _ c: C) -> TupleFirmwareView3<A, B, C> { TupleFirmwareView3(a, b, c) }
    public static func buildBlock<A: FirmwareView, B: FirmwareView, C: FirmwareView, D: FirmwareView>(_ a: A, _ b: B, _ c: C, _ d: D) -> TupleFirmwareView4<A, B, C, D> { TupleFirmwareView4(a, b, c, d) }
    public static func buildBlock<A: FirmwareView, B: FirmwareView, C: FirmwareView, D: FirmwareView, E: FirmwareView>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) -> TupleFirmwareView5<A, B, C, D, E> { TupleFirmwareView5(a, b, c, d, e) }
    public static func buildBlock<A: FirmwareView, B: FirmwareView, C: FirmwareView, D: FirmwareView, E: FirmwareView, F: FirmwareView>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) -> TupleFirmwareView6<A, B, C, D, E, F> { TupleFirmwareView6(a, b, c, d, e, f) }
    
    public static func buildOptional<A: FirmwareView>(_ component: A?) -> OptionalFirmwareView<A> {
        return OptionalFirmwareView(component)
    }
    
    public static func buildEither<A: FirmwareView, B: FirmwareView>(first component: A) -> EitherFirmwareView<A, B> {
        return EitherFirmwareView(a: component, b: nil)
    }
    
    public static func buildEither<A: FirmwareView, B: FirmwareView>(second component: B) -> EitherFirmwareView<A, B> {
        return EitherFirmwareView(a: nil, b: component)
    }
}

public struct FirmwareText: FirmwareView {
    let text: String
    let font: Renderer.FontSize
    let color: Bool
    let scale: Int
    
    public init(_ text: String, font: Renderer.FontSize = .small, color: Bool = true, scale: Int = 1) {
        self.text = text; self.font = font; self.color = color; self.scale = scale
    }
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        let w = renderer.getStringWidth(text, size: font) * scale
        let h = (font == .small ? 8 : (font == .display ? 32 : 12)) * scale
        return (w, h)
    }
    
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        renderer.drawString(text, x: x, y: y, size: font, color: color, scale: scale)
    }
}

public struct FirmwareChar: FirmwareView {
    let ch: UInt8
    let font: Renderer.FontSize
    let color: Bool
    let scale: Int
    
    public init(_ ch: UInt8, font: Renderer.FontSize = .small, color: Bool = true, scale: Int = 1) {
        self.ch = ch; self.font = font; self.color = color; self.scale = scale
    }
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        let w = renderer.getCharWidth(UInt32(ch), size: font) * scale
        let h = (font == .small ? 8 : (font == .display ? 32 : 12)) * scale
        return (w, h)
    }
    
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        _ = renderer.drawChar(UInt32(ch), x: x, y: y, size: font, color: color, scale: scale)
    }
}

public struct FirmwareSpacer: FirmwareView {
    let minWidth: Int
    let minHeight: Int
    public init(minWidth: Int = 0, minHeight: Int = 0) {
        self.minWidth = minWidth; self.minHeight = minHeight
    }
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        return (minWidth, minHeight)
    }
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {}
}

public enum HStackAlignment { case top, center, bottom }
public enum VStackAlignment { case leading, center, trailing }

// HStacks and VStacks need to iterate over their children. Since they contain TupleFirmwareViews, we need a way to get sizes and draw them.
// To keep it simple, we'll implement specific versions or use a helper protocol.




extension FirmwareView {
    public func hstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int) { return size(in: renderer) }
    public func hstackDraw(renderer: Renderer, x: Int, y: Int, alignment: HStackAlignment, spacing: Int, engine: CalculatorEngine) {
        draw(in: renderer, x: x, y: y, engine: engine)
    }
    public func vstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int) { return size(in: renderer) }
    public func vstackDraw(renderer: Renderer, x: Int, y: Int, alignment: VStackAlignment, spacing: Int, engine: CalculatorEngine) {
        draw(in: renderer, x: x, y: y, engine: engine)
    }
}

extension EmptyFirmwareView {
    public func hstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int) { return (0, 0) }
    public func hstackDraw(renderer: Renderer, x: Int, y: Int, alignment: HStackAlignment, spacing: Int, engine: CalculatorEngine) {}
    public func vstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int) { return (0, 0) }
    public func vstackDraw(renderer: Renderer, x: Int, y: Int, alignment: VStackAlignment, spacing: Int, engine: CalculatorEngine) {}
}

extension TupleFirmwareView2 {
    public func hstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int) {
        let sA = a.size(in: renderer); let sB = b.size(in: renderer)
        return (sA.width + sB.width + spacing, max(sA.height, sB.height))
    }
    public func hstackDraw(renderer: Renderer, x: Int, y: Int, alignment: HStackAlignment, spacing: Int, engine: CalculatorEngine) {
        let sA = a.size(in: renderer); let sB = b.size(in: renderer)
        let totalH = max(sA.height, sB.height)
        let yA = alignment == .top ? y : (alignment == .bottom ? y + totalH - sA.height : y + (totalH - sA.height)/2)
        let yB = alignment == .top ? y : (alignment == .bottom ? y + totalH - sB.height : y + (totalH - sB.height)/2)
        a.draw(in: renderer, x: x, y: yA, engine: engine)
        b.draw(in: renderer, x: x + sA.width + spacing, y: yB, engine: engine)
    }
    public func vstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int) {
        let sA = a.size(in: renderer); let sB = b.size(in: renderer)
        return (max(sA.width, sB.width), sA.height + sB.height + spacing)
    }
    public func vstackDraw(renderer: Renderer, x: Int, y: Int, alignment: VStackAlignment, spacing: Int, engine: CalculatorEngine) {
        let sA = a.size(in: renderer); let sB = b.size(in: renderer)
        let totalW = max(sA.width, sB.width)
        let xA = alignment == .leading ? x : (alignment == .trailing ? x + totalW - sA.width : x + (totalW - sA.width)/2)
        let xB = alignment == .leading ? x : (alignment == .trailing ? x + totalW - sB.width : x + (totalW - sB.width)/2)
        a.draw(in: renderer, x: xA, y: y, engine: engine)
        b.draw(in: renderer, x: xB, y: y + sA.height + spacing, engine: engine)
    }
}

extension TupleFirmwareView3 {
    public func hstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int) {
        let sA = a.size(in: renderer); let sB = b.size(in: renderer); let sC = c.size(in: renderer)
        return (sA.width + sB.width + sC.width + spacing * 2, max(sA.height, max(sB.height, sC.height)))
    }
    public func hstackDraw(renderer: Renderer, x: Int, y: Int, alignment: HStackAlignment, spacing: Int, engine: CalculatorEngine) {
        let sA = a.size(in: renderer); let sB = b.size(in: renderer); let sC = c.size(in: renderer)
        let totalH = max(sA.height, max(sB.height, sC.height))
        let dy = { (h: Int) in alignment == .top ? y : (alignment == .bottom ? y + totalH - h : y + (totalH - h)/2) }
        a.draw(in: renderer, x: x, y: dy(sA.height), engine: engine)
        b.draw(in: renderer, x: x + sA.width + spacing, y: dy(sB.height), engine: engine)
        c.draw(in: renderer, x: x + sA.width + sB.width + spacing * 2, y: dy(sC.height), engine: engine)
    }
    public func vstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int) {
        let sA = a.size(in: renderer); let sB = b.size(in: renderer); let sC = c.size(in: renderer)
        return (max(sA.width, max(sB.width, sC.width)), sA.height + sB.height + sC.height + spacing * 2)
    }
    public func vstackDraw(renderer: Renderer, x: Int, y: Int, alignment: VStackAlignment, spacing: Int, engine: CalculatorEngine) {
        let sA = a.size(in: renderer); let sB = b.size(in: renderer); let sC = c.size(in: renderer)
        let totalW = max(sA.width, max(sB.width, sC.width))
        let dx = { (w: Int) in alignment == .leading ? x : (alignment == .trailing ? x + totalW - w : x + (totalW - w)/2) }
        a.draw(in: renderer, x: dx(sA.width), y: y, engine: engine)
        b.draw(in: renderer, x: dx(sB.width), y: y + sA.height + spacing, engine: engine)
        c.draw(in: renderer, x: dx(sC.width), y: y + sA.height + sB.height + spacing * 2, engine: engine)
    }
}

extension TupleFirmwareView4 {
    public func hstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int) {
        let sA = a.size(in: renderer)
        let sB = b.size(in: renderer)
        let sC = c.size(in: renderer)
        let sD = d.size(in: renderer)
        return (sA.width + sB.width + sC.width + sD.width + spacing * 3, max(max(max(sA.height, sB.height), sC.height), sD.height))
    }
    public func hstackDraw(renderer: Renderer, x: Int, y: Int, alignment: HStackAlignment, spacing: Int, engine: CalculatorEngine) {
        let sA = a.size(in: renderer)
        let sB = b.size(in: renderer)
        let sC = c.size(in: renderer)
        let sD = d.size(in: renderer)
        let totalH = max(max(max(sA.height, sB.height), sC.height), sD.height)
        let dy = { (h: Int) in alignment == .top ? y : (alignment == .bottom ? y + totalH - h : y + (totalH - h)/2) }
        a.draw(in: renderer, x: x, y: dy(sA.height), engine: engine)
        b.draw(in: renderer, x: x + sA.width + spacing, y: dy(sB.height), engine: engine)
        c.draw(in: renderer, x: x + sA.width + spacing + sB.width + spacing, y: dy(sC.height), engine: engine)
        d.draw(in: renderer, x: x + sA.width + spacing + sB.width + spacing + sC.width + spacing, y: dy(sD.height), engine: engine)
    }
    public func vstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int) {
        let sA = a.size(in: renderer)
        let sB = b.size(in: renderer)
        let sC = c.size(in: renderer)
        let sD = d.size(in: renderer)
        return (max(max(max(sA.width, sB.width), sC.width), sD.width), sA.height + sB.height + sC.height + sD.height + spacing * 3)
    }
    public func vstackDraw(renderer: Renderer, x: Int, y: Int, alignment: VStackAlignment, spacing: Int, engine: CalculatorEngine) {
        let sA = a.size(in: renderer)
        let sB = b.size(in: renderer)
        let sC = c.size(in: renderer)
        let sD = d.size(in: renderer)
        let totalW = max(max(max(sA.width, sB.width), sC.width), sD.width)
        let dx = { (w: Int) in alignment == .leading ? x : (alignment == .trailing ? x + totalW - w : x + (totalW - w)/2) }
        a.draw(in: renderer, x: dx(sA.width), y: y, engine: engine)
        b.draw(in: renderer, x: dx(sB.width), y: y + sA.height + spacing, engine: engine)
        c.draw(in: renderer, x: dx(sC.width), y: y + sA.height + spacing + sB.height + spacing, engine: engine)
        d.draw(in: renderer, x: dx(sD.width), y: y + sA.height + spacing + sB.height + spacing + sC.height + spacing, engine: engine)
    }
}

extension TupleFirmwareView5 {
    public func hstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int) {
        let sA = a.size(in: renderer)
        let sB = b.size(in: renderer)
        let sC = c.size(in: renderer)
        let sD = d.size(in: renderer)
        let sE = e.size(in: renderer)
        return (sA.width + sB.width + sC.width + sD.width + sE.width + spacing * 4, max(max(max(max(sA.height, sB.height), sC.height), sD.height), sE.height))
    }
    public func hstackDraw(renderer: Renderer, x: Int, y: Int, alignment: HStackAlignment, spacing: Int, engine: CalculatorEngine) {
        let sA = a.size(in: renderer)
        let sB = b.size(in: renderer)
        let sC = c.size(in: renderer)
        let sD = d.size(in: renderer)
        let sE = e.size(in: renderer)
        let totalH = max(max(max(max(sA.height, sB.height), sC.height), sD.height), sE.height)
        let dy = { (h: Int) in alignment == .top ? y : (alignment == .bottom ? y + totalH - h : y + (totalH - h)/2) }
        a.draw(in: renderer, x: x, y: dy(sA.height), engine: engine)
        b.draw(in: renderer, x: x + sA.width + spacing, y: dy(sB.height), engine: engine)
        c.draw(in: renderer, x: x + sA.width + spacing + sB.width + spacing, y: dy(sC.height), engine: engine)
        d.draw(in: renderer, x: x + sA.width + spacing + sB.width + spacing + sC.width + spacing, y: dy(sD.height), engine: engine)
        e.draw(in: renderer, x: x + sA.width + spacing + sB.width + spacing + sC.width + spacing + sD.width + spacing, y: dy(sE.height), engine: engine)
    }
    public func vstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int) {
        let sA = a.size(in: renderer)
        let sB = b.size(in: renderer)
        let sC = c.size(in: renderer)
        let sD = d.size(in: renderer)
        let sE = e.size(in: renderer)
        return (max(max(max(max(sA.width, sB.width), sC.width), sD.width), sE.width), sA.height + sB.height + sC.height + sD.height + sE.height + spacing * 4)
    }
    public func vstackDraw(renderer: Renderer, x: Int, y: Int, alignment: VStackAlignment, spacing: Int, engine: CalculatorEngine) {
        let sA = a.size(in: renderer)
        let sB = b.size(in: renderer)
        let sC = c.size(in: renderer)
        let sD = d.size(in: renderer)
        let sE = e.size(in: renderer)
        let totalW = max(max(max(max(sA.width, sB.width), sC.width), sD.width), sE.width)
        let dx = { (w: Int) in alignment == .leading ? x : (alignment == .trailing ? x + totalW - w : x + (totalW - w)/2) }
        a.draw(in: renderer, x: dx(sA.width), y: y, engine: engine)
        b.draw(in: renderer, x: dx(sB.width), y: y + sA.height + spacing, engine: engine)
        c.draw(in: renderer, x: dx(sC.width), y: y + sA.height + spacing + sB.height + spacing, engine: engine)
        d.draw(in: renderer, x: dx(sD.width), y: y + sA.height + spacing + sB.height + spacing + sC.height + spacing, engine: engine)
        e.draw(in: renderer, x: dx(sE.width), y: y + sA.height + spacing + sB.height + spacing + sC.height + spacing + sD.height + spacing, engine: engine)
    }
}

extension TupleFirmwareView6 {
    public func hstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int) {
        let sA = a.size(in: renderer)
        let sB = b.size(in: renderer)
        let sC = c.size(in: renderer)
        let sD = d.size(in: renderer)
        let sE = e.size(in: renderer)
        let sF = f.size(in: renderer)
        return (sA.width + sB.width + sC.width + sD.width + sE.width + sF.width + spacing * 5, max(max(max(max(max(sA.height, sB.height), sC.height), sD.height), sE.height), sF.height))
    }
    public func hstackDraw(renderer: Renderer, x: Int, y: Int, alignment: HStackAlignment, spacing: Int, engine: CalculatorEngine) {
        let sA = a.size(in: renderer)
        let sB = b.size(in: renderer)
        let sC = c.size(in: renderer)
        let sD = d.size(in: renderer)
        let sE = e.size(in: renderer)
        let sF = f.size(in: renderer)
        let totalH = max(max(max(max(max(sA.height, sB.height), sC.height), sD.height), sE.height), sF.height)
        let dy = { (h: Int) in alignment == .top ? y : (alignment == .bottom ? y + totalH - h : y + (totalH - h)/2) }
        a.draw(in: renderer, x: x, y: dy(sA.height), engine: engine)
        b.draw(in: renderer, x: x + sA.width + spacing, y: dy(sB.height), engine: engine)
        c.draw(in: renderer, x: x + sA.width + spacing + sB.width + spacing, y: dy(sC.height), engine: engine)
        d.draw(in: renderer, x: x + sA.width + spacing + sB.width + spacing + sC.width + spacing, y: dy(sD.height), engine: engine)
        e.draw(in: renderer, x: x + sA.width + spacing + sB.width + spacing + sC.width + spacing + sD.width + spacing, y: dy(sE.height), engine: engine)
        f.draw(in: renderer, x: x + sA.width + spacing + sB.width + spacing + sC.width + spacing + sD.width + spacing + sE.width + spacing, y: dy(sF.height), engine: engine)
    }
    public func vstackSize(renderer: Renderer, spacing: Int) -> (width: Int, height: Int) {
        let sA = a.size(in: renderer)
        let sB = b.size(in: renderer)
        let sC = c.size(in: renderer)
        let sD = d.size(in: renderer)
        let sE = e.size(in: renderer)
        let sF = f.size(in: renderer)
        return (max(max(max(max(max(sA.width, sB.width), sC.width), sD.width), sE.width), sF.width), sA.height + sB.height + sC.height + sD.height + sE.height + sF.height + spacing * 5)
    }
    public func vstackDraw(renderer: Renderer, x: Int, y: Int, alignment: VStackAlignment, spacing: Int, engine: CalculatorEngine) {
        let sA = a.size(in: renderer)
        let sB = b.size(in: renderer)
        let sC = c.size(in: renderer)
        let sD = d.size(in: renderer)
        let sE = e.size(in: renderer)
        let sF = f.size(in: renderer)
        let totalW = max(max(max(max(max(sA.width, sB.width), sC.width), sD.width), sE.width), sF.width)
        let dx = { (w: Int) in alignment == .leading ? x : (alignment == .trailing ? x + totalW - w : x + (totalW - w)/2) }
        a.draw(in: renderer, x: dx(sA.width), y: y, engine: engine)
        b.draw(in: renderer, x: dx(sB.width), y: y + sA.height + spacing, engine: engine)
        c.draw(in: renderer, x: dx(sC.width), y: y + sA.height + spacing + sB.height + spacing, engine: engine)
        d.draw(in: renderer, x: dx(sD.width), y: y + sA.height + spacing + sB.height + spacing + sC.height + spacing, engine: engine)
        e.draw(in: renderer, x: dx(sE.width), y: y + sA.height + spacing + sB.height + spacing + sC.height + spacing + sD.height + spacing, engine: engine)
        f.draw(in: renderer, x: dx(sF.width), y: y + sA.height + spacing + sB.height + spacing + sC.height + spacing + sD.height + spacing + sE.height + spacing, engine: engine)
    }
}

// We will map FirmwareHStack / VStack directly to the FirmwareViewTuple protocol

public struct FirmwareHStack<Content: FirmwareView>: FirmwareView {
    let alignment: HStackAlignment
    let spacing: Int
    let content: Content
    
    public init(alignment: HStackAlignment = .center, spacing: Int = 0, @FirmwareBuilder _ builder: () -> Content) {
        self.alignment = alignment; self.spacing = spacing; self.content = builder()
    }
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        return content.hstackSize(renderer: renderer, spacing: spacing)
    }
    
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        content.hstackDraw(renderer: renderer, x: x, y: y, alignment: alignment, spacing: spacing, engine: engine)
    }
}

public struct FirmwareVStack<Content: FirmwareView>: FirmwareView {
    let alignment: VStackAlignment
    let spacing: Int
    let content: Content
    
    public init(alignment: VStackAlignment = .leading, spacing: Int = 0, @FirmwareBuilder _ builder: () -> Content) {
        self.alignment = alignment; self.spacing = spacing; self.content = builder()
    }
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        return content.vstackSize(renderer: renderer, spacing: spacing)
    }
    
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        content.vstackDraw(renderer: renderer, x: x, y: y, alignment: alignment, spacing: spacing, engine: engine)
    }
}
public struct FirmwarePadding<Content: FirmwareView>: FirmwareView {
    let top: Int; let bottom: Int; let leading: Int; let trailing: Int
    let content: Content
    
    public init(top: Int = 0, bottom: Int = 0, leading: Int = 0, trailing: Int = 0, @FirmwareBuilder _ builder: () -> Content) {
        self.top = top; self.bottom = bottom; self.leading = leading; self.trailing = trailing; self.content = builder()
    }
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        let s = content.size(in: renderer)
        return (s.width + leading + trailing, s.height + top + bottom)
    }
    
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        content.draw(in: renderer, x: x + leading, y: y + top, engine: engine)
    }
}

public struct FirmwareBackground<Content: FirmwareView>: FirmwareView {
    let color: Bool
    let content: Content
    
    public init(color: Bool, @FirmwareBuilder _ builder: () -> Content) {
        self.color = color; self.content = builder()
    }
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        return content.size(in: renderer)
    }
    
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        let s = content.size(in: renderer)
        renderer.fillRect(x: x, y: y, w: s.width, h: s.height, color: color)
        content.draw(in: renderer, x: x, y: y, engine: engine)
    }
}

public struct FirmwareRect: FirmwareView {
    let width: Int; let height: Int; let color: Bool
    public init(width: Int, height: Int, color: Bool = true) {
        self.width = width; self.height = height; self.color = color
    }
    public func size(in renderer: Renderer) -> (width: Int, height: Int) { return (width, height) }
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        renderer.fillRect(x: x, y: y, w: width, h: height, color: color)
    }
}

public struct FirmwareFrame<Content: FirmwareView>: FirmwareView {
    let width: Int?; let height: Int?
    let alignment: VStackAlignment; let vAlignment: HStackAlignment
    let content: Content
    
    public init(width: Int? = nil, height: Int? = nil, alignment: VStackAlignment = .center, vAlignment: HStackAlignment = .center, @FirmwareBuilder _ builder: () -> Content) {
        self.width = width; self.height = height; self.alignment = alignment; self.vAlignment = vAlignment; self.content = builder()
    }
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        let s = content.size(in: renderer)
        return (width ?? s.width, height ?? s.height)
    }
    
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        let s = content.size(in: renderer)
        let finalW = width ?? s.width
        let finalH = height ?? s.height
        var drawX = x
        switch alignment {
        case .leading: drawX = x
        case .center: drawX = x + (finalW - s.width) / 2
        case .trailing: drawX = x + finalW - s.width
        }
        var drawY = y
        switch vAlignment {
        case .top: drawY = y
        case .center: drawY = y + (finalH - s.height) / 2
        case .bottom: drawY = y + finalH - s.height
        }
        content.draw(in: renderer, x: drawX, y: drawY, engine: engine)
    }
}
public struct FirmwareChart: FirmwareView {
    let content: [ChartNode]
    let width: Int
    let height: Int
    
    public init(content: [ChartNode], width: Int, height: Int) {
        self.content = content
        self.width = width
        self.height = height
    }
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        return (width, height)
    }
    
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
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
            case .line(let cx, let cy, let dash):
                lineMarks.append((x: cx, y: cy, dash: dash))
                if cx < minX { minX = cx }
                if cx > maxX { maxX = cx }
                if cy < minY { minY = cy }
                if cy > maxY { maxY = cy }
            case .area(let cx, let cyStart, let cyEnd):
                areaMarks.append((x: cx, yStart: cyStart, yEnd: cyEnd))
                if cx < minX { minX = cx }
                if cx > maxX { maxX = cx }
                if cyStart < minY { minY = cyStart }
                if cyStart > maxY { maxY = cyStart }
                if cyEnd < minY { minY = cyEnd }
                if cyEnd > maxY { maxY = cyEnd }
            case .point(let cx, let cy):
                pointMarks.append((x: cx, y: cy))
                if cx < minX { minX = cx }
                if cx > maxX { maxX = cx }
                if cy < minY { minY = cy }
                if cy > maxY { maxY = cy }
            case .rule(let cx, let cy):
                ruleMarks.append((x: cx, y: cy))
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
        
        let numGridLines = 6
        for i in 1..<numGridLines {
            let gy = y + (height * i) / numGridLines
            for gx in stride(from: x, to: x + width, by: 4) { renderer.setPixel(x: gx, y: gy, color: true) }
            let gx = x + (width * i) / numGridLines
            for gy2 in stride(from: y, to: y + height, by: 4) { renderer.setPixel(x: gx, y: gy2, color: true) }
        }
        
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
        
        var prevCurve: (Int, Int)? = nil
        var prevTangent: (Int, Int)? = nil
        for line in lineMarks {
            let sc = toScreen(line.x, line.y)
            let isTangent = line.dash.count > 0
            if isTangent {
                if let prev = prevTangent { renderer.drawLine(x0: prev.0, y0: prev.1, x1: sc.0, y1: sc.1, color: true) }
                prevTangent = sc
            } else {
                if let prev = prevCurve { renderer.drawLine(x0: prev.0, y0: prev.1, x1: sc.0, y1: sc.1, color: true) }
                prevCurve = sc
            }
        }
        
        for point in pointMarks {
            let sc = toScreen(point.x, point.y)
            renderer.drawRect(x: sc.0 - 1, y: sc.1 - 1, w: 3, h: 3, color: true)
        }
        
        // Bounds Label avoiding String formatting dynamically if possible
        // We'll leave it as is for now since Chart only runs in specific modes, not general math
        var minStr = "\(minX + padX)"
        var maxStr = "\(maxX - padX)"
        if minStr.count > 6 { minStr = String(minStr.prefix(6)) }
        if maxStr.count > 6 { maxStr = String(maxStr.prefix(6)) }
        renderer.drawString("[\(minStr), \(maxStr)]", x: x + 2, y: y + 2, size: .small, color: true)
#endif
    }
}
public struct TopBarIndicatorsView: FirmwareView {
    public init() {}
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        return (132, 11)
    }
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        let indY = y + 1 // Changed from y + 6 to fit within 11px height
        var leftX = x + 6
        
        let drawInd = { (label: String) in
            let w = renderer.getStringWidth(label, size: .small)
            renderer.drawString(label, x: leftX, y: indY, size: .small, color: true, scale: 1)
            leftX += w + 6
        }
        
        if engine.shiftState == 1 { drawInd("↰") }
        if engine.shiftState == 2 { drawInd("↱") }
        
        for ann in engine.activeAnnunciators {
            drawInd(ann.rawValue)
        }
    }
}

public struct MainDisplayNumberView: FirmwareView {
    public init() {}
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        return (132, 16) // Changed from 11 to 16 since .display font is 16px tall
    }
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        engine.displayXBuffer.withUnsafeBufferPointer { ptr in
            let len = min(engine.displayXLength, 64)
            var currentX = x
            
            // Calculate total text width
            var textW = 0
            for i in 0..<len {
                textW += renderer.getCharWidth(UInt32(ptr[i]), size: .display)
            }
            
            let hasCursor = engine.isBuildingNumber || engine.prgmIsBuildingNumber || engine.isWaitingForAlpha
            
            // HP-32S II is always left-justified
            currentX = x + 2
            
            for i in 0..<len {
                let cw = renderer.drawChar(UInt32(ptr[i]), x: currentX, y: y, size: .display, color: true, scale: 1)
                currentX += cw
            }
            
            if hasCursor {
                renderer.fillRect(x: currentX, y: y + FontData.Display.charHeight - 2, w: 6, h: 2, color: true)
            }
        }
    }
}

public struct SoftkeyRowView: FirmwareView {
    public init() {}
    public func size(in renderer: Renderer) -> (width: Int, height: Int) {
        return (132, 11)
    }
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        for i in 0..<6 {
            let segment = renderer.menuSegments[i]
            let funcName = engine.lfuManager.slots[i] ?? ""
            let label = renderer.fitSoftkeyLabel(funcName)
            
            renderer.fillRect(x: segment.x, y: y, w: segment.w, h: 11, color: true)
            let lw = renderer.getStringWidth(label, size: .tiny)
            renderer.drawString(label, x: segment.x + (segment.w - lw) / 2, y: y + (11 - FontData.Tiny.charHeight)/2, size: .tiny, color: false, scale: 1)
        }
    }
}

public struct MenuSoftkeyRowView: FirmwareView {
    let items: [MenuItem]
    let offset: Int
    public init(items: [MenuItem], offset: Int) { self.items = items; self.offset = offset }
    
    public func size(in renderer: Renderer) -> (width: Int, height: Int) { return (132, 11) }
    public func draw(in renderer: Renderer, x: Int, y: Int, engine: CalculatorEngine) {
        let visibleItems = Array(items.dropFirst(offset))
        for i in 0..<min(6, visibleItems.count) {
            let segment = renderer.menuSegments[i]
            let item = visibleItems[i]
            let label = (i == 5 && visibleItems.count > 6) ? "..." : item.label
            
            renderer.fillRect(x: segment.x, y: y, w: segment.w, h: 11, color: true)
            
            let fitted = renderer.fitSoftkeyLabel(label)
            let lw = renderer.getStringWidth(fitted, size: .tiny)
            renderer.drawString(fitted, x: segment.x + (segment.w - lw) / 2, y: y + (11 - FontData.Tiny.charHeight)/2, size: .tiny, color: false, scale: 1)
        }
    }
}
