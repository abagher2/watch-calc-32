#if canImport(CoreGraphics)
import CoreGraphics

public protocol DisplayDriver {
    associatedtype Output
    func renderFrame(buffer: [UInt8], previousBuffer: [UInt8]?) -> Output
}

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
