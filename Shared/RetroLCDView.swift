import SwiftUI
import RPNCore

#if canImport(CoreGraphics)
import CoreGraphics

public struct RetroLCDView: View {
    @Bindable public var engine: CalculatorEngine
    public var controller: RetroUIController
    public var pixelColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8)
    public var backgroundColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8)
    
    public init(
        engine: CalculatorEngine,
        controller: RetroUIController? = nil,
        pixelColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8) = (20, 25, 20, 255),
        backgroundColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8) = (155, 175, 145, 255)
    ) {
        self.engine = engine
        self.controller = controller ?? RetroUIController(engine: engine)
        self.pixelColor = pixelColor
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 30.0)) { _ in
            let _ = controller.render()
            if let cgImage = controller.renderer.toCGImage(pixelColor: pixelColor, backgroundColor: backgroundColor) {
                Image(decorative: cgImage, scale: 1.0, orientation: .up)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(128.0 / 64.0, contentMode: .fit)
                    .accessibilityValue(controller.renderer.buffer.map { String(format: "%02x", $0) }.joined())
            } else {
                Color.black
            }
        }
        .accessibilityAddTraits(.isStaticText)
        .accessibilityIdentifier("lcd_display")
        .accessibilityLabel(
            engine.statusMessage ?? 
            engine.errorMessage ?? 
            engine.transientMessage ?? 
            (engine.promptString != nil ? engine.promptString! : engine.displayX)
        )
        .background(
            Text(controller.renderer.buffer.map { String(format: "%02x", $0) }.joined())
                .accessibilityIdentifier("lcd_buffer_hex")
                .frame(width: 0, height: 0)
        )
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("iOSMenuTrigger"))) { notification in
            if let command = notification.userInfo?["command"] as? CalculatorOperation {
                controller.processAction(command)
            }
        }
    }
}
#endif
