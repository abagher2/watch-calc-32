public class Renderer {
    public var buffer: [UInt8]
    
    public init() {
        buffer = [UInt8](repeating: 0, count: 1024)
    }
    
    public func clear() {
        for i in 0..<1024 {
            buffer[i] = 0
        }
    }
    
    public func setPixel(x: Int, y: Int, color: Bool) {
        if x < 0 || x >= 128 || y < 0 || y >= 64 { return }
        
        // OLED mapping: usually 128 columns, 8 pages (each page is 8 vertical pixels)
        let page = y / 8
        let bit = y % 8
        let index = page * 128 + x
        
        if color {
            buffer[index] |= UInt8(1 << bit)
        } else {
            buffer[index] &= ~UInt8(1 << bit)
        }
    }
    
    public enum FontSize {
        case tiny, small, display, medium, large
    }
    
    public func drawChar(_ c: Character, x: Int, y: Int, size: FontSize = .small, color: Bool = true) {
        let width: Int
        let height: Int
        let glyph: [UInt8]?
        
        switch size {
        case .tiny:
            width = FontData.Tiny.charWidth
            height = FontData.Tiny.charHeight
            glyph = FontData.Tiny.glyph(for: c)
        case .small:
            width = FontData.Small.charWidth
            height = FontData.Small.charHeight
            glyph = FontData.Small.glyph(for: c)
        case .display:
            width = FontData.Display.charWidth
            height = FontData.Display.charHeight
            glyph = FontData.Display.glyph(for: c)
        case .medium:
            width = FontData.Medium.charWidth
            height = FontData.Medium.charHeight
            glyph = FontData.Medium.glyph(for: c)
        case .large:
            width = FontData.Large.charWidth
            height = FontData.Large.charHeight
            glyph = FontData.Large.glyph(for: c)
        }
        
        guard let glyph = glyph else { return }
        
        let bytesPerRow = (width + 7) / 8
        for row in 0..<height {
            for byteIdx in 0..<bytesPerRow {
                let rowByte = glyph[row * bytesPerRow + byteIdx]
                for bitIdx in 0..<8 {
                    let col = byteIdx * 8 + bitIdx
                    if col < width {
                        let pixel = (rowByte & (1 << (7 - bitIdx))) != 0
                        if pixel {
                            setPixel(x: x + col, y: y + row, color: color)
                        }
                    }
                }
            }
        }
    }
    
    public func getStringWidth(_ str: String, size: FontSize = .small) -> Int {
        let width: Int
        switch size {
        case .tiny: width = FontData.Tiny.charWidth
        case .small: width = FontData.Small.charWidth
        case .display: width = FontData.Display.charWidth
        case .medium: width = FontData.Medium.charWidth
        case .large: width = FontData.Large.charWidth
        }
        return str.count * width
    }
    
    
    public func drawString(_ buffer: UnsafePointer<UInt8>, length: Int, x: Int, y: Int, size: FontSize = .small, color: Bool = true) {
        var cursorX = x
        let width: Int
        switch size {
        case .tiny: width = FontData.Tiny.charWidth
        case .small: width = FontData.Small.charWidth
        case .display: width = FontData.Display.charWidth
        case .medium: width = FontData.Medium.charWidth
        case .large: width = FontData.Large.charWidth
        }
        
        for i in 0..<length {
            let scalar = UnicodeScalar(buffer[i])
            let char = Character(scalar)
            drawChar(char, x: cursorX, y: y, size: size, color: color)
            cursorX += width
        }
    }

    public func drawString(_ str: String, x: Int, y: Int, size: FontSize = .small, color: Bool = true) {
        var cursorX = x
        let width: Int
        switch size {
        case .tiny: width = FontData.Tiny.charWidth
        case .small: width = FontData.Small.charWidth
        case .display: width = FontData.Display.charWidth
        case .medium: width = FontData.Medium.charWidth
        case .large: width = FontData.Large.charWidth
        }
        
        for c in str {
            drawChar(c, x: cursorX, y: y, size: size, color: color)
            cursorX += width
        }
    }
    
    public func fillRect(x: Int, y: Int, w: Int, h: Int, color: Bool = true) {
        for row in y..<(y+h) {
            for col in x..<(x+w) {
                setPixel(x: col, y: row, color: color)
            }
        }
    }
    
    public func drawRect(x: Int, y: Int, w: Int, h: Int, color: Bool = true) {
        for col in x..<(x+w) {
            setPixel(x: col, y: y, color: color)
            setPixel(x: col, y: y+h-1, color: color)
        }
        for row in y..<(y+h) {
            setPixel(x: x, y: row, color: color)
            setPixel(x: x+w-1, y: row, color: color)
        }
    }
    
    public func renderMenu(menu: CalculatorMenu, query: String = "") {
        if !query.isEmpty {
            drawString("Search: \(query)_", x: 2, y: 38, size: .small, color: true)
        }
        // Render soft keys
        let items = MenuSystem.filter(menu: menu, query: query)
        let segmentWidth = 128 / 6
        
        for i in 0..<min(6, items.count) {
            let item = items[i]
            let xOffset = i * segmentWidth
            
            drawRect(x: xOffset + 1, y: 53, w: segmentWidth - 2, h: 10, color: true)
            
            let textW = item.label.count * FontData.Tiny.charWidth
            let textX = xOffset + (segmentWidth - textW) / 2
            drawString(item.label, x: textX, y: 55, size: .tiny, color: true)
        }
    }
    
    public func renderLFU(manager: LFUManager) {
        let segmentWidth = 128 / 6
        for i in 0..<6 {
            guard let funcName = manager.slots[i] else { continue }
            let xOffset = i * segmentWidth
            
            let textW = funcName.count * FontData.Tiny.charWidth
            let textX = xOffset + (segmentWidth - textW) / 2
            drawString(funcName, x: textX, y: 55, size: .tiny, color: true)
        }
    }
}
