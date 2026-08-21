
#if canImport(CoreGraphics)
import CoreGraphics
#endif

public struct EInkUpdatePacket {
    public let isFullRefresh: Bool
    public let x: Int
    public let y: Int
    public let width: Int
    public let height: Int
    public let diffBytes: [UInt8]
    public let totalChangedPixels: Int
    
    public init(isFullRefresh: Bool, x: Int, y: Int, width: Int, height: Int, diffBytes: [UInt8], totalChangedPixels: Int) {
        self.isFullRefresh = isFullRefresh
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.diffBytes = diffBytes
        self.totalChangedPixels = totalChangedPixels
    }
}

public protocol DisplayDriver {
    associatedtype Output
    func renderFrame(buffer: [UInt8], previousBuffer: [UInt8]?) -> Output
}

public class EInkDisplayDriver: DisplayDriver {
    public init() {}
    
    public func renderFrame(buffer: [UInt8], previousBuffer: [UInt8]?) -> EInkUpdatePacket {
        guard let prev = previousBuffer, prev.count == 1024, buffer.count == 1024 else {
            return EInkUpdatePacket(
                isFullRefresh: true,
                x: 0,
                y: 0,
                width: 128,
                height: 64,
                diffBytes: buffer,
                totalChangedPixels: 128 * 64
            )
        }
        
        var minX = 128
        var maxX = -1
        var minY = 64
        var maxY = -1
        var changedCount = 0
        
        for y in 0..<64 {
            let page = y / 8
            let bit = y % 8
            for x in 0..<128 {
                let idx = page * 128 + x
                let currentPixel = (buffer[idx] & (1 << bit)) != 0
                let prevPixel = (prev[idx] & (1 << bit)) != 0
                
                if currentPixel != prevPixel {
                    changedCount += 1
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                }
            }
        }
        
        if changedCount == 0 {
            return EInkUpdatePacket(
                isFullRefresh: false,
                x: 0,
                y: 0,
                width: 0,
                height: 0,
                diffBytes: [],
                totalChangedPixels: 0
            )
        }
        
        let startX = (minX / 8) * 8
        let endX = min(128, ((maxX + 8) / 8) * 8)
        let rectW = endX - startX
        let rectH = (maxY - minY) + 1
        
        var diffData = [UInt8]()
        diffData.reserveCapacity((rectW * rectH) / 8)
        
        for y in minY...maxY {
            let page = y / 8
            let bit = y % 8
            var currentByte: UInt8 = 0
            var bitIdx = 0
            
            for x in startX..<endX {
                let idx = page * 128 + x
                let isPixelOn = (buffer[idx] & (1 << bit)) != 0
                if isPixelOn {
                    currentByte |= UInt8(1 << (7 - bitIdx))
                }
                bitIdx += 1
                if bitIdx == 8 {
                    diffData.append(currentByte)
                    currentByte = 0
                    bitIdx = 0
                }
            }
        }
        
        return EInkUpdatePacket(
            isFullRefresh: false,
            x: startX,
            y: minY,
            width: rectW,
            height: rectH,
            diffBytes: diffData,
            totalChangedPixels: changedCount
        )
    }
}

#if canImport(CoreGraphics)
public class CGImageDisplayDriver: DisplayDriver {
    public var pixelColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8)
    public var backgroundColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8)
    
    public init(
        pixelColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8) = (0, 0, 0, 255),
        backgroundColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8) = (150, 165, 140, 255)
    ) {
        self.pixelColor = pixelColor
        self.backgroundColor = backgroundColor
    }
    
    public func renderFrame(buffer: [UInt8], previousBuffer: [UInt8]?) -> CGImage? {
        let renderer = Renderer()
        renderer.buffer = buffer
        return renderer.toCGImage(pixelColor: pixelColor, backgroundColor: backgroundColor)
    }
}
#endif

public class OLEDDisplayDriver: DisplayDriver {
    public init() {}
    
    public func renderFrame(buffer: [UInt8], previousBuffer: [UInt8]?) -> [UInt8] {
        var payload = [UInt8](repeating: 0, count: 1025)
        payload[0] = 0x40
        for i in 0..<min(1024, buffer.count) {
            payload[i + 1] = buffer[i]
        }
        return payload
    }
}
