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
        case small, medium, large
    }
    
    public func drawChar(_ c: Character, x: Int, y: Int, size: FontSize = .small, color: Bool = true) {
        let width: Int
        let height: Int
        let glyph: [UInt8]?
        
        switch size {
        case .small:
            width = FontData.Small.charWidth
            height = FontData.Small.charHeight
            glyph = FontData.Small.glyph(for: c)
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
        case .small: width = FontData.Small.charWidth
        case .medium: width = FontData.Medium.charWidth
        case .large: width = FontData.Large.charWidth
        }
        return str.count * width
    }
    
    public func drawString(_ str: String, x: Int, y: Int, size: FontSize = .small, color: Bool = true) {
        var cursorX = x
        let width: Int
        switch size {
        case .small: width = FontData.Small.charWidth
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
    
    public func renderMenu(menu: CalculatorMenu, query: String = "") {
        // Draw the menu title
        let titleStr = query.isEmpty ? "\(menu.rawValue) Menu:" : "Search: \(query)_"
        drawString(titleStr, x: 2, y: 34, size: .small, color: true)
        
        // Render soft keys
        let items = MenuSystem.filter(menu: menu, query: query)
        let segmentWidth = 128 / 6
        
        for i in 0..<min(6, items.count) {
            let item = items[i]
            let xOffset = i * segmentWidth
            
            fillRect(x: xOffset + 2, y: 56, w: segmentWidth - 4, h: 8, color: true)
            
            let textW = item.label.count * FontData.Small.charWidth
            let textX = xOffset + (segmentWidth - textW) / 2
            drawString(item.label, x: textX, y: 46, size: .small, color: true)
            
            drawChar("▼", x: xOffset + (segmentWidth - FontData.Small.charWidth) / 2, y: 56, size: .small, color: false)
        }
    }
}
