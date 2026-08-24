#if !hasFeature(Embedded)
import Foundation
#endif

public class Renderer {
    public var buffer: [UInt8]
    public var previousBuffer: [UInt8]?
    
    public var detectOverlap: Bool = false
    public var hasOverlap: Bool = false
    public var boldFonts: Bool = false
    
    public init() {
        buffer = [UInt8](repeating: 0, count: 12000) // 400x240 memory LCD (50 bytes * 240 rows)
        previousBuffer = nil
    }
    
    public func fitSoftkeyLabel(_ rawLabel: String) -> String {
        var l = rawLabel
        while getStringWidth(l, size: .tiny) > 20 && !l.isEmpty {
            l.removeLast()
        }
        return l
    }
    
    public func clear() {
        for i in 0..<12000 {
            buffer[i] = 0
        }
        hasOverlap = false
    }
    
    public func setPixel(x: Int, y: Int, color: Bool) {
        if x < 0 || x >= 400 || y < 0 || y >= 240 { return }
        
        let byteIndex = y * 50 + (x / 8)
        let bitIndex = x % 8
        let mask = UInt8(1 << bitIndex)
        
        if color {
            if detectOverlap && (buffer[byteIndex] & mask) != 0 {
                hasOverlap = true
            }
            buffer[byteIndex] |= mask
        } else {
            buffer[byteIndex] &= ~mask
        }
    }
    
    public enum FontSize {
        case tiny, small, display, medium, large
    }
    
    public func drawChar(_ scalarValue: UInt32, x: Int, y: Int, size: FontSize = .small, color: Bool = true) -> Int {
        var returnWidth: Int = 0
        let shouldBold = boldFonts && size != .tiny
        switch size {
        case .tiny:
            if let result = FontData.Tiny.glyph(forScalar: scalarValue) {
                returnWidth = result.width
                drawGlyphFromStatic(FontData.Tiny.bitmapData, offset: result.offset, width: result.width, height: FontData.Tiny.charHeight, bytesPerRow: FontData.Tiny.bytesPerRow, x: x, y: y, color: color, bold: false)
            }
        case .small:
            if let result = FontData.Small.glyph(forScalar: scalarValue) {
                returnWidth = result.width + (shouldBold ? 1 : 0)
                drawGlyphFromStatic(FontData.Small.bitmapData, offset: result.offset, width: result.width, height: FontData.Small.charHeight, bytesPerRow: FontData.Small.bytesPerRow, x: x, y: y, color: color, bold: shouldBold)
            }
        case .display:
            if let result = FontData.Display.glyph(forScalar: scalarValue) {
                returnWidth = result.width + (shouldBold ? 1 : 0)
                drawGlyphFromStatic(FontData.Display.bitmapData, offset: result.offset, width: result.width, height: FontData.Display.charHeight, bytesPerRow: FontData.Display.bytesPerRow, x: x, y: y, color: color, bold: shouldBold)
            }
        case .medium:
            if let result = FontData.Medium.glyph(forScalar: scalarValue) {
                returnWidth = result.width + (shouldBold ? 1 : 0)
                drawGlyphFromStatic(FontData.Medium.bitmapData, offset: result.offset, width: result.width, height: FontData.Medium.charHeight, bytesPerRow: FontData.Medium.bytesPerRow, x: x, y: y, color: color, bold: shouldBold)
            }
        case .large:
            if let result = FontData.Large.glyph(forScalar: scalarValue) {
                returnWidth = result.width + (shouldBold ? 1 : 0)
                drawGlyphFromStatic(FontData.Large.bitmapData, offset: result.offset, width: result.width, height: FontData.Large.charHeight, bytesPerRow: FontData.Large.bytesPerRow, x: x, y: y, color: color, bold: shouldBold)
            }
        }
        return returnWidth
    }
    
    private func drawGlyphFromStatic(_ data: [UInt8], offset: Int, width: Int, height: Int, bytesPerRow: Int, x: Int, y: Int, color: Bool, bold: Bool = false) {
        for row in 0..<height {
            for byteIdx in 0..<bytesPerRow {
                let rowByte = data[offset + row * bytesPerRow + byteIdx]
                for bitIdx in 0..<8 {
                    let col = byteIdx * 8 + bitIdx
                    if col < width {
                        let pixel = (rowByte & (1 << (7 - bitIdx))) != 0
                        if pixel {
                            setPixel(x: x + col, y: y + row, color: color)
                            if bold {
                                setPixel(x: x + col + 1, y: y + row, color: color)
                            }
                        }
                    }
                }
            }
        }
    }
    private func applyGlyphReplacements(to str: String, size: FontSize) -> String {
        var processed = str
        
        let replacements: [(String, String)] = [
            ("1/𝑥", "\u{E000}"), ("10ˣ", "\u{E001}"), ("𝑒ˣ", "\u{E002}"),
            ("𝑦ˣ", "\u{E003}"), ("𝑥²", "\u{E004}"), ("√𝑥", "\u{E005}"),
            ("ˣ√𝑦", "\u{E006}"), ("𝑥!", "\u{E007}"), ("s,σ", "\u{E008}"),
            ("𝑥̄,𝑦̄", "\u{E009}"), ("Σ+", "\u{E00A}"), ("Σ-", "\u{E00B}"),
            ("x̂", "\u{E00C}"), ("ŷ,r", "\u{E00D}"), ("x̄", "\u{E00E}"),
            ("ȳ", "\u{E00F}"), ("L.R.", "\u{E012}"), ("INT÷", "\u{E013}"),
            ("4-LVL", "\u{E016}")
        ]
        
        for (old, new) in replacements {
            let sArr = Array(processed)
            let oArr = Array(old)
            var res: [Character] = []
            var i = 0
            while i < sArr.count {
                var match = true
                for j in 0..<oArr.count {
                    if i + j >= sArr.count || sArr[i+j] != oArr[j] {
                        match = false
                        break
                    }
                }
                if match {
                    res.append(contentsOf: Array(new))
                    i += oArr.count
                } else {
                    res.append(sArr[i])
                    i += 1
                }
            }
            processed = String(res)
        }
        return processed
    }

    public func getStringWidth(_ str: String, size: FontSize = .small) -> Int {
        let processed = applyGlyphReplacements(to: str, size: size)
        var total = 0
        let shouldBold = boldFonts && size != .tiny
        for scalar in processed.unicodeScalars {
            var charWidth = 0
            switch size {
            case .tiny: if let result = FontData.Tiny.glyph(forScalar: scalar.value) { charWidth = result.width }
            case .small: if let result = FontData.Small.glyph(forScalar: scalar.value) { charWidth = result.width }
            case .display: if let result = FontData.Display.glyph(forScalar: scalar.value) { charWidth = result.width }
            case .medium: if let result = FontData.Medium.glyph(forScalar: scalar.value) { charWidth = result.width }
            case .large: if let result = FontData.Large.glyph(forScalar: scalar.value) { charWidth = result.width }
            }
            if shouldBold && charWidth > 0 { charWidth += 1 }
            total += charWidth
        }
        return total
    }
    
    public func getStringWidth(_ buffer: UnsafePointer<UInt8>, length: Int, size: FontSize = .small) -> Int {
        var total = 0
        let shouldBold = boldFonts && size != .tiny
        for i in 0..<length {
            let scalar = UInt32(buffer[i])
            var charWidth = 0
            switch size {
            case .tiny: if let result = FontData.Tiny.glyph(forScalar: scalar) { charWidth = result.width }
            case .small: if let result = FontData.Small.glyph(forScalar: scalar) { charWidth = result.width }
            case .display: if let result = FontData.Display.glyph(forScalar: scalar) { charWidth = result.width }
            case .medium: if let result = FontData.Medium.glyph(forScalar: scalar) { charWidth = result.width }
            case .large: if let result = FontData.Large.glyph(forScalar: scalar) { charWidth = result.width }
            }
            if shouldBold && charWidth > 0 { charWidth += 1 }
            total += charWidth
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
        let processed = applyGlyphReplacements(to: str, size: size)
        var cursorX = x
        for scalar in processed.unicodeScalars {

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
    
    // Perfectly symmetrically balanced segments mapping the 400 pixel display 
    // to exactly 6 hardware columns
    public let menuSegments: [(x: Int, w: Int)] = [
        (0, 66),
        (67, 66),
        (134, 66),
        (201, 66),
        (268, 66),
        (335, 65)
    ]
    
    public func renderMenu(menu: CalculatorMenu, query: String = "", offset: Int = 0) {
        if !query.isEmpty {
            drawString("Search: \(query)_", x: 2, y: 38, size: .small, color: true)
        }
        let items = MenuSystem.filter(menu: menu, query: query)
        let visibleCount = items.count - offset
        let isMore = visibleCount > 6
        
        let displayCount = isMore ? 5 : min(visibleCount, 6)
        
        for i in 0..<displayCount {
            let itemIndex = offset + i
            if itemIndex >= items.count { break }
            let item = items[itemIndex]
            
            var colIndex = i
            if !isMore {
                if visibleCount == 4 {
                    if i >= 2 { colIndex = i + 2 }
                } else if visibleCount == 5 {
                    if i >= 3 { colIndex = i + 1 }
                }
            }
            
            let segment = menuSegments[colIndex]
            fillRect(x: segment.x, y: 53, w: segment.w, h: 11, color: true)
            
            let label = fitSoftkeyLabel(item.label)
            let textW = getStringWidth(label, size: .tiny)
            let textX = max(segment.x, segment.x + (segment.w - textW) / 2)
            drawString(label, x: textX, y: 53, size: .tiny, color: false)
        }
        
        if isMore {
            let segment = menuSegments[5]
            fillRect(x: segment.x, y: 53, w: segment.w, h: 11, color: true)
            let textW = getStringWidth("▶", size: .tiny)
            let textX = segment.x + (segment.w - textW) / 2
            drawString("▶", x: textX, y: 53, size: .tiny, color: false)
        }
    }
    
    public func renderLFU(manager: LFUManager) {
        for i in 0..<6 {
            let segment = menuSegments[i]
            guard let rawName = manager.slots[i] else { continue }
            
            let funcName = fitSoftkeyLabel(rawName)
            fillRect(x: segment.x, y: 53, w: segment.w, h: 11, color: true)
            
            let textW = getStringWidth(funcName, size: .tiny)
            let textX = max(segment.x, segment.x + (segment.w - textW) / 2)
            drawString(funcName, x: textX, y: 53, size: .tiny, color: false)
        }
    }
}

#if canImport(CoreGraphics)
import CoreGraphics

public extension Renderer {
    func toCGImage(
        pixelColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8) = (10, 20, 10, 255),
        backgroundColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8) = (160, 180, 150, 255),
        scale: Int = 1
    ) -> CGImage? {
        let baseW = 400
        let baseH = 240
        let s = max(1, scale)
        let width = baseW * s
        let height = baseH * s
        var rgbaPixels = [UInt8](repeating: 0, count: width * height * 4)
        
        for y in 0..<baseH {
            for x in 0..<baseW {
                let byteIndex = y * 50 + (x / 8)
                let bitIndex = x % 8
                let isPixelOn = (buffer[byteIndex] & UInt8(1 << bitIndex)) != 0
                let color = isPixelOn ? pixelColor : backgroundColor
                
                for sy in 0..<s {
                    let py = y * s + sy
                    for sx in 0..<s {
                        let px = x * s + sx
                        let pixelOffset = (py * width + px) * 4
                        rgbaPixels[pixelOffset]     = color.r
                        rgbaPixels[pixelOffset + 1] = color.g
                        rgbaPixels[pixelOffset + 2] = color.b
                        rgbaPixels[pixelOffset + 3] = color.a
                    }
                }
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

