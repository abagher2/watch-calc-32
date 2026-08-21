public class Renderer {
    public var buffer: [UInt8]
    public var previousBuffer: [UInt8]?
    
    public init() {
        buffer = [UInt8](repeating: 0, count: 1024)
        previousBuffer = nil
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
    
    public func drawChar(_ scalarValue: UInt32, x: Int, y: Int, size: FontSize = .small, color: Bool = true) -> Int {
        var returnWidth: Int = 0
        switch size {
        case .tiny:
            if var result = FontData.Tiny.glyph(forScalar: scalarValue) {
                returnWidth = result.width
                withUnsafeBytes(of: &result.bitmap) { ptr in
                    let bytes = ptr.bindMemory(to: UInt8.self)
                    drawGlyphBytes(bytes, width: result.width, height: FontData.Tiny.charHeight, x: x, y: y, color: color)
                }
            }
        case .small:
            if var result = FontData.Small.glyph(forScalar: scalarValue) {
                returnWidth = result.width
                withUnsafeBytes(of: &result.bitmap) { ptr in
                    let bytes = ptr.bindMemory(to: UInt8.self)
                    drawGlyphBytes(bytes, width: result.width, height: FontData.Small.charHeight, x: x, y: y, color: color)
                }
            }
        case .display:
            if var result = FontData.Display.glyph(forScalar: scalarValue) {
                returnWidth = result.width
                withUnsafeBytes(of: &result.bitmap) { ptr in
                    let bytes = ptr.bindMemory(to: UInt8.self)
                    drawGlyphBytes(bytes, width: result.width, height: FontData.Display.charHeight, x: x, y: y, color: color)
                }
            }
        case .medium:
            if var result = FontData.Medium.glyph(forScalar: scalarValue) {
                returnWidth = result.width
                withUnsafeBytes(of: &result.bitmap) { ptr in
                    let bytes = ptr.bindMemory(to: UInt8.self)
                    drawGlyphBytes(bytes, width: result.width, height: FontData.Medium.charHeight, x: x, y: y, color: color)
                }
            }
        case .large:
            if var result = FontData.Large.glyph(forScalar: scalarValue) {
                returnWidth = result.width
                withUnsafeBytes(of: &result.bitmap) { ptr in
                    let bytes = ptr.bindMemory(to: UInt8.self)
                    drawGlyphBytes(bytes, width: result.width, height: FontData.Large.charHeight, x: x, y: y, color: color)
                }
            }
        }
        return returnWidth
    }
    
    private func drawGlyphBytes(_ bytes: UnsafeBufferPointer<UInt8>, width: Int, height: Int, x: Int, y: Int, color: Bool) {
        let bytesPerRow = (width + 7) / 8
        for row in 0..<height {
            for byteIdx in 0..<bytesPerRow {
                let rowByte = bytes[row * bytesPerRow + byteIdx]
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
        var total = 0
        for scalar in str.unicodeScalars {
            switch size {
            case .tiny: if let result = FontData.Tiny.glyph(forScalar: scalar.value) { total += result.width }
            case .small: if let result = FontData.Small.glyph(forScalar: scalar.value) { total += result.width }
            case .display: if let result = FontData.Display.glyph(forScalar: scalar.value) { total += result.width }
            case .medium: if let result = FontData.Medium.glyph(forScalar: scalar.value) { total += result.width }
            case .large: if let result = FontData.Large.glyph(forScalar: scalar.value) { total += result.width }
            }
        }
        return total
    }
    
    public func getStringWidth(_ buffer: UnsafePointer<UInt8>, length: Int, size: FontSize = .small) -> Int {
        var total = 0
        for i in 0..<length {
            let scalar = UInt32(buffer[i])
            switch size {
            case .tiny: if let result = FontData.Tiny.glyph(forScalar: scalar) { total += result.width }
            case .small: if let result = FontData.Small.glyph(forScalar: scalar) { total += result.width }
            case .display: if let result = FontData.Display.glyph(forScalar: scalar) { total += result.width }
            case .medium: if let result = FontData.Medium.glyph(forScalar: scalar) { total += result.width }
            case .large: if let result = FontData.Large.glyph(forScalar: scalar) { total += result.width }
            }
        }
        return total
    }
    
    
    public func drawString(_ buffer: UnsafePointer<UInt8>, length: Int, x: Int, y: Int, size: FontSize = .small, color: Bool = true) {
        var cursorX = x
        for i in 0..<length {
            let width = drawChar(UInt32(buffer[i]), x: cursorX, y: y, size: size, color: color)
            cursorX += width
        }
    }

    public func drawString(_ str: String, x: Int, y: Int, size: FontSize = .small, color: Bool = true) {
        var cursorX = x
        for scalar in str.unicodeScalars {
            let width = drawChar(scalar.value, x: cursorX, y: y, size: size, color: color)
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
    
    public func drawSoftkeyArrow(x: Int, y: Int) {
        // Draw a small downward pointing triangle (▼)
        // x, y is the top-left of a 5x3 box
        // Row 0: #####
        // Row 1:  ###
        // Row 2:   #
        for col in 0..<5 { setPixel(x: x + col, y: y, color: true) }
        for col in 1..<4 { setPixel(x: x + col, y: y + 1, color: true) }
        setPixel(x: x + 2, y: y + 2, color: true)
    }
    
    public func renderMenu(menu: CalculatorMenu, query: String = "", offset: Int = 0) {
        if !query.isEmpty {
            drawString("Search: \(query)_", x: 2, y: 38, size: .small, color: true)
        }
        // Render soft keys
        var items = MenuSystem.filter(menu: menu, query: query)
        if offset > 0 {
            items = Array(items.dropFirst(offset))
        }
        
        let segmentWidth = 128 / 6
        
        var slots = [Int]()
        let visibleCount = items.count
        if visibleCount == 4 { slots = [0, 1, 4, 5] }
        else if visibleCount == 5 { slots = [0, 1, 2, 4, 5] }
        else { slots = [0, 1, 2, 3, 4, 5] }
        
        for i in 0..<min(6, items.count) {
            let item = items[i]
            let slotIndex = (items.count > 6) ? i : slots[i]
            let xOffset = slotIndex * segmentWidth
            
            if items.count > 6 && i == 5 {
                fillRect(x: xOffset, y: 54, w: segmentWidth - 1, h: 10, color: true)
                let textW = getStringWidth("MORE▶", size: .tiny)
                let textX = xOffset + (segmentWidth - 1 - textW) / 2
                drawString("MORE▶", x: textX, y: 55, size: .tiny, color: false)
                continue
            }
            
            fillRect(x: xOffset, y: 54, w: segmentWidth - 1, h: 10, color: true)
            var label = item.label
            if label.count > 5 { label = String(label.prefix(5)) }
            let textW = getStringWidth(label, size: .tiny)
            let textX = max(xOffset, xOffset + (segmentWidth - 1 - textW) / 2)
            drawString(label, x: textX, y: 55, size: .tiny, color: false)
        }
    }
    
    public func renderLFU(manager: LFUManager) {
        let segmentWidth = 128 / 6
        for i in 0..<6 {
            let xOffset = i * segmentWidth
            guard var funcName = manager.slots[i] else { continue }
            
            if funcName == "MODINT" { funcName = "MOD" }
            if funcName.count > 5 { funcName = String(funcName.prefix(5)) }
            
            fillRect(x: xOffset, y: 54, w: segmentWidth - 1, h: 10, color: true)
            
            let textW = getStringWidth(funcName, size: .tiny)
            let textX = max(xOffset, xOffset + (segmentWidth - 1 - textW) / 2)
            drawString(funcName, x: textX, y: 55, size: .tiny, color: false)
        }
    }
}

#if canImport(CoreGraphics)
import CoreGraphics
import Foundation

public extension Renderer {
    func toCGImage(
        pixelColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8) = (0, 0, 0, 255),
        backgroundColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8) = (150, 165, 140, 255)
    ) -> CGImage? {
        let width = 128
        let height = 64
        var rgbaPixels = [UInt8](repeating: 0, count: width * height * 4)
        
        for y in 0..<height {
            let page = y / 8
            let bit = y % 8
            for x in 0..<width {
                let bufferIndex = page * 128 + x
                let isPixelOn = (buffer[bufferIndex] & UInt8(1 << bit)) != 0
                let pixelOffset = (y * width + x) * 4
                let color = isPixelOn ? pixelColor : backgroundColor
                
                rgbaPixels[pixelOffset]     = color.r
                rgbaPixels[pixelOffset + 1] = color.g
                rgbaPixels[pixelOffset + 2] = color.b
                rgbaPixels[pixelOffset + 3] = color.a
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let provider = CGDataProvider(data: Data(rgbaPixels) as CFData) else {
            return nil
        }
        
        return CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
    }
}
#endif

